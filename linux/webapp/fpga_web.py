#!/usr/bin/env python3
"""
fpga_web.py - the DE25-Nano's web GUI, served on the board's own IP: a
drawing of the board with its LEDs, switches, keys and fan live, the LED
blinker picker, and over-the-network updates of this GUI itself.

The FPGA side is the de25_nano_uart register file, reached over the LWH2F
bridge (the same registers hps/baremetal_lwh2f_regs/ reaches from bare
metal; de25_nano_uart_top.vhd's header has the map). The LED blinkers are FPGA
modules (source/led_blinkers.vhd, source/blinkers/); this only picks the
mode (register 13) and shows what the LEDs do (registers 14..17).

Stdlib only - runs on the Alpine rootfs (`apk add python3`).

Usage:
    python3 fpga_web.py [--port 80] [--bind 0.0.0.0]   # on the board
    python3 fpga_web.py --sim --port 8000              # anywhere: simulated registers

Layout on the board (installed by linux/tools/install_webapp.py; see
linux/webapp/README.md):
    /opt/de25web/releases/<name>/   one GUI release (this file, static/, VERSION)
    /opt/de25web/current            -> the release running
    /opt/de25web/previous           -> the one before (rollback target)
    /opt/de25web/pending            exists while a new release is on test
    /opt/de25web/supervisor.sh      starts this, reverts a release that fails its test
    /opt/de25web/token              if present, required (X-Token) for updates

API:
    GET  /api/board                 every register, decoded
    GET  /api/events                the same, as server-sent events, 20 a second
    POST /api/blinker   {"mode": "scanner"}  (or 0..5)
    POST /api/leds      {"value": 0x55}      LED register 5 (blinker mode "software")
    POST /api/fan       {"duty": 0..255}
    GET  /api/read?reg=N, POST /api/write {"reg": N, "value": V}   raw access
    GET  /api/version               GUI release, previous, whether on test
    POST /api/update                body: a release .tar.gz; headers X-Sha256, X-Token
    POST /api/update/confirm        keep the release on test
    POST /api/update/rollback       back to the previous release (X-Token)
"""
import argparse
import hashlib
import io
import json
import math
import mmap
import os
import random
import re
import shutil
import struct
import tarfile
import threading
import time

HERE = os.path.dirname(os.path.realpath(__file__))   # through the "current" link

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

# blinker modes (register 13) - led_blinkers.vhd
BLINKER_MODES = ["software", "off", "counter", "scanner", "breathing", "sparkle"]

