# linux/webapp/ — the DE25-Nano web GUI

A page served by the board itself (`http://192.168.1.222/`): a drawing of
the DE25-Nano with its LEDs, slide switches, push-buttons and fan live (20
updates a second), the LED blinker picker, the LED register, the fan duty,
and updates of the GUI itself over the network with automatic rollback.

The LED blinkers are FPGA modules — `source/led_blinkers.vhd` and
`source/blinkers/` (ported from `~/dev/pr_testing`). The GUI only picks the
mode (register 13) and shows what the LEDs do (registers 14..17). How the
modules become partial bitstreams loaded from Linux:
[docs/partial_reconfiguration_plan.md](../../docs/partial_reconfiguration_plan.md).

## Files

| file | what |
|------|------|
| `fpga_web.py` | the server (stdlib only): register access over LWH2F, the API, release handling. `--sim` runs it without hardware |
| `static/` | `index.html`, `app.js`, `style.css`, `board.svg` (drawn after the user manual's Figure 2-1) |
| `VERSION` | the GUI's version; releases add the git state (`1.0.0+b2351c3`) |
| `../board/de25web-supervisor.sh` | runs the server on the board and reverts a bad release - installed once, never part of a release |
| `../tools/install_webapp.py` | one-time install on a running board, over the serial console |
| `../tools/deploy_web.py` | an update over HTTP: pack, upload, wait, check, confirm |
| `../tools/gui_test.py` | drives the page in headless Chromium: every blinker, an LED click, screenshots |

## Install (once)

Needs the [Alpine rootfs](../README.md#real-rootfs-alpine-linux) and a
bitstream with the blinkers (register 16 bit 0 set; an older bitstream
still works, the blinker buttons are disabled). Either:

- **a new SD card**: `setup_alpine_rootfs.sh` installs the GUI too; the first
  boot with network runs `apk add python3`. It prints the update token -
  put it in `~/.de25web_token` on the host.
- **a running board**: `python3 linux/tools/install_webapp.py` (serial
  console, found by id as the DE25-Nano's USB interface 3; board online). It installs python3, the first
  release and the supervisor, writes a token (kept on re-runs, copied to
  `~/.de25web_token`), adds the supervisor to `/etc/inittab` and starts it.

## Update

```bash
python3 linux/tools/deploy_web.py            # pack linux/webapp, upload, check, confirm
```

or the page's **GUI release** panel: pick a `.tar.gz` made with
`deploy_web.py --pack-only out.tar.gz`, enter the token, **Upload**.

What happens on the board (`/opt/de25web`):

```
releases/<version>-<sha8>/   each release (the newest 4 are kept)
current  -> releases/...     what runs
previous -> releases/...     the rollback target
pending                      the release on test
token                        required in X-Token for uploads and rollbacks
supervisor.log, server.log
```

1. `POST /api/update` checks the SHA-256 and the token, unpacks into
   `releases/`, points `current` at it (`previous` at the old one), writes
   `pending`, and exits.
2. The supervisor starts the new release, on test for 120 s.
3. The release is kept once it is confirmed (`POST /api/update/confirm`):
   the page confirms by itself when it loads and reads the board;
   `deploy_web.py` confirms after checking the version and the board id.
4. Otherwise the supervisor reverts to `previous` when the 120 s pass, when
   the release exits 3 times, or when the board restarts during the test.

**Roll back** puts the previous release on test the same way, so rolling
back onto a broken release reverts too.

These cases - a good update, two updates within the test time, no
confirmation, a release that crashes, a restart during the test, and a
rollback onto the broken one - were run against a local copy of the layout
with the real supervisor under busybox `sh` and `fpga_web.py --sim`.

## API

| | |
|---|---|
| `GET /api/board` | every register, decoded (LED levels, switches, keys, fan, blinker mode and module id), plus `soc`: the SoC's temperatures (°C) and supply voltages (V) from the kernel's `soc64-hwmon` (SDM sensors), sampled once a second |
| `GET /api/events` | the same as server-sent events, 20 a second |
| `POST /api/blinker` | `{"mode": "scanner"}` or `0..5` (software, off, counter, scanner, breathing, sparkle) |
| `POST /api/leds` | `{"value": 85}` - LED register 5 (blinker mode software) |
| `POST /api/fan` | `{"duty": 0..255}` |
| `GET /api/read?reg=N`, `POST /api/write` | raw register access, as before |
| `GET /api/version` | release running, previous, on test |
| `POST /api/update` | body: release `.tar.gz`; headers `X-Sha256`, `X-Token` |
| `POST /api/update/confirm`, `/api/update/rollback` | |

```bash
curl -X POST -d '{"mode":"breathing"}' http://192.168.1.222/api/blinker
```

## Develop without the board

```bash
python3 linux/webapp/fpga_web.py --sim --port 8000      # http://127.0.0.1:8000/
python3 linux/tools/gui_test.py http://127.0.0.1:8000/ --shots /tmp/shots
```

`--sim` models the register file, including the four blinker patterns.
Updates are off in a plain run (not under `/opt/de25web`); to try them, lay
out a `releases/` directory and run the supervisor with `DE25WEB_BASE`,
`DE25WEB_PORT`, `DE25WEB_TEST_SECONDS` and `DE25WEB_ARGS=--sim`.

## Notes

- Register access needs root (`/dev/mem`); init runs the supervisor as root.
- Every register read and write goes through one lock in `Board`
  (`fpga_web.py`) and is sampled once for all clients - the place a
  bitstream load will pause register traffic.
- The token guards uploads and rollbacks only; the rest of the page is open
  to the LAN, like the board's console.
