#!/usr/bin/env python3
"""
fpga_web.py - the DE25-Nano's web GUI, served on the board's own IP: a
drawing of the board with its LEDs, switches, keys and fan live, the LED
blinker picker, the die temperature control loop, and over-the-network
updates of this GUI itself.

One of three processes (linux/webapp/README.md, "Architecture"):
    fpga_access.py   the only one that maps /dev/mem: registers over <run>/fpga.sock
    temp_control.py  the die temperature loop: state and commands over <run>/control.sock
    fpga_web.py      this: HTTP, talks to the other two
The supervisor (linux/board/de25web-supervisor.sh) starts them in that order.

The FPGA side is the de25_nano_uart register file (de25_nano_uart_top.vhd's
header has the map). The LED blinkers are FPGA modules
(source/led_blinkers.vhd, source/blinkers/); this only picks the mode
(register 13) and shows what the LEDs do (registers 14..17).

Stdlib only - runs on the Alpine rootfs (`apk add python3`).

Usage:
    python3 fpga_web.py [--port 80] [--bind 0.0.0.0] [--run /run/de25web]
    python3 fpga_web.py --sim --port 8000      # with fpga_access.py --sim, temp_control.py --sim

Layout on the board (installed by linux/tools/install_webapp.py; see
linux/webapp/README.md):
    /opt/de25web/releases/<name>/   one GUI release (the three .py, static/, VERSION)
    /opt/de25web/current            -> the release running
    /opt/de25web/previous           -> the one before (rollback target)
    /opt/de25web/pending            exists while a new release is on test
    /opt/de25web/supervisor.sh      starts the three, reverts a release that fails its test
    /opt/de25web/token              if present, required (X-Token) for updates
    /opt/de25web/control.json       the temperature loop's settings

API:
    GET  /api/board                 every register, decoded, plus soc and control
    GET  /api/events                the same, as server-sent events, 20 a second
    GET  /api/control               the temperature loop: state and the last 10 min
    POST /api/control   {"mode": "auto"|"manual"|"off", "setpoint": 42.0, "manual_duty": 80}
    POST /api/blinker   {"mode": "scanner"}  (or 0..5)
    POST /api/leds      {"value": 0x55}      LED register 5 (blinker mode "software")
    POST /api/fan       {"duty": 0..255}     loop in auto/manual: becomes manual at this duty
    GET  /api/read?reg=N, POST /api/write {"reg": N, "value": V}   raw access
    GET  /api/version               GUI release, previous, whether on test
    POST /api/update                body: a release .tar.gz; headers X-Sha256, X-Token
    POST /api/update/confirm        keep the release on test (only when all three answer)
    POST /api/update/rollback       back to the previous release (X-Token)
    GET  /api/fpga                  the FPGA core: running build id, installed, previous
    POST /api/fpga                  body: a core bundle .tar.gz (linux/tools/deploy_fpga.py);
                                    headers X-Sha256, X-Token, X-Force: 1 (no installed
                                    manifest). fpga_access.py checks it, loads it (~2 s,
                                    the registers pause), rolls back if it fails
    POST /api/fpga/reload           load the installed core again (X-Token)
"""
import argparse
import collections
import hashlib
import io
import json
import os
import shutil
import sys
import tarfile
import threading
import time

HERE = os.path.dirname(os.path.realpath(__file__))   # through the "current" link
sys.path.insert(0, HERE)

from fpga_access import (BOARD_ID, FEATURE_HW_BLINKERS, FAN_MIN_DUTY,  # noqa: E402
                         REG_BLINKER, REG_BLINKER_ID, REG_FAN_DUTY, REG_FAN_RPM,
                         REG_FAN_STATUS, REG_FAN_TACH, REG_FEATURES, REG_GIT, REG_ID,
                         REG_KEY, REG_LEDS, REG_LEVELS0, REG_LEVELS1, REG_LOOPBACK,
                         REG_BUILD_ID, REG_READ_COUNT, REG_SW, REG_UPTIME, FpgaClient,
                         FpgaUnavailable, hwmon_root, run_dir)
from temp_control import (HISTORY_S, ControlClient, ControlUnavailable,  # noqa: E402
                          find_hwmon, read_hwmon)

# blinker modes (register 13) - led_blinkers.vhd
BLINKER_MODES = ["software", "off", "counter", "scanner", "breathing", "sparkle"]

