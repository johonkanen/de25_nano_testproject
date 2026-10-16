#!/usr/bin/env python3
"""gui_test.py [url] [--shots DIR] - drive the DE25-Nano web GUI in a real
(headless) Chromium over the DevTools protocol: open the page, click each
blinker mode and check the page (and the register file behind it) follow,
toggle an LED in software mode, check the temperature control plot renders
and its mode buttons, setpoint and the fan slider reach the controller (the
loop's settings are put back afterwards), then screenshot the page at
desktop and phone widths. Exit status 1 when the page does not show what
was expected.

Works against the board or a local `fpga_web.py --sim`:
    python3 linux/webapp/fpga_web.py --sim --port 8000 &
    python3 linux/tools/gui_test.py http://127.0.0.1:8000/ --shots /tmp/shots

Chromium: Playwright's headless shell in ~/.cache/ms-playwright (or CHROME).
The DevTools client is ~/dev/pr_testing/tools/gui_test.py's.
"""
import base64
import glob
import json
import os
import socket
import struct
import subprocess
import sys
import time
import urllib.request

ARGV = sys.argv[1:]
SHOTS = None
if "--shots" in ARGV:
    i = ARGV.index("--shots")
    SHOTS = ARGV[i + 1]
    del ARGV[i:i + 2]
URL = ARGV[0] if ARGV else "http://192.168.1.222/"
PORT = 9224
MODES = ["off", "counter", "scanner", "breathing", "sparkle", "software"]


def chrome():
    if os.environ.get("CHROME"):
        return os.environ["CHROME"]
    found = glob.glob(os.path.expanduser(
        "~/.cache/ms-playwright/chromium_headless_shell-*/*/chrome-headless-shell"))
    if not found:
        sys.exit("no headless Chromium: set CHROME")
    return sorted(found)[-1]


class WebSocket:
    """just enough of a WebSocket client for the DevTools protocol"""

    def __init__(self, url):
        host, path = url[len("ws://"):].split("/", 1)
        h, p = host.split(":")
        self.s = socket.create_connection((h, int(p)), timeout=10)
        key = base64.b64encode(os.urandom(16)).decode()
        self.s.sendall((f"GET /{path} HTTP/1.1\r\nHost: {host}\r\nUpgrade: websocket\r\n"
                        f"Connection: Upgrade\r\nSec-WebSocket-Key: {key}\r\n"
                        "Sec-WebSocket-Version: 13\r\n\r\n").encode())
        self.buf = b""
        while b"\r\n\r\n" not in self.buf:
            self.buf += self.s.recv(4096)
        self.buf = self.buf.split(b"\r\n\r\n", 1)[1]

    def send(self, text):
        data, mask = text.encode(), os.urandom(4)
        n = len(data)
        head = bytes([0x81]) + (bytes([0x80 | n]) if n < 126 else
                                bytes([0x80 | 126]) + struct.pack(">H", n) if n < 65536 else
                                bytes([0x80 | 127]) + struct.pack(">Q", n))
        self.s.sendall(head + mask + bytes(b ^ mask[i % 4] for i, b in enumerate(data)))

    def _need(self, n):
        while len(self.buf) < n:
            self.buf += self.s.recv(65536)

    def recv(self):
        self._need(2)
        n, off = self.buf[1] & 0x7F, 2
        if n == 126:
            self._need(4)
            n, off = struct.unpack(">H", self.buf[2:4])[0], 4
        elif n == 127:
            self._need(10)
            n, off = struct.unpack(">Q", self.buf[2:10])[0], 10
        self._need(off + n)
        data, self.buf = self.buf[off:off + n], self.buf[off + n:]
        return json.loads(data)


class Page:
    def __init__(self, ws):
        self.ws, self.next_id = ws, 0

    def call(self, method, **params):
        self.next_id += 1
        self.ws.send(json.dumps({"id": self.next_id, "method": method, "params": params}))
        while True:
            msg = self.ws.recv()
            if msg.get("id") == self.next_id:
                return msg.get("result", {})

    def js(self, expr):
        r = self.call("Runtime.evaluate", expression=expr, returnByValue=True, awaitPromise=True)
        return r.get("result", {}).get("value")


