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

## Flash layout (16 MB MT25QU128) - as programmed 2026-10-17 (R1)

| region | address | content |
|---|---|---|
| BOOT_INFO | 0x000000-0x20FFFF | SDM firmware, decision firmware (RSU mode makes it 0x210000 long) |
| FACTORY_IMAGE | 0x220000-0x31FFFF | phase 1 + SPL, 1 MB (0xCD000 used) - never touched by updates |
| SPT0, SPT1 | 0x320000, 0x328000 | sub-partition tables, 32 KB each |
| CPB0, CPB1 | 0x330000, 0x338000 | CMF pointer blocks (slot priorities), 32 KB each |
| P1 | 0x400000-0x4FFFFF | application image, 1 MB (priority 1) |
| SSBL.FACTORY_IM | 0x500000-0x5FFFFF | the factory image's u-boot.itb (R2; SPT names are 16 characters at most) |
| SSBL.P1 | 0x600000-0x6FFFFF | P1's u-boot.itb (R2) |
| free | 0x700000-0x9FFFFF | P2 + SSBL.P2 later |
| UBOOT | 0xA00000-0xAFFFFF | u-boot.itb, the SPL's fallback when the card has none (as before RSU) |
| CORE.FACTORY_IM | 0xC00000-0xD0FFFF | the factory image's FPGA core (R3b; where U-Boots without `rsu running_slot` look) |
| CORE.P1 | 0xD10000-0xE1FFFF | P1's FPGA core (R3b) |

`make_jic.sh` writes it (RSU=1, the default; RSU=0 the plain layout). It
needs fixed partition addresses: with "auto", quartus_pfg 26.1.1 stops
with an internal error. U-Boot's `rsu list` shows UBOOT and CORE in the
SPT too, under their names.

Every slot is sized from today's image plus margin; a design that grows
past 1 MB means re-laying the flash once (from JTAG).

## The update bundle (R3)

```bash
./linux/make_jic.sh                          # RSU layout, and the application image de25_nano_app.rpd
python3 linux/tools/make_rsu_bundle.py       # build_output/de25_nano_rsu_<build>.tar.gz
python3 linux/tools/make_rsu_bundle.py --check BUNDLE
```

A bundle holds everything one slot needs, from one build: `app.rpd`
(phase 1 + SPL, start address 0, bitswapped), `u-boot.itb`,
`de25_nano.core.rbf` and its manifest, plus `rsu.json` (build id,
periphery hash, git, size and SHA-256 of each file). It is reproducible:
the same inputs give the same bytes.

The `.rpd` is the image the `.jic` puts in P1 before relocation: written
into a slot by `rsu slot_program_buf` / librsu, which fix two pointers and
the CRC of the first 8 KB block - compared on the board: the generated
`.rpd` and P1 in flash differ in exactly those 8 bytes.

## A core per image (R3b)

HPS-first: an image's core only fits its own phase 1, so every slot has
one. U-Boot gets `rsu running_slot <var>` (linux/patches/
u-boot-rsu-running-slot.patch, applied by the build): `<var>` = the SPT
name of the image the SDM booted, `<var>_core` = the offset of its
`CORE.<name>` partition. The preboot loads `de25_nano_<name>.core.rbf`
from the card, else that partition; without an RSU layout the old names.
Tested 2026-10-18: power-on P1 (card), factory (card), factory and P1 with
the card file moved aside (QSPI 0xc00000 / 0xd10000). On Linux,
`fpga_access.py` keeps each image's core in `/lib/firmware/rsu/<name>/`
(webapp README). An install over the network writes the card copy; the
QSPI `CORE.<name>` copy is written by an RSU update (R6) or the `.jic`.

## Booting a slot by hand

```sh
echo 0x220000 > /sys/devices/platform/stratix10-rsu.0/reboot_image; reboot   # factory image
echo 0x400000 > /sys/devices/platform/stratix10-rsu.0/reboot_image; reboot   # P1
cat /sys/devices/platform/stratix10-rsu.0/current_image                      # which one runs
```

Such a reboot reconfigures the whole device: in HPS-first mode the console
is silent until U-Boot's preboot has loaded the core again (` FPGA
reconfiguration OK!`). A plain `reboot` after it keeps the image and the
fabric, so the SPL's lines show (`rsu_spl_mmc_filename, filename:
u-boot_P1.itb`, or `RSU: found SSBL partition P1 at address 0x00600000`).

## Steps

| # | step | done when |
|---|---|---|
| R0 (done) | **Kernel**: `CONFIG_INTEL_STRATIX10_RSU=y`; DE25-Nano DT: enable `&qspi`, add `flash@0` (MT25QU128) with partitions matching the layout; build script applies both (like `CONFIG_SENSORS_SOC64`) | `/proc/mtd` lists the partitions, `/sys/devices/platform/stratix10-rsu.0/` exists, `current_image` reads the running image |
| R1 (done 2026-10-17) | **Initial RSU flash image**: `make_jic.sh` gets an RSU mode - a `.pfg` with the factory image, P1, the SSBL partitions and the RSU options (decision firmware, SPT/CPB); program once over JTAG | power-on boots the factory image; U-Boot `rsu list` shows the slots; Linux `rsu_client --log` agrees |
| R2 (done 2026-10-18) | **U-Boot from SSBL**: SPL loads U-Boot from the running image's SSBL partition instead of the fixed 0xA00000 (U-Boot's RSU SPL support); SD card first, as now | each image boots its own U-Boot; a blank SD card still reaches U-Boot (factory SSBL) |
| R3 (done 2026-10-18) | **Application images**: `quartus_pfg` writes an RSU application `.rpd` from a `.sof`; `tools/make_rsu_bundle.py` wraps it with version, git hash, SHA-256 (like the persona bundles) | a bundle for today's design builds reproducibly |
| R3b (done 2026-10-18) | **A core per slot** (HPS-first): today U-Boot's preboot loads `de25_nano.core.rbf` (card) or the one QSPI copy at 0xC00000 whatever image runs, but a slot's core belongs to its phase 1. U-Boot's `rsu` command has no "running slot" subcommand; the SPL knows it (`u-boot_<slot>.itb`). Add one (`rsu running_slot <var>`, a small patch in the build script, from `rsu_spl_mmc_filename()`), then the preboot loads `de25_nano_${rsu_slot}.core.rbf` from the card, else QSPI `CORE.<slot>`; `fpga_access.py` installs the core under the running slot's name | factory and P1 boot with different cores; `fpga-reload` and `/api/fpga` keep working |
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
