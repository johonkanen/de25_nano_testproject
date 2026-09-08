#!/usr/bin/env python3
"""
vunit_run_de25_nano_test.py - VUnit test runner for de25_nano_testproject.

Compiles and runs both testbenches (de25_nano_uart_top_tb, fan_control_tb)
with nvc.  Needs vunit_hdl (pip install vunit_hdl) and nvc >= 1.14 on PATH.

    python3 vunit_run_de25_nano_test.py                    # run everything
    python3 vunit_run_de25_nano_test.py -v                 # verbose output
    python3 vunit_run_de25_nano_test.py --list              # list test cases
    python3 vunit_run_de25_nano_test.py de25_nano_lib.fan_control_tb.all

Source list mirrors sim/run.sh; keep the two in sync if files move.
"""

from pathlib import Path
from vunit import VUnit

ROOT = Path(__file__).resolve().parent

VU = VUnit.from_argv(vhdl_standard="2019")

lib = VU.add_library("de25_nano_lib")

# submodules
lib.add_source_files(ROOT / "source/hVHDL_fpga_interconnect/fpga_interconnect_generic_pkg.vhd")
lib.add_source_files(ROOT / "source/hVHDL_uart/uart_rx/uart_rx_pkg.vhd")
lib.add_source_files(ROOT / "source/hVHDL_uart/uart_tx/uart_tx_pkg.vhd")

# vendored fpga_communication glue
lib.add_source_files(ROOT / "source/fpga_communication/fpga_interconnect_16bit_pkg.vhd")
lib.add_source_files(ROOT / "source/fpga_communication/serial_protocol_generic_pkg.vhd")
lib.add_source_files(ROOT / "source/fpga_communication/communications.vhd")

# fan control: I2C master + AMC6821 sequencer
lib.add_source_files(ROOT / "source/fan_control/i2c_master_pkg.vhd")
lib.add_source_files(ROOT / "source/fan_control/amc6821_fan_control.vhd")

# simulation-only AMC6821 I2C slave model
lib.add_source_files(ROOT / "sim/amc6821_model.vhd")

# top level
lib.add_source_files(ROOT / "git_hash_pkg.vhd")
lib.add_source_files(ROOT / "de25_nano_uart_top.vhd")

# testbenches
lib.add_source_files(ROOT / "sim/de25_nano_uart_top_tb.vhd")
lib.add_source_files(ROOT / "sim/fan_control_tb.vhd")

VU.main()
