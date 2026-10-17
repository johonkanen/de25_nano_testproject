#!/usr/bin/env python3
"""
vunit_run_de25_nano_test.py - VUnit test runner for de25_nano_testproject.

Compiles every source (the top level included) and runs the testbenches
(fan_control_tb, led_blinkers_tb) with nvc.  Needs vunit_hdl (pip install vunit_hdl) and nvc >= 1.14 on PATH.

    python3 vunit_run_de25_nano_test.py                    # run everything
    python3 vunit_run_de25_nano_test.py -v                 # verbose output
    python3 vunit_run_de25_nano_test.py --list              # list test cases
    python3 vunit_run_de25_nano_test.py de25_nano_lib.fan_control_tb.all

Keep the source list in step with build_de25_nano_uart.tcl.
"""

from pathlib import Path
import subprocess
from vunit import VUnit

ROOT = Path(__file__).resolve().parent

VU = VUnit.from_argv(vhdl_standard="2019")

lib = VU.add_library("de25_nano_lib")

# submodules
lib.add_source_files(ROOT / "source/hVHDL_fpga_interconnect/fpga_interconnect_generic_pkg.vhd")

# vendored: the 32 data / 16 address fpga_interconnect instance
lib.add_source_files(ROOT / "source/fpga_communication/fpga_interconnect_16bit_pkg.vhd")

# fan control: I2C master + AMC6821 sequencer
lib.add_source_files(ROOT / "source/fan_control/i2c_master_pkg.vhd")
lib.add_source_files(ROOT / "source/fan_control/amc6821_fan_control.vhd")

# LED blinkers: the common package, the modules, the slot, the static part
lib.add_source_files(ROOT / "source/blinkers/blinker_pkg.vhd")
lib.add_source_files(ROOT / "source/blinkers/blinker_counter.vhd")
lib.add_source_files(ROOT / "source/blinkers/blinker_scanner.vhd")
lib.add_source_files(ROOT / "source/blinkers/blinker_breathing.vhd")
lib.add_source_files(ROOT / "source/blinkers/blinker_sparkle.vhd")
lib.add_source_files(ROOT / "source/blinkers/blinker_slot.vhd")
lib.add_source_files(ROOT / "source/led_blinkers.vhd")

# simulation-only AMC6821 I2C slave model
lib.add_source_files(ROOT / "sim/amc6821_model.vhd")

# top level
lib.add_source_files(ROOT / "git_hash_pkg.vhd")
# register 19's build id: generated (git-ignored) - a fresh clone has none yet
if not (ROOT / "build_id_pkg.vhd").exists():
    subprocess.run([str(ROOT / "write_build_id.sh")], check=True)
lib.add_source_files(ROOT / "build_id_pkg.vhd")
lib.add_source_files(ROOT / "axi_lwh2f_bridge.vhd")
lib.add_source_files(ROOT / "de25_nano_uart_top.vhd")

# testbenches
lib.add_source_files(ROOT / "sim/fan_control_tb.vhd")
lib.add_source_files(ROOT / "sim/led_blinkers_tb.vhd")

VU.main()
