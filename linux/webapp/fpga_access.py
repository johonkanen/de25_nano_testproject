#!/usr/bin/env python3
"""
fpga_access.py - the one process that touches the FPGA's register file.

It maps the LWH2F bridge (/dev/mem at 0x2000_0000, register n at n*0x10;
de25_nano_uart_top.vhd's header has the map) and serves register reads and
writes to the other processes of the web stack over a Unix socket, under one
lock - so a bitstream load (partial or full reconfiguration) can pause all
register traffic here, in one place (op "pause"/"resume").

    python3 fpga_access.py [--run /run/de25web]          # on the board, as root
    python3 fpga_access.py --sim [--run DIR]             # anywhere: simulated board
    python3 fpga_access.py --client read 9               # one request, for a shell
    python3 fpga_access.py --client write 9 128

Protocol: <run>/fpga.sock, one JSON object per line each way.
    {"op": "read", "reg": 9}                    -> {"ok": true, "value": 30}
    {"op": "read_many", "regs": [1, 9, 10]}     -> {"ok": true, "values": [...]}
    {"op": "write", "reg": 9, "value": 80, "lease": 10}
                                                -> {"ok": true, "value": 80}
    {"op": "release", "reg": 9}                 drop a lease (below)
    {"op": "pause", "seconds": 30, "reason": "..."}, {"op": "resume"}
    {"op": "status"}, {"op": "ping"}
    {"op": "sim", "ambient": 15.0, "load": 1.0} the simulated plant (--sim only)
Errors: {"ok": false, "error": "..."}; while paused every read/write answers
{"ok": false, "error": "paused: <reason>", "paused": true}.

Fan lease (the temperature controller's dead-man switch): a write with
"lease": N promises another write to that register within N seconds. If none
comes - the controller crashed, hung or was killed - this process raises the
fan to SAFE_FAN_DUTY (never lowers it) and logs it. The AMC6821's own THERM
fail-safe (docs/de25_nano_fan.md) stays the last line under all of this.

--sim also models the board's heat: a first-order thermal plant (die
temperature from ambient, heat and the fan's airflow, tau 30 s, a little
noise) written as a fake soc64hwmon directory under <run>/sim-hwmon/, which
temp_control.py and fpga_web.py read exactly like /sys/class/hwmon.

Stdlib only.
"""
import argparse
import json
import math
import mmap
import os
import random
import socket
import socketserver
import struct
import sys
import threading
import time

LWH2F_BASE = 0x20000000
REG_STRIDE = 0x10          # each register is 16 bytes apart: LWH2F_BASE + (n << 4)
MAP_SIZE = 0x1000          # 4 KB window: registers 0..255
PAGE_SIZE = mmap.PAGESIZE

# register numbers - de25_nano_uart_top.vhd's header has the full map
REG_ID, REG_GIT, REG_LOOPBACK, REG_READ_COUNT, REG_LEDS = 1, 2, 3, 4, 5
REG_SW, REG_KEY, REG_UPTIME = 6, 7, 8
REG_FAN_DUTY, REG_FAN_RPM, REG_FAN_TACH, REG_FAN_STATUS = 9, 10, 11, 12
REG_BLINKER, REG_LEVELS0, REG_LEVELS1, REG_FEATURES, REG_BLINKER_ID = 13, 14, 15, 16, 17

BOARD_ID = 0x0000DE25
FEATURE_HW_BLINKERS = 1 << 0
WRITABLE = {REG_LOOPBACK, REG_LEDS, REG_FAN_DUTY, REG_BLINKER}

FAN_MIN_DUTY = 30          # below ~18-22 the fan gets erratic (docs/de25_nano_fan.md)
SAFE_FAN_DUTY = 128        # what an expired fan lease raises the fan to

DEFAULT_RUN = os.environ.get("DE25WEB_RUN", "/run/de25web")
SIM_RUN = os.environ.get("DE25WEB_RUN", "/tmp/de25web-sim")
SOCKET_NAME = "fpga.sock"


def run_dir(arg, sim):
    return arg or (SIM_RUN if sim else DEFAULT_RUN)


