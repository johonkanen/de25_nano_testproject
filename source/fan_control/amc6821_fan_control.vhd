------------------------------------------------------------------------
-- amc6821_fan_control - drive the DE25-Nano's fan through the on-board
-- AMC6821 temperature monitor / PWM fan controller, and report back the
-- measured fan speed.
--
-- The AMC6821 sits on the board's HDMI I2C bus (HDMI_I2C_SCL PIN_BT1 /
-- HDMI_I2C_SDA PIN_BW2, 3.3-V LVCMOS) at 7-bit address 0x2E, shared with
-- the ADV7513 HDMI transmitter at a different address. Terasic's
-- Demonstration/FPGA/Board_Info_RTL/board_management_ip/BOARD_MANAGEMENT.v
-- is the reference for the bus, the address and the board-specific bits.
--
-- Control mode: Software-DCY (open loop).  [FDRC1:FDRC0] = 00, so the duty
-- cycle written to the DCY register (0x22) drives the PWM output directly
-- and immediately - 0x00 = 0 % (fan off), 0xFF = 100 %. duty_in is that
-- register, so the fan speed maps straight onto a UART register with no
-- regulator in between.
--
-- Why not Software-RPM mode (what Terasic uses)?  That mode is a closed
-- loop onto a target TACH value: asking for an RPM the fan cannot reach
-- makes the regulator wind the duty cycle to an extreme rather than settle,
-- which is the opposite of a predictable "run at minimum" setting.
--
-- Startup: the AMC6821 runs its own spin-up at power-on and lands at 33 %
-- duty. This module then configures the chip and drives the fan to whatever
-- duty_in says - the minimum speed comes from the reset value of the duty
-- register in the top level, so there is one source of truth for it.
-- Because a fan may not start from rest at a low duty cycle, the duty is
-- first held at g_kick_duty for g_kick_cycles core clocks and only then
-- dropped to duty_in, so "initialise to minimum speed" means the fan
-- actually turns. Set g_kick_cycles to 0 to skip the kick.
--
-- Spin-up (FSPD bit of 0x20) is deliberately DISABLED. With spin-up on, the
-- AMC6821 shoves the duty cycle back up to 33 % every time it measures an
-- RPM below its TACH low limit, which fights a deliberately low setpoint.
--
-- Thermal fail-safe is deliberately KEPT: Configuration Register 3 is left
-- at its 0x82 default so THERM-FAN-EN stays set, and the AMC6821 forces the
-- fan to 100 % on its own if either temperature sensor crosses the THERM
-- limit. This is hardware behaviour, independent of the duty cycle asked
-- for here, and it is the safety net for running the fan slowly.  (Terasic
-- writes 0x02 to this register, which clears THERM-FAN-EN and throws that
-- protection away.)
--
-- Register values written, all board-specific bits following Terasic:
--   0x01 Config2 = 0x07  PWM-EN=1, TACH-EN=1, TACH-MODE=1, interrupts off
--                        TACH-MODE=1 is required for a 4-wire dc-powered
--                        fan, and also keeps RPM monitoring alive - and
--                        stops DCY being forced to 0 - below 7 % duty.
--   0x04 Config4 = 0xC8  PSPR=1 (four TACH pulses per revolution),
--                        TACH-FAST=1 (250 ms RPM updates instead of 1 s)
--   0x20 FanChar = 0xBD  FSPD=1 (spin-up off), PWM=111 (40 kHz), STIME=101
--   0x22 DCY     = duty  the fan speed setpoint
--   0x00 Config1 = 0x09  written last: FDRC=00 (software DCY), PWMINV=1,
--                        START=1.  PWMINV=1 matches the board's NMOS fan
--                        drive - with PWMINV=0 the PWM pin polarity is
--                        inverted and a low duty request would run the fan
--                        fast.
--
-- Then it polls, forever: DCY (only when duty_in changes), device ID
-- (0x3D, reads 0x21), Status 1 (0x02) and TACH data (0x08 / 0x09).
--
-- Fan speed, per the AMC6821 datasheet with PSPR = 1:
--     RPM = (100000 * 60) / TACH = 6000000 / TACH
-- computed here by a sequential divider, so rpm_out is in RPM directly.
------------------------------------------------------------------------
--
-- A write the AMC6821 does not acknowledge aborts the transaction with a
-- STOP - never mid-frame, which would wedge the shared bus - raises
-- i2c_error, and retries the whole configuration after a back-off.
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.i2c_master_pkg.all;

