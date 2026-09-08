# DE25-Nano pin notes for `de25_nano_uart`

All pin/IO-standard values are taken from the Terasic golden top
(`~/dev/de25_nano/Demonstration/FPGA/Golden_top/golden_top.qsf`) for the
Agilex 5 `A5EB013BB23BE4SCS`.

| signal | pin | IO standard | note |
|--------|-----|-------------|------|
| `CLOCK0_50`      | PIN_DJ35 | 1.1-V | 50 MHz oscillator |
| `KEY[1:0]`       | C8 / C11 | 3.3-V LVCMOS | active low |
| `SW[3:0]`        | DK24 DD24 DD27 DF27 | 1.1-V | |
| `LED[7:0]`       | DF35 DJ32 DN22 DP23 DN25 DP25 DJ27 DP30 | 1.1-V | LED[7] = heartbeat |
| `FPGA_UART_RX`   | PIN_BR19 | 3.3-V LVCMOS | board→FPGA |
| `FPGA_UART_TX`   | PIN_CJ1  | 3.3-V LVCMOS | FPGA→board |
| `HDMI_I2C_SCL`   | PIN_BT1  | 3.3-V LVCMOS | AMC6821 fan controller + ADV7513, board pull-up |
| `HDMI_I2C_SDA`   | PIN_BW2  | 3.3-V LVCMOS | as above, bidirectional open-drain |
| `FAN_ALERT_n`    | PIN_DK32 | 1.1-V | active-low fan alert, input only |

Two more 50 MHz oscillators are available if you need them:
`CLOCK1_50` PIN_V16 and `CLOCK2_50` PIN_BF23, both **3.3-V LVCMOS**. This
build uses `CLOCK0_50` to match the DE25-Standard project's naming; the
Terasic demos use all three interchangeably as plain fabric clocks
(`SDRAM_Test_RTL` and `RTL_LPDDR4_AXI4_Test` clock fabric logic straight off
`CLOCK0_50`). If your design needs a 3.3-V clock input bank, switch to
`CLOCK1_50` and change the IO standard in `build_de25_nano_uart.tcl`.

## The UART is on-board — no adapter needed

This is the main difference from the DE25-Standard. On that board the
CP2105 USB bridge is wired to the **HPS**, there is no FPGA-fabric UART, and
`de25_std_testproject` has to break the UART out to two GPIO-header pins and
have you attach an external 3.3 V USB-serial adapter.

The DE25-Nano has a dedicated FPGA-fabric UART: `FPGA_UART_TX` (PIN_CJ1) and
`FPGA_UART_RX` (PIN_BR19) go to the board's own USB serial bridge. Plug in
the USB cable, find the `/dev/ttyUSB*` it enumerates as, and run
`test_uart.py` against it.

Terasic's own `Demonstration/FPGA/UART` demo is the reference for these two
pins — its entire body is a loopback gated by a key:

```verilog
assign FPGA_UART_TX = KEY[0] ? FPGA_UART_RX : 0;
assign LED[1:0]     = {~KEY[0], ~FPGA_UART_TX};
```

That demo is a useful sanity check on the cable and terminal before you
blame the register block: program its prebuilt
`Demonstration/FPGA/UART/demo_batch/golden_top.sof`, hold `KEY[0]`, and
anything you type in a terminal should echo back.

## No reset button

The DE25-Nano has **no `CPU_RESET_n`** — the DE25-Standard's PIN_BM78 button
has no equivalent in the Nano golden top. So `de25_nano_uart_top` derives
reset from its `g_por_cycles` power-on counter alone (~21 ms at 50 MHz), and
both push-buttons stay free as readable inputs on register 7.

If you want a manual reset, spend `KEY[0]`: add it to the reset
synchroniser the way `de25_uart_top.vhd` uses `CPU_RESET_n` in
`de25_std_testproject`, and narrow register 7 to `KEY[1]`.

## Repointing the pins

Edit the `set_location_assignment` lines in `build_de25_nano_uart.tcl` and
re-run `quartus_sh -t build_de25_nano_uart.tcl`.

## Using a PLL instead of the raw 50 MHz clock

This build runs everything on `CLOCK0_50` (`g_clock_divider = 434`). To get
a faster core clock, add an `altera_iopll`. Two board-tested IOPLLs for this
exact device are in the Nano demos and can be copied into an `ip/` directory
here:

- `Demonstration/FPGA/ADC_RTL/PLL.ip`
- `Demonstration/FPGA/ADC_NiosV/ip/nios_system/iopll.ip`

Check the configured output frequencies in the IP editor, then set
`g_clock_divider` to `core_clock_hz / 115200` (868 for 100 MHz) and hold
`system_reset` until the PLL's `locked` output is high.

## Configuration scheme

The Nano golden top differs from the DE25-Standard in two config settings —
both are already in `build_de25_nano_uart.tcl`:

| assignment | DE25-Standard | DE25-Nano |
|---|---|---|
| `ACTIVE_SERIAL_CLOCK` | `AS_FREQ_100MHZ` | `AS_FREQ_125MHZ` |
| `USE_INIT_DONE` | `SDM_IO13` | *not set* |

The Nano golden top also sets `PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"`
and `PWRMGT_LINEAR_FORMAT_N "-12"`, which this build carries over.

## Fan controller

`HDMI_I2C_SCL` / `HDMI_I2C_SDA` are not only HDMI — the AMC6821 PWM fan
controller shares that bus at 7-bit address `0x2E`, alongside the ADV7513
transmitter at `0x72`/`0x7A`. This project drives the fan there and leaves
HDMI alone; anything added later that wants HDMI has to share the bus.

See [de25_nano_fan.md](de25_nano_fan.md) for the AMC6821 configuration, why
Software-DCY mode is used, and how to trim the minimum fan speed.
