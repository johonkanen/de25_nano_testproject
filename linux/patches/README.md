# ATF/U-Boot patches — kept for reference, not applied

Neither patch here is applied by `build_de25_nano_linux.sh` anymore.
Both are kept only as a record of a real investigation and a real fix
that turned out to be unnecessary once the actual root cause (a
different, FPGA-side setting) was found — see
[docs/de25_nano_lwh2f_bringup.md](../../docs/de25_nano_lwh2f_bringup.md)
for the full story.

## What each patch does

**`arm-trusted-firmware.patch`** — ports two calls into BL31's
`bl31_platform_setup()` that are normally only made from ATF's BL2:

- `init_ncore_ccu()` — programs the NCore CCU crossbar's LWSOC2FPGA
  routing window, so the ARM cores' AXI masters have a route to the
  LWH2F bridge at all.
- `enable_nonsecure_access()` — unlocks the dedicated LWSOC2FPGA bridge
  firewall for non-secure (EL0) access, so Linux userspace accesses
  aren't silently dropped.

This board's boot chain uses U-Boot's own SPL instead of ATF's BL2,
which is why neither call ever runs without this patch.

**`u-boot-socfpga.patch`** — relaxes `is_fpga_config_ready()`
(`arch/arm/mach-socfpga/misc_soc64.c`) to accept
`SYSMGR_SOC64_FPGA_CONFIG`'s `EARLY_USERMODE` bit alone, instead of
upstream's default requirement that both `FPGA_COMPLETE` and
`EARLY_USERMODE` be set. Without this, `bridge enable` (and hence any
LWH2F access) fails forever with "FPGA not ready. Bridge reset
aborted!" — under the *old*, wrong `HPS_INITIALIZATION "HPS FIRST"`
setting this project used at the time, `FPGA_COMPLETE` genuinely never
set.

## Why they're not applied

All three fixes (the two here, plus `agilex5_ddr.c`'s `config_ddr_size`
fix, which *is* still applied — a `sed` in the build script — for an
unrelated 1GB-vs-2GB DDR bug) were found while chasing a permanent
LWH2F-bridge freeze. The *actual* root cause turned out to be
`build_de25_nano_uart.tcl`'s `HPS_INITIALIZATION "HPS FIRST"` +
`QSPI_OWNERSHIP HPS` QSF settings, which let the ARM cores start
executing before the FPGA fabric was guaranteed fully configured — not
anything these two patches address directly. Once that was corrected
to `HPS_INITIALIZATION "AFTER INIT_DONE"` + `QSPI_OWNERSHIP SDM`,
confirmed on hardware (2026-09-10) that reverting *both* of these
patches — rebuilding BL31 and U-Boot SPL from pristine upstream
sources, keeping only the DDR fix — still boots cleanly and LWH2F still
works: 10/10 consecutive register reads plus a write/readback
round-trip, reproduced across two independent power cycles.

Likely explanation: under `"AFTER INIT_DONE"`,
`SYSMGR_SOC64_FPGA_CONFIG` genuinely reads `0x3` (both `FPGA_COMPLETE`
and `EARLY_USERMODE` set) by the time HPS starts, rather than the
`0x2`-only value seen under `"HPS FIRST"` — the SDM has already
finished its own hardware bring-up, including whatever it does for
NCore CCU routing and the LWSOC2FPGA firewall, before the ARM cores
ever get a chance to race ahead of it. The BL2-only init calls these
patches port into BL31 were most likely compensating for that race,
not fixing an unconditional hardware requirement.

## If LWH2F breaks again

If a future change reintroduces this class of symptom (LWH2F/HPS
bridge access permanently hangs the CPU with no exception), these
patches are a reasonable first thing to try re-applying via `git apply
patches/<name>.patch` inside the relevant checkout — but check
`HPS_INITIALIZATION`/`QSPI_OWNERSHIP` in `de25_nano_uart.qsf` first;
that's the much more likely culprit based on this project's actual
history.