entity amc6821_fan_control is
    generic (
        g_clock_hz     : natural := 50_000_000
        ;g_scl_hz      : natural := 100_000
        -- AMC6821 7-bit address on the DE25-Nano (Terasic uses 0x5C as the
        -- 8-bit write address, i.e. 0x2E << 1).
        ;g_slave_addr  : std_logic_vector(6 downto 0) := "0101110"   -- 0x2E
        -- brief higher duty to get the fan turning, then drop to duty_in
        ;g_kick_duty   : natural range 0 to 255 := 255               -- 100 %
        ;g_kick_cycles : natural := 25_000_000                       -- 0.5 s
        -- gap between poll cycles
        ;g_poll_cycles : natural := 5_000_000                        -- 100 ms
        -- settling time before the first config, and the back-off after an
        -- I2C error (~100 ms at 50 MHz)
        ;g_por_cycles  : natural := 5_000_000
    );
    port (
        clock       : in  std_logic
        ;reset      : in  std_logic                       -- synchronous, active high
        -- fan speed setpoint: AMC6821 DCY register, 0 = off, 255 = full
        ;duty_in    : in  std_logic_vector(7 downto 0)
        -- measurements
        ;rpm_out    : out std_logic_vector(15 downto 0)   -- 6000000 / tach
        ;tach_out   : out std_logic_vector(15 downto 0)   -- raw TACH data
        ;device_id  : out std_logic_vector(7 downto 0)    -- 0x3D, reads 0x21
        ;status_out : out std_logic_vector(7 downto 0)    -- 0x02, Status 1
        ;duty_out   : out std_logic_vector(7 downto 0)    -- duty last programmed
        ;init_done  : out std_logic                       -- config sequence sent
        ;i2c_error  : out std_logic                       -- a write went unacknowledged
        -- open-drain I2C pins
        ;sda_in     : in  std_logic
        ;sda_low    : out std_logic
        ;scl_low    : out std_logic
    );
end entity amc6821_fan_control;

