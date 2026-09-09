# HPS LWH2F register test

A bare-metal program letting a human, typing over HPS UART1, read and write
the `fpga_interconnect` register file (`de25_nano_uart_top.vhd`) through the
HPS's lightweight HPS-to-FPGA bridge (LWH2F / `lwhps2fpga`) — the same
registers the fabric UART already reaches — poked from the ARM cores as
plain memory-mapped I/O instead. Same bring-up approach as
[`../baremetal_uart1_test`](../baremetal_uart1_test) — **no ATF, no
U-Boot, no Linux, no SD card**.

## ✅ Hardware-confirmed working, first attempt (2026-09-09)

Unlike [`de25_std_testproject`'s equivalent
test](https://github.com/johonkanen/de25_std_testproject/tree/main/hps/baremetal_lwh2f_regs)
— which took a very long investigation (a fabric RTL reset-polarity bug,
plus a missing Ncore CCU crossbar routing window) — this board worked on
the very first try, applying both of that project's fixes from the start
rather than rediscovering them:

```
self-test: register 1 (id) = 0x0000DE25  -> PASS
> w 3 0xcafef00d
wrote 0xCAFEF00D to reg 00000003
> r 3
reg 00000003 = 0xCAFEF00D
> r 9
reg 00000009 = 0x0000001E
```

Why it worked immediately here: `de25_nano_uart_top.vhd`'s
`lwhps2fpga_axi_reset_reset => system_reset` wiring was already correct
(direct, no inversion) *before* this test was written — checked first,
specifically because of what de25_std_testproject hit. The Ncore CCU
routing-window fix (`ncore_program_lwsoc2fpga_window()` in
`hps_lwh2f_regs.c`) is a die-level Agilex 5 fix, not board-specific, so it
was expected to be needed here too, and was included from the start.

## Register map

| addr | meaning | access |
|-----:|---------|--------|
| 1 | constant id `0x0000DE25` | RO |
| 2 | git hash | RO |
| 3 | loopback register | R/W |
| 4 | read-strobe counter (++ per read) | RO |
| 5 | LED register | R/W |
| 6 | `SW` slide switches | RO |
| 7 | `KEY` push-buttons | RO |
| 8 | uptime counter | RO |
| 9 | fan duty setpoint | R/W |
| 10 | fan RPM | RO |
| 11 | fan tach (raw) | RO |
| 12 | fan status word | RO |

## Console

Same as [`../baremetal_uart1_test`](../baremetal_uart1_test) - HPS UART1,
115200 8N1:

```
r <reg>          read a register, e.g.  r 1        -> reg 00000001 = 0x0000DE25
w <reg> <value>  write a register, e.g. w 3 0x1234  -> wrote 0x00001234 to reg 00000003
?                print help
```

## Build

```
export PATH="$HOME/aarch64-none-elf/bin:$PATH"   # or wherever it was extracted
cmake -GNinja -B build . -DATF_GIT_TAG=rel_socfpga_v2.10.1_24.11.03_pr
cmake --build build
# objcopy in generate_bin_file() resolves to the *system* objcopy - convert
# manually (same toolchain quirk as baremetal_uart1_test):
aarch64-none-elf-objcopy -O binary build/hps_lwh2f_regs.elf build/hps_lwh2f_regs.bin
aarch64-none-elf-objcopy -I binary -O ihex --change-address 0x0 build/hps_lwh2f_regs.bin build/hps_lwh2f_regs.hex
```

## Embed and load

Run from the repo root (`output_files/de25_nano_uart.sof` needs the
LWH2F-wired `de25_nano_uart` project built first):

```
quartus_pfg -c output_files/de25_nano_uart.sof out.sof -o hps_path=hps/baremetal_lwh2f_regs/build/hps_lwh2f_regs.hex
quartus_pgm -c 1 -m jtag -o "p;out.sof"    # cable index depends on what else is attached
```

`/dev/ttyUSB0` was this session's HPS-UART1 device path (the
`if02-port0` entry under `/dev/serial/by-id/usb-TERASIC_DE25-Nano_*`) -
check yours the same way `baremetal_uart1_test/README.md` does.
