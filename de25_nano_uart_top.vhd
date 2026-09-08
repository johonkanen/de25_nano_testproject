------------------------------------------------------------------------
-- Minimal Agilex 5 UART bring-up build for the Terasic DE25-Nano board.
--
-- Same skeleton as johonkanen/axc3000_test and de25_std_testproject,
-- trimmed to the essentials: the fpga_communication UART block + an
-- fpga_interconnect register file. No PLL, no DSP, no processors - the
-- 50 MHz board clock drives everything.
--
-- Board / pinout from the DE25-Nano golden top (Demonstration/FPGA):
--   CLOCK0_50      PIN_DJ35  1.1-V          50 MHz oscillator
--   LED[7:0]       ...       1.1-V          green user LEDs
--   SW[3:0]        ...       1.1-V          slide switches
--   KEY[1:0]       ...       3.3-V LVCMOS   push-buttons, active low
--   FPGA_UART_RX   PIN_BR19  3.3-V LVCMOS   board TX -> FPGA RX
--   FPGA_UART_TX   PIN_CJ1   3.3-V LVCMOS   FPGA TX -> board RX
--
-- Unlike the DE25-Standard - where the on-board USB bridge is wired to the
-- HPS and the UART has to be broken out to the GPIO header - the DE25-Nano
-- has a dedicated FPGA-fabric UART on FPGA_UART_TX / FPGA_UART_RX. No
-- jumper wires and no external adapter: the on-board USB serial port is the
-- register interface. Terasic's own Demonstration/FPGA/UART demo loops
-- these two pins back through KEY[0], which is where the pins are from.
--
-- Reset: the DE25-Nano has no CPU_RESET_n push-button, so reset is the
-- ~21 ms power-on counter only (g_por_cycles). Both push-buttons stay free
-- as readable inputs on register 7.
--
-- Clocking / baud:
--   g_clock_divider = 434  ->  50e6 / 434 = 115207 baud (~115200, 0.006% err)
--
-- Register map reachable over UART (32 bit data, 16 bit address):
--   addr 1 : constant id      0x0000DE25   (read only)
--   addr 2 : git hash                       (read only)
--   addr 3 : loopback register              (read / write)
--   addr 4 : read strobe counter            (read only, ++ on every read of 4)
--   addr 5 : LED register, low 7 bits -> LED[6:0]    (read / write)
--   addr 6 : SW[3:0] slide switches          (read only)
--   addr 7 : KEY[1:0] push-buttons, 1 = pressed  (read only)
--   addr 8 : free-running core-clock uptime counter  (read only)
--   addr 9 : fan speed - AMC6821 duty cycle, low 8 bits (read / write)
--   addr 10: fan speed measured, RPM                    (read only)
--   addr 11: fan raw TACH count                         (read only)
--   addr 12: fan controller status                       (read only)
--
-- LED[6:0] follow addr-5 bits 6..0; LED[7] is a ~1 Hz heartbeat so the
-- board shows life without a terminal attached.
--
-- Fan control (see source/fan_control/amc6821_fan_control.vhd): the board's
-- AMC6821 PWM fan controller hangs off the HDMI I2C bus, and register 9 is
-- its duty cycle - 0 = off, 255 = full. It resets to g_fan_min_duty, so the
-- fan comes up at minimum speed and stays there until something writes a
-- new value over the UART.
--
-- Register 12 packs the fan controller's status:
--   bits  7..0 : AMC6821 device ID, reads 0x21 when the I2C link is good
--   bits 15..8 : AMC6821 Status 1 register (0x02)
--   bits 23..16: duty cycle currently programmed into the chip
--   bit  24    : init_done  - configuration sequence completed
--   bit  25    : i2c_error  - sticky, a write went unacknowledged
--   bit  26    : FAN_ALERT_n pin level (active low, straight from the pad)
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity de25_nano_uart_top is
    generic (
        -- core clock (Hz) / baud rate.  50 MHz / 115200 = 434.
        g_clock_divider : natural := 434
        -- power-on reset length in core-clock cycles (~21 ms at 50 MHz).
        ;g_por_cycles   : natural := 1_048_575
        -- fan duty cycle after reset: minimum speed.  0..255 maps to 0..100 %
        -- PWM. The true lowest duty a fan will still turn at is fan-specific
        -- - watch register 10 (RPM) and trim this on hardware.
        ;g_fan_min_duty : natural range 0 to 255 := 51            -- ~20 %
        -- fan controller timing, exposed so simulation can shrink it
        ;g_fan_scl_hz      : natural := 100_000
        ;g_fan_kick_cycles : natural := 25_000_000                -- 0.5 s
        ;g_fan_poll_cycles : natural := 5_000_000                 -- 100 ms
        ;g_fan_por_cycles  : natural := 5_000_000                 -- 100 ms
    );
    port (
        CLOCK0_50      : in  std_logic                       -- 50 MHz (PIN_DJ35)
        ;SW            : in  std_logic_vector(3 downto 0)     -- slide switches
        ;KEY           : in  std_logic_vector(1 downto 0)     -- push-buttons, active low
        ;LED           : out std_logic_vector(7 downto 0)     -- green user LEDs
        ;FPGA_UART_RX  : in  std_logic                        -- PIN_BR19
        ;FPGA_UART_TX  : out std_logic                        -- PIN_CJ1
        -- AMC6821 fan controller, on the shared HDMI I2C bus
        ;HDMI_I2C_SCL  : inout std_logic                      -- PIN_BT1
        ;HDMI_I2C_SDA  : inout std_logic                      -- PIN_BW2
        ;FAN_ALERT_n   : in  std_logic                        -- PIN_DK32
    );
