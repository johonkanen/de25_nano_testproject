# de25_nano_testproject — UART bring-up build

Minimal Quartus Prime Pro build for the **Terasic DE25-Nano**
(Agilex 5 `A5EB013BB23BE4SCS`), structured like
[`johonkanen/axc3000_test`](https://github.com/johonkanen/axc3000_test) and
its sibling `de25_std_testproject`.

Scope: a UART + `fpga_interconnect` register block plus fan control, running
straight off the 50 MHz board oscillator. No PLL, no DSP, no processors —
just enough to prove the toolchain, the pins, the serial register interface
and the board's fan controller work on a fresh board.

Unlike the DE25-Standard, the DE25-Nano has a **dedicated FPGA-fabric UART
wired to the board's own USB serial bridge**, so there are no jumper wires
and no external adapter: plug in the USB cable and talk to the registers.

## Sources

`source/` holds two submodules and three vendored files:

| path | origin |
|------|--------|
| `source/hVHDL_uart` | `hVHDL/hVHDL_uart` |
| `source/hVHDL_fpga_interconnect` | `hVHDL/hVHDL_fpga_interconnect` |
| `source/fpga_communication/*.vhd` | vendored from `johonkanen/fpga_communication` |
| `source/fan_control/*.vhd` | written here — I2C master + AMC6821 fan controller |

The vendored `communications.vhd` has one local change from upstream: the
two UART config signals are given initial values so `number_of_clocks_per_bit`
is never 0 on the first clock edge (see the comment in the file).

## Build (run from this directory)

```
git submodule update --init
./write_githash.sh                       # stamp git_hash_pkg.vhd (optional)
quartus_sh  -t build_de25_nano_uart.tcl
quartus_syn de25_nano_uart
quartus_fit de25_nano_uart
quartus_sta de25_nano_uart
quartus_asm de25_nano_uart
```

The `.tcl` writes `de25_nano_uart.qpf` / `de25_nano_uart.qsf` (both
git-ignored) and sets every device / pin / config-scheme assignment.

**Verified end to end through `quartus_asm` with Quartus Prime Pro 26.1.0**
(the DE25-Nano demos themselves ship for 25.1), with the HPS (`hps_min`,
see [HPS](#hps)) present. Results:

| stage | result |
|---|---|
| `quartus_syn` | 0 errors, 1 warning (Critical Warning 20759, see [Note](#note)) |
| `quartus_fit` | 0 errors — 133 pins placed, 639 / 46,800 ALMs (1 %), HSSI HPS 1/1 |
| `quartus_sta` | fully constrained; worst-case setup slack **+17.098 ns**, hold **+0.096 ns** |
| `quartus_asm` | 0 errors, 0 warnings → `output_files/de25_nano_uart.sof` |

The fabric register interface (UART + fan control, unaffected by the HPS —
same register map) has been repeatedly loaded and exercised on real
hardware; see [Talk to it](#talk-to-it) and [Fan](#fan). Quartus refuses to
program an HPS-inclusive `.sof` at all until an HPS boot payload is
embedded (confirmed directly: `quartus_pgm` errors "HPS is present but
bootloader information is missing" otherwise), so that requires one extra
step — embed the [`hps/baremetal_uart1_test`](hps/baremetal_uart1_test/)
program via `quartus_pfg -o hps_path=...` — documented in
[docs/de25_nano_hps.md](docs/de25_nano_hps.md).

**This exact HPS-inclusive `.sof` (this build, this bitstream) has now been
loaded onto hardware and verified end to end**, both halves at once:
HPS UART1's bare-metal test banners and byte-echoes correctly over
`/dev/ttyUSB0` (see [HPS](#hps)), and the fabric register interface still
passes **20/20** over `/dev/ttyUSB1` via `test_uart.py` — including the fan
controller — confirming the HPS and the fabric register block coexist
correctly on one bitstream, not just individually.

## Program (volatile JTAG load)

On-board **Intel FPGA Download Cable II** (USB-Blaster II).

```
quartus_pgm -c 1 -m jtag -o "p;output_files/de25_nano_uart.sof@1"
```

`@1` is the FPGA's position in the JTAG chain — run `jtagconfig` to confirm
(the Agilex 5 SoC puts the SDM in the chain; Terasic's own `demo_batch`
scripts omit the index entirely). Use the cable **index** (`-c 1`), not a
name.

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
`jtagconfig`, `quartus_pgm`):

```
./program.sh                            # flash output_files/de25_nano_uart.sof
./program.sh path/to/other.sof          # flash a specific file
./program.sh --check                    # set up + jtagconfig, don't flash
sudo ./program.sh --install-udev        # once: persistent 0666 rule
```

`QUARTUS_BIN=`, `CABLE=` and `DEVICE=` env vars override the tool path,
cable index and JTAG device index. Forward the board's **USB serial**
interface into WSL too if you want to run `test_uart.py` from there.

## Talk to it

The UART **is** the on-board USB port — `FPGA_UART_TX` / `FPGA_UART_RX` are
FPGA-fabric pins wired to the board's USB serial bridge. No adapter, no
jumper wires. Find the `/dev/ttyUSB*` it enumerates as and run:

```
python test_uart.py [/dev/ttyUSB0] [115200]
```

50 MHz / `g_clock_divider` (434) = 115207 baud, 32-bit data words.
`test_uart.py` is self-contained (`pip install pyserial`) and exercises every
register. Exit status 0 = all passed.

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

`LED[7]` is a ~1 Hz heartbeat so the board shows life with nothing attached.

If the link doesn't come up, sanity-check the cable and terminal with
Terasic's prebuilt UART loopback demo
(`~/dev/de25_nano/Demonstration/FPGA/UART/demo_batch/golden_top.sof`): hold
`KEY[0]` and anything you type should echo back.

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

```
python test_uart.py --fan-sweep     # drive the fan up, check RPM rises, restore minimum
```

Two things worth knowing: the AMC6821's own **thermal fail-safe is left
enabled**, so the chip forces the fan to 100 % on over-temperature whatever
the duty register says — but there is no temperature-driven fan curve in the
FPGA, register 9 just holds what it was given. Details, the register-by-
register configuration and how to trim the minimum are in
[docs/de25_nano_fan.md](docs/de25_nano_fan.md).

## HPS

`de25_nano_uart_top.vhd` also instantiates `hps_min` (see
[hps/README.md](hps/README.md)): the Agilex 5 hard processor system plus
its LPDDR4 EMIF, generated from the DE25-Nano GHRD's own `agilex_hps.ip` /
`emif_io96b_hps.ip` with every FPGA↔HPS bridge disabled. It shares the die
and the pins with the fabric register block above but is otherwise
independent — no memory-mapped path between the two, so nothing in the
register map above changed by adding it.

`HPS_UART_TX`/`HPS_UART_RX` are HPS UART1, on IOB15/IOB16 in the HPS's own
pin-mux table — confirmed directly from `agilex_hps.ip`'s pin-mux array,
not hand-derived. This is a **second, independent** UART from
`FPGA_UART_TX`/`FPGA_UART_RX` above: reachable only from software running
on the HPS ARM cores, never from the `test_uart.py` register interface.

Synthesizes/fits/times cleanly as part of this same build (see the table
above). **HPS UART1 is confirmed working on real hardware** — a
from-scratch bare-metal program ([hps/baremetal_uart1_test/](hps/baremetal_uart1_test/),
no ATF, no U-Boot, no Linux, no SD card) brings up pin-mux and clock-manager
PLLs from the same SDM-provided handoff data Quartus already computes, then
banners and byte-perfect echoes over `/dev/ttyUSB0`:

```
=== de25_nano_testproject HPS bare-metal UART1 test (v3) ===
IOB15 (UART1 TX) pinmux sel = 0x00000005
IOB16 (UART1 RX) pinmux sel = 0x00000005
clkmgr_bringup() rc = 0x00000000
measured UART (L4_SP) clock = 100000000 Hz
divisor programmed = 54
```

Confirmed on **this project's own generated `de25_nano_uart.sof`** (HPS
boot payload embedded via `quartus_pfg -o hps_path=...`, see [Build](#build)
above) — running at the same time as, and without disturbing, the fabric
register interface on `FPGA_UART_TX`/`FPGA_UART_RX`.

Full detail — including the clock-manager PLL bring-up ported from
`arm-trusted-firmware` (Altera's own official bare-metal example doesn't do
this step, so it wasn't reused from a working reference) and a UART driver
byte-order bug found along the way — is in
[docs/de25_nano_hps.md](docs/de25_nano_hps.md).

## Simulate

Two [VUnit](https://vunit.github.io/) testbenches, both run by
`vunit_run_de25_nano_test.py`. Needs `nvc` ≥ 1.14
([nickg/nvc](https://github.com/nickg/nvc)) on `PATH` and
`pip install vunit_hdl`:

```
python3 vunit_run_de25_nano_test.py          # run everything
python3 vunit_run_de25_nano_test.py -v       # verbose
python3 vunit_run_de25_nano_test.py --list   # list test cases
```

- `de25_nano_uart_top_tb` drives the real UART pins of `de25_nano_uart_top`
  and checks every register response. An `amc6821_model` hangs off the I2C
  pins, so the fan registers are exercised end to end — a UART write to
  register 9 is checked to actually land in the model's DCY register.
- `fan_control_tb` points `amc6821_fan_control` at the same model on its own
  and checks the configuration it writes, the startup kick, the settle to
  minimum, the RPM conversion, and that an unacknowledged write raises
  `i2c_error`, releases the bus rather than wedging it, and recovers.

Expected: `pass 2 of 2` — 16 checks in `de25_nano_uart_top_tb`, 21 in
`fan_control_tb` (verified with VUnit 4.7.0 / nvc 1.18.2).

## Differences from `de25_std_testproject`

| | DE25-Standard | DE25-Nano |
|---|---|---|
| device | `A5ED013BB32AE4SCS` | `A5EB013BB23BE4SCS` |
| UART | **no fabric UART** — CP2105 goes to the HPS, so the UART is broken out to `GPIO_D[0]/[1]` for an external 3.3 V adapter | **`FPGA_UART_TX` CJ1 / `FPGA_UART_RX` BR19** on the on-board USB bridge |
| clock | `CLOCK0_50` CH128, 3.3-V LVCMOS | `CLOCK0_50` DJ35, **1.1-V** (plus `CLOCK1_50` V16 / `CLOCK2_50` BF23, 3.3-V) |
| reset button | `CPU_RESET_n` BM78 | **none** — power-on counter only |
| push-buttons | `KEY[3:0]`, 1.2-V | `KEY[1:0]`, **3.3-V LVCMOS** |
| switches | `SW[9:0]`, 1.2-V | `SW[3:0]`, **1.1-V** |
| LEDs | `LEDR[9:0]`, 1.2-V | **`LED[7:0]`**, **1.1-V** |
| AS config clock | `AS_FREQ_100MHZ` | **`AS_FREQ_125MHZ`** |
| `USE_INIT_DONE` | `SDM_IO13` | *not set* |
| fan | not addressed in that project | **AMC6821 on the HDMI I2C bus**, duty + RPM on registers 9..12 |
| HPS | separate `de25_soc_top` + `linux/` (HPS + DDR4) | **`hps_min` instantiated directly in `de25_nano_uart_top`** (HPS + LPDDR4, bridges disabled) — see below |

Unlike the DE25-Standard, where the HPS lives in a separate `de25_soc`
build, the DE25-Nano's HPS (`hps_min`, LPDDR4 instead of DDR4) is
instantiated straight into `de25_nano_uart_top` — one bitstream, one top
level, both the fabric register block and the HPS present together. See
[HPS](#hps) below.

## Pinout

| signal | pin | IO standard |
|--------|-----|-------------|
| `CLOCK0_50` | DJ35 | 1.1-V (50 MHz) |
| `KEY[1:0]` | C8 / C11 | 3.3-V LVCMOS (active low) |
| `SW[3:0]` | DK24 DD24 DD27 DF27 | 1.1-V |
| `LED[7:0]` | DF35 DJ32 DN22 DP23 DN25 DP25 DJ27 DP30 | 1.1-V |
| `FPGA_UART_RX` | BR19 | 3.3-V LVCMOS |
| `FPGA_UART_TX` | CJ1 | 3.3-V LVCMOS |
| `HDMI_I2C_SCL` | BT1 | 3.3-V LVCMOS (AMC6821 + ADV7513) |
| `HDMI_I2C_SDA` | BW2 | 3.3-V LVCMOS (AMC6821 + ADV7513) |
| `FAN_ALERT_n` | DK32 | 1.1-V (active low) |

Full table + notes: [docs/de25_nano_pinout.md](docs/de25_nano_pinout.md),
fan specifics in [docs/de25_nano_fan.md](docs/de25_nano_fan.md).

## Note

- Critical Warning 20759 (missing Reset Release IP) is expected, exactly as
  in `axc3000_test` and `de25_std_testproject`. Startup is covered here by a
  ~21 ms power-on-reset counter (`g_por_cycles`); add the **Reset Release
  IP** (`ninit_done`) for a production build — the Nano demos have
  ready-made ones for this device at
  `Demonstration/FPGA/LPDDR4_Test_NiosV/reset_release.ip` and
  `Demonstration/FPGA/RTL_LPDDR4_AXI4_Test/agilex_reset_release.ip`.
- The DE25-Nano has no reset button, so reset is the power-on counter alone
  and both push-buttons stay readable on register 7. To spend `KEY[0]` on a
  manual reset instead, see `docs/de25_nano_pinout.md`.
- To move to a faster core clock via an IOPLL, see the last sections of
  `docs/de25_nano_pinout.md`.