architecture rtl of amc6821_fan_control is

    function max2 (a, b : natural) return natural is
    begin
        if a > b then return a; else return b; end if;
    end function max2;

    ------------------------------------------------------------------
    -- AMC6821 register addresses
    constant c_reg_config1 : std_logic_vector(7 downto 0) := x"00";
    constant c_reg_config2 : std_logic_vector(7 downto 0) := x"01";
    constant c_reg_status1 : std_logic_vector(7 downto 0) := x"02";
    constant c_reg_config4 : std_logic_vector(7 downto 0) := x"04";
    constant c_reg_tach_l  : std_logic_vector(7 downto 0) := x"08";
    constant c_reg_tach_h  : std_logic_vector(7 downto 0) := x"09";
    constant c_reg_fanchar : std_logic_vector(7 downto 0) := x"20";
    constant c_reg_dcy     : std_logic_vector(7 downto 0) := x"22";
    constant c_reg_devid   : std_logic_vector(7 downto 0) := x"3D";

    ------------------------------------------------------------------
    -- the configuration script; Config1 is written last so that the chip
    -- only starts once every other setting is in place
    type t_reg_write is record
        reg  : std_logic_vector(7 downto 0);
        data : std_logic_vector(7 downto 0);
    end record;

    type t_reg_write_array is array (natural range <>) of t_reg_write;

    constant c_config : t_reg_write_array := (
         (c_reg_config2, x"07")
        ,(c_reg_config4, x"C8")
        ,(c_reg_fanchar, x"BD")
        ,(c_reg_config1, x"09")
    );

    -- registers polled every cycle, in order
    type t_reg_array is array (natural range <>) of std_logic_vector(7 downto 0);

    constant c_poll : t_reg_array := (
         c_reg_devid
        ,c_reg_status1
        ,c_reg_tach_l
        ,c_reg_tach_h
    );

    ------------------------------------------------------------------
    signal addr_write : std_logic_vector(7 downto 0);
    signal addr_read  : std_logic_vector(7 downto 0);

    ------------------------------------------------------------------
    -- top-level sequencer
    type t_state is (st_por_wait, st_config, st_kick_wait, st_write_duty,
                     st_poll, st_poll_wait, st_error_wait);

    signal state : t_state := st_por_wait;

    constant c_delay_max : natural :=
        max2(g_por_cycles, max2(g_kick_cycles, g_poll_cycles));

    signal cfg_index  : natural range 0 to c_config'high := 0;
    signal poll_index : natural range 0 to c_poll'high   := 0;
    signal delay      : natural range 0 to c_delay_max   := 0;

    -- the duty cycle currently programmed into the chip, and the target
    signal duty_target  : std_logic_vector(7 downto 0) := (others => '0');
    signal duty_written : std_logic_vector(7 downto 0) := (others => '0');
    signal kick_done    : std_logic := '0';

    signal tach_lo      : std_logic_vector(7 downto 0) := (others => '0');
    signal tach_word    : unsigned(15 downto 0) := (others => '0');
    signal tach_update  : std_logic := '0';

    ------------------------------------------------------------------
    -- one I2C transaction: a register write or a register read
    --   write_reg : START, addr+W, reg, data, STOP
    --   read_reg  : START, addr+W, reg, START, addr+R, read+NACK, STOP
    type t_xact is (xact_idle, xact_write_reg, xact_read_reg);

    -- driven by the sequencer
    signal xact       : t_xact := xact_idle;
    signal xact_start : std_logic := '0';
    signal xact_reg   : std_logic_vector(7 downto 0) := (others => '0');
    signal xact_wdata : std_logic_vector(7 downto 0) := (others => '0');

    -- driven by the transaction sequencer
    signal xact_busy  : std_logic := '0';
    signal xact_done  : std_logic := '0';
    signal xact_err   : std_logic := '0';
    signal xact_abort : std_logic := '0';
    -- set only while the op just issued was a write, so a stale ack_err from
    -- an earlier failure cannot abort the transaction that is retrying
    signal check_ack  : std_logic := '0';
    signal xact_rdata : std_logic_vector(7 downto 0) := (others => '0');
    signal xact_step  : natural range 0 to 7 := 0;

    -- i2c_master handshake
    signal i2c_req      : std_logic := '0';
    signal i2c_op       : t_i2c_op := i2c_op_start;
    signal i2c_wr_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal i2c_read_ack : std_logic := '0';
    signal i2c_busy     : std_logic;
    signal i2c_done     : std_logic;
    signal i2c_rd_data  : std_logic_vector(7 downto 0);
    signal i2c_ack_err  : std_logic;

    ------------------------------------------------------------------
    -- sequential restoring divider: rpm = 6_000_000 / tach
    constant c_rpm_numerator : natural := 6_000_000;
    constant c_dw            : natural := 24;          -- 6e6 needs 23 bits

    signal div_num  : unsigned(c_dw - 1 downto 0) := (others => '0');
    signal div_rem  : unsigned(c_dw - 1 downto 0) := (others => '0');
    signal div_quot : unsigned(c_dw - 1 downto 0) := (others => '0');
    signal div_den  : unsigned(c_dw - 1 downto 0) := (others => '0');
    signal div_step : natural range 0 to c_dw     := 0;
    signal div_busy : std_logic := '0';
    signal rpm_reg  : std_logic_vector(15 downto 0) := (others => '0');

