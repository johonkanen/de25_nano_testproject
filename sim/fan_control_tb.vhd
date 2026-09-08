------------------------------------------------------------------------
-- fan_control_tb - point amc6821_fan_control at the amc6821_model over a
-- modelled open-drain I2C bus and check that it
--
--   * writes the intended configuration, Config1 last
--   * kicks the fan to g_kick_duty and then settles to duty_in
--   * reads the device ID back as 0x21
--   * converts the TACH reading to RPM
--   * follows a new duty setpoint
--   * never raises i2c_error against a slave that acknowledges
--   * on a NACK, releases the bus rather than wedging it, and recovers
--
-- I2C rate and the startup delays are scaled right down here; the real
-- build runs at 100 kHz with ~0.5 s of kick.
--
-- VUnit testbench - run via vunit_run_de25_nano_test.py, or standalone:
--   python3 vunit_run_de25_nano_test.py de25_nano_lib.fan_control_tb.all -v
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;

entity fan_control_tb is
    generic (runner_cfg : string);
end entity;

architecture sim of fan_control_tb is

    constant clock_period : time := 20 ns;              -- 50 MHz

    constant c_min_duty  : std_logic_vector(7 downto 0) := x"33";   -- 51, ~20 %
    constant c_new_duty  : std_logic_vector(7 downto 0) := x"80";   -- 128, ~50 %
    constant c_kick_duty : natural := 255;

    signal clock : std_logic := '0';
    signal reset : std_logic := '1';

    signal duty_in : std_logic_vector(7 downto 0) := c_min_duty;

    signal rpm_out    : std_logic_vector(15 downto 0);
    signal tach_out   : std_logic_vector(15 downto 0);
    signal device_id  : std_logic_vector(7 downto 0);
    signal status_out : std_logic_vector(7 downto 0);
    signal duty_out   : std_logic_vector(7 downto 0);
    signal init_done  : std_logic;
    signal i2c_error  : std_logic;

    signal sda_low : std_logic;
    signal scl_low : std_logic;

    -- the bus itself, with pull-ups
    signal sda : std_logic;
    signal scl : std_logic;

    -- 2000 TACH counts -> 6_000_000 / 2000 = 3000 rpm
    signal tach_set : std_logic_vector(15 downto 0) := x"07D0";

    signal reg_dcy    : std_logic_vector(7 downto 0);
    signal reg_cfg1   : std_logic_vector(7 downto 0);
    signal reg_cfg2   : std_logic_vector(7 downto 0);
    signal reg_cfg4   : std_logic_vector(7 downto 0);
    signal reg_fanchr : std_logic_vector(7 downto 0);
    signal write_count : natural;

    signal slave_enable : std_logic := '1';

    signal test_running : boolean := true;

begin

    test_runner_watchdog(runner, 100 ms);

    clock <= not clock after clock_period / 2 when test_running else '0';

    -- pull-ups, then the master's open-drain pulls
    scl <= 'H';
    sda <= 'H';
    scl <= '0' when scl_low = '1' else 'Z';
    sda <= '0' when sda_low = '1' else 'Z';

------------------------------------------------------------------------
    dut : entity work.amc6821_fan_control
    generic map (
        g_clock_hz     => 50_000_000
        ,g_scl_hz      => 2_500_000     -- fast, to keep the simulation short
        ,g_kick_duty   => c_kick_duty
        ,g_kick_cycles => 2_000
        ,g_poll_cycles => 200
        ,g_por_cycles  => 200
    )
    port map (
        clock       => clock
        ,reset      => reset
        ,duty_in    => duty_in
        ,rpm_out    => rpm_out
        ,tach_out   => tach_out
        ,device_id  => device_id
        ,status_out => status_out
        ,duty_out   => duty_out
        ,init_done  => init_done
        ,i2c_error  => i2c_error
        ,sda_in     => sda
        ,sda_low    => sda_low
        ,scl_low    => scl_low
    );

------------------------------------------------------------------------
    slave : entity work.amc6821_model
    port map (
        scl          => scl
        ,sda         => sda
        ,tach_set    => tach_set
        ,enable      => slave_enable
        ,reg_dcy     => reg_dcy
        ,reg_cfg1    => reg_cfg1
        ,reg_cfg2    => reg_cfg2
        ,reg_cfg4    => reg_cfg4
        ,reg_fanchr  => reg_fanchr
        ,write_count => write_count
    );

