# ------------------------------------------------------------------------
# Quartus Prime Pro project script - minimal UART bring-up build
# Target board: Terasic DE25-Nano (Agilex 5 A5EB013BB23BE4SCS)
#
# Scope: fpga_communication UART block + an fpga_interconnect register file.
# Everything runs on the 50 MHz board clock - no PLL, no DSP, no processors.
#
# VHDL sources live under source/ : hVHDL_uart and hVHDL_fpga_interconnect
# are submodules; the three fpga_communication glue files are vendored
# (see source/fpga_communication/README.md).
#
# First checkout:
#     git submodule update --init
#
# Build (run every command from this directory):
#     quartus_sh  -t build_de25_nano_uart.tcl
#     quartus_syn de25_nano_uart
#     quartus_fit de25_nano_uart
#     quartus_sta de25_nano_uart
#     quartus_asm de25_nano_uart
#
# Program (cable INDEX - see program.sh / jtagconfig):
#     quartus_pgm -c 1 -m jtag -o "p;output_files/de25_nano_uart.sof@1"
#
# The fan runs at minimum speed out of reset; register 9 is its duty cycle
# and register 10 reads back the measured RPM.
#
# Talk to it - on-board USB serial, no adapter needed
# (50e6 / 434 ~= 115200 baud, 32-bit data words):
#     python test_uart.py /dev/ttyUSB0 115200
#     >>> Uart(...).read(1)   # -> 0x0000DE25
# ------------------------------------------------------------------------

package require ::quartus::project

variable this_file_path [file dirname [file normalize [info script]]]

set need_to_close_project 0

if {[is_project_open]} {
    if {[string compare $quartus(project) "de25_nano_uart"]} {
        puts "Project de25_nano_uart is not open"
        exit 1
    }
} else {
    if {[project_exists de25_nano_uart]} {
        project_open -revision de25_nano_uart de25_nano_uart
    } else {
        project_new -revision de25_nano_uart de25_nano_uart
    }
    set need_to_close_project 1
}

# ---------------------------------------------------------------- device
set_global_assignment -name FAMILY "Agilex 5"
set_global_assignment -name DEVICE A5EB013BB23BE4SCS
set_global_assignment -name DEVICE_FILTER_PACKAGE VPBGA
set_global_assignment -name TOP_LEVEL_ENTITY de25_nano_uart_top
set_global_assignment -name ORIGINAL_QUARTUS_VERSION 25.1.0
set_global_assignment -name LAST_QUARTUS_VERSION "26.1.0 Pro Edition"
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name VHDL_INPUT_VERSION VHDL_2019
set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
set_global_assignment -name OPTIMIZATION_MODE BALANCED
set_global_assignment -name BOARD default

# DE25-Nano configuration scheme (matches the Terasic golden top).
# Note: 125 MHz AS clock here, vs 100 MHz on the DE25-Standard, and the
# Nano golden top sets no USE_INIT_DONE.
set_global_assignment -name USE_CONF_DONE SDM_IO16
set_global_assignment -name USE_HPS_COLD_RESET SDM_IO11
set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "ACTIVE SERIAL X4"
set_global_assignment -name ACTIVE_SERIAL_CLOCK AS_FREQ_125MHZ
set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ

# Both assignments below come from Intel/Altera's own official reference
# design for this exact board (altera-fpga/agilex5e-ed-gsrd,
# terasic-de25-nano-devkit/baseline-a55/baseline_a55.qsf) - found while
# chasing a FreeRTOS-over-QSPI attempt that configured the fabric fine
# (confirmed by fan/LEDs) but produced zero HPS UART output. Bisection via
# instrumented ATF checkpoints showed BL2 hangs forever on its very first
# register read of the Cadence QSPI controller (cad_qspi_idle()) - a
# hardware bus stall, not a software timeout. QSPI_OWNERSHIP defaults away
# from HPS, so the ARM cores never actually have a live bus path to that
# peripheral's registers at all until this is set.
#
# HPS_CONFIG_ORDER (guessed initially) is not a real assignment name -
# quartus_sh's get_all_assignment_names has no such entry. The real name
# for that concept is HPS_INITIALIZATION.
set_global_assignment -name QSPI_OWNERSHIP HPS
set_global_assignment -name HPS_INITIALIZATION "HPS FIRST"
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"

# HPS-specific assignments (matches de25_std_testproject/build_de25_soc.tcl)
set_global_assignment -name HPS_DAP_NO_CERTIFICATE on
set_global_assignment -name HPS_DAP_SPLIT_MODE DISABLED
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL

# ------------------------------------------------------------ source set
# fpga_interconnect protocol (generic package + 32 data / 16 address instance)
set_global_assignment -name VHDL_FILE $this_file_path/source/hVHDL_fpga_interconnect/fpga_interconnect_generic_pkg.vhd
set_global_assignment -name VHDL_FILE $this_file_path/source/fpga_communication/fpga_interconnect_16bit_pkg.vhd

# AMC6821 fan controller on the HDMI I2C bus (see source/fan_control/)
set_global_assignment -name VHDL_FILE $this_file_path/source/fan_control/i2c_master_pkg.vhd
set_global_assignment -name VHDL_FILE $this_file_path/source/fan_control/amc6821_fan_control.vhd

# uart rx / tx (entity + package in the same file) and the serial protocol
set_global_assignment -name VHDL_FILE $this_file_path/source/hVHDL_uart/uart_rx/uart_rx_pkg.vhd
set_global_assignment -name VHDL_FILE $this_file_path/source/hVHDL_uart/uart_tx/uart_tx_pkg.vhd
set_global_assignment -name VHDL_FILE $this_file_path/source/fpga_communication/serial_protocol_generic_pkg.vhd
set_global_assignment -name VHDL_FILE $this_file_path/source/fpga_communication/communications.vhd

