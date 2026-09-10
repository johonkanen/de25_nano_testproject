# LWH2F AXI bring-up: what actually fixed the freezes

Handoff for a ~2-day DE25-Nano bug: any register access through the HPS's
LWH2F bridge (`0x20000000`, `axi_lwh2f_bridge` in `de25_nano_uart_top.vhd`)
permanently hung the ARM core — a genuine hardware bus stall (no exception,
unresponsive even to Ctrl-C), reproducible from Linux, U-Boot, and a
from-scratch bare-metal program alike, on the very first access.

## The actual root cause

`build_de25_nano_uart.tcl` (commit `386b2a2`) added two QSF assignments to
fix a *different*, unrelated bug (SPL hanging on its first QSPI-controller
register read during real QSPI cold boot):

```tcl
set_global_assignment -name QSPI_OWNERSHIP HPS
set_global_assignment -name HPS_INITIALIZATION "HPS FIRST"
```

`HPS_INITIALIZATION "HPS FIRST"` lets the ARM cores start executing before
the FPGA fabric is guaranteed to have finished configuring, instead of
strictly after it. Everything downstream of that — `axi_lwh2f_bridge`, the
whole `fpga_interconnect` register file — can still be mid-configuration
(or not yet clocked/stable) when software makes its first LWH2F access,
producing a permanent bus stall with no error path anywhere to report it.

Both assignments were added together, copied from Intel's own reference
design's `.qsf` diff, and were **never tested independently** — so it was
never established that `"HPS FIRST"` specifically (rather than
`QSPI_OWNERSHIP HPS` alone) was what fixed the original QSPI hang.

### The fix

```tcl
set_global_assignment -name QSPI_OWNERSHIP SDM
set_global_assignment -name HPS_INITIALIZATION "AFTER INIT_DONE"
```

Both are actually the Quartus *defaults* for this assignment (not written
explicitly to a `.qsf` unless changed away from them) — confirmed by
probing Quartus's own `set_global_assignment` validation via its Tcl API
(deliberately setting bogus/candidate values and reading the resulting
"illegal value" errors), and cross-checked against Terasic's own GHRD
reference design (`~/dev/de25_nano/Demonstration/SoC_FPGA/GHRD`, visible
in the Quartus GUI's Device & Pin Options dialog, not grep-able in
`golden_top.qsf` for the same "it's the default" reason).

`QSPI_OWNERSHIP HPS` turned out to be unnecessary for this project's own
boot flow specifically: `linux/make_jic.sh`'s `.jic` only embeds the *SPL*
binary as `hps_path` (loaded directly by the SDM's own configuration
engine, never touched by ARM-side software reading QSPI controller
registers) — U-Boot proper, the kernel, dtb, and initramfs all come from
the SD card afterward. `QSPI_OWNERSHIP HPS`'s original motivating case
(commit `386b2a2`) was a genuinely different scenario — FreeRTOS running
entirely from QSPI, with ARM-side software directly driving the Cadence
QSPI controller — which this project's SPL+SD-card hybrid boot never does.

Confirmed on hardware, together, with a real QSPI cold boot
(SPL → ATF → U-Boot → Linux): LWH2F reads/writes, network/ethernet, and
the webapp's HTTP read/write round-trip all work.

## How this was isolated

`hps/baremetal_lwh2f_regs` (no ATF, no U-Boot, no Linux) was hardware-
confirmed passing on 2026-09-09, one commit (`c76f534`) before `386b2a2`
landed. Checked out `c76f534` into a separate `git worktree`, rebuilt the
*exact* original `.sof` + *exact* original bare-metal binary, loaded via
QSPI flash + power-cycle (same method used for every failing test on the
current tree) — it passed cleanly. Since the RTL was byte-for-byte
identical between the two trees, and only the QSF settings differed, this
is a clean A/B that isolates the QSF assignments as the cause.

## Ruled out along the way (real dead ends, don't re-chase these)

All of these were tested on real hardware and made **no difference** to
the freeze:

- **RTL reset wiring**: whether `axi_lwh2f_bridge`'s `resetn` and
  `hps_subsys`'s `lwhps2fpga_axi_reset_reset` are driven by a plain
  `system_reset` power-on counter vs. the HPS's own `h2f_reset` output
  (with or without a synchronizer). The TRM says `h2f_reset` should be
  used, and it's the more correct design, but it was not the cause of
  this particular freeze.