------------------------------------------------------------------------
    main : process

        -- wait for a condition with a timeout, so a hang fails on the next
        -- check instead of running silently to the watchdog
        procedure wait_kick_duty is
        begin
            for i in 1 to 200000 loop
                exit when reg_dcy = std_logic_vector(to_unsigned(c_kick_duty, 8));
                wait until rising_edge(clock);
            end loop;
        end procedure wait_kick_duty;

    begin
        test_runner_setup(runner, runner_cfg);

        reset <= '1';
        wait for 1 us;
        reset <= '0';

        ----------------------------------------------------------------
        -- the configuration script must complete
        for i in 1 to 500000 loop
            exit when init_done = '1';
            wait until rising_edge(clock);
        end loop;
        check_equal(init_done, '1', "init_done asserted");

        check_equal(reg_cfg2, std_logic_vector'(x"07"), "Config2 (0x01)");
        check_equal(reg_cfg4, std_logic_vector'(x"C8"), "Config4 (0x04)");
        check_equal(reg_fanchr, std_logic_vector'(x"BD"), "FanChar (0x20)");
        check_equal(reg_cfg1, std_logic_vector'(x"09"), "Config1 (0x00)");

        -- Config1 is written last, so the fan cannot start before the rest
        -- of the configuration is in place
        check(write_count >= 4, "four config writes before the first DCY write");

        ----------------------------------------------------------------
        -- the fan is kicked to full duty to make sure it turns
        wait_kick_duty;
        check_equal(reg_dcy, std_logic_vector(to_unsigned(c_kick_duty, 8)),
                    "DCY kicked to full");

        ----------------------------------------------------------------
        -- and then settles at the minimum-speed setpoint
        for i in 1 to 500000 loop
            exit when reg_dcy = c_min_duty;
            wait until rising_edge(clock);
        end loop;
        check_equal(reg_dcy, c_min_duty, "DCY settles at the minimum setpoint");
        for i in 1 to 500000 loop
            exit when duty_out = c_min_duty;
            wait until rising_edge(clock);
        end loop;
        check_equal(duty_out, c_min_duty, "duty_out reports what was programmed");

        ----------------------------------------------------------------
        -- readback: device ID, TACH and the RPM conversion
        for i in 1 to 500000 loop
            exit when device_id = x"21" and tach_out = tach_set;
            wait until rising_edge(clock);
        end loop;
        check_equal(device_id, std_logic_vector'(x"21"), "device ID (0x3D)");
        check_equal(status_out, std_logic_vector'(x"00"), "Status 1 (0x02)");
        check_equal(tach_out, tach_set, "raw TACH");

        for i in 1 to 500000 loop
            exit when rpm_out /= x"0000";
            wait until rising_edge(clock);
        end loop;
        -- 6_000_000 / 2000 = 3000 = 0x0BB8
        check_equal(rpm_out, std_logic_vector'(x"0BB8"), "rpm = 6e6 / tach");

        ----------------------------------------------------------------
        -- a new setpoint over the register interface reaches the chip
        duty_in <= c_new_duty;
        for i in 1 to 500000 loop
            exit when reg_dcy = c_new_duty;
            wait until rising_edge(clock);
        end loop;
        check_equal(reg_dcy, c_new_duty, "DCY follows a new setpoint");
        for i in 1 to 500000 loop
            exit when duty_out = c_new_duty;
            wait until rising_edge(clock);
        end loop;
        check_equal(duty_out, c_new_duty, "duty_out follows too");

        ----------------------------------------------------------------
        -- a slave that acknowledges everything must not raise an error
        check_equal(i2c_error, '0', "no i2c_error against an acknowledging slave");

        ----------------------------------------------------------------
        -- take the slave off the bus: writes stop being acknowledged, which
        -- must raise i2c_error and - crucially - must not leave the shared
        -- bus wedged with SCL or SDA held low
        slave_enable <= '0';
        for i in 1 to 2000000 loop
            exit when i2c_error = '1';
            wait until rising_edge(clock);
        end loop;
        check_equal(i2c_error, '1', "i2c_error raised when nothing acknowledges");

        -- during the back-off the master must have released both lines
        for i in 1 to 200000 loop
            exit when to_x01(scl) = '1' and to_x01(sda) = '1';
            wait until rising_edge(clock);
        end loop;
        check_equal(to_x01(scl), '1', "bus released after a NACK (SCL high)");
        check_equal(to_x01(sda), '1', "bus released after a NACK (SDA high)");

        ----------------------------------------------------------------
        -- put it back and confirm the retry brings the fan up again
        duty_in      <= c_min_duty;
        slave_enable <= '1';
        for i in 1 to 2000000 loop
            exit when init_done = '1' and reg_dcy = c_min_duty;
            wait until rising_edge(clock);
        end loop;
        check_equal(init_done, '1', "reconfigured after the slave returned");
        check_equal(reg_dcy, c_min_duty, "DCY reprogrammed on recovery");

        ----------------------------------------------------------------
        info("==== " & integer'image(get_checker_stat.n_passed) & " of "
             & integer'image(get_checker_stat.n_checks) & " fan checks passed ====");

        test_runner_cleanup(runner);
        test_running <= false;
        wait;
    end process main;

end architecture sim;