REGISTER_NAMES = {
    REG_ID: "id", REG_GIT: "git hash", REG_LOOPBACK: "loopback",
    REG_READ_COUNT: "read counter", REG_LEDS: "LED register", REG_SW: "switches",
    REG_KEY: "keys", REG_UPTIME: "uptime counter", REG_FAN_DUTY: "fan duty",
    REG_FAN_RPM: "fan rpm", REG_FAN_TACH: "fan tach", REG_FAN_STATUS: "fan status",
    REG_BLINKER: "blinker mode", REG_LEVELS0: "levels 3..0", REG_LEVELS1: "levels 7..4",
    REG_FEATURES: "features", REG_BLINKER_ID: "blinker id",
}
WRITABLE = {REG_LOOPBACK, REG_LEDS, REG_FAN_DUTY, REG_BLINKER}


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
    """The register file without hardware, for developing the GUI: the same
    registers, the blinker patterns roughly as the FPGA modules draw them,
    switches and keys changing now and then."""

    IDS = {2: b"BCNT", 3: b"BSCN", 4: b"BBRT", 5: b"BSPK"}

    def __init__(self):
        self._regs = {REG_ID: BOARD_ID, REG_GIT: 0x5151D00D, REG_FAN_DUTY: 30,
                      REG_FEATURES: FEATURE_HW_BLINKERS, REG_FAN_STATUS: 0x011E0021}
        self._t0 = time.monotonic()
        self._levels = [0] * 8
        self._last_frame = 0
        self._lock = threading.Lock()

    def _frames(self):
        return int((time.monotonic() - self._t0) * 50)       # 50 Hz, as led_blinkers

    def _step(self):
        # advance the pattern to the current frame (only as far as it's read)
        now = self._frames()
        mode = self._regs.get(REG_BLINKER, 0) & 7
        for f in range(max(self._last_frame + 1, now - 100), now + 1):
            if mode == 2:
                count = (f // 25 * 2 + (1 if f % 25 >= 12 else 0)) & 0xFF
                self._levels = [255 if count >> i & 1 else 0 for i in range(8)]
            elif mode == 3:
                self._levels = [l - (l >> 2) if l >= 4 else 0 for l in self._levels]
                pos = (f // 3) % 14
                self._levels[pos if pos < 8 else 14 - pos] = 255
            elif mode == 4:
                p = f % 150
                tri = p if p < 75 else 150 - p
                t = min(255, tri * 3482 >> 10)
                self._levels = [t * t >> 8] * 8
            elif mode == 5:
                self._levels = [l - (l >> 3) if l >= 8 else 0 for l in self._levels]
                if random.random() < 0.25:
                    self._levels[random.randrange(8)] = 255
            else:
                self._levels = [0] * 8
        self._last_frame = now

    def read(self, reg_num: int) -> int:
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
            if reg_num in (REG_FAN_RPM, REG_FAN_TACH):
                duty = self._regs.get(REG_FAN_DUTY, 0) & 0xFF
                rpm = int(duty * 14.5 + 30 * math.sin(t)) if duty else 0
                if reg_num == REG_FAN_RPM:
                    return rpm
                return 6_000_000 // rpm if rpm else 0xFFFF
            if reg_num == REG_READ_COUNT:
                self._regs[REG_READ_COUNT] = self._regs.get(REG_READ_COUNT, 0) + 1
            return self._regs.get(reg_num, 0) & 0xFFFFFFFF

    def write(self, reg_num: int, value: int) -> None:
        with self._lock:
            if reg_num in WRITABLE:
                self._regs[reg_num] = value & 0xFFFFFFFF


def linux_uptime():
    try:
        with open("/proc/uptime") as f:
            return float(f.read().split()[0])
    except OSError:
        return 0.0


# --------------------------------------------------------------------------
# the SoC's own sensors: temperatures and supply voltages, from the SDM
# --------------------------------------------------------------------------
class SocSensors:
    """The Agilex 5's temperature and voltage sensors, read by the SDM and
    exposed by the kernel's soc64-hwmon driver (CONFIG_SENSORS_SOC64=y,
    linux/build_de25_nano_linux.sh) as /sys/class/hwmon/hwmonN, name
    "soc64hwmon": temp*_input in millidegrees C, in*_input in millivolts,
    labels from the device tree. Every read is an SDM mailbox round trip,
    so this samples once a second on its own thread and the 20 Hz board
    state just takes the latest reading."""

    HWMON_NAME = "soc64hwmon"

    def __init__(self, sim=False, period_s=1.0):
        self._sim = sim
        self._period = period_s
        self._dir = None if sim else self._find()
        self._latest = {"available": sim or self._dir is not None, "temps": [], "volts": []}
        if self._latest["available"]:
            threading.Thread(target=self._sampler, daemon=True).start()

    @classmethod
    def _find(cls):
        root = "/sys/class/hwmon"
        try:
            for h in sorted(os.listdir(root)):
                d = os.path.join(root, h)
                with open(os.path.join(d, "name")) as f:
                    if f.read().strip() == cls.HWMON_NAME:
                        return d
        except OSError:
            pass
        return None

    def _read_dir(self):
        temps, volts = [], []
        for name in sorted(os.listdir(self._dir), key=lambda n: (len(n), n)):
            m = re.fullmatch(r"(temp|in)(\d+)_input", name)
            if not m:
                continue
            base = os.path.join(self._dir, f"{m.group(1)}{m.group(2)}")
            try:
                with open(base + "_input") as f:
                    value = int(f.read())
            except (OSError, ValueError):
                continue            # the SDM can refuse a read now and then
            try:
                with open(base + "_label") as f:
                    label = f.read().strip()
            except OSError:
                label = f"{m.group(1)}{m.group(2)}"
            if m.group(1) == "temp":
                temps.append({"label": label, "c": value / 1000})
            else:
                volts.append({"label": label, "v": value / 1000})
        return temps, volts

    def _read_sim(self):
        t = time.monotonic()
        base = 42 + 2 * math.sin(t / 30)
        temps = [{"label": "Main Die SDM", "c": round(base + 1.5, 3)},
                 {"label": "Main Die corner bottom left max", "c": round(base - 0.5, 3)},
                 {"label": "Main Die corner bottom right max", "c": round(base + 2.8, 3)},
                 {"label": "Main Die corner top right max", "c": round(base - 1.6, 3)}]
        volts = [{"label": l, "v": v} for l, v in (
            ("0.8V VCC", 0.842), ("1.8V VCCIO_SDM", 1.818), ("1.8V VCCPT", 1.815),
            ("1.2V VCCCRCORE", 1.212), ("0.9V VCCH", 0.846), ("0.8V VCCL", 0.841))]
        return temps, volts

    def _sampler(self):
        while True:
            try:
                temps, volts = self._read_sim() if self._sim else self._read_dir()
                self._latest = {"available": True, "temps": temps, "volts": volts}
            except OSError:
                pass
            time.sleep(self._period)

    def latest(self):
        return self._latest


# --------------------------------------------------------------------------
# the board's state, sampled once for every client
# --------------------------------------------------------------------------
class Board:
    """Owns the bridge. All register access goes through here, under one
    lock, so a later bitstream load can pause it in one place
    (docs/partial_reconfiguration_plan.md)."""

    def __init__(self, bridge, sensors, rate_hz=20):
        self._bridge = bridge
        self._sensors = sensors
        self._lock = threading.Lock()
        self._state = None
        self._seq = 0
        self._changed = threading.Condition()
        self._period = 1.0 / rate_hz
        threading.Thread(target=self._sampler, daemon=True).start()

    def read(self, reg):
        with self._lock:
            return self._bridge.read(reg)

    def write(self, reg, value):
        with self._lock:
            self._bridge.write(reg, value)

    def _sample(self):
        with self._lock:
            r = {n: self._bridge.read(n) for n in REGISTER_NAMES if n != REG_READ_COUNT}
        levels = [(r[REG_LEVELS0] >> (8 * i)) & 0xFF for i in range(4)] + \
                 [(r[REG_LEVELS1] >> (8 * i)) & 0xFF for i in range(4)]
        mode = r[REG_BLINKER] & 7
        bid = r[REG_BLINKER_ID]
        fan = r[REG_FAN_STATUS]
        return {
            "id": r[REG_ID],
            "id_ok": r[REG_ID] == BOARD_ID,
            "git_hash": "%08x" % r[REG_GIT],
            "features": r[REG_FEATURES],
            "hw_blinkers": bool(r[REG_FEATURES] & FEATURE_HW_BLINKERS),
            "blinker": {
                "mode": mode,
                "name": BLINKER_MODES[mode] if mode < len(BLINKER_MODES) else "off",
                "module_id": bid.to_bytes(4, "big").decode("ascii", "replace") if bid else "",
            },
            "modes": BLINKER_MODES,
            "led_register": r[REG_LEDS] & 0x7F,
            "levels": levels,
            "switches": [(r[REG_SW] >> i) & 1 for i in range(4)],
            "keys": [(r[REG_KEY] >> i) & 1 for i in range(2)],
            "linux_uptime_s": linux_uptime(),
            "fan": {
                "duty": r[REG_FAN_DUTY] & 0xFF,
                "rpm": r[REG_FAN_RPM],
                "device_id": fan & 0xFF,
                "init_done": bool(fan >> 24 & 1),
                "i2c_error": bool(fan >> 25 & 1),
            },
            "soc": self._sensors.latest(),
        }

    def _sampler(self):
        while True:
            try:
                state = self._sample()
            except Exception as e:                       # keep serving the GUI
                state = {"error": str(e)}
            with self._changed:
                self._state = state
                self._seq += 1
                self._changed.notify_all()
            time.sleep(self._period)

    def state(self):
        with self._changed:
            while self._state is None:
                self._changed.wait()
            return self._state

    def wait_next(self, seq, timeout=2.0):
        with self._changed:
            self._changed.wait_for(lambda: self._seq != seq, timeout)
            return self._seq, self._state


# --------------------------------------------------------------------------
# GUI releases: install, test, confirm, roll back
# --------------------------------------------------------------------------
class Releases:
    """The release directories under base (/opt/de25web). The safety net
    is supervisor.sh, outside any release: it reverts a release still
    pending after its test time, or one that keeps crashing."""

    REQUIRED = ("VERSION", "fpga_web.py", "static/index.html")

    def __init__(self, base):
        self.base = base
        self.enabled = bool(base) and os.path.isdir(os.path.join(base, "releases"))

    def _link(self, name):
        p = os.path.join(self.base, name)
        return os.path.basename(os.readlink(p)) if os.path.islink(p) else None

    def info(self, running_version):
        out = {"version": running_version, "managed": self.enabled}
        if self.enabled:
            pending = os.path.join(self.base, "pending")
            out.update({
                "current": self._link("current"),
                "previous": self._link("previous"),
                "pending": open(pending).read().strip() if os.path.exists(pending) else None,
                "releases": sorted(os.listdir(os.path.join(self.base, "releases"))),
            })
        return out

    def token_ok(self, given):
        path = os.path.join(self.base, "token") if self.base else None
        if not path or not os.path.exists(path):
            return True
        return given is not None and open(path).read().strip() == given.strip()

    def install(self, blob, sha256):
        if hashlib.sha256(blob).hexdigest() != sha256.lower():
            raise ValueError("sha256 does not match the upload")
        with tarfile.open(fileobj=io.BytesIO(blob), mode="r:gz") as tar:
            members = tar.getmembers()
            for m in members:
                name = os.path.normpath(m.name)
                if name.startswith(("/", "..")) or not (m.isfile() or m.isdir()):
                    raise ValueError("refusing %r in the archive" % m.name)
            names = {os.path.normpath(m.name) for m in members}
            missing = [f for f in self.REQUIRED if f not in names]
            if missing:
                raise ValueError("not a GUI release, missing %s" % ", ".join(missing))
            version = tar.extractfile("VERSION").read().decode().strip()
            if not version or "/" in version or version.startswith("."):
                raise ValueError("bad VERSION %r" % version)
            rel = "%s-%s" % (version, sha256[:8])
            dest = os.path.join(self.base, "releases", rel)
            tmp = dest + ".tmp"
            shutil.rmtree(tmp, ignore_errors=True)
            os.makedirs(tmp)
            for m in members:
                target = os.path.join(tmp, os.path.normpath(m.name))
                if m.isdir():
                    os.makedirs(target, exist_ok=True)
                else:
                    os.makedirs(os.path.dirname(target), exist_ok=True)
                    with open(target, "wb") as f:
                        f.write(tar.extractfile(m).read())
        shutil.rmtree(dest, ignore_errors=True)
        os.rename(tmp, dest)
        # switch: previous <- current, current <- new, pending marks the test
        cur = self._link("current")
        if cur and cur != rel:
            self._symlink("previous", cur)
        self._symlink("current", rel)
        with open(os.path.join(self.base, "pending"), "w") as f:
            f.write(rel + "\n")
        self._prune(keep={rel, cur})
        return rel

    def confirm(self, running_release):
        pending = os.path.join(self.base, "pending")
        if not os.path.exists(pending):
            return False
        if open(pending).read().strip() != running_release:
            raise ValueError("the release on test is not the one running")
        os.remove(pending)
        return True

    def rollback(self):
        prev, cur = self._link("previous"), self._link("current")
        if not prev:
            raise ValueError("no previous release")
        self._symlink("current", prev)
        self._symlink("previous", cur)
        # on test like any new release: "previous" can be one the supervisor
        # just reverted, and it must not get to stay without proving itself
        with open(os.path.join(self.base, "pending"), "w") as f:
            f.write(prev + "\n")
        return prev

    def _symlink(self, name, rel):
        tmp = os.path.join(self.base, name + ".new")
        if os.path.lexists(tmp):
            os.remove(tmp)
        os.symlink(os.path.join("releases", rel), tmp)
        os.replace(tmp, os.path.join(self.base, name))         # atomic

    def _prune(self, keep, max_releases=4):
        d = os.path.join(self.base, "releases")
        rels = sorted((os.path.getmtime(os.path.join(d, r)), r) for r in os.listdir(d))
        for _, r in rels[:-max_releases]:
            if r not in keep:
                shutil.rmtree(os.path.join(d, r), ignore_errors=True)


# --------------------------------------------------------------------------
# HTTP
# --------------------------------------------------------------------------
CONTENT_TYPES = {".html": "text/html; charset=utf-8", ".js": "text/javascript",
                 ".css": "text/css", ".svg": "image/svg+xml", ".json": "application/json",
                 ".png": "image/png", ".ico": "image/x-icon"}


def parse_value(v) -> int:
    if isinstance(v, int):
        return v
    s = str(v).strip()
    return int(s, 16) if s.lower().startswith("0x") else int(s, 10)


def make_app(board: Board, releases: Releases, version: str, release_name: str):
    from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
    from urllib.parse import urlparse, parse_qs

    static_dir = os.path.join(HERE, "static")

    def restart_soon():
        # the supervisor starts whatever "current" points at
        threading.Timer(0.5, lambda: os._exit(0)).start()

    class Handler(BaseHTTPRequestHandler):
        server_version = "de25-nano-web/" + version
        protocol_version = "HTTP/1.1"

        def _send(self, status, body, ctype, extra=()):
            self.send_response(status)
            self.send_header("Content-Type", ctype)
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            for k, v in extra:
                self.send_header(k, v)
            self.end_headers()
            self.wfile.write(body)

        def _json(self, obj, status=200):
            self._send(status, json.dumps(obj).encode(), "application/json")

        def _body(self, limit=1 << 20):
            length = int(self.headers.get("Content-Length", 0))
            if length > limit:
                raise ValueError("body too large")
            return self.rfile.read(length)

        def _json_body(self):
            return json.loads(self._body() or b"{}")

        def _static(self, rel):
            path = os.path.normpath(os.path.join(static_dir, rel))
            if not path.startswith(static_dir + os.sep) or not os.path.isfile(path):
                self.send_error(404)
                return
            with open(path, "rb") as f:
                body = f.read()
            ctype = CONTENT_TYPES.get(os.path.splitext(path)[1], "application/octet-stream")
            self._send(200, body, ctype)

        def do_GET(self):
            url = urlparse(self.path)
            p = url.path
            if p in ("/", "/index.html"):
                self._static("index.html")
            elif p.startswith("/static/"):
                self._static(p[len("/static/"):])
            elif p == "/api/board":
                self._json(board.state())
            elif p == "/api/events":
                self._events()
            elif p == "/api/version":
                info = releases.info(version)
                info["release"] = release_name
                self._json(info)
            elif p == "/api/read":
                try:
                    reg = int(parse_qs(url.query)["reg"][0])
                    self._json({"reg": reg, "value": board.read(reg)})
                except (KeyError, ValueError, IndexError) as e:
                    self._json({"error": str(e)}, 400)
            else:
                self.send_error(404)

        def _events(self):
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Connection", "close")
            self.end_headers()
            self.close_connection = True
            seq = -1
            try:
                while True:
                    seq, state = board.wait_next(seq)
                    self.wfile.write(b"data: " + json.dumps(state).encode() + b"\n\n")
                    self.wfile.flush()
            except (BrokenPipeError, ConnectionResetError, TimeoutError):
                pass

        def do_POST(self):
            p = urlparse(self.path).path
            try:
                if p == "/api/blinker":
                    mode = self._json_body()["mode"]
                    if isinstance(mode, str) and not mode.isdigit():
                        mode = BLINKER_MODES.index(mode)
                    mode = int(mode)
                    if not 0 <= mode < len(BLINKER_MODES):
                        raise ValueError("mode 0..%d" % (len(BLINKER_MODES) - 1))
                    board.write(REG_BLINKER, mode)
                    self._json({"mode": board.read(REG_BLINKER) & 7})
                elif p == "/api/leds":
                    value = parse_value(self._json_body()["value"]) & 0x7F
                    board.write(REG_LEDS, value)
                    self._json({"value": board.read(REG_LEDS)})
                elif p == "/api/fan":
                    duty = parse_value(self._json_body()["duty"])
                    if not 0 <= duty <= 255:
                        raise ValueError("duty 0..255")
                    board.write(REG_FAN_DUTY, duty)
                    self._json({"duty": board.read(REG_FAN_DUTY)})
                elif p == "/api/write":
                    data = self._json_body()
                    reg = int(data["reg"])
                    board.write(reg, parse_value(data["value"]))
                    self._json({"reg": reg, "value": board.read(reg)})
                elif p.startswith("/api/update"):
                    self._update(p)
                else:
                    self.send_error(404)
            except (KeyError, ValueError, json.JSONDecodeError) as e:
                self._json({"error": str(e)}, 400)

        def _update(self, p):
            if not releases.enabled:
                self._json({"error": "not an installed release (no /opt/de25web)"}, 501)
                return
            if p == "/api/update/confirm":
                self._json({"confirmed": releases.confirm(release_name)})
                return
            if not releases.token_ok(self.headers.get("X-Token")):
                self._json({"error": "bad or missing X-Token"}, 403)
                return
            if p == "/api/update":
                blob = self._body(limit=8 << 20)
                rel = releases.install(blob, self.headers.get("X-Sha256", ""))
                self._json({"installed": rel, "pending": True}, 202)
                restart_soon()
            elif p == "/api/update/rollback":
                rel = releases.rollback()
                self._json({"current": rel}, 202)
                restart_soon()
            else:
                self.send_error(404)

        def log_message(self, fmt, *args):
            if not self.path.startswith(("/api/events", "/api/board", "/api/version")):
                print("%s - %s" % (self.address_string(), fmt % args), flush=True)

    class Server(ThreadingHTTPServer):
        daemon_threads = True
        allow_reuse_address = True

    return Server, Handler


def main():
    ap = argparse.ArgumentParser(description="DE25-Nano web GUI")
    ap.add_argument("--port", type=int, default=80)
    ap.add_argument("--bind", default="0.0.0.0")
    ap.add_argument("--sim", action="store_true", help="simulated registers, no /dev/mem")
    ap.add_argument("--base", default=os.environ.get("DE25WEB_BASE", ""),
                    help="release directory root (default: the parent of releases/ this runs from)")
    args = ap.parse_args()

    version = open(os.path.join(HERE, "VERSION")).read().strip()
    release_name = os.path.basename(HERE)
    base = args.base
    if not base and os.path.basename(os.path.dirname(HERE)) == "releases":
        base = os.path.dirname(os.path.dirname(HERE))

    board = Board(SimBridge() if args.sim else Bridge(), SocSensors(sim=args.sim))
    server_cls, handler_cls = make_app(board, Releases(base), version, release_name)
    httpd = server_cls((args.bind, args.port), handler_cls)
    print(f"de25-nano web {version} ({release_name}) on http://{args.bind}:{args.port}/"
          + (" [simulated registers]" if args.sim else ""), flush=True)
    httpd.serve_forever()


if __name__ == "__main__":
    main()
