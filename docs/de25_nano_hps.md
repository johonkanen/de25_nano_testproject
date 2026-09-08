# HPS on the DE25-Nano

`de25_nano_uart_top.vhd` instantiates `hps_min` (see
[hps/README.md](../hps/README.md)): the Agilex 5 hard processor system plus
its LPDDR4 EMIF, generated from the DE25-Nano GHRD's own
`agilex_hps.ip` / `emif_io96b_hps.ip`, with every FPGA↔HPS bridge disabled.

This is a genuine Platform Designer (qsys) system, not a hand-derived pin
configuration — the previous attempt at a from-scratch bare-metal HPS test
(see git history / earlier session notes) got blocked on exactly this: the
HPS's own internal, software-selectable pin-function-select registers were
never configured, so UART1's signal never reached the physical pin, even
though the driver code and clocking were correct. Reusing Terasic's own
`agilex_hps.ip` sidesteps that problem entirely — the pin-mux configuration
is baked into the generated hardware, the same way it is on the vendor's
own working GHRD.

## Why the HPS and the fabric register block don't talk to each other

`hps/disable_bridges.py` zeroes the H2F / LWH2F / F2SDRAM bridge widths and
disables the F2H IRQ. That means:

- The HPS cannot see `de25_nano_uart_top`'s fabric registers (UART/fan
  control, addresses 1–12 over `FPGA_UART_TX/RX`).
- The fabric cannot see HPS memory or peripherals.

The two halves of the design share a die and a board, nothing else. This
was a deliberate choice, matching `de25_std_testproject`'s own `hps_min` —
a UART bring-up test doesn't need HPS↔fabric memory-mapped access, and
disabling the bridges keeps the fabric design exactly as it was before the
HPS was added (same register map, same behaviour, verified unaffected by
resynthesizing with HPS present — see the build log below).

## UART1 → IOB15/IOB16

Confirmed directly from `agilex_hps.ip`'s 48-entry pin-mux selection array
(`REG_pinmux_iomux_sel_array`, one entry per physical HPS I/O pin):

```
index 38 (IOB15): UART1:TX
index 39 (IOB16): UART1:RX
```

The array runs IOA01..24 at indices 0..23, then IOB01..24 at indices
24..47, so `IOB15 = 24 + (15-1) = 38` and `IOB16 = 24 + (16-1) = 39` — this
matches the array positions exactly. `HPS_UART_TX`/`HPS_UART_RX` in
`golden_top.qsf` (PIN_N71 / PIN_AD72) are the physical package pins those
two HPS I/O positions land on for this board.

This `HPS_UART_TX`/`HPS_UART_RX` pair is **independent of** and **different
from** `FPGA_UART_TX`/`FPGA_UART_RX` — the fabric UART register interface
`test_uart.py` talks to. HPS UART1 is only reachable from software running
on the ARM cores; nothing in the fabric register file touches it.

## Simulation

`hps_min` is not simulatable in the VUnit/nvc environment this project uses
(the HPS hard IP has no RTL model here — Altera's own bare-metal flow uses
Simics for that). `vunit_run_de25_nano_test.py` compiles and runs unaffected:
nvc elaborates `u_hps_min` as an unbound black box —

```
** Warning: (init): cannot find entity for component HPS_MIN without binding indication
```

— and continues; the two testbenches never touch its ports, so this is
expected and harmless. All `in` ports on the new HPS/LPDDR4A port block
default to `'0'`/all-zero specifically so the existing testbenches, which
predate the HPS and don't drive those ports, keep elaborating without
change. That default is a simulation-elaboration convenience only — real
hardware always drives every physical pin regardless of it.

## Build status

Synthesizes/fits/times/assembles cleanly as part of `de25_nano_uart_top` —
0 errors at every stage. IO pin count grew from 20 (UART + fan build) to
133 with the HPS + LPDDR4A ports added; the fabric-only register interface
and fan control logic are otherwise unchanged (same source files, same
register map) — verified separately on hardware with the HPS temporarily
removed (see the top-level README).

## HPS UART1: hardware-verified working

[`hps/baremetal_uart1_test/`](baremetal_uart1_test/) is a from-scratch
bare-metal program — no ATF, no U-Boot, no Linux, no SD card, no QSPI
flash — that brings up HPS UART1 and proves it live: a banner plus a
byte-perfect echo test, confirmed on real hardware over `/dev/ttyUSB0`.

Getting there took two pieces of software, both ported from real
Intel/Altera source (not derived or guessed) reading the *same*
SDM-provided handoff blob Quartus already populates from
`agilex_hps.ip`'s configuration:

1. **Pin-mux** — `fsbl_configuration()`, already part of
   `baremetal-drivers`. Confirmed via a live register readback:
   `IOB15 (UART1 TX) pinmux sel = 0x5`, `IOB16 (UART1 RX) pinmux sel = 0x5`.
2. **Clock-manager PLL bring-up** —
   [`clkmgr_bringup.c`](baremetal_uart1_test/clkmgr_bringup.c), ported
   from `arm-trusted-firmware`'s `agilex5_clock_manager.c`. Without this
   the clkmgr stays in "boot mode" (both PLLs bypassed) and UART1
   transmits real, correctly pin-muxed data at the wrong rate — confirmed
   by getting exactly that (structured but garbled output at every baud
   rate tried) before this was added. After it: `measured UART (L4_SP)
   clock = 100000000 Hz`, exactly the design target, and the driver's
   existing hardcoded divisor (54, for 100 MHz → 115200) turns out to
   already be correct once the clock genuinely is 100 MHz.

Notably, Altera's own official real-hardware "hello world" example
(`baremetal-drivers/test/simics/hello-world/printf_hello_world.c`) only
does step 1 — this project's clock-manager port is new ground, not reused
from a working reference.

Full detail, including the driver bug found along the way
(`uart_baud_rate_divisor_set()`'s byte order disagrees with
`uart_init()`'s own use of the same registers), is in
[`hps/baremetal_uart1_test/README.md`](baremetal_uart1_test/README.md).

Not yet done: confirming LPDDR4 calibrates on **this project's own**
generated bitstream specifically (as opposed to Terasic's prebuilt
`golden_top_hps.sof`, which is proven working) — the bare-metal UART1 test
above never touches DDR, so it doesn't exercise that path.

## Prior art this vendors from

`~/dev/de25_nano/Demonstration/SoC_FPGA/GHRD/` — Terasic's own reference
design, confirmed on real hardware in this project's own testing: JTAG-load
`output_files/golden_top_hps.sof` and `/dev/ttyUSB0` (the board's second
on-board USB-serial channel, distinct from `/dev/ttyUSB1` which is
`FPGA_UART_TX/RX`) shows a full boot: U-Boot SPL → LPDDR4 calibration
succeeding → ATF BL31 → U-Boot proper → Linux 6.12 → a working Ubuntu
22.04 console. That confirms the HPS, its LPDDR4 EMIF, and UART1 all work
on this exact board when built the way Terasic ships it (bridges enabled,
stock SD card). `hps_min` here is the same IP, same UART1 pin-mux, with
only the bridges turned off.
