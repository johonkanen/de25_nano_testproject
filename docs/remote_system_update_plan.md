# Plan: Remote System Update (RSU) - new FPGA images from Linux, no hands on the board

Status 2026-10-16: **plan only.** Today a new FPGA image means programming
the QSPI over JTAG and then a power cycle (or a JTAG load of the matching
`_hps_auto.sof`, which also restarts the board). With RSU, Linux writes the
image into a slot in the QSPI over the network and asks the SDM to
reconfigure from it; a bad image falls back to a known-good one by itself.
A full reconfiguration still restarts the HPS (SPL → U-Boot → Linux) -
only partial reconfiguration (docs/partial_reconfiguration_plan.md) keeps
Linux running.

## How RSU works on Agilex 5 (short)

- The QSPI holds a **factory image** and several **application images**,
  each a complete configuration: bitstream + HPS first-stage (SPL).
- The SDM's **decision firmware** (in the flash's boot-info area) picks the
  highest-priority application image that hasn't failed; if none works, the
  factory image. Priorities live in the **CPB** tables, the slot map in the
  **SPT** tables (two copies of each).
- An image counts as failed if configuration fails, or if the HPS watchdog
  expires before software reports success - so a broken image costs one
  automatic fallback, not a dead board.
- Linux talks to the SDM through the kernel's `stratix10-rsu` driver
  (sysfs); Intel's `librsu`/`rsu_client` program slots, set priorities,
  request a reboot into an image and report status.
- The SPL loads U-Boot from the **SSBL partition belonging to the image it
  came from** (`SSBL.<image>`), so each image can carry its own U-Boot.

## What we already have

| piece | status |
|---|---|
| `QSPI_OWNERSHIP HPS` | set - the HPS (SPL, U-Boot, Linux) may access the QSPI |
| U-Boot 2026.04 | `CONFIG_CMD_SOCFPGA_RSU=y`, RSU in the SPL (`rsu_spl.c`) |
| kernel QSPI/MTD drivers | built in (`SPI_CADENCE_QUADSPI`, `MTD_SPI_NOR`) |
| kernel `stratix10-rsu` | built in (2026-10-17); probe fails until the flash has an RSU layout (SDM error 0xc) |
| kernel DT | upstream's QSPI flash node, with the reference clock corrected to 500 MHz: `/dev/mtd0` (16 MB, "u-boot") reads clean |
| web GUI | release upload, test-start, confirm/revert - the model for image uploads |

## Flash layout (16 MB MT25QU128)

| region | size | content |
|---|---|---|
| boot info | 2 MB | SDM firmware, decision firmware, pointers (quartus_pfg) |
| SPT0/SPT1, CPB0/CPB1 | 4 × 32 KB | slot and priority tables |
| FACTORY_IMAGE | 1 MB | known-good bitstream + SPL (today's ~0.75 MB) - never touched by updates |
| SSBL.FACTORY_IMAGE | 1 MB | its U-Boot - also the SD card recovery path (`sd_recover.py`) |
| P1, P2 | 2 × 1 MB | application images |
| SSBL.P1, SSBL.P2 | 2 × 1 MB | their U-Boots |
| free | ~7.8 MB | room for P3, or keep for persona storage |

Every slot is sized from today's image plus margin; a design that grows
past 1 MB means re-laying the flash once (from JTAG).

## Steps

| # | step | done when |
|---|---|---|
| R0 | **Kernel**: `CONFIG_INTEL_STRATIX10_RSU=y`; DE25-Nano DT: enable `&qspi`, add `flash@0` (MT25QU128) with partitions matching the layout; build script applies both (like `CONFIG_SENSORS_SOC64`) | `/proc/mtd` lists the partitions, `/sys/devices/platform/stratix10-rsu.0/` exists, `current_image` reads the running image |
| R1 | **Initial RSU flash image**: `make_jic.sh` gets an RSU mode - a `.pfg` with the factory image, P1, the SSBL partitions and the RSU options (decision firmware, SPT/CPB); program once over JTAG | power-on boots the factory image; U-Boot `rsu list` shows the slots; Linux `rsu_client --log` agrees |
| R2 | **U-Boot from SSBL**: SPL loads U-Boot from the running image's SSBL partition instead of the fixed 0xA00000 (U-Boot's RSU SPL support); SD card first, as now | each image boots its own U-Boot; a blank SD card still reaches U-Boot (factory SSBL) |
| R3 | **Application images**: `quartus_pfg` writes an RSU application `.rpd` from a `.sof`; `tools/make_rsu_bundle.py` wraps it with version, git hash, SHA-256 (like the persona bundles) | a bundle for today's design builds reproducibly |
| R4 | **Userspace**: cross-build `librsu` + `rsu_client` (altera-fpga/intel-rsu) statically for aarch64, ship them in the rootfs; `/etc/librsu.rc` for the layout | from a shell: program P1, request it, reboot into it, read the status |
| R5 | **Boot confirmation**: the web GUI's supervisor reports "image OK" (`rsu notify`) once the GUI answers and LWH2F reads the expected board id - the same idea as the GUI release test; until then the HPS watchdog runs, and an unconfirmed image falls back | a deliberately broken image (wrong LWH2F id, or no GUI) reverts to the previous one with no hands on the board |
| R6 | **API and GUI**: `POST /api/fpga` (bundle upload, token, checks build/SHA), `GET /api/fpga` (slots, running image, last failure); a "FPGA image" card next to "GUI release"; `tools/deploy_fpga.py` like `deploy_web.py` | `deploy_fpga.py` puts a new design on the board, it reboots into it and confirms it; `--no-confirm` shows the automatic fallback |
| R7 | **Docs and tests**: `docs/linux_boot.md` (RSU boot path), fault tests (truncated image, wrong SHA, power cut mid-write, image that never confirms) | all faults leave a booting board |

## Risks and open questions

- **Decision firmware and SPT/CPB generation for Agilex 5 in Quartus
  26.1.1** - R1 is the proof; the GSRD on this machine has no RSU example,
  so the `.pfg` RSU options come from Intel's RSU user guide.
- **SSBL loading from RSU slots in the SPL** - supported by the U-Boot
  RSU code, but this board's SPL has never done it; until R2 works the
  fixed 0xA00000 copy stays.
- **Linux writing the QSPI the SDM boots from**: only the inactive slot is
  written; the factory image and boot info are never touched by an update
  (enforced in the API, not just by convention).
- **HPS watchdog**: U-Boot starts it (30 s); the fallback depends on
  nothing in Linux stopping it before the confirmation - check which
  watchdog the SDM monitors for RSU.
- **Interaction with partial reconfiguration**: personas belong to one
  static image (build id); after an RSU update the stored personas must
  match the image now running - store them per build id, as the PR plan
  says.
- **Interaction with the A76 investigation**: both change the bitstream's
  HPS hand-off; do one at a time.
