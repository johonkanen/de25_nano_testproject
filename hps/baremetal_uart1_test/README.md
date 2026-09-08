# HPS UART1 bare-metal test

A minimal, from-scratch bare-metal program proving HPS UART1
(`HPS_UART_TX`/`HPS_UART_RX`, IOB15/IOB16) works, with **no ATF, no
U-Boot, no Linux, no SD card, no QSPI flash** — it runs straight out of
HPS OCRAM as the very first and only thing the ARM cores execute.

**Hardware-verified working**, DE25-Nano, `de25_nano_uart_top`'s `hps_min`:

```
=== de25_nano_testproject HPS bare-metal UART1 test (v3) ===
no ATF, no U-Boot, no Linux - running straight out of HPS OCRAM
fsbl_configuration() rc = 0x00000000
handoff header_magic = 0x424F4F54
IOB15 (UART1 TX) pinmux sel = 0x00000005
IOB16 (UART1 RX) pinmux sel = 0x00000005
clkmgr_bringup() rc = 0x00000000
measured UART (L4_SP) clock = 100000000 Hz
divisor programmed = 54
type anything: it echoes back
```

Plus a live echo test: bytes sent from the host over `/dev/ttyUSB0` come
back byte-for-byte identical.

## What it took

Two things had to be brought up in software before UART1 would produce
anything but noise — both ported from real, tested Intel/Altera source
rather than derived or guessed (see file headers for exact provenance):

1. **Pin-mux** (`fsbl_configuration()`, already part of
   `altera-fpga/baremetal-drivers`' `alterametal` library). Without it,
   nothing at all reaches the physical pins.
2. **Clock-manager PLL bring-up** ([`clkmgr_bringup.c`](clkmgr_bringup.c),
   ported from `altera-fpga/arm-trusted-firmware`'s
   `agilex5_clock_manager.c`). Without it, UART1 is correctly wired but
   transmits at the wrong rate — the clkmgr sits in "boot mode" out of
   reset with both PLLs fully bypassed, so `uart_init()`'s baud divisor
   (hardcoded assuming a 100 MHz clock) is wrong until something brings
   the PLLs up for real.

Both read the *same* SDM-provided handoff blob (a fixed OCRAM address,
`PLAT_HANDOFF_OFFSET`) that Quartus populates automatically from
`hps/ip/hps_subsys/agilex_hps.ip`'s configuration — no register value in
either file is derived or guessed; they're all read straight out of what
Quartus already computed for this exact hardware.

Notably: **Altera's own official real-hardware "hello world"
reference** (`test/simics/hello-world/printf_hello_world.c` in
baremetal-drivers, the file their own getting-started guide has you build
for JTAG+QSPI loading) only does step 1, not step 2 — this project's
`clkmgr_bringup.c` is not something reused from an existing example.

## A driver bug found along the way

`uart_baud_rate_divisor_set()` (`src/uart/uart_internal.c` in
baremetal-drivers) writes the divisor's low byte to `IER` and high byte to
`RBR` — the opposite of what `uart_init()` itself does on the exact same
two registers (`RBR` is DLL/low at offset 0x00, `IER` is DLLM/high at
offset 0x04 - standard 16550 layout). `hps_uart1_test.c` reprograms the
divisor directly (`uart_set_divisor()`), bypassing that IOCTL, rather than
compensating for a byte-order bug in someone else's driver.

## Build

```
export PATH=<path-to>/gcc-arm/bin:$PATH        # aarch64-none-elf-*, ARM GNU Toolchain 13.2.Rel1
cmake -GNinja -B build .
cmake --build build
# objcopy in generate_bin_file() resolves to the *system* objcopy due to a
# CMake variable-scoping quirk in baremetal-drivers' target_aarch64.cmake -
# convert manually instead:
aarch64-none-elf-objcopy -O binary build/hps_uart1_test.elf build/hps_uart1_test.bin
aarch64-none-elf-objcopy -I binary -O ihex --change-address 0x0 build/hps_uart1_test.bin build/hps_uart1_test.hex
```

Needs `github.com/altera-fpga/baremetal-drivers` (tag
`QPDS25.1_REL_GSRD_PR`) checked out as a sibling directory (this
`CMakeLists.txt`'s `FetchContent_Declare(esw_bare SOURCE_DIR ...)` points
at `../../baremetal-drivers` - adjust the path, or `git clone` it there).

## Embed and load

```
quartus_pfg -c output_files/de25_nano_uart.sof out.sof -o hps_path=build/hps_uart1_test.hex
quartus_pgm -c 1 -m jtag -o "p;out.sof@1"
python3 -c "
import serial, time
s = serial.Serial('/dev/ttyUSB0', 115200, timeout=1)
time.sleep(0.3)
print(s.read(500).decode(errors='replace'))
"
```

`/dev/ttyUSB0` is the board's second on-board USB-serial channel (distinct
from `/dev/ttyUSB1`, which is `FPGA_UART_TX/RX` - the fabric register
interface `test_uart.py` talks to).

Same volatile-JTAG-load category as every other `.sof` in this project -
nothing persistent, nothing touches QSPI flash or an SD card.
