------------------------------------------------------------------------
-- de25_nano_uart_top_tb - drive the real UART pins of de25_nano_uart_top
-- and check the fpga_interconnect register responses.  8N1, LSB first, one
-- stop bit, g_clock_divider clocks per bit (overridden small here for speed).
--
-- The DE25-Nano has no reset button, so the DUT comes out of its power-on
-- reset counter on its own - g_por_cycles is shortened for the simulation.
--
-- An amc6821_model hangs off the HDMI I2C pins so the fan registers (9..12)
-- can be exercised over the UART the same way the real chip would be: the
-- test checks the fan comes up at minimum duty and that writing register 9
-- actually reaches the chip's DCY register.
--
-- VUnit testbench - run via vunit_run_de25_nano_test.py, or standalone:
--   python3 vunit_run_de25_nano_test.py de25_nano_lib.de25_nano_uart_top_tb.all -v
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;

entity de25_nano_uart_top_tb is
    generic (runner_cfg : string);
end entity;

architecture sim of de25_nano_uart_top_tb is

    constant clock_period : time    := 20 ns;   -- 50 MHz
    constant divider      : natural := 16;      -- clocks per UART bit
    constant bit_time     : time    := divider * clock_period;
    constant por_cycles   : natural := 64;

    signal clock    : std_logic := '0';
    signal sw       : std_logic_vector(3 downto 0) := "0000";
    signal key      : std_logic_vector(1 downto 0) := "11";
    signal led      : std_logic_vector(7 downto 0);
    signal fpga_rx  : std_logic := '1';   -- host -> FPGA  (FPGA_UART_RX)
    signal fpga_tx  : std_logic;          -- FPGA -> host  (FPGA_UART_TX)

    -- fan controller I2C bus, with pull-ups, plus the alert pin
    signal i2c_scl    : std_logic;
    signal i2c_sda    : std_logic;
    signal fan_alert_n : std_logic := '1';

    constant c_fan_min_duty : natural := 51;                    -- ~20 %
    -- 2500 TACH counts -> 6_000_000 / 2500 = 2400 rpm
    signal tach_set : std_logic_vector(15 downto 0) := x"09C4";

    signal reg_dcy    : std_logic_vector(7 downto 0);
    signal reg_cfg1   : std_logic_vector(7 downto 0);
    signal reg_cfg2   : std_logic_vector(7 downto 0);
    signal reg_cfg4   : std_logic_vector(7 downto 0);
    signal reg_fanchr : std_logic_vector(7 downto 0);
    signal write_count : natural;

    signal test_running : boolean := true;

    type byte_array is array (natural range <>) of std_logic_vector(7 downto 0);

begin

    test_runner_watchdog(runner, 20 ms);

    clock <= not clock after clock_period / 2 when test_running else '0';

    i2c_scl <= 'H';
    i2c_sda <= 'H';

------------------------------------------------------------------------
    slave : entity work.amc6821_model
    port map (
        scl          => i2c_scl
        ,sda         => i2c_sda
        ,tach_set    => tach_set
        ,reg_dcy     => reg_dcy
        ,reg_cfg1    => reg_cfg1
        ,reg_cfg2    => reg_cfg2
        ,reg_cfg4    => reg_cfg4
        ,reg_fanchr  => reg_fanchr
        ,write_count => write_count
    );

------------------------------------------------------------------------
    dut : entity work.de25_nano_uart_top
        generic map (
            g_clock_divider   => divider,
            g_por_cycles      => por_cycles,
            g_fan_min_duty    => c_fan_min_duty,
            g_fan_scl_hz      => 2_500_000,   -- fast, to keep the sim short
            g_fan_kick_cycles => 2_000,
            g_fan_poll_cycles => 200,
            g_fan_por_cycles  => 200
        )
        port map (
            CLOCK0_50    => clock,
            SW           => sw,
            KEY          => key,
            LED          => led,
            FPGA_UART_RX => fpga_rx,
            FPGA_UART_TX => fpga_tx,
            HDMI_I2C_SCL => i2c_scl,
            HDMI_I2C_SDA => i2c_sda,
            FAN_ALERT_n  => fan_alert_n
        );

