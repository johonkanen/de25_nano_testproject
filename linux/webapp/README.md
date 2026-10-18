# linux/webapp/ — the DE25-Nano web GUI

A page served by the board itself (`http://192.168.1.222/`): a drawing of
the DE25-Nano with its LEDs, slide switches, push-buttons and fan live (20
updates a second), the LED blinker picker, the LED register, the fan duty,
closed-loop control of the die temperature (42 °C by default, with a live
10-minute plot), new FPGA cores loaded over the network while Linux keeps
running, and updates of the GUI itself over the network with automatic
rollback.

The LED blinkers are FPGA modules — `source/led_blinkers.vhd` and
`source/blinkers/` (ported from `~/dev/pr_testing`). The GUI only picks the
mode (register 13) and shows what the LEDs do (registers 14..17). How the
modules become partial bitstreams loaded from Linux:
[docs/partial_reconfiguration_plan.md](../../docs/partial_reconfiguration_plan.md).

## Architecture

Three processes, all from the release in `current/`, started (in this
order) and restarted by the supervisor:

```
                    /dev/mem (LWH2F 0x2000_0000)
                              |
  fpga_access.py  ------------+   the only process mapping it; one lock;
     |  /run/de25web/fpga.sock    pause/resume; the fan lease; FPGA core
     |                            loads (/lib/firmware); --sim board
     |
     +-- temp_control.py   reads soc64hwmon (/sys/class/hwmon), PI on the
     |      |  /run/de25web/control.sock   hottest die sensor, writes fan duty
     |      |                              (register 9) through fpga.sock
     +------+-- fpga_web.py   HTTP :80 - registers via fpga.sock, the loop
                                via control.sock; never touches /dev/mem
```

Both sockets speak one JSON object per line each way (the protocols are in
the docstrings of `fpga_access.py` and `temp_control.py`); both have a
`--client` mode for the shell:

```sh
python3 /opt/de25web/current/fpga_access.py --client read 9          # fan duty
python3 /opt/de25web/current/fpga_access.py --client status
python3 /opt/de25web/current/fpga_access.py --client pause 30        # hold register traffic (reconfiguration)
python3 /opt/de25web/current/fpga_access.py --client core            # running build id, installed core
python3 /opt/de25web/current/fpga_access.py --client reload          # load the installed core again (~2 s)
python3 /opt/de25web/current/temp_control.py --client state
python3 /opt/de25web/current/temp_control.py --client set setpoint=45 mode=auto
```

**Fail safe, not crash.** A client that cannot reach a socket reports it -
the page shows "FPGA access unavailable" or "temperature control not
running" - and retries; nothing crashes over a missing peer. All register
traffic is serialised in `fpga_access.py`, the one place a partial or full
bitstream load pauses it (`{"op": "pause"}` / `"resume"`, with a timeout
so a forgotten pause cannot hold the fan loop forever).

## FPGA core

`fpga_access.py` also loads the FPGA core (HPS-first images): op `reload`
loads `/lib/firmware/de25_nano.core.rbf` again, op `install_core` checks a
bundle (core + `de25_nano.core.json` from `linux/make_jic.sh`) and installs
it - refusing a core that doesn't match its manifest or the periphery of
the first stage in QSPI, keeping the old core and loading it back if the
new one fails, writing a good one to the SD card too. During a load (~2 s)
register reads and writes answer "paused"; after it the LED register, fan
duty, blinker mode and loopback are written back, and fan leases are
extended by the pause. Details: [docs/hps_first.md](../../docs/hps_first.md),
"A new core over the network".