def api(path, body=None):
    req = urllib.request.Request(URL.rstrip("/") + path,
                                 data=None if body is None else json.dumps(body).encode(),
                                 headers={"Content-Type": "application/json"})
    return json.load(urllib.request.urlopen(req, timeout=5))


def check(ok, text):
    global failures
    failures += not ok
    print(f"{'PASS' if ok else 'FAIL'}  {text}")
    return ok


def wait_for(fn, timeout=4.0):
    t0 = time.time()
    while True:
        v = fn()
        if v or time.time() - t0 > timeout:
            return v
        time.sleep(0.3)


def control_tests(page):
    """the temperature control card: plot, mode buttons, setpoint, slider"""
    c0 = api("/api/control")["state"]
    if not check(c0.get("available"), f"temperature controller answers: {c0.get('status') or c0.get('error')}"):
        return
    time.sleep(2.5)                     # a few samples for the plot
    plot = page.js('''(() => {
        const t = document.querySelector("#plot-temp svg"), d = document.querySelector("#plot-duty svg");
        const lt = t && t.querySelector("path.line-temp"), ld = d && d.querySelector("path.line-duty");
        return {temp: lt ? lt.getAttribute("d").split(/[ML]/).length - 1 : 0,
                duty: ld ? ld.getAttribute("d").split(/[ML]/).length - 1 : 0,
                sp: !!(t && t.querySelector("line.sp")),
                spText: (t && t.querySelector(".sp-label") || {}).textContent || "",
                width: t ? t.getBoundingClientRect().width : 0,
                pill: document.getElementById("ctl-status").textContent};
    })()''')
    check(plot["temp"] >= 2 and plot["duty"] >= 2 and plot["width"] > 200 and
          (plot["sp"] or c0["mode"] != "auto"),
          f"control plot: {plot['temp']} temperature points, {plot['duty']} duty points, "
          f"setpoint line {plot['sp']} ({plot['spText']!r}), {plot['width']:.0f} px wide, status {plot['pill']!r}")
    # hover: the crosshair and the tooltip
    page.js('''(() => { const h = document.getElementById("plot-temp"), r = h.getBoundingClientRect();
        h.dispatchEvent(new PointerEvent("pointermove", {clientX: r.right - 40, clientY: r.top + 40, bubbles: true})); })()''')
    time.sleep(0.3)
    tip = page.js('!document.getElementById("plot-tip").hidden && document.getElementById("plot-tip").textContent')
    check(bool(tip) and "hottest" in tip, f"plot hover tooltip: {tip!r}")
    page.js('document.getElementById("plot-temp").dispatchEvent(new PointerEvent("pointerleave"))')

    try:
        for mode in ("manual", "off", "auto"):
            page.js(f'document.querySelector("#ctl-modes [data-mode={mode}]").click()')
            got = wait_for(lambda: api("/api/control")["state"].get("mode") == mode)
            shown = wait_for(lambda: (lambda m: m if m == mode else None)(page.js(
                'document.querySelector("#ctl-modes [aria-checked=true]")?.dataset.mode')), 2.0)
            check(got and shown == mode, f"mode button {mode}: controller {api('/api/control')['state']['mode']}, page {shown}")
        sp_new = 43.5 if abs(c0["setpoint"] - 43.5) > 0.05 else 41.5
        page.js(f'(() => {{ const i = document.getElementById("sp-input"); i.focus(); i.value = "{sp_new}";'
                ' document.querySelector("#sp-form button").click(); })()')
        got = wait_for(lambda: abs(api("/api/control")["state"]["setpoint"] - sp_new) < 0.01)
        time.sleep(1.5)
        label = page.js('document.querySelector("#plot-temp .sp-label")?.textContent')
        check(got and label and f"{sp_new:.1f}" in label, f"setpoint {sp_new}: controller "
              f"{api('/api/control')['state']['setpoint']}, plot label {label!r}")
        # the fan slider, with the loop on auto, switches it to manual at that duty
        page.js('(() => { const d = document.getElementById("fan-duty"); d.value = 90;'
                ' d.dispatchEvent(new Event("change")); })()')
        st = wait_for(lambda: (lambda s: s if s["mode"] == "manual" and s["manual_duty"] == 90 else None)(
            api("/api/control")["state"]))
        time.sleep(1.5)
        duty = api("/api/board")["fan"]["duty"]
        check(bool(st) and duty == 90, f"fan slider 90 in auto: controller {api('/api/control')['state']['mode']}, "
              f"register 9 = {duty}")
    finally:
        api("/api/control", {"mode": c0["mode"], "setpoint": c0["setpoint"],
                             "manual_duty": c0["manual_duty"]})
        print(f"      (put back: mode {c0['mode']}, setpoint {c0['setpoint']}, manual duty {c0['manual_duty']})")