begin

    addr_write <= g_slave_addr & '0';
    addr_read  <= g_slave_addr & '1';

    rpm_out    <= rpm_reg;
    tach_out   <= std_logic_vector(tach_word);
    duty_out   <= duty_written;

------------------------------------------------------------------------
    u_i2c : entity work.i2c_master
    generic map (
        g_clock_hz => g_clock_hz
        ,g_scl_hz  => g_scl_hz
    )
    port map (
        clock     => clock
        ,reset    => reset
        ,req      => i2c_req
        ,op       => i2c_op
        ,wr_data  => i2c_wr_data
        ,read_ack => i2c_read_ack
        ,busy     => i2c_busy
        ,done     => i2c_done
        ,rd_data  => i2c_rd_data
        ,ack_err  => i2c_ack_err
        ,sda_in   => sda_in
        ,sda_low  => sda_low
        ,scl_low  => scl_low
    );

------------------------------------------------------------------------
-- transaction sequencer: expands a register write or read into individual
-- START / WRITE / READ / STOP operations of the i2c_master. A byte the
-- slave does not acknowledge is followed by a STOP so the bus is always
-- released, then the transaction completes with xact_err set.
------------------------------------------------------------------------
    transaction : process (clock) is
        variable op_v : t_i2c_op;
    begin
        if rising_edge(clock) then

            i2c_req   <= '0';
            xact_done <= '0';

            if xact_busy = '1' and i2c_busy = '0' and i2c_req = '0' then

                if xact_abort = '1' then
                    -- the STOP that follows a NACK has completed
                    xact_busy  <= '0';
                    xact_done  <= '1';
                    xact_err   <= '1';
                    xact_abort <= '0';
                    xact_step  <= 0;

                elsif check_ack = '1' and i2c_ack_err = '1' then
                    -- the write just issued went unacknowledged: release the
                    -- bus with a STOP before giving up, never mid-frame
                    check_ack  <= '0';
                    xact_abort <= '1';
                    i2c_req    <= '1';
                    i2c_op     <= i2c_op_stop;

                else
                    op_v         := i2c_op_stop;
                    i2c_req      <= '1';
                    i2c_read_ack <= '0';        -- NACK terminates every read

                    case xact is

                        when xact_write_reg =>
                            case xact_step is
                                when 0 => op_v := i2c_op_start;
                                when 1 => op_v := i2c_op_write;
                                          i2c_wr_data <= addr_write;
                                when 2 => op_v := i2c_op_write;
                                          i2c_wr_data <= xact_reg;
                                when 3 => op_v := i2c_op_write;
                                          i2c_wr_data <= xact_wdata;
                                when others => op_v := i2c_op_stop;
                            end case;
                            if xact_step = 4 then
                                xact_busy <= '0';
                                xact_done <= '1';
                                xact_step <= 0;
                            else
                                xact_step <= xact_step + 1;
                            end if;

                        when xact_read_reg =>
                            case xact_step is
                                when 0 => op_v := i2c_op_start;
                                when 1 => op_v := i2c_op_write;
                                          i2c_wr_data <= addr_write;
                                when 2 => op_v := i2c_op_write;
                                          i2c_wr_data <= xact_reg;
                                when 3 => op_v := i2c_op_start;     -- repeated
                                when 4 => op_v := i2c_op_write;
                                          i2c_wr_data <= addr_read;
                                when 5 => op_v := i2c_op_read;
                                when others => op_v := i2c_op_stop;
                            end case;
                            -- step 6 issues the STOP, by which point the read
                            -- op has finished and rd_data holds the byte just
                            -- clocked in. Capturing at step 5 would latch the
                            -- previous transaction's byte.
                            if xact_step = 6 then
                                xact_rdata <= i2c_rd_data;
                            end if;
                            if xact_step = 6 then
                                xact_busy <= '0';
                                xact_done <= '1';
                                xact_step <= 0;
                            else
                                xact_step <= xact_step + 1;
                            end if;

                        when others =>
                            i2c_req   <= '0';
                            xact_busy <= '0';

                    end case;

                    i2c_op <= op_v;
                    -- only a write has an acknowledge worth judging
                    if op_v = i2c_op_write then
                        check_ack <= '1';
                    else
                        check_ack <= '0';
                    end if;
                end if;
            end if;

            -- a new transaction request always wins
            if xact_start = '1' then
                xact_busy  <= '1';
                xact_step  <= 0;
                xact_err   <= '0';
                xact_abort <= '0';
                check_ack  <= '0';
            end if;

            if reset = '1' then
                i2c_req    <= '0';
                xact_done  <= '0';
                xact_busy  <= '0';
                xact_err   <= '0';
                xact_abort <= '0';
                check_ack  <= '0';
                xact_step  <= 0;
            end if;
        end if;
    end process transaction;

