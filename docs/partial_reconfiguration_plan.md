# Plan: the LED blinkers as partial bitstreams, loaded from Linux

Status 2026-10-16: **plan only, nothing here is implemented.** What exists:
the blinkers as separate FPGA modules with one common port list
(`source/blinkers/`), all four side by side in `blinker_slot.vhd`, picked
by register 13; the web GUI and its network updates (`linux/webapp/`).
This plan turns `blinker_slot` into a partial reconfiguration (PR) region
that holds one module at a time, loaded by Linux over the network.

References: `~/dev/pr_testing` (Artix-7, phases D-F: the modules, the
static part, bundles, the GUI flow - the model for this repo's blinkers)
and `~/dev/axc3000_test` (Quartus Pro PR on Agilex 3, and the Agilex 5
`niosv_zephyr/hw_axe5000` build: `PR_BASE` revision, `static.qdb` export,
`PR_IMPL` + `ENTITY_REBINDING` personas, the PR Controller IP;
`PARTIAL_RECONFIGURATION.md` there).

## 1. What changes, in one picture

```
 browser ─► fpga_web.py ─(LWH2F 0x2000_0000)─► axi_lwh2f_bridge
                │                                  ├─ bit 20 = 0: register file (as now)
                │                                  └─ bit 20 = 1: PR Controller IP ─► SDM
                │                                         (timeout guard: never stall the bus)
                └─ /opt/de25web/personas/<build>/*.pbin     led_blinkers
                                                             ├─ frame tick, PWM, modes (static)
                                                             ├─ freeze / reset (RP_CTRL)
                                                             └─ PR region: one blinker_* module
```

## 2. Decisions taken (and why)

| | choice | why |
|---|---|---|
| Region contents | one blinker module, the `blinker_pkg` port list | the modules already share it; `ENTITY_REBINDING` binds `blinker_counter` / `_scanner` / ... directly, no wrappers |
| Loader | **PR Controller IP in the fabric, driven from Linux userspace over LWH2F** | proven on Agilex 3 (60 ms loads, `axc3000_test`); needs no kernel change. Linux fpga-manager PR for Agilex 5 only arrived in a June 2026 patch series - Terasic's 6.12.11 kernel would need a backport |
| Full reconfiguration from Linux | not needed | the static region (HPS, EMIF, LWH2F, fan, UART) keeps running; `HPS_INITIALIZATION "AFTER INIT_DONE"` stays as is (docs/de25_nano_lwh2f_bringup.md) |
| Default persona | the base `.sof`/`.jic` carries one (scanner) | the board blinks with no software at all |
| Compatibility | bundle header carries the static build id; checked against register 19 before anything is written | the SDM also checks the PR POF ID, but a refusal there is late and its failure mode on this path is untested |

## 3. Hardware (VHDL, Quartus)

1. **`led_blinkers.vhd`**: add `g_reconfigurable` as in `pr_testing`:
   `true` instantiates a black-box `component blinker_rm` (the region),
   `false` keeps `blinker_slot` (simulation, non-PR builds). New ports
   `rp_freeze`, `rp_reset`. While frozen, the region's outputs are
   replaced by 0 on the static side (registered), and `rp_reset` holds the
   module in reset across the load and one frame after.
   - Mode semantics with PR: 0 software, 1 off, 2 = "the module" (whatever
     is loaded; id tells which). Modes 3..5 kept as aliases of 2 so the
     GUI and API stay the same.
2. **Registers** (both buses, next free addresses):
   - 18 `RP_CTRL` R/W: bit 0 freeze, bit 1 reset (synchronised into the
     region's clock domain - here the same core_clock).
   - 19 `BUILD_ID` RO: identifies the static build (e.g. the build's Unix
     time, stamped like `git_hash_pkg.vhd`).
   - 16 `FEATURES`: bit 1 = PR region present.
3. **PR Controller IP** (`altera_s10_pr`, "Partial Reconfiguration
   Controller Intel FPGA IP", internal host): instantiate in the top,
   Avalon-MM slave (CSR + data). Generated `.ip` checked in like the HPS
   IP.
4. **`axi_lwh2f_bridge.vhd`**: address bit 20 selects the PR IP window
   (LWH2F `0x2010_0000`), bits [19:4] still select registers. A small
   AXI→Avalon path for that window with a **timeout**: if the IP holds
   `waitrequest` for more than N cycles (e.g. 2^16), complete the AXI
   transaction with `SLVERR` and set a sticky error bit. Reason: the
   Agilex 3 work found a damaged persona stalls the PR IP's data port, and
   on this board a stalled LWH2F transfer hangs the ARM core - Linux would
   die. The bridge already does the same for reads (`read_watchdog`).
5. **`build_de25_nano_uart.tcl`** (behind `PR_BASE=1`, default off until
   it works):
   ```tcl
   set_global_assignment -name REVISION_TYPE PR_BASE
   set_instance_assignment -name PARTITION blinker -to u_led_blinkers|u_rp
   set_instance_assignment -name PARTIAL_RECONFIGURATION_PARTITION ON -to u_led_blinkers|u_rp
   set_instance_assignment -name PLACE_REGION "<x0 y0 x1 y1>" -to u_led_blinkers|u_rp
   set_instance_assignment -name ROUTE_REGION "<one LAB larger>" -to u_led_blinkers|u_rp
   set_instance_assignment -name RESERVE_PLACE_REGION ON -to u_led_blinkers|u_rp
   set_instance_assignment -name CORE_ONLY_PLACE_REGION ON -to u_led_blinkers|u_rp
   ```
   Region size: the four modules are a few hundred ALMs together; 10x10
   LABs as on the AXE5000 is ample. Place it away from the HPS / EMIF
   I/O corner - read the coordinates off the first base fit's floorplan.
6. **`pr/build_personas.sh`** (after `hw_axe5000/pr/build_personas.sh`):
   export the static region (`quartus_cdb --export_block root_partition
   --snapshot final --file output_files/static.qdb`), then one `PR_IMPL`
   revision per module with `QDB_FILE_PARTITION static.qdb` and
   `ENTITY_REBINDING blinker_<name> -to u_led_blinkers|u_rp`; syn, fit,
   sta, asm each. Output: `output_files/impl_<name>.blinker.rbf`. The
   revisions are independent - run them in parallel.
7. **`tools/make_bundle.py`** (after `pr_testing/tools/mkpartial.py`): a
   header - magic, version, static build id, module id (4 chars), payload
   length, SHA-256 - then the `.rbf`. Rule from both references: **any
   change to the static region means rebuilding every persona**; the
   build id makes a stale one refuse to load instead of misbehaving.

## 4. Linux side

1. **Loader in `fpga_web.py`** (a `PrLoader` next to `Board`, using the
   same lock so register traffic pauses during a load):
   1. check the bundle: magic, SHA-256, build id == register 19, the
      module id is one we know;
   2. `RP_CTRL` = freeze | reset;
   3. PR IP: write start, wait for "in progress", write every 32-bit word
      of the `.rbf` to the data register, wait for "done" (or error /
      bridge timeout);
   4. release reset, then freeze;
   5. verify register 17 shows the bundle's module id.
   On failure: report the step (the step-wise error enum from
   `axc3000_test`'s `pr.h`), load the scanner persona again; if the PR IP
   is in an error state, the only recovery is a reboot (full
   configuration from QSPI) - say so in the GUI rather than retrying.
2. **Storage**: `/opt/de25web/personas/<build id>/<id>.pbin`, the
   persona set for the bitstream that is in QSPI. Installed by
   `deploy_web.py --personas output_files/` (new option) and by the GUI.
3. **API**: `GET /api/personas` (what is stored, what is loaded, last
   load time/result); `POST /api/blinker {"mode": "breathing"}` loads that
   persona when the bitstream has PR (FEATURES bit 1), sets the mode
   register otherwise - so the GUI's buttons stay the same;
   `POST /api/persona` uploads a bundle (token, as `/api/update`).
4. **GUI**: the blinker card shows "loaded in 60 ms" / the error step, an
   upload field for bundles, and which build the stored personas belong
   to. The board drawing is unchanged.
5. **Persistence**: the last chosen persona is reloaded by the server at
   start (after the supervisor starts it at boot).

## 5. Order of work, each step testable on its own

| # | step | done when |
|---|---|---|
| P0 | Quartus check: PR_BASE compile of this design with an empty region; confirm the license/edition allows PR on `A5EB013BB23BE4SCS` | base `.sof` and the region's `blinker.rbf` written |
| P1 | `led_blinkers` freeze/reset + registers 18/19 + FEATURES bit 1; extend `led_blinkers_tb` (outputs 0 while frozen, module restarts after reset) | sim passes; non-PR build unchanged on the board |
| P2 | `pr/build_personas.sh`; load personas **over JTAG** (`quartus_pgm --pr impl_<name>.blinker.rbf`) | the LEDs change pattern, register 17 follows, Linux and the GUI keep running |
| P3 | PR Controller IP + the LWH2F window with the timeout; a minimal C or Python loader run by hand on the board | a persona loads from Linux; a deliberately truncated `.rbf` returns an error instead of hanging the CPU |
| P4 | `make_bundle.py`, the loader in `fpga_web.py`, `/api/personas`, `/api/persona`, GUI changes | picking a blinker in the GUI loads its persona |
| P5 | fault tests (wrong build id, bad SHA, truncated, corrupt payload, power cut mid-load) and a soak (1000 loads in a loop, as `pr_testing` did 2000) | no hang, every fault reported and recovered |
| P6 | QSPI image update from Linux (new `.jic` = new static + new persona set), so a static change is also network-deployable | optional; RSU-based, separate plan |

## 6. Risks and open questions

- **PR Controller IP on Agilex 5 is untested on hardware** - the AXE5000
  build compiles it, but the on-board PR results are from the Agilex 3.
  P0/P2 (JTAG) separate "PR works on this device" from "our loader works".
- **A stalled bus kills Linux.** The bridge timeout (3.4) is mandatory,
  not an optimisation; test it in P3 before anything else uses the path.
- **License**: Quartus Pro PR - checked in P0 on the first PR_BASE compile.
- **Region placement vs. the HPS**: keep the region core-only and away
  from the HPS/EMIF I/O; any LWH2F timing change shows up in P1/P2 as a
  regression of the register file - rerun the GUI test (`gui_test.py`)
  against the board after each base build.
- **Static rebuilds** invalidate every persona; the build id check and
  storing personas per build id keep that safe, but deploying a new base
  also means deploying its personas (P6 couples them).