def shot(page, name, width, height):
    page.call("Emulation.setDeviceMetricsOverride", width=width, height=height,
              deviceScaleFactor=1, mobile=width < 600)
    time.sleep(0.8)
    full = page.js("document.documentElement.scrollHeight")
    page.call("Emulation.setDeviceMetricsOverride", width=width, height=full,
              deviceScaleFactor=1, mobile=width < 600)
    time.sleep(0.5)
    data = page.call("Page.captureScreenshot", format="png")["data"]
    os.makedirs(SHOTS, exist_ok=True)
    path = os.path.join(SHOTS, name)
    with open(path, "wb") as f:
        f.write(base64.b64decode(data))
    overflow = page.js("document.documentElement.scrollWidth > window.innerWidth")
    print(f"screenshot {path} ({width} px wide{', HORIZONTAL OVERFLOW' if overflow else ''})")
    return not overflow


proc = subprocess.Popen([chrome(), "--no-sandbox", "--hide-scrollbars", f"--remote-debugging-port={PORT}",
                         "--window-size=1280,900", "about:blank"],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
failures = 0
try:
    for _ in range(50):
        try:
            targets = json.load(urllib.request.urlopen(f"http://127.0.0.1:{PORT}/json"))
            break
        except OSError:
            time.sleep(0.2)
    page_target = next(t for t in targets if t["type"] == "page")
    page = Page(WebSocket(page_target["webSocketDebuggerUrl"]))
    page.call("Page.enable")
    page.call("Runtime.enable")
    page.call("Page.navigate", url=URL)
    time.sleep(2.5)
    conn = page.js('document.getElementById("conn").textContent')
    leds = page.js('document.querySelectorAll("#board .led").length')
    ok = conn == "live" and leds == 8
    failures += not ok
    print(f"{'PASS' if ok else 'FAIL'}  page: connection {conn!r}, {leds} LEDs in the drawing")

    for mode in MODES:
        page.js(f'[...document.querySelectorAll("#modes button")].find(b => b.textContent === "{mode}").click()')
        time.sleep(1.0)
        shown = page.js('({checked: document.querySelector(\'#modes [aria-checked="true"]\')?.textContent,'
                        ' module: document.getElementById("module-id").textContent,'
                        ' glow: [...document.querySelectorAll("#board .led-glow")].map(g => +g.style.opacity)})')
        board = api("/api/board")
        lit = sum(1 for g in shown["glow"] if g > 0.05)
        ok = shown["checked"] == mode and board["blinker"]["name"] == mode
        if mode in ("counter", "scanner", "breathing", "sparkle"):
            ok = ok and len(shown["module"]) == 4
        failures += not ok
        print(f"{'PASS' if ok else 'FAIL'}  picked {mode:9s} -> page {shown['checked']!s:9s} "
              f"module {shown['module']!s:11s} register {board['blinker']['name']:9s} lit {lit}/8")
        if mode == "scanner" and SHOTS:
            shot(page, "desktop.png", 1280, 900)

    # software mode: clicking LED 2 in the drawing toggles bit 2 of register 5
    before = api("/api/board")["led_register"]
    page.js('document.querySelector("#board #led2").dispatchEvent(new MouseEvent("click", {bubbles: true}))')
    time.sleep(0.8)
    after = api("/api/board")["led_register"]
    ok = after == before ^ 0x04
    failures += not ok
    print(f"{'PASS' if ok else 'FAIL'}  click LED2 in software mode: register 5 {before:#04x} -> {after:#04x}")

    control_tests(page)

    if SHOTS:
        time.sleep(2)
        shot(page, "control.png", 1280, 900)
        page.js('[...document.querySelectorAll("#modes button")].find(b => b.textContent === "sparkle").click()')
        time.sleep(1.0)
        failures += not shot(page, "phone.png", 390, 844)
finally:
    proc.terminate()

print("PASS" if not failures else f"{failures} FAILED")
sys.exit(1 if failures else 0)
