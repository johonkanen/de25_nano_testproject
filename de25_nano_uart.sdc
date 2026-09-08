# Timing constraints for the DE25-Nano UART bring-up build.
#
# Everything runs on the 50 MHz board oscillator - no PLL, so the clock is
# created here directly.

create_clock -name CLOCK0_50 -period 20.000 [get_ports CLOCK0_50]

derive_clock_uncertainty

# Asynchronous pins - no external timing relationship
set_false_path -from [get_ports {SW[*]}]
set_false_path -from [get_ports {KEY[*]}]
set_false_path -to   [get_ports {LED[*]}]
set_false_path -from [get_ports FPGA_UART_RX]
set_false_path -to   [get_ports FPGA_UART_TX]

# AMC6821 fan controller I2C. A slow, open-drain, self-clocked bus driven
# entirely from the core clock - there is no external timing relationship to
# constrain, and SDA is read back through a synchroniser.
set_false_path -from [get_ports HDMI_I2C_SDA]
set_false_path -to   [get_ports HDMI_I2C_SDA]
set_false_path -to   [get_ports HDMI_I2C_SCL]
set_false_path -from [get_ports FAN_ALERT_n]