------------------------------------------------------------------------
-- top-level sequencer
------------------------------------------------------------------------
    sequencer : process (clock) is

        procedure start_write (reg, data : in std_logic_vector(7 downto 0)) is
        begin
            xact       <= xact_write_reg;
            xact_reg   <= reg;
            xact_wdata <= data;
            xact_start <= '1';
        end procedure start_write;

        procedure start_read (reg : in std_logic_vector(7 downto 0)) is
        begin
            xact       <= xact_read_reg;
            xact_reg   <= reg;
            xact_start <= '1';
        end procedure start_read;

    begin
        if rising_edge(clock) then

            xact_start  <= '0';
            tach_update <= '0';
            duty_target <= duty_in;

            case state is

                -- let the AMC6821 finish its own power-on sequence
                when st_por_wait =>
                    if delay = g_por_cycles then
                        delay     <= 0;
                        cfg_index <= 0;
                        state     <= st_config;
                        start_write(c_config(0).reg, c_config(0).data);
                    else
                        delay <= delay + 1;
                    end if;

                -- walk the configuration script
                when st_config =>
                    if xact_done = '1' then
                        if xact_err = '1' then
                            i2c_error <= '1';
                            delay     <= 0;
                            state     <= st_error_wait;
                        elsif cfg_index = c_config'high then
                            init_done <= '1';
                            state     <= st_write_duty;
                            if g_kick_cycles = 0 then
                                kick_done <= '1';
                                start_write(c_reg_dcy, duty_target);
                            else
                                start_write(c_reg_dcy,
                                    std_logic_vector(to_unsigned(g_kick_duty, 8)));
                            end if;
                        else
                            cfg_index <= cfg_index + 1;
                            start_write(c_config(cfg_index + 1).reg,
                                        c_config(cfg_index + 1).data);
                        end if;
                    end if;

                -- a DCY write finished
                when st_write_duty =>
                    if xact_done = '1' then
                        if xact_err = '1' then
                            i2c_error <= '1';
                            delay     <= 0;
                            state     <= st_error_wait;
                        elsif kick_done = '0' then
                            -- that was the kick: hold it, then drop to target
                            delay <= 0;
                            state <= st_kick_wait;
                        else
                            duty_written <= xact_wdata;
                            poll_index   <= 0;
                            state        <= st_poll;
                            start_read(c_poll(0));
                        end if;
                    end if;

                when st_kick_wait =>
                    if delay = g_kick_cycles then
                        delay     <= 0;
                        kick_done <= '1';
                        state     <= st_write_duty;
                        start_write(c_reg_dcy, duty_target);
                    else
                        delay <= delay + 1;
                    end if;

                -- read back ID / status / TACH
                when st_poll =>
                    if xact_done = '1' then
                        if xact_err = '1' then
                            i2c_error <= '1';
                            delay     <= 0;
                            state     <= st_error_wait;
                        else
                            case poll_index is
                                when 0 => device_id  <= xact_rdata;
                                when 1 => status_out <= xact_rdata;
                                when 2 => tach_lo    <= xact_rdata;
                                when others =>
                                    tach_word   <= unsigned(xact_rdata) & unsigned(tach_lo);
                                    tach_update <= '1';
                            end case;

                            if poll_index = c_poll'high then
                                delay <= 0;
                                state <= st_poll_wait;
                            else
                                poll_index <= poll_index + 1;
                                start_read(c_poll(poll_index + 1));
                            end if;
                        end if;
                    end if;

                -- idle between poll cycles; a new setpoint pre-empts the wait
                when st_poll_wait =>
                    if duty_target /= duty_written then
                        delay <= 0;
                        state <= st_write_duty;
                        start_write(c_reg_dcy, duty_target);
                    elsif delay = g_poll_cycles then
                        delay      <= 0;
                        poll_index <= 0;
                        state      <= st_poll;
                        start_read(c_poll(0));
                    else
                        delay <= delay + 1;
                    end if;

                -- back off, then reconfigure from scratch. The fan is not
                -- kicked again on a retry - it is already turning.
                when st_error_wait =>
                    if delay = g_por_cycles then
                        delay     <= 0;
                        init_done <= '0';
                        kick_done <= '1';
                        cfg_index <= 0;
                        state     <= st_config;
                        start_write(c_config(0).reg, c_config(0).data);
                    else
                        delay <= delay + 1;
                    end if;

            end case;

            if reset = '1' then
                state        <= st_por_wait;
                delay        <= 0;
                cfg_index    <= 0;
                poll_index   <= 0;
                xact         <= xact_idle;
                xact_start   <= '0';
                kick_done    <= '0';
                tach_update  <= '0';
                init_done    <= '0';
                i2c_error    <= '0';
                device_id    <= (others => '0');
                status_out   <= (others => '0');
                tach_word    <= (others => '0');
                tach_lo      <= (others => '0');
                duty_written <= (others => '0');
            end if;
        end if;
    end process sequencer;