end entity de25_nano_uart_top;

architecture rtl of de25_nano_uart_top is

    use work.fpga_interconnect_pkg.all;

    signal core_clock : std_logic;

    -- synchronous, active-high reset: power-on counter only (no reset button)
    signal por_counter  : natural range 0 to g_por_cycles := g_por_cycles;
    signal system_reset : std_logic := '1';

    signal bus_to_communications   : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_communications : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_top            : fpga_interconnect_record := init_fpga_interconnect;

    signal loopback_register : std_logic_vector(31 downto 0) := (others => '0');
    signal read_counter      : std_logic_vector(31 downto 0) := (others => '0');
    signal led_register      : std_logic_vector(31 downto 0) := (others => '0');
    signal uptime_counter    : unsigned(31 downto 0)         := (others => '0');

    -- ~1 Hz heartbeat: 50 MHz / 2**26 ~= 0.75 Hz toggle
    signal heartbeat_count : unsigned(25 downto 0) := (others => '0');
    signal heartbeat       : std_logic := '0';

    -- double-flop the async inputs before they reach the register file
    signal sw_meta,  sw_sync  : std_logic_vector(3 downto 0) := (others => '0');
    signal key_meta, key_sync : std_logic_vector(1 downto 0) := (others => '1');
    signal alert_meta, alert_sync : std_logic := '1';

    -- fan control.  The reset value of fan_duty_register is the one place
    -- the minimum speed is defined.
    constant c_fan_min_duty : std_logic_vector(31 downto 0) :=
        std_logic_vector(to_unsigned(g_fan_min_duty, 32));

    signal fan_duty_register : std_logic_vector(31 downto 0) := c_fan_min_duty;

    signal fan_rpm       : std_logic_vector(15 downto 0);
    signal fan_tach      : std_logic_vector(15 downto 0);
    signal fan_device_id : std_logic_vector(7 downto 0);
    signal fan_status    : std_logic_vector(7 downto 0);
    signal fan_duty_prog : std_logic_vector(7 downto 0);
    signal fan_init_done : std_logic;
    signal fan_i2c_error : std_logic;
    signal fan_status_word : std_logic_vector(31 downto 0);

    signal i2c_sda_low : std_logic;
    signal i2c_scl_low : std_logic;

begin

------------------------------------------------------------------------
    core_clock <= CLOCK0_50;

------------------------------------------------------------------------
    -- hold reset for ~21 ms after configuration
    reset_generator : process (core_clock) is
    begin
        if rising_edge(core_clock) then
            if por_counter /= 0 then
                por_counter  <= por_counter - 1;
                system_reset <= '1';
            else
                system_reset <= '0';
            end if;
        end if;
    end process reset_generator;

------------------------------------------------------------------------
    input_synchroniser : process (core_clock) is
    begin
        if rising_edge(core_clock) then
            sw_meta  <= SW;   sw_sync  <= sw_meta;
            key_meta <= KEY;  key_sync <= key_meta;
            alert_meta <= FAN_ALERT_n;  alert_sync <= alert_meta;
        end if;
    end process input_synchroniser;