------------------------------------------------------------------------
    main : process

        procedure send_byte (b : in std_logic_vector(7 downto 0)) is
        begin
            fpga_rx <= '0';                      -- start bit
            wait for bit_time;
            for i in 0 to 7 loop                 -- LSB first
                fpga_rx <= b(i);
                wait for bit_time;
            end loop;
            fpga_rx <= '1';                      -- stop bit
            wait for bit_time;
        end procedure;

        procedure recv_byte (signal line : in std_logic; b : out std_logic_vector(7 downto 0)) is
            variable v : std_logic_vector(7 downto 0);
        begin
            wait until line = '0';               -- start bit edge
            wait for bit_time / 2;               -- move to mid-bit
            wait for bit_time;                   -- first data bit
            for i in 0 to 7 loop
                v(i) := line;
                wait for bit_time;
            end loop;
            b := v;                              -- (line is now in the stop bit)
        end procedure;

        procedure bus_read (addr : in natural; result : out std_logic_vector(31 downto 0)) is
            variable rx : byte_array(0 to 6);
            variable a  : unsigned(15 downto 0) := to_unsigned(addr, 16);
        begin
            send_byte(x"02");
            send_byte(std_logic_vector(a(15 downto 8)));
            send_byte(std_logic_vector(a(7 downto 0)));
            for i in rx'range loop
                recv_byte(fpga_tx, rx(i));
            end loop;
            -- rx = [ len=6 , addr_hi , addr_lo , d31..24 , d23..16 , d15..8 , d7..0 ]
            result := rx(3) & rx(4) & rx(5) & rx(6);
        end procedure;

        procedure bus_write (addr : in natural; data : in std_logic_vector(31 downto 0)) is
            variable a : unsigned(15 downto 0) := to_unsigned(addr, 16);
        begin
            send_byte(x"04");
            send_byte(std_logic_vector(a(15 downto 8)));
            send_byte(std_logic_vector(a(7 downto 0)));
            send_byte(data(31 downto 24));
            send_byte(data(23 downto 16));
            send_byte(data(15 downto 8));
            send_byte(data(7 downto 0));
        end procedure;

        variable d : std_logic_vector(31 downto 0);

    begin
        test_runner_setup(runner, runner_cfg);

        -- no reset pin on this board - just wait out the power-on counter
        wait for 4 us;

        bus_read(1, d);
        check_equal(d, std_logic_vector'(x"0000DE25"), "id (addr 1)");

        bus_write(3, x"DEADBEEF");
        bus_read(3, d);
        check_equal(d, std_logic_vector'(x"DEADBEEF"), "loopback (addr 3)");

        bus_write(3, x"12345678");
        bus_read(3, d);
        check_equal(d, std_logic_vector'(x"12345678"), "loopback (addr 3)");

        bus_write(5, x"0000005A");
        bus_read(5, d);
        check_equal(d, std_logic_vector'(x"0000005A"), "LED register (addr 5)");
        check_equal(led(6 downto 0), std_logic_vector'("1011010"),
                    "LED[6:0] follows the LED register");

        sw <= "1010";
        wait for 1 us;
        bus_read(6, d);
        check_equal(d, std_logic_vector'(x"0000000A"), "SW readback (addr 6)");

        key <= "10";                           -- KEY0 pressed (active low)
        wait for 1 us;
        bus_read(7, d);
        check_equal(d, std_logic_vector'(x"00000001"), "KEY readback (addr 7)");

        bus_read(4, d);
        bus_read(4, d);
        info("read counter after two reads = 0x" & to_hstring(d));

        ----------------------------------------------------------------
        -- fan registers.  Wait for the controller to have configured the
        -- chip and read its ID back before checking anything.
        for i in 1 to 500000 loop
            exit when reg_dcy = std_logic_vector(to_unsigned(c_fan_min_duty, 8));
            wait until rising_edge(clock);
        end loop;

        bus_read(9, d);
        check_equal(d, std_logic_vector(to_unsigned(c_fan_min_duty, 32)),
                    "fan duty resets to minimum (addr 9)");
        check_equal(reg_dcy, std_logic_vector(to_unsigned(c_fan_min_duty, 8)),
                    "the AMC6821 DCY register holds the minimum duty");

        bus_read(12, d);
        check_equal(unsigned(d(7 downto 0)), natural'(16#21#),
                    "fan device id (addr 12, bits 7..0)");
        check_equal(d(24), '1', "fan init_done set (addr 12, bit 24)");
        check_equal(d(25), '0', "fan i2c_error clear (addr 12, bit 25)");
        check_equal(unsigned(d(23 downto 16)), to_unsigned(c_fan_min_duty, 8),
                    "fan duty programmed (addr 12, bits 23..16)");

        bus_read(11, d);
        check_equal(d, std_logic_vector'(x"000009C4"), "fan raw TACH (addr 11)");

        bus_read(10, d);
        check_equal(d, std_logic_vector'(x"00000960"), "fan RPM = 6e6 / tach (addr 10)");   -- 2400

        -- drive the fan faster over the UART and watch it reach the chip
        bus_write(9, x"000000C0");
        for i in 1 to 500000 loop
            exit when reg_dcy = x"C0";
            wait until rising_edge(clock);
        end loop;
        check_equal(reg_dcy, std_logic_vector'(x"C0"),
                    "an addr 9 write reaches the AMC6821 DCY register");

        bus_write(9, std_logic_vector(to_unsigned(c_fan_min_duty, 32)));

        info("==== " & integer'image(get_checker_stat.n_passed) & " of "
             & integer'image(get_checker_stat.n_checks) & " checks passed ====");

        test_runner_cleanup(runner);
        test_running <= false;
        wait;
    end process main;

end architecture;