------------------------------------------------------------------------
-- rpm = 6_000_000 / tach, one bit of restoring division per clock, kicked
-- off whenever a new TACH word lands. A TACH of 0 means the fan is stopped
-- or not being measured, and reports as 0 rpm.
------------------------------------------------------------------------
    rpm_divider : process (clock) is
        variable shifted : unsigned(c_dw - 1 downto 0);
    begin
        if rising_edge(clock) then

            if div_busy = '0' then
                if tach_update = '1' then
                    if tach_word = 0 then
                        rpm_reg <= (others => '0');
                    else
                        div_den  <= resize(tach_word, c_dw);
                        div_num  <= to_unsigned(c_rpm_numerator, c_dw);
                        div_rem  <= (others => '0');
                        div_quot <= (others => '0');
                        div_step <= 0;
                        div_busy <= '1';
                    end if;
                end if;
            else
                if div_step = c_dw then
                    div_busy <= '0';
                    if div_quot > 65535 then
                        rpm_reg <= (others => '1');      -- saturate
                    else
                        rpm_reg <= std_logic_vector(resize(div_quot, 16));
                    end if;
                else
                    shifted := div_rem(c_dw - 2 downto 0) & div_num(c_dw - 1);
                    if shifted >= div_den then
                        div_rem  <= shifted - div_den;
                        div_quot <= div_quot(c_dw - 2 downto 0) & '1';
                    else
                        div_rem  <= shifted;
                        div_quot <= div_quot(c_dw - 2 downto 0) & '0';
                    end if;
                    div_num  <= div_num(c_dw - 2 downto 0) & '0';
                    div_step <= div_step + 1;
                end if;
            end if;

            if reset = '1' then
                div_busy <= '0';
                div_step <= 0;
                rpm_reg  <= (others => '0');
            end if;
        end if;
    end process rpm_divider;

end architecture rtl;