REGISTER_NAMES = {
    REG_ID: "id", REG_GIT: "git hash", REG_LOOPBACK: "loopback",
    REG_READ_COUNT: "read counter", REG_LEDS: "LED register", REG_SW: "switches",
    REG_KEY: "keys", REG_UPTIME: "uptime counter", REG_FAN_DUTY: "fan duty",
    REG_FAN_RPM: "fan rpm", REG_FAN_TACH: "fan tach", REG_FAN_STATUS: "fan status",
    REG_BLINKER: "blinker mode", REG_LEVELS0: "levels 3..0", REG_LEVELS1: "levels 7..4",
    REG_FEATURES: "features", REG_BLINKER_ID: "blinker id", REG_BUILD_ID: "build id",
}
SAMPLED = [n for n in REGISTER_NAMES if n != REG_READ_COUNT]


def linux_uptime():
    try:
        with open("/proc/uptime") as f:
            return float(f.read().split()[0])
    except OSError:
        return 0.0


# --------------------------------------------------------------------------
# the temperature loop, as seen from here
# --------------------------------------------------------------------------
class ControlLink:
    """Polls temp_control.py once a second and keeps its own 10-minute copy
    of the loop's history - so the plot survives a restart of either
    process (a controller restart leaves a gap, honestly)."""

    def __init__(self, client, period=1.0):
        self.client = client
        self.period = period
        self.latest = None              # the controller's state, or None
        self.error = "starting"
        self.boot = None
        self.history = collections.deque(maxlen=int(HISTORY_S / period) + 30)
        self.lock = threading.Lock()
        threading.Thread(target=self._poller, daemon=True).start()

    def _poller(self):
        while True:
            try:
                st = self.client.call(op="state")["state"]
                if st.get("boot") != self.boot:
                    self._seed(st["boot"])
                with self.lock:
                    if "t" in st and (not self.history or st["t"] > self.history[-1][0]):
                        self.history.append([st["t"], st.get("measured"),
                                             st["setpoint"] if st.get("mode") == "auto" else None,
                                             st.get("duty"), st.get("rpm")])
                    self.latest, self.error = st, None
            except (ControlUnavailable, ValueError) as e:
                self.latest, self.error = None, str(e)
            time.sleep(self.period)

    def _seed(self, boot):
        h = self.client.call(op="history")["history"]
        with self.lock:
            first = h[0][0] if h else float("inf")
            kept = [x for x in self.history if x[0] < first]
            self.history.clear()
            self.history.extend(kept + h)
            self.boot = boot

    def fresh(self):
        st = self.latest
        return st if st and "t" in st and time.monotonic() - st["t"] < 5 else None

    def summary(self):
        """the loop's state for the 20 Hz board state (without the sensor list)"""
        st = self.latest
        if not st:
            return {"available": False, "error": self.error}
        return {"available": True, **{k: v for k, v in st.items() if k != "temps"}}

    def full(self):
        with self.lock:
            hist = list(self.history)
        return {"state": self.summary(), "history": hist, "now": round(time.monotonic(), 2),
                "history_s": HISTORY_S}

    def set(self, req):
        st = self.client.call(op="set", **req)["state"]
        self.latest = st                # the 20 Hz state shows it at once, not in a second
        return st


# --------------------------------------------------------------------------
# the SoC's own sensors: temperatures and supply voltages, from the SDM
# --------------------------------------------------------------------------
class SocSensors:
    """The Agilex 5's temperature and voltage sensors, read by the SDM and
    exposed by the kernel's soc64-hwmon driver (CONFIG_SENSORS_SOC64=y,
    linux/build_de25_nano_linux.sh) as /sys/class/hwmon/hwmonN, name
    "soc64hwmon". Every read is an SDM mailbox round trip, so the die
    temperatures come from the temperature controller, which reads them
    every second anyway; this reads them itself only while the controller
    is not answering, and the supply voltages every 5 s."""

    def __init__(self, root, control):
        self._root = root
        self._control = control
        self._dir = None
        self._volts = []
        self._own_temps = []
        threading.Thread(target=self._sampler, daemon=True).start()

    def _sampler(self):
        n = 0
        while True:
            try:
                if not self._dir or not os.path.isdir(self._dir):
                    self._dir = find_hwmon(self._root)
                if self._dir:
                    if n % 5 == 0:
                        _, self._volts = read_hwmon(self._dir, temps=False)
                    if not self._control.fresh():
                        self._own_temps, _ = read_hwmon(self._dir, volts=False)
            except OSError:
                pass
            n += 1
            time.sleep(1.0)

    def latest(self):
        ctl = self._control.fresh()
        temps = ctl["temps"] if ctl and ctl.get("temps") else self._own_temps
        return {"available": self._dir is not None, "temps": temps, "volts": self._volts}


