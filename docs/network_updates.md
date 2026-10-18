# Updating the DE25-Nano over the network - recipes

Three things can be updated without touching the board, each with its own
tool and safety net:

| what changed | update | tool | reboot | if it goes wrong |
|---|---|---|---|---|
| web GUI (`linux/webapp/`) | GUI release | `linux/tools/deploy_web.py` | no (the GUI restarts) | the supervisor reverts to the previous release |
| FPGA fabric logic (VHDL, registers) - same pins, HPS, DDR, Quartus | FPGA core | `linux/tools/deploy_fpga.py` | no (~2 s pause) | the previous core is loaded back |
| HPS IP, pinout, DDR, Quartus version, SPL or U-Boot | whole image (RSU) | `linux/tools/deploy_rsu.py` | yes, into the new image | the watchdog falls back to the factory image |

Not over the network (yet): the kernel, the device tree and the root
filesystem - those come from the SD card (`linux/tools/sd_recover.py`
writes it from U-Boot over TFTP), and the factory image (JTAG only, on
purpose).

How it works: [hps_first.md](hps_first.md) (cores),
[remote_system_update_plan.md](remote_system_update_plan.md) (RSU),
[../linux/webapp/README.md](../linux/webapp/README.md) (GUI releases, API).

## Once: a board that can take updates

The board needs the RSU flash layout, the matching SD card and the update
token. From a fresh checkout (the builds take a while - Quartus needs a lot
of memory, close other big programs):

```bash
# 1. FPGA (HPS-first, RSU watchdog setting are the defaults)
quartus_sh -t build_de25_nano_uart.tcl
quartus_ipgenerate de25_nano_uart -c de25_nano_uart --run_default_mode_op
./write_build_id.sh
quartus_syn de25_nano_uart && quartus_fit de25_nano_uart && quartus_sta de25_nano_uart && quartus_asm de25_nano_uart

# 2. boot software, kernel, rsu_client
CROSS_TOOLCHAIN=<dir with bin/aarch64-none-linux-gnu-gcc> ./linux/build_de25_nano_linux.sh

# 3. QSPI image (RSU layout), core + manifest, application image
./linux/make_jic.sh

# 4. SD card image, keeping the token you already have (else a new one)
DE25WEB_TOKEN_FILE=~/.de25web_token ./linux/tools/make_sdcard_image.sh
```

Install - **card first, then QSPI**:

1. write the card: `python3 linux/tools/sd_recover.py` (from U-Boot over
   TFTP), or with a card reader;
2. program QSPI: `quartus_pgm -c "DE25-Nano [1-1-iface0]" -m jtag -o "pvi;linux/build_output/de25_nano.jic"`
   (cable name from `jtagconfig`). **Check it says "Successfully performed
   operation(s)"** - a failed erase leaves the flash unbootable; program
   again;
3. power-cycle. The console stays silent until U-Boot has loaded the FPGA
   core (the UART runs through the fabric), then ` FPGA reconfiguration OK!`.

The token: `~/.de25web_token` on the PC = `/opt/de25web/token` on the board
(`DE25WEB_TOKEN_FILE` above puts it there; or copy it over by hand). The
tools read it from that file, or `--token` / `DE25WEB_TOKEN`.

Check: `python3 linux/tools/deploy_rsu.py --status` ->
`image P1, build ..., confirm 'confirmed 0x00400000 ..'`.

All tools default to `--host 192.168.1.222`.

## Recipe A - a new GUI release

```bash
# edit linux/webapp/ (bump linux/webapp/VERSION)
python3 linux/tools/deploy_web.py
```

It packs `linux/webapp/`, uploads it, waits for the restart, checks the
board id and confirms. Not confirmed within 120 s (or crashing): the board
reverts to the previous release by itself. Back by hand: the GUI's "Roll
back" button, or `POST /api/update/rollback` with the token.

## Recipe B - new FPGA logic, Linux keeps running

For changes inside the fabric - anything that keeps the pins, the HPS and
DDR configuration and the Quartus version.

```bash
./write_build_id.sh                         # new build id (register 19)
quartus_syn de25_nano_uart && quartus_fit de25_nano_uart && quartus_sta de25_nano_uart && quartus_asm de25_nano_uart
./linux/make_jic.sh                         # writes the core + its manifest (de25_nano.core.{rbf,json})
python3 linux/tools/deploy_fpga.py
```

Expect:

```
>> build 17923... running, loaded in 2.1 s; SD card copy written
>> GUI sees build 17923..., fan duty .., blinker ..
```

The register traffic pauses for ~2 s (the console too); the LED, fan and
blinker registers are written back after the load. The core is copied to
the card as `de25_nano_<image>.core.rbf`, so the next power-on keeps it.

From the GUI instead: `python3 linux/tools/deploy_fpga.py --pack-only core.tar.gz`,
then the "FPGA core" card. Load the installed core again:
`deploy_fpga.py --reload` (or `fpga-reload` on the board).

Refused (nothing changed) when:

| message | meaning / what to do |
|---|---|
| `does not fit the first stage in QSPI: periphery ...` | pins, HPS or DDR changed - use recipe C |
| `the installed core has no manifest` | the board's core came from the card or the `.jic` - `--force` once |
| `does not match the manifest (truncated?)` / `(corrupt)` | rebuild the bundle (`make_jic.sh`) |