- **Bring-up ordering** in the bare-metal test: NCore CCU window + NoC
  firewall unlock before vs. after the RSTMGR HDSKREQ/HDSKACK
  bridge-enable handshake — identical result either way.
- **`SYSMGR_SOC64_FPGA_CONFIG`'s `EARLY_USERMODE` bit** as a "fabric
  ready" gate — it reads ready (`0x2`) instantly, before the hang, so
  it's not a sufficient readiness signal under `"HPS FIRST"` ordering.
  (Under `"AFTER INIT_DONE"`, this register correctly reads `0x3` — both
  `FPGA_COMPLETE` and `EARLY_USERMODE` — confirming the real difference
  is genuine fabric-configuration completeness, not this specific bit.)
- **The RSTMGR HDSKACK poll timing out** (`iters=0x002DC6C0`, the full
  3,000,000-iteration budget) in the bare-metal test's own bridge-enable
  sequence — looked highly suspicious, but occurs *identically* in both
  the passing (`c76f534`) and failing (pre-fix) trees. Turned out to be a
  pre-existing quirk of the minimal bare-metal bring-up (the real
  ATF-driven boot chain's identical handshake completes without a
  timeout), not a signal of anything wrong.

These ATF-side fixes made during the investigation remain in the boot
chain and are believed to still be necessary (not disproven by the QSF
fix — they were already in place in every build tested, including the
successful ones, so they weren't isolated as *unnecessary* either):
`init_ncore_ccu()` and `enable_nonsecure_access()` ported into BL31 (this
board's boot chain uses U-Boot's own SPL, not ATF's BL2, so these
BL2-only init calls were simply missing), and `is_fpga_config_ready()`
relaxed to accept `EARLY_USERMODE` alone (`FPGA_COMPLETE` never sets on
this board even on a normal working boot).

## Related work built on top of this fix (separate incidents)

Two follow-on changes, done after the core freeze was fixed, on the
now-working baseline:

1. **`h2f_reset` 3-FF synchronizer** (commit `2f2ab09`): re-wired
   `axi_lwh2f_bridge`'s `resetn` and `hps_subsys`'s
   `lwhps2fpga_axi_reset_reset` to the TRM-correct `h2f_reset`-derived
   signal (through an async-assert/sync-release 3-FF chain) instead of
   the unrelated `system_reset` power-on counter. This is a design
   correctness improvement, not a fix for the freeze above — confirmed
   working on the already-fixed baseline.

2. **`core_clock` from `h2f_user0_clock`** (commit `311a1c5`): switched
   the whole fabric design's clock from the `CLOCK0_50` board oscillator
   to the HPS's own free-running `h2f_user0_clock` output. This
   introduced a *new*, separate freeze — the 3-FF synchronizer from (1)
   passed once then hung permanently on the very next LWH2F access under
   this clock. Root-caused to insufficient synchronizer margin: `h2f_reset`
   and `h2f_user0_clock` both originate from the same HPS hard macro, so
   they're not as cleanly asynchronous to each other as `h2f_reset` was
   against the independent `CLOCK0_50` oscillator. Extending the chain
   from 3 to 10 stages (commit `72c21ef`) fixed it — confirmed with 30
   consecutive LWH2F reads across 2 independent boots plus the webapp's
   HTTP round-trip.

## Quick reference for future debugging

If LWH2F (or any HPS↔fabric bridge) freezes again on this or a similar
board:

- Check `HPS_INITIALIZATION` and `QSPI_OWNERSHIP` in the `.qsf` first —
  they're easy to overlook since they're build-system settings, not RTL,
  and their effects (ARM cores racing ahead of fabric readiness) look
  exactly like an RTL/reset bug from the software side.
- `hps/baremetal_lwh2f_regs` is the fastest iteration loop for this class
  of bug — no ATF/U-Boot/Linux boot chain to wait through. See its own
  README.
- A `git worktree` checkout of an old, confirmed-working commit is a
  cheap, high-confidence way to A/B "did my recent changes actually
  cause this, or did something in the build environment change" —
  rebuild the *exact* old bitstream + binary and see if it still passes
  before spending more time on RTL-level hypotheses.