def hwmon_root(run, sim):
    """Where the SoC sensors are: the kernel's, or the simulated plant's."""
    return os.path.join(run, "sim-hwmon") if sim else "/sys/class/hwmon"


def log(*a):
    print(time.strftime("%F %T"), "fpga_access:", *a, flush=True)


# --------------------------------------------------------------------------
# the register file: real (/dev/mem) or simulated
# --------------------------------------------------------------------------
class Bridge:
    """mmap-backed access to the LWH2F register window (/dev/mem, root)."""

    def __init__(self):
        self._fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
        aligned_base = LWH2F_BASE & ~(PAGE_SIZE - 1)
        self._offset_in_page = LWH2F_BASE - aligned_base
        self._mm = mmap.mmap(
            self._fd, MAP_SIZE + self._offset_in_page,
            mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE,
            offset=aligned_base,
        )

    def read(self, reg_num: int) -> int:
        off = self._offset_in_page + reg_num * REG_STRIDE
        return struct.unpack_from("<I", self._mm, off)[0]

    def write(self, reg_num: int, value: int) -> None:
        off = self._offset_in_page + reg_num * REG_STRIDE
        struct.pack_into("<I", self._mm, off, value & 0xFFFFFFFF)


class SimBridge:
    """The register file without hardware: the same registers, the blinker
    patterns roughly as the FPGA modules draw them, switches and keys
    changing now and then, and a fan whose rpm follows the duty with a lag.
    The writable registers are kept in <run>/sim-regs.json, so they survive
    a restart of this process - as the real FPGA's do."""

    IDS = {2: b"BCNT", 3: b"BSCN", 4: b"BBRT", 5: b"BSPK"}

    def __init__(self, state_file=None):
        self._regs = {REG_ID: BOARD_ID, REG_GIT: 0x5151D00D, REG_FAN_DUTY: FAN_MIN_DUTY,
                      REG_FEATURES: FEATURE_HW_BLINKERS, REG_FAN_STATUS: 0x011E0021}
        self._state_file = state_file
        if state_file:
            try:
                with open(state_file) as f:
                    for k, v in json.load(f).items():
                        if int(k) in WRITABLE:
                            self._regs[int(k)] = int(v)
            except (OSError, ValueError):
                pass
        self._t0 = time.monotonic()
        self._levels = [0] * 8
        self._last_frame = 0
        self._rpm = self.rpm_for(self._regs[REG_FAN_DUTY])
        self._rpm_t = self._t0
        self._lock = threading.Lock()

    @staticmethod
    def rpm_for(duty):
        # measured: duty 30 -> ~430-500 rpm; roughly linear above
        return duty * 14.5 if duty else 0.0

    def fan_rpm(self):
        """the simulated fan's speed: first-order lag (tau 1.5 s) on the duty"""
        with self._lock:
            now = time.monotonic()
            dt, self._rpm_t = now - self._rpm_t, now
            target = self.rpm_for(self._regs.get(REG_FAN_DUTY, 0) & 0xFF)
            self._rpm += (target - self._rpm) * (1 - math.exp(-dt / 1.5))
            return self._rpm

    def _frames(self):
        return int((time.monotonic() - self._t0) * 50)       # 50 Hz, as led_blinkers

    def _step(self):
        now = self._frames()
        mode = self._regs.get(REG_BLINKER, 0) & 7
        for f in range(max(self._last_frame + 1, now - 100), now + 1):
            if mode == 2:
                count = (f // 25 * 2 + (1 if f % 25 >= 12 else 0)) & 0xFF
                self._levels = [255 if count >> i & 1 else 0 for i in range(8)]
            elif mode == 3:
                self._levels = [lv - (lv >> 2) if lv >= 4 else 0 for lv in self._levels]
                pos = (f // 3) % 14
                self._levels[pos if pos < 8 else 14 - pos] = 255
            elif mode == 4:
                p = f % 150
                tri = p if p < 75 else 150 - p
                t = min(255, tri * 3482 >> 10)
                self._levels = [t * t >> 8] * 8
            elif mode == 5:
                self._levels = [lv - (lv >> 3) if lv >= 8 else 0 for lv in self._levels]
                if random.random() < 0.25:
                    self._levels[random.randrange(8)] = 255
            else:
                self._levels = [0] * 8
        self._last_frame = now

    def read(self, reg_num: int) -> int:
        if reg_num in (REG_FAN_RPM, REG_FAN_TACH):
            t = time.monotonic() - self._t0
            rpm = int(self.fan_rpm() + 10 * math.sin(t))
            rpm = max(rpm, 0) if self._regs.get(REG_FAN_DUTY, 0) & 0xFF else 0
            if reg_num == REG_FAN_RPM:
                return rpm
            return 6_000_000 // rpm if rpm else 0xFFFF
        with self._lock:
            t = time.monotonic() - self._t0
            mode = self._regs.get(REG_BLINKER, 0) & 7
            if reg_num in (REG_LEVELS0, REG_LEVELS1, REG_BLINKER_ID):
                self._step()
            if reg_num in (REG_LEVELS0, REG_LEVELS1):
                if mode == 0:
                    leds = (self._regs.get(REG_LEDS, 0) & 0x7F) | ((int(t / 1.34) & 1) << 7)
                    lv = [255 if leds >> i & 1 else 0 for i in range(8)]
                else:
                    lv = self._levels
                base = 0 if reg_num == REG_LEVELS0 else 4
                return sum(lv[base + i] << (8 * i) for i in range(4))
            if reg_num == REG_BLINKER_ID:
                return int.from_bytes(self.IDS[mode], "big") if mode in self.IDS else 0
            if reg_num == REG_UPTIME:
                return int(t * 50_000_000) & 0xFFFFFFFF
            if reg_num == REG_SW:
                return int(t / 7) % 16
            if reg_num == REG_KEY:
                return 1 if int(t * 2) % 11 == 0 else 0
            if reg_num == REG_READ_COUNT:
                self._regs[REG_READ_COUNT] = self._regs.get(REG_READ_COUNT, 0) + 1
            return self._regs.get(reg_num, 0) & 0xFFFFFFFF

    def write(self, reg_num: int, value: int) -> None:
        with self._lock:
            if reg_num not in WRITABLE:
                return
            if reg_num == REG_FAN_DUTY:
                value &= 0xFF
            self._regs[reg_num] = value & 0xFFFFFFFF
            if self._state_file:
                tmp = self._state_file + ".tmp"
                with open(tmp, "w") as f:
                    json.dump({str(k): self._regs[k] for k in WRITABLE if k in self._regs}, f)
                os.replace(tmp, self._state_file)


# --------------------------------------------------------------------------
# the simulated heat: what the temperature controller is tuned against
# --------------------------------------------------------------------------
class ThermalPlant:
    """The die's hottest spot as a first-order system:

        T_ss = ambient + load * P / G(rpm),   G(rpm) = g0 + g1 * sqrt(rpm)
        dT/dt = (T_ss - T) / tau

    Calibrated to the board: fan at duty 30 (~435 rpm) and 25 C ambient gives
    ~45 C (the real board reads 40-44 C there), a stopped fan ~67 C, full
    fan (~3700 rpm) ~35 C. 42 C then needs about duty 55. The four sensors
    sit at fixed offsets below the hottest one (bottom right)."""

    G0, G1 = 0.0239, 0.001251       # 1/(K per unit heat)
    HEAT = 1.0
    TAU = 30.0
    SENSORS = (("Main Die SDM", -1.3), ("Main Die corner bottom left max", -3.1),
               ("Main Die corner bottom right max", 0.0), ("Main Die corner top right max", -4.4))
    VOLTS = (("0.8V VCC", 0.842), ("1.8V VCCIO_SDM", 1.818), ("1.8V VCCPT", 1.815),
             ("1.2V VCCCRCORE", 1.212), ("0.9V VCCH", 0.846), ("0.8V VCCL", 0.841))

    def __init__(self, ambient=25.0, load=1.0, noise=0.08, t0=None):
        self.ambient = ambient
        self.load = load
        self.noise = noise
        self.temp = t0 if t0 is not None else self.steady(SimBridge.rpm_for(FAN_MIN_DUTY))

    def steady(self, rpm):
        g = self.G0 + self.G1 * math.sqrt(max(rpm, 0.0))
        return self.ambient + self.load * self.HEAT / g

    def step(self, dt, rpm, t=None):
        # the load wanders a little (+-3 %, 5 min period), like a busy CPU
        wobble = 1 + 0.03 * math.sin((t or 0) * 2 * math.pi / 300)
        target = self.ambient + (self.steady(rpm) - self.ambient) * wobble
        self.temp += (target - self.temp) * (1 - math.exp(-dt / self.TAU))
        return self.temp

    def readings(self):
        return [(label, self.temp + off + random.gauss(0, self.noise)) for label, off in self.SENSORS]


class SimHwmon(threading.Thread):
    """Runs the plant against the simulated fan and writes it out as a
    soc64hwmon directory (millidegrees, millivolts, labels)."""

    def __init__(self, root, bridge, ambient, load):
        super().__init__(daemon=True)
        self.dir = os.path.join(root, "hwmon0")
        os.makedirs(self.dir, exist_ok=True)
        self.bridge = bridge
        t0 = None
        try:                                # carry on from where the last run left
            with open(os.path.join(self.dir, "plant.json")) as f:
                saved = json.load(f)
            t0 = float(saved["temp"])
            ambient = saved.get("ambient", ambient) if ambient is None else ambient
            load = saved.get("load", load) if load is None else load
        except (OSError, ValueError, KeyError):
            pass
        self.plant = ThermalPlant(ambient=25.0 if ambient is None else ambient,
                                  load=1.0 if load is None else load, t0=t0)
        self._write("name", "soc64hwmon")
        for i, (label, v) in enumerate(ThermalPlant.VOLTS):
            self._write(f"in{i}_label", label)
            self._write(f"in{i}_input", str(int(v * 1000)))
        for i, (label, _) in enumerate(ThermalPlant.SENSORS):
            self._write(f"temp{i + 1}_label", label)
        self._publish()

    def _write(self, name, text):
        tmp = os.path.join(self.dir, "." + name + ".tmp")
        with open(tmp, "w") as f:
            f.write(text + "\n")
        os.replace(tmp, os.path.join(self.dir, name))

    def _publish(self):
        for i, (_, c) in enumerate(self.plant.readings()):
            self._write(f"temp{i + 1}_input", str(int(round(c * 1000))))
        self._write("plant.json", json.dumps({"temp": round(self.plant.temp, 4),
                                              "ambient": self.plant.ambient, "load": self.plant.load}))

    def run(self):
        last = time.monotonic()
        n = 0
        while True:
            time.sleep(0.2)
            now = time.monotonic()
            self.plant.step(now - last, self.bridge.fan_rpm(), now)
            last = now
            n += 1
            if n % 5 == 0:                  # the SDM updates about once a second
                try:
                    self._publish()
                except OSError as e:
                    log("sim hwmon:", e)


# --------------------------------------------------------------------------
# the server
# --------------------------------------------------------------------------
class Access:
    """Every register access, under one lock; pause/resume; the fan lease."""

    def __init__(self, bridge, sim_hwmon=None):
        self.bridge = bridge
        self.sim = sim_hwmon
        self.lock = threading.Lock()
        self.paused_until = 0.0
        self.pause_reason = ""
        self.leases = {}                    # reg -> monotonic deadline
        self.counts = {"read": 0, "write": 0, "lease_expired": 0}
        threading.Thread(target=self._watchdog, daemon=True).start()

    def paused(self):
        return time.monotonic() < self.paused_until

    def handle(self, req):
        op = req.get("op")
        if op == "ping":
            return {"ok": True, "pid": os.getpid()}
        if op == "status":
            now = time.monotonic()
            return {"ok": True, "pid": os.getpid(), "sim": self.sim is not None,
                    "paused": self.paused(), "pause_reason": self.pause_reason if self.paused() else "",
                    "leases": {str(r): round(d - now, 1) for r, d in self.leases.items()},
                    "counts": self.counts,
                    "plant": ({"ambient": self.sim.plant.ambient, "load": self.sim.plant.load,
                               "temp": round(self.sim.plant.temp, 3)} if self.sim else None)}
        if op == "pause":
            secs = min(float(req.get("seconds", 60)), 600.0)
            with self.lock:                  # waits for the access in flight
                self.paused_until = time.monotonic() + secs
                self.pause_reason = str(req.get("reason", "paused"))
            log(f"register traffic paused for {secs:.0f} s: {self.pause_reason}")
            return {"ok": True, "seconds": secs}
        if op == "resume":
            with self.lock:
                self.paused_until = 0.0
            log("register traffic resumed")
            return {"ok": True}
        if op == "sim":
            if not self.sim:
                return {"ok": False, "error": "not simulated"}
            if "ambient" in req:
                self.sim.plant.ambient = float(req["ambient"])
            if "load" in req:
                self.sim.plant.load = float(req["load"])
            if "temp" in req:
                self.sim.plant.temp = float(req["temp"])
            log(f"sim plant: ambient {self.sim.plant.ambient} C, load {self.sim.plant.load}")
            return {"ok": True, "ambient": self.sim.plant.ambient, "load": self.sim.plant.load}
        if op == "release":
            self.leases.pop(int(req["reg"]), None)
            return {"ok": True}
        if op not in ("read", "read_many", "write"):
            return {"ok": False, "error": f"unknown op {op!r}"}
        with self.lock:
            if self.paused():
                return {"ok": False, "paused": True, "error": "paused: " + self.pause_reason}
            if op == "read":
                reg = self._reg(req["reg"])
                self.counts["read"] += 1
                return {"ok": True, "value": self.bridge.read(reg)}
            if op == "read_many":
                regs = [self._reg(r) for r in req["regs"]]
                self.counts["read"] += len(regs)
                return {"ok": True, "values": [self.bridge.read(r) for r in regs]}
            reg = self._reg(req["reg"])
            self.bridge.write(reg, int(req["value"]))
            self.counts["write"] += 1
            if "lease" in req:
                self.leases[reg] = time.monotonic() + max(1.0, float(req["lease"]))
            return {"ok": True, "value": self.bridge.read(reg)}

    @staticmethod
    def _reg(r):
        r = int(r)
        if not 0 <= r < MAP_SIZE // REG_STRIDE:
            raise ValueError(f"register {r} out of range")
        return r

    def _watchdog(self):
        while True:
            time.sleep(0.5)
            now = time.monotonic()
            for reg, deadline in list(self.leases.items()):
                if now < deadline or self.paused():
                    continue
                self.leases.pop(reg, None)
                if reg != REG_FAN_DUTY:
                    continue
                with self.lock:
                    duty = self.bridge.read(REG_FAN_DUTY) & 0xFF
                    if duty < SAFE_FAN_DUTY:
                        self.bridge.write(REG_FAN_DUTY, SAFE_FAN_DUTY)
                self.counts["lease_expired"] += 1
                log(f"fan lease expired (the controller went silent): duty {duty} -> "
                    f"{max(duty, SAFE_FAN_DUTY)}")


def serve(access, path):
    class Handler(socketserver.StreamRequestHandler):
        def handle(self):
            for line in self.rfile:
                if not line.strip():
                    continue
                try:
                    resp = access.handle(json.loads(line))
                except (ValueError, KeyError, TypeError) as e:
                    resp = {"ok": False, "error": f"bad request: {e}"}
                except OSError as e:
                    resp = {"ok": False, "error": f"bridge: {e}"}
                try:
                    self.wfile.write(json.dumps(resp).encode() + b"\n")
                    self.wfile.flush()
                except (BrokenPipeError, ConnectionResetError):
                    return

    class Server(socketserver.ThreadingUnixStreamServer):
        daemon_threads = True

    # bind beside the old name and rename over it: clients never see a
    # missing socket file during a restart, only a refused connection
    tmp = path + ".new"
    if os.path.exists(tmp):
        os.remove(tmp)
    srv = Server(tmp, Handler)
    os.chmod(tmp, 0o660)
    os.replace(tmp, path)
    return srv


# --------------------------------------------------------------------------
# the client the other processes use
# --------------------------------------------------------------------------
class FpgaUnavailable(Exception):
    """The access process is not answering (or register traffic is paused)."""


class FpgaClient:
    """Thread-safe, reconnecting client of fpga.sock. Every failure is an
    FpgaUnavailable - callers report it rather than crash."""

    def __init__(self, run, timeout=2.0):
        self.path = os.path.join(run, SOCKET_NAME)
        self.timeout = timeout
        self._sock = None
        self._rfile = None
        self._lock = threading.Lock()

    def _close(self):
        try:
            if self._sock:
                self._sock.close()
        except OSError:
            pass
        self._sock = self._rfile = None

    def call(self, **req):
        with self._lock:
            for attempt in (0, 1):          # one reconnect: the server may have restarted
                try:
                    if self._sock is None:
                        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                        s.settimeout(self.timeout)
                        s.connect(self.path)
                        self._sock, self._rfile = s, s.makefile("rb")
                    self._sock.sendall(json.dumps(req).encode() + b"\n")
                    line = self._rfile.readline()
                    if not line:
                        raise ConnectionResetError("closed")
                    resp = json.loads(line)
                    break
                except (OSError, ValueError) as e:
                    self._close()
                    if attempt:
                        raise FpgaUnavailable("FPGA access unavailable (%s)" % e) from None
        if not resp.get("ok"):
            if resp.get("paused"):
                raise FpgaUnavailable("FPGA access " + resp.get("error", "paused"))
            raise ValueError(resp.get("error", "request failed"))
        return resp

    def read(self, reg):
        return self.call(op="read", reg=reg)["value"]

    def read_many(self, regs):
        return self.call(op="read_many", regs=list(regs))["values"]

    def write(self, reg, value, lease=None):
        req = {"op": "write", "reg": reg, "value": int(value)}
        if lease:
            req["lease"] = lease
        return self.call(**req)["value"]


def main():
    ap = argparse.ArgumentParser(description="DE25-Nano FPGA register access process")
    ap.add_argument("--run", default=None, help="socket directory (default /run/de25web, "
                    "or /tmp/de25web-sim with --sim; env DE25WEB_RUN)")
    ap.add_argument("--sim", action="store_true", help="simulated registers and thermal plant")
    ap.add_argument("--sim-ambient", type=float, default=None, help="plant ambient, C (default 25)")
    ap.add_argument("--sim-load", type=float, default=None, help="plant heat scale (default 1.0)")
    ap.add_argument("--client", nargs=argparse.REMAINDER,
                    help="send one request: read N | write N V | status | pause S | resume | "
                         "sim ambient=V load=V | ping")
    args = ap.parse_args()
    run = run_dir(args.run, args.sim)

    if args.client is not None:
        c, a = FpgaClient(run), args.client
        try:
            if a[0] == "read":
                print(c.read(int(a[1], 0)))
            elif a[0] == "write":
                print(c.write(int(a[1], 0), int(a[2], 0)))
            elif a[0] == "pause":
                print(json.dumps(c.call(op="pause", seconds=float(a[1]) if len(a) > 1 else 60)))
            elif a[0] == "sim":
                print(json.dumps(c.call(op="sim", **{k: float(v) for k, v in
                                                     (x.split("=") for x in a[1:])})))
            else:
                print(json.dumps(c.call(op=a[0])))
        except (FpgaUnavailable, ValueError, IndexError) as e:
            sys.exit(str(e))
        return

    os.makedirs(run, exist_ok=True)
    if args.sim:
        bridge = SimBridge(os.path.join(run, "sim-regs.json"))
        sim = SimHwmon(hwmon_root(run, True), bridge, args.sim_ambient, args.sim_load)
        sim.start()
    else:
        bridge, sim = Bridge(), None
    access = Access(bridge, sim)
    srv = serve(access, os.path.join(run, SOCKET_NAME))
    log(f"serving {os.path.join(run, SOCKET_NAME)}" + (" [simulated board]" if sim else ""))
    srv.serve_forever()


if __name__ == "__main__":
    main()