If the new core loads but fails its checks (board id, build id), the
previous one is loaded back: `core not installed (500): ... - the previous
core is back`.

Note: this updates the running image's core on the card and in
`/lib/firmware`; the QSPI copy (`CORE.<image>`, used when the card has
none) stays as the last `.jic` or RSU update wrote it.

## Recipe C - a whole new image (RSU), with automatic fallback

For HPS IP, pinout, DDR, Quartus, SPL or U-Boot changes - everything in
one bundle: the image (first stage + SPL), its U-Boot and its FPGA core.

```bash
# changed U-Boot/SPL? first: ./linux/build_de25_nano_linux.sh
# changed the HPS IP? regenerate it explicitly first:
#   quartus_ipgenerate --generate_ip_file --ip_file=hps/ip/hps_subsys/agilex_hps.ip \
#     --synthesis=verilog --clear_ip_generation_dirs de25_nano_uart -c de25_nano_uart
./write_build_id.sh
quartus_syn de25_nano_uart && quartus_fit de25_nano_uart && quartus_sta de25_nano_uart && quartus_asm de25_nano_uart
./linux/make_jic.sh                         # also writes the application image de25_nano_app.rpd
python3 linux/tools/make_rsu_bundle.py      # build_output/de25_nano_rsu_<build>.tar.gz
python3 linux/tools/deploy_rsu.py           # the newest bundle
```

Expect (about a minute):

```
>> written in 15.9 s (erase P1, erase SSBL.P1, write SSBL.P1, erase CORE.P1, write CORE.P1, card, /lib/firmware, write P1, verify P1)
>> the board reboots into it; waiting for rsu-confirm
      56 s  image P1, build 17923..., confirm 'confirmed 0x00400000 16', P1 holds build 17923...
>> build 17923... confirmed in P1, 56 s after the upload
```

What happens: the board erases slot P1 first (from then on a power cut
boots the factory image), writes the new U-Boot and core, then the image,
verifies it and reboots into it. On the board `rsu-confirm` waits until the
GUI answers with the board id read over LWH2F; then the image is
confirmed. If that does not happen within 300 s of boot - or the image
hangs - the watchdog makes the SDM load the factory image instead:

```
>> P1 did not come up healthy: the SDM fell back to the factory image (state 0xF0060002). ...
```

Then the board runs the factory image (its own U-Boot and core, never
written by updates). Fix the design, build a new bundle and run
`deploy_rsu.py` again - it works from the factory image the same way. The
failure record stays until `rsu_client --clear-error-status` on the board.

From the GUI instead: the "FPGA image" card, with the bundle file and the
token. `--no-reboot` writes P1 without rebooting (it runs from the next
reboot or power-on).

Refused (nothing changed): wrong token or SHA-256, a file in the bundle
that does not match its manifest, a part too big for its partition, a core
bundle (that is recipe B).

There is one application slot: a failed update leaves no previous P1 to go
back to - the factory image is the fallback.

## Checking the state

```bash
python3 linux/tools/deploy_rsu.py --status      # image (P1/factory), build, confirmation, P1 content, failures
curl -s http://192.168.1.222/api/fpga            # the core: running build id, installed, previous
curl -s http://192.168.1.222/api/rsu             # RSU: status, confirm, p1_priority, installed bundle
curl -s http://192.168.1.222/api/version         # GUI release
```

On the board (console, `/dev/serial/by-id/usb-TERASIC_DE25-Nano_*-if03-port0`, 115200):

```sh
rsu_client --log                        # current / failed image, state, retries
cat /run/rsu-confirm                    # confirmed / waiting / failed / factory
dmesg | grep 'rsu-confirm\|FPGA core\|eth-watchdog'
cat /sys/devices/platform/stratix10-rsu.0/current_image   # 0x400000 P1, 0x220000 factory
```

## Recovery

| situation | do |
|---|---|
| fell back to the factory image | it runs and answers; deploy a fixed bundle (recipe C); `rsu_client --clear-error-status` clears the record |
| back to P1 by hand (it is good) | `rsu_client --clear-error-status; echo 0x400000 > /sys/devices/platform/stratix10-rsu.0/reboot_image; reboot` |
| try the factory image by hand | `echo 0x220000 > /sys/devices/platform/stratix10-rsu.0/reboot_image; reboot` |
| an RSU update was cut short (power, network) | P1 is erased or incomplete, the factory image boots; run `deploy_rsu.py` again |
| a core update failed | the previous core is back (or, after a hang/power cut, put back at the next start of `fpga_access.py`) |
| no network after a reboot | `eth-watchdog` bounces eth0 within ~15 s of boot, ~90 s later on; or on the console `ip link set eth0 down; ip link set eth0 up` |
| the board hangs, JTAG times out | power-cycle (a damaged core can hang the SDM - the SHA-256 checks exist for that) |
| nothing boots | program the `.jic` over JTAG (check the result), write the card with `sd_recover.py` |

## Rules of thumb

- Check every programming/upload result before power-cycling.
- Never load a core or image whose SHA-256 you made match a damaged file -
  a damaged core hung the SDM; a damaged P1 would be retried at every
  power-on.
- `reboot` after a JTAG `.sof` load does not come back (the SPL came over
  JTAG); power-cycle instead. After a power-on boot `reboot` works.
- Test reboot loops only with the current inittab (processes stopped before
  the root filesystem goes read-only) - an unclean shutdown loop broke the
  ext4 journal once.
