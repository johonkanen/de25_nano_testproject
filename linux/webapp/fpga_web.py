#!/usr/bin/env python3
"""
fpga_web.py - a webpage, served on the DE25-Nano's own IP, that reads and
writes the de25_nano_uart fabric register file over the LWH2F bridge
(the same registers test_uart.py reaches over the fabric UART, and the
same window hps/baremetal_lwh2f_regs/ reaches from bare metal - see that
file's header for how LWH2F_BASE/the register spacing were derived).

Needs CONFIG_STRICT_DEVMEM disabled in the kernel (see linux/README.md's
"Web-controlled FPGA registers" section) - with it enabled, mmap() on
/dev/mem at this address gets SIGBUS'd by the kernel's iomem access
control, same symptom de25_std_testproject hit reading the same class of
register over devmem from Linux.

No external dependencies (stdlib only) - runs on both the toybox and the
Alpine rootfs, though Alpine's real dynamic linking makes `apk add
python3` the easiest way to get an interpreter at all.

Usage:
    python3 fpga_web.py [--port 8000] [--bind 0.0.0.0]

Then browse to http://<board-ip>:8000/
"""
import argparse
import html
import json
import mmap
import os
import struct

LWH2F_BASE = 0x20000000
REG_STRIDE = 0x10          # each register is 16 bytes apart, see LWH2F_BASE + (n << 4)
MAP_SIZE = 0x1000          # 4KB window, covers registers 1-12 with room to grow
PAGE_SIZE = mmap.PAGESIZE

REGISTERS = [
    (1, "id", "RO", "0x0000DE25"),
    (2, "git hash", "RO", ""),
    (3, "loopback", "RW", ""),
    (4, "read counter", "RO", "+1 on every read"),
    (5, "LED", "RW", "low 7 bits -> LED[6:0]"),
    (6, "SW[3:0] switches", "RO", ""),
    (7, "KEY[1:0] buttons", "RO", "1 = pressed"),
    (8, "uptime counter", "RO", "free-running core-clock"),
    (9, "fan duty cycle", "RW", "AMC6821 DCY, low 8 bits"),
    (10, "fan speed", "RO", "RPM"),
    (11, "fan raw TACH", "RO", ""),
    (12, "fan status", "RO", "see test_uart.py header for bit fields"),
]


class Bridge:
    """mmap-backed access to the LWH2F register window."""

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


PAGE_TEMPLATE = """<!doctype html>
<html>
<head>
<title>DE25-Nano registers</title>
<meta charset="utf-8">
<style>
  body {{ font-family: monospace; background: #111; color: #ddd; margin: 2em; }}
  h1 {{ color: #6cf; }}
  table {{ border-collapse: collapse; width: 100%; max-width: 760px; }}
  th, td {{ border: 1px solid #444; padding: 6px 10px; text-align: left; }}
  th {{ background: #222; }}
  tr:hover {{ background: #1a1a1a; }}
  input[type=text] {{ width: 5em; background: #000; color: #6f6; border: 1px solid #555; }}
  button {{ background: #246; color: #fff; border: none; padding: 4px 10px; cursor: pointer; }}
  button:hover {{ background: #358; }}
  .ro {{ color: #888; }}
  #status {{ margin-top: 1em; min-height: 1.2em; }}
</style>
</head>
<body>
<h1>DE25-Nano &mdash; LWH2F registers</h1>
<p>Live over the HPS-to-FPGA lightweight bridge (<code>0x20000000</code>).
Refreshes on load; press "read" on any row to refresh just that one.</p>
<table>
<tr><th>#</th><th>name</th><th>rw</th><th>value</th><th>note</th><th></th></tr>
{rows}
</table>
<div id="status"></div>
<script>
async function readReg(n) {{
  const r = await fetch('/api/read?reg=' + n);
  const j = await r.json();
  document.getElementById('val' + n).textContent = '0x' + j.value.toString(16).padStart(8, '0');
  status(n, 'read ok');
}}
async function writeReg(n) {{
  const v = document.getElementById('in' + n).value;
  const r = await fetch('/api/write', {{
    method: 'POST', headers: {{'Content-Type': 'application/json'}},
    body: JSON.stringify({{reg: n, value: v}})
  }});
  const j = await r.json();
  if (j.error) {{ status(n, 'error: ' + j.error); return; }}
  document.getElementById('val' + n).textContent = '0x' + j.value.toString(16).padStart(8, '0');
  status(n, 'wrote ok');
}}
function status(n, msg) {{
  document.getElementById('status').textContent = 'register ' + n + ': ' + msg;
}}
</script>
</body>
</html>
"""

ROW_TEMPLATE_RO = """<tr><td>{n}</td><td>{name}</td><td class="ro">RO</td>
<td id="val{n}">0x{value:08x}</td><td>{note}</td>
<td><button onclick="readReg({n})">read</button></td></tr>
"""

ROW_TEMPLATE_RW = """<tr><td>{n}</td><td>{name}</td><td>RW</td>
<td id="val{n}">0x{value:08x}</td><td>{note}</td>
<td><input type="text" id="in{n}" placeholder="0x..">
<button onclick="readReg({n})">read</button>
<button onclick="writeReg({n})">write</button></td></tr>
"""


def parse_value(s: str) -> int:
    s = s.strip()
    return int(s, 16) if s.lower().startswith("0x") else int(s, 10)


def make_app(bridge: Bridge):
    from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
    from urllib.parse import urlparse, parse_qs

    class Handler(BaseHTTPRequestHandler):
        server_version = "de25-nano-fpga-web/1.0"

        def _json(self, obj, status=200):
            body = json.dumps(obj).encode()
            self.send_response(status)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def do_GET(self):
            parsed = urlparse(self.path)
            if parsed.path == "/":
                rows = []
                for n, name, rw, note in REGISTERS:
                    value = bridge.read(n)
                    tmpl = ROW_TEMPLATE_RW if rw == "RW" else ROW_TEMPLATE_RO
                    rows.append(tmpl.format(n=n, name=html.escape(name), value=value, note=html.escape(note)))
                body = PAGE_TEMPLATE.format(rows="".join(rows)).encode()
                self.send_response(200)
                self.send_header("Content-Type", "text/html; charset=utf-8")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
            elif parsed.path == "/api/read":
                qs = parse_qs(parsed.query)
                try:
                    reg = int(qs["reg"][0])
                    self._json({"reg": reg, "value": bridge.read(reg)})
                except (KeyError, ValueError, IndexError) as e:
                    self._json({"error": str(e)}, 400)
            else:
                self.send_error(404)

        def do_POST(self):
            if self.path != "/api/write":
                self.send_error(404)
                return
            length = int(self.headers.get("Content-Length", 0))
            try:
                data = json.loads(self.rfile.read(length))
                reg = int(data["reg"])
                value = parse_value(str(data["value"]))
                bridge.write(reg, value)
                self._json({"reg": reg, "value": bridge.read(reg)})
            except Exception as e:
                self._json({"error": str(e)}, 400)

        def log_message(self, fmt, *args):
            print("%s - %s" % (self.address_string(), fmt % args))

    return ThreadingHTTPServer, Handler


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=8000)
    ap.add_argument("--bind", default="0.0.0.0")
    args = ap.parse_args()

    bridge = Bridge()
    server_cls, handler_cls = make_app(bridge)
    httpd = server_cls((args.bind, args.port), handler_cls)
    print(f"serving on http://{args.bind}:{args.port}/")
    httpd.serve_forever()


if __name__ == "__main__":
    main()
