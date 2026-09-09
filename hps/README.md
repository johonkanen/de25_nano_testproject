# hps/ — Agilex 5 HPS + HPS-EMIF for the DE25-Nano

A Platform Designer system, `hps/hps_subsys.qsys`, instantiated directly as
a VHDL `component` in `de25_nano_uart_top.vhd` — the Agilex 5 hard
processor system plus its LPDDR4 EMIF. Same pattern as
[`de25_std_testproject/hps/`](https://github.com/johonkanen/de25_std_testproject/tree/main/hps)
(DDR4 there, LPDDR4 here; `hps_subsystem.qsys` there, `hps_subsys.qsys`
here) — see that project's `hps/README.md` for more background on the
approach.

## What's vendored

| file | origin (DE25-Nano GHRD `Demonstration/SoC_FPGA/GHRD/`) |
|------|----------------------------------------------------------|
| `ip/hps_subsys/agilex_hps.ip` | `hps_subsys/ip/hps_subsys/agilex_hps.ip`, vendored |
| `ip/qsys_top/emif_io96b_hps.ip` | `hps_subsys/ip/qsys_top/emif_io96b_hps.ip`, verbatim |
| `hps_pins.tcl` | the 196 `HPS_*` / `LPDDR4A_*` pin + IO-standard lines from `golden_top.qsf` |

`agilex_hps.ip` keeps the GHRD's DE25-Nano pin mux — EMAC0 (RGMII + MDIO),
SD/MMC 4-bit, **UART1 on IOB15/IOB16** (`HPS_UART_TX`/`HPS_UART_RX`), USB0,
I2C1, plus four GPIOs (gsensor interrupt/enable, `HPS_KEY`, `HPS_LED`).
Confirmed directly from `agilex_hps.ip`'s 48-entry pinmux-select array:
index 38 (`IOB15`) = `UART1:TX`, index 39 (`IOB16`) = `UART1:RX` — the array
is IOA01..24 at indices 0..23, IOB01..24 at indices 24..47, so `IOB15` =
24 + (15−1) = 38.

## Bridges

| bridge | state |
|---|---|
| `H2F` (128-bit) | disabled |
| `LWH2F` (32-bit, lightweight) | **enabled**, exported as `lwhps2fpga` — wired into `de25_nano_uart_top.vhd`'s fabric register file via `axi_lwh2f_bridge.vhd`, **hardware-confirmed working** (see [`baremetal_lwh2f_regs/README.md`](baremetal_lwh2f_regs/README.md)) |
| `F2SDRAM` | disabled |
| F2H interrupts | enabled, exported as `f2h_irq0_in`/`f2h_irq1_in`, tied to `0` (unused) |

This means this design **cannot use the stock Terasic GHRD Linux SD
image** — that image's device tree assumes a different bridge/pin-mux
configuration than this one. Boot with your own device tree and your own
U-Boot SPL handoff (see
[`de25_std_testproject/linux/`](https://github.com/johonkanen/de25_std_testproject/tree/main/linux)
for how that project did it — nothing here yet).

## Regenerating

Nothing to run by hand for a normal build: `build_de25_nano_uart.tcl` sets
`PROJECT_IP_REGENERATION_POLICY ALWAYS_REGENERATE_IP`, so `quartus_syn`
regenerates `hps_subsys` itself from the `QSYS_FILE`/`IP_FILE`
assignments. To inspect the generated component port list (e.g. after
re-vendoring or changing an `.ip` parameter), run once:

```
cd hps
qsys-generate hps_subsys.qsys --synthesis=VHDL --part=A5EB013BB23BE4SCS --search-path='ip/hps_subsys,$'
```
which writes `hps_subsys/hps_subsys_inst.vhd` — the source for the
`component hps_subsys` declaration in `de25_nano_uart_top.vhd`. Generated
trees (`hps_subsys/`, `ip/hps_subsys/agilex_hps/`, etc.) are git-ignored;
only the `.qsys` and `.ip` files are tracked.

Editing an instance's *parameters* (e.g. bridge widths, or the H2F User0
clock — see de25_std_testproject's own `hps/README.md` for a real
tooling limitation hit doing exactly this there) requires editing the
`.ip` file directly, not `hps_subsys.qsys` — the same "Generic Component"
caveats documented in that project's `hps/README.md` apply here too, since
this uses the same underlying HPS IP.

## Talking to HPS UART1

`HPS_UART_TX`/`HPS_UART_RX` are a **second, independent** UART from this
project's `FPGA_UART_TX`/`FPGA_UART_RX` (the fabric register interface
`test_uart.py` talks to) — HPS UART1 is reachable only from software
running on the ARM cores (bare-metal or Linux), never from the UART
register interface. See [docs/de25_nano_hps.md](../docs/de25_nano_hps.md)
for how to actually get software running on the HPS to talk on it, and
[`baremetal_lwh2f_regs/`](baremetal_lwh2f_regs/) for reaching the same
fabric register file over LWH2F instead, from the ARM cores directly.

## H2F User0 clock (HPS-generated free-running clock to fabric) - .ip ready, one GUI step left

`User0_clk_enable`/`User0_clk_freq` in `ip/hps_subsys/agilex_hps.ip` are
set to `true`/`50.0` MHz - the same HPS-generated, board-oscillator-
independent free-running clock feature de25_std_testproject wired up (see
that project's own `hps/README.md` "H2F User0 clock" section for the full
account, including a gotcha worth reading before touching the GUI: it's
easy to enable the similarly-named but opposite-direction "Enable
FPGA-to-HPS Free Clock" by mistake instead).

Confirmed headlessly (safe, done): regenerating `agilex_hps.ip` directly
produces a real `h2f_user0_clk_clk` port on that sub-component, and the
whole project still synthesizes clean (0 errors, 0 warnings) with this
change in place - inert, since `hps_subsys.qsys` doesn't see the new
interface yet.

**What's left needs the Platform Designer GUI** (a real tooling
limitation, not a preference - see de25_std_testproject's own
`hps/README.md` for why `intel_agilex_5_soc`/`agilex_hps`'s "Generic
Component" wrapper can't be refreshed headlessly): open
`hps_subsys.qsys`, let it re-import `agilex_hps.ip`, export the new
`h2f_user0_clk` interface at the system level (same way `lwhps2fpga`
etc. already are), save. Then wire the new `h2f_user0_clock_clk` port
into `de25_nano_uart_top.vhd` - an isolated test module
(`h2f_user0_clk_heartbeat.vhd`, ported from de25_std_testproject) driving
a spare pin, not the register file, exactly as done there.

## Status

✅ Hardware-confirmed, both interfaces: HPS UART1 (bare-metal, see
[docs/de25_nano_hps.md](../docs/de25_nano_hps.md)) and LWH2F (see
[`baremetal_lwh2f_regs/README.md`](baremetal_lwh2f_regs/README.md)), plus
the fabric register interface's own `test_uart.py` suite, all confirmed
working simultaneously on the same HPS-inclusive bitstream. LPDDR4
calibration on this project's own generated bitstream specifically is
still unconfirmed (nothing here exercises the DDR path yet) — see the
top-level README.