With an RSU flash each image has its own core (P1, FACTORY_IMAGE):
`fpga_access.py` finds the running one (the RSU driver's `current_image`,
the SPT read from the QSPI's MTD partitions), keeps its core in `/lib/firmware/rsu/<image>/`
with `/lib/firmware/de25_nano.core.rbf` linking there, and writes the card
copy as `de25_nano_<image>.core.rbf`. `GET /api/fpga` has `slot`. The first
boot of an image with no core there takes the one U-Boot loaded (card,
else QSPI `CORE.<image>`), without a manifest - its first install needs
`--force`.

```bash
python3 linux/tools/deploy_fpga.py                  # linux/build_output's core, to 192.168.1.222
python3 linux/tools/deploy_fpga.py --pack-only core.tar.gz   # a bundle for the GUI's "FPGA core" card
python3 linux/tools/deploy_fpga.py --reload
```

## Control loop

- **Controlled variable**: the hottest of the die sensors (`temp*_input` of
  `soc64hwmon`: SDM and three corners), sampled once a second (every read
  is an SDM mailbox call; the web server takes the temperatures from the
  controller rather than reading them a second time).
- **Setpoint** 42.0 °C (25..85), kept in `/opt/de25web/control.json` with the
  mode and gains, across releases and restarts.
- **Actuator**: the fan duty, register 9, clamped to **30..255** - below 30
  the fan stalls or runs erratically (`docs/de25_nano_fan.md`).
- **Law**: positional PI, `e = T_max - setpoint` (too hot -> more fan),
  `u = Kp e + I`, conditional integration (the integrator stops when the
  output is at a limit and the error pushes further) and an integrator
  clamped to the output range: no windup. Entering auto is bumpless (the
  integrator starts from the duty in the register).
- **Gains**: `Kp = 16 duty/°C`, `Ki = 0.55 duty/(°C·s)` (`Ti` ~ 30 s). From
  the simulated plant (below): gain -0.09 °C per duty step at the 42 °C
  operating point (-0.17 at duty 30, -0.02 at 200), `tau` 30 s, ~2.5 s lag;
  SIMC/IMC with a 15 s closed-loop time constant gives `Kp = tau / (K
  (tau_c + theta))` ~ 16 and `Ti = tau`. With `tau` doubled the same gains
  still settle (130 s, 0.3 °C overshoot) - margin for a heatsink slower
  than the model. Change them with `POST /api/control {"kp": .., "ki": ..}`
  if the real board needs it.
- **Honest limits**: a fan only cools. At duty 30 with the die still below
  the setpoint (a cool room) the loop is **saturated low** and says so;
  at 255 and still above it, **saturated high**. "Settled" means every
  5-sample average of the last 30 s within ±0.3 °C. The sensor's own noise
  and resolution are the floor of "exactly 42".
- **Modes**: `auto` (PI), `manual` (fixed duty, at least 30), `off` (the
  loop leaves the fan alone). The GUI's fan slider in auto or manual puts
  the loop in manual at that duty; with the loop off it writes register 9
  directly, as before.

**When something dies:**

| what | the fan |
|------|---------|
| `temp_control.py` killed / crashed | keeps its duty (the FPGA holds register 9); a crash with a Python exception raises it to 128 first; the supervisor restarts the loop within ~1 s, bumpless |
| `temp_control.py` hung (alive, silent) | each fan write carries a 10 s **lease**: `fpga_access.py` raises the fan to 128 (never lowers it) when it runs out |
| `fpga_access.py` killed | keeps its duty; the loop and the page report "FPGA access unavailable"; restarted within ~1 s |
| no die temperature for 5 samples | the loop puts the fan at >= 128 and says why |
| everything | the AMC6821's own THERM fail-safe (fan to 100 %) is still enabled |

## Files

| file | what |
|------|------|
| `fpga_web.py` | the HTTP server (stdlib only): the API, release handling; registers through `fpga_access.py`, the loop through `temp_control.py` |
| `fpga_access.py` | the register process: `/dev/mem`, `fpga.sock`, pause, fan lease; `--sim` simulates the register file and the board's heat |
| `temp_control.py` | the temperature loop: hwmon, PI, `control.sock`, `control.json` |
| `static/` | `index.html`, `app.js`, `style.css`, `board.svg` (drawn after the user manual's Figure 2-1) |
| `VERSION` | the GUI's version; releases add the git state (`1.0.0+b2351c3`) |
| `../board/de25web-supervisor.sh` | runs the three processes on the board and reverts a bad release - installed once, never part of a release |
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
control.json                 the temperature loop's settings
supervisor.log, server.log, access.log, control.log
```

Sockets and pid files are in `/run/de25web/`.

1. `POST /api/update` checks the SHA-256 and the token, unpacks into
   `releases/`, points `current` at it (`previous` at the old one), writes
   `pending`, and exits.
2. The supervisor stops the three processes and starts the new release's,
   on test for 120 s.
3. The release is kept once it is confirmed (`POST /api/update/confirm`):
   the page confirms by itself when it loads and reads the board;
   `deploy_web.py` confirms after checking the version and the board id.
   The server refuses to confirm (503) unless `fpga_access.py` and
   `temp_control.py` answer.
4. Otherwise the supervisor reverts to `previous` when the 120 s pass, when
   the release's processes exit 3 times (together), or when the board
   restarts during the test.

A release from before 1.3.0 (no `fpga_access.py`) still runs - alone, as
it used to - so rolling back to one works. The other way round needs the
new supervisor: 1.3.0 under the old one starts without its two helpers,
fails the board check and is reverted.

**Roll back** puts the previous release on test the same way, so rolling
back onto a broken release reverts too.

These cases - a good update, two updates within the test time, no
confirmation, a release that crashes, a restart during the test, and a
rollback onto the broken one - were run against a local copy of the layout
with the real supervisor under busybox `sh` and `fpga_web.py --sim`.

## API

| | |
|---|---|
| `GET /api/board` | every register, decoded (LED levels, switches, keys, fan, blinker mode and module id, `build_id`), plus `soc`: the SoC's temperatures (°C) and supply voltages (V) from the kernel's `soc64-hwmon` (SDM sensors), and `control`: the loop's latest sample. With `fpga_access.py` down: `{"error": "FPGA access unavailable ...", "fpga_unavailable": true, soc, control}` |
| `GET /api/control` | the loop: `state` (mode, setpoint, measured, hottest, duty, rpm, p, i, error, saturated `"low"`/`"high"`/null, settled, status text, gains) and `history`: `[t, T_max, setpoint (null unless auto), duty, rpm]` once a second for 10 min (`t`: CLOCK_MONOTONIC s) |
| `POST /api/control` | any of `{"mode": "auto"\|"manual"\|"off", "setpoint": 42.0, "manual_duty": 80, "kp": 16, "ki": 0.55}` |
| `GET /api/events` | the same as server-sent events, 20 a second |
| `POST /api/blinker` | `{"mode": "scanner"}` or `0..5` (software, off, counter, scanner, breathing, sparkle) |
| `POST /api/leds` | `{"value": 85}` - LED register 5 (blinker mode software) |
| `POST /api/fan` | `{"duty": 0..255}` - loop in auto/manual: it becomes manual at this duty (at least 30); loop off: register 9 directly |
| `GET /api/read?reg=N`, `POST /api/write` | raw register access, as before |
| `GET /api/version` | release running, previous, on test |
| `POST /api/update` | body: release `.tar.gz`; headers `X-Sha256`, `X-Token` |
| `POST /api/update/confirm`, `/api/update/rollback` | |
| `GET /api/fpga` | the FPGA core: `running_build_id` (register 19), `installed` and `previous` manifests, `last_load` |
| `POST /api/fpga` | body: core bundle `.tar.gz` (`deploy_fpga.py`); headers `X-Sha256`, `X-Token`, `X-Force: 1` (the board's core has no manifest, or another periphery). 200 loaded, 409 refused before anything was touched, 500 failed to load (`rolled_back` says whether the previous core is back) |
| `POST /api/fpga/reload` | load the installed core again (`X-Token`) |

```bash
curl -X POST -d '{"mode":"breathing"}' http://192.168.1.222/api/blinker
```

## Develop without the board

```bash
export DE25WEB_RUN=/tmp/de25web-sim                  # the sockets (also the --sim default)
python3 linux/webapp/fpga_access.py --sim &          # registers + the simulated heat
python3 linux/webapp/temp_control.py --sim &         # the loop
python3 linux/webapp/fpga_web.py --sim --port 8000   # http://127.0.0.1:8000/
python3 linux/tools/gui_test.py http://127.0.0.1:8000/ --shots /tmp/shots
```

`--sim` models the register file, including the four blinker patterns, a
fan whose rpm follows the duty (duty x 14.5, 1.5 s lag), and the die's heat:

    T_ss = ambient + load / (0.0239 + 0.001251 sqrt(rpm)),   tau 30 s

calibrated so duty 30 at 25 °C ambient gives ~45 °C (the board reads
40-44 °C there) and 42 °C needs about duty 55; the load wanders ±3 % with a
5 min period and each sensor has 0.08 °C of noise. The plant is written as a
fake `soc64hwmon` under `$DE25WEB_RUN/sim-hwmon/`, so the loop reads it exactly
as it reads `/sys/class/hwmon`. Change it while running:
`fpga_access.py --sim --client sim ambient=10` (saturates the loop low),
`ambient=40` (high), `load=1.2`, `temp=45`.

Updates are off in a plain run (not under `/opt/de25web`); to try them, lay
out a `releases/` directory and run the supervisor with `DE25WEB_BASE`,
`DE25WEB_PORT`, `DE25WEB_RUN`, `DE25WEB_TEST_SECONDS` and `DE25WEB_ARGS=--sim`
(`--sim` goes to all three processes). Unix socket paths are limited to 107
bytes: keep `DE25WEB_RUN` short.

## Notes

- Register access needs root (`/dev/mem`); init runs the supervisor as root.
- Every register read and write goes through one lock in `fpga_access.py`
  - the place a bitstream load will pause register traffic. The web server
  samples the registers once (20 Hz) for all its clients.
- The token guards uploads and rollbacks only; the rest of the page is open
  to the LAN, like the board's console.
