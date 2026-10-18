# de25_nano_testproject — DE25-Nano: HPS Linux, FPGA LED blinkers, web GUI

Quartus Prime Pro build for the **Terasic DE25-Nano** (Agilex 5
`A5EB013BB23BE4SCS`), structured like
[`johonkanen/axc3000_test`](https://github.com/johonkanen/axc3000_test) and
its sibling `de25_std_testproject`.

- **HPS** (`hps/hps_subsys.qsys`: the ARM cores + LPDDR4) boots Linux from
  QSPI + SD card — [linux/README.md](linux/README.md).
- **Fabric**: an `fpga_interconnect` register file reached from Linux over
  the lightweight HPS-to-FPGA bridge (LWH2F), with the
  [LED blinkers](#led-blinkers) (each pattern its own module), the
  board's [fan](#fan) controller, switches and buttons.
- **Web GUI** served by the board: a drawing of the board with the LEDs,
  switches, keys and fan live, the blinker picker, and updates of the GUI
  over the network — [linux/webapp/README.md](linux/webapp/README.md).
- Next: the blinkers as partial bitstreams loaded from Linux —
  [docs/partial_reconfiguration_plan.md](docs/partial_reconfiguration_plan.md).

The board's main USB serial port (`FPGA_UART_TX`/`FPGA_UART_RX`) carries
the HPS's Linux console, routed through the fabric (commit `247409b`); the
register file's own UART master that used to sit on those pins is retired.

## Sources

| path | origin |
|------|--------|
| `source/hVHDL_fpga_interconnect` | submodule, `hVHDL/hVHDL_fpga_interconnect` |
| `source/fpga_communication/fpga_interconnect_16bit_pkg.vhd` | vendored from `johonkanen/fpga_communication` |
| `source/fan_control/*.vhd` | written here — I2C master + AMC6821 fan controller |
| `source/led_blinkers.vhd`, `source/blinkers/*.vhd` | the LED blinkers, ported from `~/dev/pr_testing` |
| `axi_lwh2f_bridge.vhd` | LWH2F AXI4 → `fpga_interconnect`, from `de25_std_testproject` |
| `hps/` | the HPS Platform Designer system and its IP — [hps/README.md](hps/README.md) |

## Build (run from this directory)

```
git submodule update --init
./write_githash.sh                       # stamp git_hash_pkg.vhd (optional)
quartus_sh  -t build_de25_nano_uart.tcl
quartus_ipgenerate de25_nano_uart -c de25_nano_uart --run_default_mode_op
./write_build_id.sh                      # new build id, register 19
quartus_syn de25_nano_uart
quartus_fit de25_nano_uart
quartus_sta de25_nano_uart
quartus_asm de25_nano_uart
```

The `.tcl` writes `de25_nano_uart.qpf` / `de25_nano_uart.qsf` (both
git-ignored) and sets every device / pin / config-scheme assignment.
`quartus_ipgenerate` regenerates the HPS IP output, which is not tracked.

Last clean build, Quartus Prime Pro 26.1.1, 2026-10-16:

| stage | result |
|---|---|
| `quartus_syn` | 0 errors, 0 warnings |
| `quartus_fit` | 0 errors — 116 pins, 1,180 / 46,800 ALMs (3 %), HSSI HPS 1/1 |
| `quartus_sta` | timing met on `h2f_user0_clk_src`: setup slack **+15.448 ns**, hold **+0.004 ns**; one unconstrained output, `H2F_CLK_TEST` |
| `quartus_asm` | 0 errors, 0 warnings → `output_files/de25_nano_uart.sof` |

## Program

The `.sof` contains the HPS, so it goes to the QSPI flash together with
the U-Boot SPL; Linux then comes from the SD card:

```
./linux/make_jic.sh
quartus_pgm -c "DE25-Nano [1-3-iface0]" -m jtag -o "pvi;linux/build_output/de25_nano.jic"
```

Name the cable as `jtagconfig` lists it when more than one board is
attached. Power-cycle afterwards. Details:
[linux/README.md](linux/README.md#boot-media).

### From WSL2

WSL2 has no native USB — forward the blaster with
[usbipd-win](https://github.com/dorssel/usbipd-win):

```
# Windows, admin PowerShell — bind once, attach after every replug / wsl --shutdown
usbipd list
usbipd bind   --busid <b-p>
usbipd attach --wsl --busid <b-p>
```

Then [`program.sh`](program.sh) does the WSL side (perms, `jtagd`,
`jtagconfig`):

```
./program.sh --check                    # set up + jtagconfig, don't flash
sudo ./program.sh --install-udev        # once: persistent 0666 rule
```

Forward the board's **USB serial** interface into WSL too: it is the Linux
console (`/dev/serial/by-id/usb-TERASIC_DE25-Nano_*-if03-port0`), which
`linux/tools/install_webapp.py` and `push_to_nano.py` use.

## Registers

Over LWH2F at `0x2000_0000`, register *n* at byte offset *n* × `0x10` (see
`de25_nano_uart_top.vhd`'s header):

| addr | meaning |
|-----:|---------|
| 1 | constant id `0x0000DE25` (RO) |
| 2 | git hash (RO) |
| 3 | loopback register (R/W) |
| 4 | read strobe counter (RO, ++ per read) |
| 5 | LED register — low 7 bits drive `LED[6:0]` (R/W) |
| 6 | `SW[3:0]` slide switches (RO) |
| 7 | `KEY[1:0]` push-buttons, 1 = pressed (RO) |
| 8 | free-running core-clock uptime counter (RO) |
| 9 | fan speed — AMC6821 duty cycle, low 8 bits, 0 = off, 255 = full (R/W) |
| 10 | fan speed measured, RPM (RO) |
| 11 | fan raw TACH count (RO) |
| 12 | fan controller status (RO) — see [Fan](#fan) |
| 13 | LED blinker mode, low 3 bits (R/W) — see [LED blinkers](#led-blinkers) |
| 14 | LED 3..0 brightness, a byte each, LED 0 in bits 7..0 (RO) |
| 15 | LED 7..4 brightness (RO) |
| 16 | features — bit 0: the blinkers are in hardware (RO) |
| 17 | blinker module id, four ASCII characters, 0 in modes 0/1 (RO) |
| 19 | build id — the Unix time `write_build_id.sh` stamped; the core's manifest carries it (RO) |

In blinker mode 0 (the reset default) `LED[7]` is a ~1 Hz heartbeat so the
board shows life with nothing attached. From Linux: the web GUI, or
`GET /api/read?reg=N` / `POST /api/write` on it.

## LED blinkers

The LED patterns run in the fabric, each one its own module with the same
ports (`source/blinkers/blinker_pkg.vhd`: clock, reset, a 50 Hz `frame`
tick in, eight 8-bit brightness levels and a four-character id out) -
ported from `~/dev/pr_testing` so that each can later become a partial
reconfiguration persona
([docs/partial_reconfiguration_plan.md](docs/partial_reconfiguration_plan.md)).
`source/led_blinkers.vhd` is the static part: the frame tick, ~1 kHz PWM
with 256 steps, and the modes that are not patterns.
`source/blinkers/blinker_slot.vhd` holds all four modules for now, one
selected by register 13:

| mode | LEDs | id |
|-----:|------|----|
| 0 | software: register 5 on `LED[6:0]`, heartbeat on `LED[7]` | 0 |
| 1 | off | 0 |
| 2 | counter - a binary count, 4 a second | `BCNT` |
| 3 | scanner - a light sweeping 0..7..0 with a fading trail | `BSCN` |
| 4 | breathing - all LEDs fading in and out, 3 s a breath | `BBRT` |
| 5 | sparkle - random flashes fading out | `BSPK` |

`sim/led_blinkers_tb.vhd` checks every pattern, the PWM duty and the modes
(`python3 vunit_run_de25_nano_test.py de25_nano_lib.led_blinkers_tb.all`).
The board's web GUI picks the mode and shows the LEDs live -
[linux/webapp/README.md](linux/webapp/README.md).

## Fan

The board's fan is driven by an on-board **AMC6821** PWM fan controller on
the shared HDMI I2C bus (`HDMI_I2C_SCL` BT1 / `HDMI_I2C_SDA` BW2), at 7-bit
address `0x2E`. `source/fan_control/` holds a small I2C master and the
AMC6821 sequencer; the FPGA does not PWM the fan itself.

**The fan comes up at minimum speed** and stays there until something writes
register 9. That minimum is `g_fan_min_duty` in `de25_nano_uart_top.vhd`,
the reset value of register 9 — 30/255 (~11.8 %, ≈430 rpm measured on
hardware) as shipped. Because a fan may
not start from rest at a low duty cycle, the controller holds 100 % for
~0.5 s first and then drops to the setpoint, so minimum speed means *turning
slowly*, not stalled.

Register 9 is the AMC6821 duty cycle, register 10 the measured RPM
(`6000000 / TACH`), register 11 the raw TACH count, and register 12 the
controller status:

| bits | meaning |
|-----:|---------|
| 7..0 | AMC6821 device ID — reads `0x21` when the I2C link is good |
| 15..8 | AMC6821 Status 1 register (`0x02`) |
| 23..16 | duty cycle currently programmed into the chip |
| 24 | `init_done` — configuration sequence completed |
| 25 | `i2c_error` — sticky, a write went unacknowledged |
| 26 | `FAN_ALERT_n` pin level |

The web GUI's fan slider writes register 9 and shows register 10.

Two things worth knowing: the AMC6821's own **thermal fail-safe is left
enabled**, so the chip forces the fan to 100 % on over-temperature whatever
the duty register says — but there is no temperature-driven fan curve in the
FPGA, register 9 just holds what it was given. Details, the register-by-
register configuration and how to trim the minimum are in
[docs/de25_nano_fan.md](docs/de25_nano_fan.md).

## HPS and Linux

`de25_nano_uart_top.vhd` instantiates `hps_subsys` (see
[hps/README.md](hps/README.md)): the Agilex 5 hard processor system plus
its LPDDR4 EMIF, generated from the DE25-Nano GHRD's own `agilex_hps.ip` /
`emif_io96b_hps.ip`. `H2F`/`F2SDRAM` are disabled; **`LWH2F` is enabled and
wired** into the register file via `axi_lwh2f_bridge.vhd`. Getting that
bridge to survive its first access took a multi-day bring-up — see
[docs/de25_nano_lwh2f_bringup.md](docs/de25_nano_lwh2f_bringup.md) (the
root cause was a QSF boot-order setting, not RTL). The fabric runs on the
HPS's free-running H2F User0 clock (50 MHz), which also blinks
`GPIO0_D[2]` via [`h2f_user0_clk_heartbeat.vhd`](h2f_user0_clk_heartbeat.vhd).

**Linux** (Altera's 6.18.20 kernel, Alpine rootfs on the SD card) boots
from a real QSPI cold boot: SPL → ATF 2.14.1 → U-Boot 2026.04 → Linux,
hands off - all from Altera upstream. The boot is HPS-first: U-Boot loads
the FPGA core, and a running Linux can reload it in ~2 s (`fpga-reload`,
[docs/hps_first.md](docs/hps_first.md)). The steps and settings, short:
[docs/linux_boot.md](docs/linux_boot.md);
bring-up history: [linux/README.md](linux/README.md).

**Updates over the network** - the web GUI, the FPGA core (no reboot) and
whole images with remote system update (factory image + application slot,
automatic fallback when a new image does not come up healthy): recipes in
[docs/network_updates.md](docs/network_updates.md).

Bare-metal bring-up programs from before Linux, kept as references:
[hps/baremetal_uart1_test/](hps/baremetal_uart1_test/) (HPS UART1 + the
clock-manager PLL bring-up, [docs/de25_nano_hps.md](docs/de25_nano_hps.md))
and [hps/baremetal_lwh2f_regs/](hps/baremetal_lwh2f_regs/) (the register
file over LWH2F from bare metal). Both were written when UART1 was on its
own IOB15/IOB16 pins, before it was routed through the fabric.

## Simulate

Two [VUnit](https://vunit.github.io/) testbenches, run by
`vunit_run_de25_nano_test.py`, which also compiles every other source
including the top level. Needs `nvc` ≥ 1.14
([nickg/nvc](https://github.com/nickg/nvc)) on `PATH` and
`pip install vunit_hdl`:

```
python3 vunit_run_de25_nano_test.py          # run everything
python3 vunit_run_de25_nano_test.py -v       # verbose
python3 vunit_run_de25_nano_test.py --list   # list test cases
```

- `fan_control_tb` points `amc6821_fan_control` at an `amc6821_model` I2C
  slave and checks the configuration it writes, the startup kick, the
  settle to minimum, the RPM conversion, and that an unacknowledged write
  raises `i2c_error`, releases the bus rather than wedging it, and recovers.
- `led_blinkers_tb` checks every blinker pattern, the PWM duty and the
  modes.

Expected: `pass 2 of 2`.

## Differences from `de25_std_testproject`

| | DE25-Standard | DE25-Nano |
|---|---|---|
| device | `A5ED013BB32AE4SCS` | `A5EB013BB23BE4SCS` |
| UART | **no fabric UART** — CP2105 goes to the HPS, so the UART is broken out to `GPIO_D[0]/[1]` for an external 3.3 V adapter | **`FPGA_UART_TX` CJ1 / `FPGA_UART_RX` BR19** on the on-board USB bridge — now carrying the HPS console |
| clock | `CLOCK0_50` CH128, 3.3-V LVCMOS | `CLOCK0_50` DJ35, **1.1-V** (plus `CLOCK1_50` V16 / `CLOCK2_50` BF23, 3.3-V) |
| reset button | `CPU_RESET_n` BM78 | **none** — power-on counter only |
| push-buttons | `KEY[3:0]`, 1.2-V | `KEY[1:0]`, **3.3-V LVCMOS** |
| switches | `SW[9:0]`, 1.2-V | `SW[3:0]`, **1.1-V** |
| LEDs | `LEDR[9:0]`, 1.2-V | **`LED[7:0]`**, **1.1-V** |
| AS config clock | `AS_FREQ_100MHZ` | **`AS_FREQ_125MHZ`** |
| `USE_INIT_DONE` | `SDM_IO13` | *not set* |
| fan | not addressed in that project | **AMC6821 on the HDMI I2C bus**, duty + RPM on registers 9..12 |
| HPS | separate `de25_soc_top` + `linux/` (HPS + DDR4) | **`hps_subsys` instantiated directly in `de25_nano_uart_top`** (HPS + LPDDR4, LWH2F bridge wired) |

Unlike the DE25-Standard, where the HPS lives in a separate `de25_soc`
build, the DE25-Nano's HPS (`hps_subsys`, LPDDR4 instead of DDR4) is
instantiated straight into `de25_nano_uart_top` — one bitstream, one top
level, both the fabric register block and the HPS present together.

## Pinout

| signal | pin | IO standard |
|--------|-----|-------------|
| `CLOCK0_50` | DJ35 | 1.1-V (50 MHz, unused — the fabric runs on the HPS's h2f_user0 clock) |
| `KEY[1:0]` | C8 / C11 | 3.3-V LVCMOS (active low) |
| `SW[3:0]` | DK24 DD24 DD27 DF27 | 1.1-V |
| `LED[7:0]` | DF35 DJ32 DN22 DP23 DN25 DP25 DJ27 DP30 | 1.1-V |
| `FPGA_UART_RX` | BR19 | 3.3-V LVCMOS (HPS UART1 RX, the console) |
| `FPGA_UART_TX` | CJ1 | 3.3-V LVCMOS (HPS UART1 TX, the console) |
| `HDMI_I2C_SCL` | BT1 | 3.3-V LVCMOS (AMC6821 + ADV7513) |
| `HDMI_I2C_SDA` | BW2 | 3.3-V LVCMOS (AMC6821 + ADV7513) |
| `FAN_ALERT_n` | DK32 | 1.1-V (active low) |

Full table + notes: [docs/de25_nano_pinout.md](docs/de25_nano_pinout.md),
fan specifics in [docs/de25_nano_fan.md](docs/de25_nano_fan.md).

## Note

- The DE25-Nano has no reset button, so reset is the power-on counter alone
  and both push-buttons stay readable on register 7. To spend `KEY[0]` on a
  manual reset instead, see `docs/de25_nano_pinout.md`.
- To move to a faster core clock via an IOPLL, see the last sections of
  `docs/de25_nano_pinout.md`.