# git hash constant (refresh with ./write_githash.sh)
set_global_assignment -name VHDL_FILE $this_file_path/git_hash_pkg.vhd

# lwhps2fpga (LWH2F) AXI4 <-> fpga_interconnect converter - see
# de25_std_testproject's own axi_lwh2f_bridge.vhd (ported verbatim)
set_global_assignment -name VHDL_FILE $this_file_path/axi_lwh2f_bridge.vhd

# H2F User0 clock heartbeat test - see hps/README.md's "H2F User0 clock"
# section and h2f_user0_clk_heartbeat.vhd (ported verbatim)
set_global_assignment -name VHDL_FILE $this_file_path/h2f_user0_clk_heartbeat.vhd

# bring-up top level
set_global_assignment -name VHDL_FILE $this_file_path/de25_nano_uart_top.vhd

# ------------------------------------------------------------ HPS + IP
# Agilex 5 HPS + LPDDR4 EMIF (hps_min, a real Platform Designer system -
# see hps/hps_min.qsys / hps/README.md). Instantiated from
# de25_nano_uart_top.vhd; every FPGA<->HPS bridge is disabled, so it is a
# standalone ARM host independent of the fabric logic.
#
# Generate once (or after editing hps/hps_subsys.qsys):
#     qsys-generate hps/hps_subsys.qsys --synthesis=VHDL --part=A5EB013BB23BE4SCS
set_global_assignment -name QSYS_FILE $this_file_path/hps/hps_subsys.qsys

# sub-IP referenced by hps_subsys.vhd's library/use clauses - Quartus Pro's
# IP-first flow needs each one added explicitly alongside the .qsys.
set_global_assignment -name IP_FILE $this_file_path/hps/ip/hps_subsys/agilex_hps.ip
set_global_assignment -name IP_FILE $this_file_path/hps/ip/hps_subsys/hps_subsys_s10_user_rst_clkgate_0.ip
set_global_assignment -name IP_FILE $this_file_path/hps/ip/qsys_top/emif_io96b_hps.ip

# ---------------------------------------------------------- constraints
set_global_assignment -name SDC_FILE $this_file_path/de25_nano_uart.sdc

# ------------------------------------------------------------------ pins
# from Demonstration/FPGA/Golden_top/golden_top.qsf
set_location_assignment PIN_DJ35 -to CLOCK0_50

set_location_assignment PIN_C8   -to KEY[0]
set_location_assignment PIN_C11  -to KEY[1]

set_location_assignment PIN_DK24 -to SW[0]
set_location_assignment PIN_DD24 -to SW[1]
set_location_assignment PIN_DD27 -to SW[2]
set_location_assignment PIN_DF27 -to SW[3]

set_location_assignment PIN_DF35 -to LED[0]
set_location_assignment PIN_DJ32 -to LED[1]
set_location_assignment PIN_DN22 -to LED[2]
set_location_assignment PIN_DP23 -to LED[3]
set_location_assignment PIN_DN25 -to LED[4]
set_location_assignment PIN_DP25 -to LED[5]
set_location_assignment PIN_DJ27 -to LED[6]
set_location_assignment PIN_DP30 -to LED[7]

# on-board FPGA-fabric UART -> USB serial bridge (no external adapter)
set_location_assignment PIN_BR19 -to FPGA_UART_RX
set_location_assignment PIN_CJ1  -to FPGA_UART_TX

# AMC6821 fan controller / temperature monitor. It shares the HDMI I2C bus
# with the ADV7513 transmitter, at a different address (0x2E vs 0x72/0x7A),
# and the board carries the bus pull-ups.
set_location_assignment PIN_BT1  -to HDMI_I2C_SCL
set_location_assignment PIN_BW2  -to HDMI_I2C_SDA
set_location_assignment PIN_DK32 -to FAN_ALERT_n

# H2F User0 clock heartbeat test - GPIO0_D[2] (from
# Demonstration/FPGA/Golden_top/golden_top.qsf)
set_location_assignment PIN_C2   -to H2F_CLK_TEST

set_instance_assignment -name IO_STANDARD "1.1-V"        -to CLOCK0_50    -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to KEY[0]       -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to KEY[1]       -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to SW[0]        -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to SW[1]        -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to SW[2]        -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to SW[3]        -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to LED[0]       -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to LED[1]       -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to LED[2]       -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to LED[3]       -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to LED[4]       -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to LED[5]       -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to LED[6]       -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to LED[7]       -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to FPGA_UART_RX -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to FPGA_UART_TX -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to HDMI_I2C_SCL -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to HDMI_I2C_SDA -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "1.1-V"        -to FAN_ALERT_n  -entity de25_nano_uart_top
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to H2F_CLK_TEST -entity de25_nano_uart_top

set_instance_assignment -name CURRENT_STRENGTH_NEW 6MA -to FPGA_UART_TX -entity de25_nano_uart_top

# ------------------------------------------------ HPS + LPDDR4A pins (GHRD)
# 196 pins x {location, IO_STANDARD}, incl. HPS_CLK_25 / LPDDR4A_REFCLK_p /
# LPDDR4A_RZQ - see hps/README.md.
source $this_file_path/hps/hps_pins.tcl

# --------------------------------------------------------------- commit
export_assignments

if {$need_to_close_project} {
    project_close
}