# --------------------------------------------------------------------------
# the board's state, sampled once for every client
# --------------------------------------------------------------------------
class Board:
    """All register access goes to fpga_access.py (which holds the lock
    and the pause for bitstream loads); this samples the registers once
    for every client, 20 times a second."""

    def __init__(self, fpga, sensors, control, rate_hz=20):
        self._fpga = fpga
        self._sensors = sensors
        self._control = control
        self._state = None
        self._seq = 0
        self._changed = threading.Condition()
        self._period = 1.0 / rate_hz
        threading.Thread(target=self._sampler, daemon=True).start()

    def read(self, reg):
        return self._fpga.read(reg)

    def write(self, reg, value):
        self._fpga.write(reg, value)

    def _sample(self):
        r = dict(zip(SAMPLED, self._fpga.read_many(SAMPLED)))
        levels = [(r[REG_LEVELS0] >> (8 * i)) & 0xFF for i in range(4)] + \
                 [(r[REG_LEVELS1] >> (8 * i)) & 0xFF for i in range(4)]
        mode = r[REG_BLINKER] & 7
        bid = r[REG_BLINKER_ID]
        fan = r[REG_FAN_STATUS]
        return {
            "id": r[REG_ID],
            "id_ok": r[REG_ID] == BOARD_ID,
            "git_hash": "%08x" % r[REG_GIT],
            "build_id": r[REG_BUILD_ID],
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
        }

    def _sampler(self):
        while True:
            try:
                state = self._sample()
            except FpgaUnavailable as e:             # keep serving the GUI
                state = {"error": str(e), "fpga_unavailable": True,
                         "linux_uptime_s": linux_uptime()}
            except Exception as e:
                state = {"error": str(e), "linux_uptime_s": linux_uptime()}
            state["soc"] = self._sensors.latest()
            state["control"] = self._control.summary()
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

    REQUIRED = ("VERSION", "fpga_web.py", "fpga_access.py", "temp_control.py", "static/index.html")

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
CORE_BUNDLE_MAX = 32 << 20

CONTENT_TYPES = {".html": "text/html; charset=utf-8", ".js": "text/javascript",
                 ".css": "text/css", ".svg": "image/svg+xml", ".json": "application/json",
                 ".png": "image/png", ".ico": "image/x-icon"}


def parse_value(v) -> int:
    if isinstance(v, int):
        return v
    s = str(v).strip()
    return int(s, 16) if s.lower().startswith("0x") else int(s, 10)