------------------------------------------------------------------------
    heartbeat_gen : process (core_clock) is
    begin
        if rising_edge(core_clock) then
            heartbeat_count <= heartbeat_count + 1;
            if heartbeat_count = 0 then
                heartbeat <= not heartbeat;
            end if;
        end if;
    end process heartbeat_gen;

    LED(6 downto 0) <= led_register(6 downto 0);
    LED(7)          <= heartbeat;

------------------------------------------------------------------------
    test_registers : process (core_clock) is
    begin
        if rising_edge(core_clock) then
            init_bus(bus_from_top);

            connect_read_only_data_to_address(bus_from_communications, bus_from_top, 1, x"0000DE25");
            connect_read_only_data_to_address(bus_from_communications, bus_from_top, 2, work.git_hash_pkg.git_hash);
            connect_data_to_address(bus_from_communications, bus_from_top, 3, loopback_register);

            if data_is_requested_from_address(bus_from_communications, 4) then
                read_counter <= std_logic_vector(unsigned(read_counter) + 1);
                write_data_to_address(bus_from_top, 0, read_counter);
            end if;

            connect_data_to_address(bus_from_communications, bus_from_top, 5, led_register);
            connect_read_only_data_to_address(bus_from_communications, bus_from_top, 6,
                std_logic_vector(resize(unsigned(sw_sync), 32)));
            connect_read_only_data_to_address(bus_from_communications, bus_from_top, 7,
                std_logic_vector(resize(unsigned(not key_sync), 32)));   -- KEY is active low
            connect_read_only_data_to_address(bus_from_communications, bus_from_top, 8,
                std_logic_vector(uptime_counter));

            -- fan speed setpoint and measurements
            connect_data_to_address(bus_from_communications, bus_from_top, 9, fan_duty_register);
            connect_read_only_data_to_address(bus_from_communications, bus_from_top, 10,
                std_logic_vector(resize(unsigned(fan_rpm), 32)));
            connect_read_only_data_to_address(bus_from_communications, bus_from_top, 11,
                std_logic_vector(resize(unsigned(fan_tach), 32)));
            connect_read_only_data_to_address(bus_from_communications, bus_from_top, 12,
                fan_status_word);

            uptime_counter <= uptime_counter + 1;

            bus_to_communications <= bus_from_top;

            if system_reset = '1' then
                loopback_register     <= (others => '0');
                read_counter          <= (others => '0');
                led_register          <= (others => '0');
                uptime_counter        <= (others => '0');
                fan_duty_register     <= c_fan_min_duty;
                bus_to_communications <= init_fpga_interconnect;
            end if;
        end if;
    end process test_registers;

------------------------------------------------------------------------
-- AMC6821 fan controller on the shared HDMI I2C bus. Open-drain: the pads
-- are only ever driven low or released, never driven high.
------------------------------------------------------------------------
    HDMI_I2C_SCL <= '0' when i2c_scl_low = '1' else 'Z';
    HDMI_I2C_SDA <= '0' when i2c_sda_low = '1' else 'Z';

    fan_status_word <= (31 downto 27 => '0')
                       & alert_sync & fan_i2c_error & fan_init_done
                       & fan_duty_prog & fan_status & fan_device_id;

    u_fan_control : entity work.amc6821_fan_control
    generic map (
        g_clock_hz     => 50_000_000
        ,g_scl_hz      => g_fan_scl_hz
        ,g_kick_cycles => g_fan_kick_cycles
        ,g_poll_cycles => g_fan_poll_cycles
        ,g_por_cycles  => g_fan_por_cycles
    )
    port map (
        clock       => core_clock
        ,reset      => system_reset
        ,duty_in    => fan_duty_register(7 downto 0)
        ,rpm_out    => fan_rpm
        ,tach_out   => fan_tach
        ,device_id  => fan_device_id
        ,status_out => fan_status
        ,duty_out   => fan_duty_prog
        ,init_done  => fan_init_done
        ,i2c_error  => fan_i2c_error
        ,sda_in     => HDMI_I2C_SDA
        ,sda_low    => i2c_sda_low
        ,scl_low    => i2c_scl_low
    );

------------------------------------------------------------------------
    u_fpga_communications : entity work.fpga_communications
    generic map (
        fpga_interconnect_pkg => work.fpga_interconnect_pkg
        ,g_clock_divider      => g_clock_divider
    )
    port map (
        clock                    => core_clock
        ,uart_rx                 => FPGA_UART_RX
        ,uart_tx                 => FPGA_UART_TX
        ,bus_to_communications   => bus_to_communications
        ,bus_from_communications => bus_from_communications
    );

end rtl;
