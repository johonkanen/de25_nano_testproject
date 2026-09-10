# HPS LWH2F register test

Bare-metal program (no ATF, no U-Boot, no Linux, no SD card) letting a
human, typing over HPS UART1, read/write `de25_nano_uart_top.vhd`'s
`fpga_interconnect` register file through the HPS's LWH2F bridge.

## Status: fixed (2026-09-10)

Passed hardware-confirmed on first attempt (2026-09-09). Commit `386b2a2`
then added `QSPI_OWNERSHIP HPS` + `HPS_INITIALIZATION "HPS FIRST"` to
`build_de25_nano_uart.tcl` (needed to fix a separate QSPI cold-boot hang) —
that let the ARM cores start before the fabric is guaranteed ready, and
broke this test: it hung the CPU permanently (a real bus stall, no
exception) on the very first LWH2F read.

Root-caused via a git-worktree A/B: the exact `c76f534` bitstream + binary
still passed; only those two QSF settings differed. Fixed by switching to
`HPS_INITIALIZATION "AFTER INIT_DONE"` + `QSPI_OWNERSHIP SDM` (both
defaults, and what Terasic's own GHRD reference design uses) — confirmed
working through real Linux userspace, with QSPI cold boot and ethernet
both still working too. See `memory/de25_nano_lwh2f_hps_first_regression.md`
for the full investigation, including two red herrings (RTL reset wiring,
an HDSKACK-poll timeout) and a second regression (ethernet PHY MDIO
attach) hit and fixed along the way.

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

HPS UART1, 115200 8N1 (check the actual device path via
`/dev/serial/by-id/` — it has moved between sessions):

```
r <reg>          read a register, e.g.  r 1        -> reg 00000001 = 0x0000DE25
w <reg> <value>  write a register, e.g. w 3 0x1234  -> wrote 0x00001234 to reg 00000003
?                print help
```

## Build

```
export PATH="$HOME/aarch64-none-elf/bin:$PATH"
cmake -GNinja -B build . -DATF_GIT_TAG=rel_socfpga_v2.10.1_24.11.03_pr
cmake --build build
# generate_bin_file()'s objcopy call resolves to the *system* objcopy, which
# can't read an aarch64 ELF - convert manually:
aarch64-none-elf-objcopy -O binary build/hps_lwh2f_regs.elf build/hps_lwh2f_regs.bin
aarch64-none-elf-objcopy -I binary -O ihex --change-address 0x0 build/hps_lwh2f_regs.bin build/hps_lwh2f_regs.hex
```

## Embed and load

From the repo root, with `output_files/de25_nano_uart.sof` already built:

```
quartus_pfg -c output_files/de25_nano_uart.sof out.jic \
    -o hps_path=hps/baremetal_lwh2f_regs/build/hps_lwh2f_regs.hex \
    -o device=MT25QU128 -o flash_loader=A5EB013BB23BCS -o mode=ASX4
quartus_pgm -c 1 -m jtag -o "pvi;out.jic"
```

Then power-cycle the board. QSPI flash + power-cycle, not direct JTAG
`p;sof` loading, is the reliable method now that QSPI cold boot is in
play — the boot ROM races ahead of a JTAG-only fabric reconfigure before
it can take effect.