def make_app(board: Board, control: ControlLink, fpga: FpgaClient, releases: Releases,
             version: str, release_name: str, run: str):
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
            elif p == "/api/control":
                self._json(control.full())
            elif p == "/api/version":
                info = releases.info(version)
                info["release"] = release_name
                self._json(info)
            elif p == "/api/fpga":
                try:
                    self._json(fpga.call(op="core"))
                except FpgaUnavailable as e:
                    self._json({"error": str(e)}, 503)
            elif p == "/api/read":
                try:
                    reg = int(parse_qs(url.query)["reg"][0])
                    self._json({"reg": reg, "value": board.read(reg)})
                except (KeyError, ValueError, IndexError) as e:
                    self._json({"error": str(e)}, 400)
                except FpgaUnavailable as e:
                    self._json({"error": str(e)}, 503)
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
                    self._fan(duty)
                elif p == "/api/control":
                    req = self._json_body()
                    allowed = {"mode", "setpoint", "manual_duty", "kp", "ki"}
                    bad = set(req) - allowed
                    if bad:
                        raise ValueError("unknown " + ", ".join(sorted(bad)))
                    self._json({"state": control.set(req)})
                elif p == "/api/write":
                    data = self._json_body()
                    reg = int(data["reg"])
                    board.write(reg, parse_value(data["value"]))
                    self._json({"reg": reg, "value": board.read(reg)})
                elif p.startswith("/api/update"):
                    self._update(p)
                elif p in ("/api/fpga", "/api/fpga/reload"):
                    self._fpga_core(p)
                else:
                    self.send_error(404)
            except (KeyError, ValueError, json.JSONDecodeError) as e:
                self._json({"error": str(e)}, 400)
            except (FpgaUnavailable, ControlUnavailable) as e:
                self._json({"error": str(e)}, 503)

        def _fan(self, duty):
            # The temperature loop owns the fan unless it is off: a duty from
            # the GUI puts it in manual at that duty (never below the stall
            # floor). Off, or the controller not running: the register, as is.
            st = control.latest
            if st and st.get("mode") in ("auto", "manual"):
                st = control.set({"mode": "manual", "manual_duty": duty})
                self._json({"duty": max(duty, FAN_MIN_DUTY), "mode": st["mode"],
                            "note": "temperature control switched to manual" if duty >= FAN_MIN_DUTY
                            else f"manual duty is at least {FAN_MIN_DUTY} (stall risk)"})
                return
            board.write(REG_FAN_DUTY, duty)
            self._json({"duty": board.read(REG_FAN_DUTY), "mode": st["mode"] if st else None})

        def _health(self):
            """what a release on test must show before it is kept"""
            problems = []
            try:
                fpga.call(op="ping")
            except FpgaUnavailable as e:
                problems.append(str(e))
            if not control.latest:
                problems.append(control.error or "temperature control not answering")
            return problems

        def _update(self, p):
            if p != "/api/update":
                self._body()            # drain it: the connection is kept alive
            if not releases.enabled:
                self.close_connection = True
                self._json({"error": "not an installed release (no /opt/de25web)"}, 501)
                return
            if p == "/api/update/confirm":
                problems = self._health()
                if problems:
                    self._json({"error": "not confirming, the release is not healthy: "
                                + "; ".join(problems)}, 503)
                    return
                self._json({"confirmed": releases.confirm(release_name)})
                return
            if not releases.token_ok(self.headers.get("X-Token")):
                self.close_connection = True        # an upload's body is left unread
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

        def _fpga_core(self, p):
            if not releases.token_ok(self.headers.get("X-Token")):
                self.close_connection = True        # an upload's body is left unread
                self._json({"error": "bad or missing X-Token"}, 403)
                return
            # a load takes ~2 s plus the checks: its own client, a longer wait
            slow = FpgaClient(run, timeout=120.0)
            if p == "/api/fpga/reload":
                self._body()
                resp = slow.call_raw(op="reload")
                self._json(resp, 200 if resp.get("ok") else 500)
                return
            blob = self._body(limit=CORE_BUNDLE_MAX)
            if hashlib.sha256(blob).hexdigest() != self.headers.get("X-Sha256", "").lower():
                raise ValueError("sha256 does not match the upload")
            bundle = os.path.join(run, "core-upload.tar.gz")
            with open(bundle, "wb") as f:
                f.write(blob)
            try:
                resp = slow.call_raw(op="install_core", bundle=bundle,
                                      force=self.headers.get("X-Force") == "1")
            finally:
                os.remove(bundle)
            status = 200 if resp.get("ok") else 409 if resp.get("refused") else 500
            self._json(resp, status)

        def log_message(self, fmt, *args):
            if not self.path.startswith(("/api/events", "/api/board", "/api/version", "/api/control")):
                print("%s - %s" % (self.address_string(), fmt % args), flush=True)

    class Server(ThreadingHTTPServer):
        daemon_threads = True
        allow_reuse_address = True

    return Server, Handler


def main():
    ap = argparse.ArgumentParser(description="DE25-Nano web GUI")
    ap.add_argument("--port", type=int, default=80)
    ap.add_argument("--bind", default="0.0.0.0")
    ap.add_argument("--sim", action="store_true",
                    help="against fpga_access.py --sim (simulated registers and sensors)")
    ap.add_argument("--run", default=None, help="the sockets' directory (as fpga_access.py)")
    ap.add_argument("--base", default=os.environ.get("DE25WEB_BASE", ""),
                    help="release directory root (default: the parent of releases/ this runs from)")
    args = ap.parse_args()

    version = open(os.path.join(HERE, "VERSION")).read().strip()
    release_name = os.path.basename(HERE)
    base = args.base
    if not base and os.path.basename(os.path.dirname(HERE)) == "releases":
        base = os.path.dirname(os.path.dirname(HERE))

    run = run_dir(args.run, args.sim)
    fpga = FpgaClient(run)
    control = ControlLink(ControlClient(run))
    board = Board(fpga, SocSensors(hwmon_root(run, args.sim), control), control)
    server_cls, handler_cls = make_app(board, control, fpga, Releases(base), version, release_name,
                                       run)
    httpd = server_cls((args.bind, args.port), handler_cls)
    print(f"de25-nano web {version} ({release_name}) on http://{args.bind}:{args.port}/, "
          f"sockets in {run}" + (" [simulated board]" if args.sim else ""), flush=True)
    httpd.serve_forever()


if __name__ == "__main__":
    main()
