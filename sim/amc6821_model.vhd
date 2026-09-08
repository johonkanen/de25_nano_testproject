------------------------------------------------------------------------
-- amc6821_model - simulation-only I2C slave model of the AMC6821 fan
-- controller, enough of it to verify amc6821_fan_control against.
--
-- Bit-level: it tracks START / repeated START / STOP, matches its own
-- address, acknowledges byte by byte, and implements the pointer-then-data
-- register access the real chip uses. It is deliberately strict - a master
-- that gets the framing wrong will fail to read its registers back rather
-- than quietly working.
--
-- Reads are answered from a register file preloaded with the datasheet
-- power-on defaults, except:
--   0x08 / 0x09  TACH data low / high - driven from the tach_set input, so
--                the testbench can pretend the fan is spinning at a speed
--   0x3D         device ID, reads 0x21
--
-- Writes land in the register file and are also broken out as ports so the
-- testbench can check what the DUT configured.
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity amc6821_model is
    generic (
        g_addr : std_logic_vector(6 downto 0) := "0101110"      -- 0x2E
    );
    port (
        scl         : in    std_logic
        ;sda        : inout std_logic
        -- testbench-controlled fan speed, reported through TACH 0x08 / 0x09
        ;tach_set   : in    std_logic_vector(15 downto 0)
        -- drive low to make the chip act absent: it stops acknowledging its
        -- address, which is what a broken bus or a wrong address looks like
        ;enable     : in    std_logic := '1'
        -- register file taps for checking
        ;reg_dcy    : out   std_logic_vector(7 downto 0)
        ;reg_cfg1   : out   std_logic_vector(7 downto 0)
        ;reg_cfg2   : out   std_logic_vector(7 downto 0)
        ;reg_cfg4   : out   std_logic_vector(7 downto 0)
        ;reg_fanchr : out   std_logic_vector(7 downto 0)
        ;write_count : out  natural
    );
end entity amc6821_model;

architecture model of amc6821_model is

    signal scl_c : std_logic;
    signal sda_c : std_logic;

    -- '0' pulls the line down, 'Z' releases it
    signal sda_drive : std_logic := 'Z';

begin

    scl_c <= to_x01(scl);
    sda_c <= to_x01(sda);
    sda   <= sda_drive;

    slave : process (scl_c, sda_c) is

        type t_regs is array (0 to 255) of std_logic_vector(7 downto 0);

        type t_phase is (ph_idle, ph_addr, ph_addr_ack,
                         ph_wdata, ph_wdata_ack, ph_rdata, ph_rdata_ack);

        variable regs      : t_regs := (others => x"00");
        variable defaulted : boolean := false;

        variable phase     : t_phase := ph_idle;
        variable shreg     : std_logic_vector(7 downto 0) := (others => '0');
        variable bit_cnt   : natural range 0 to 8 := 0;
        variable selected  : boolean := false;   -- address matched
        variable reading   : boolean := false;   -- master is reading
        variable have_ptr  : boolean := false;   -- pointer byte received
        variable pointer   : natural range 0 to 255 := 0;
        variable n_writes  : natural := 0;

        procedure load_defaults is
        begin
            regs := (others => x"00");
            regs(16#00#) := x"D4";      -- Configuration 1
            regs(16#01#) := x"3D";      -- Configuration 2
            regs(16#04#) := x"08";      -- Configuration 4
            regs(16#20#) := x"1D";      -- Fan characteristics
            regs(16#21#) := x"55";      -- DCY-Low-Temp
            regs(16#22#) := x"55";      -- DCY
            regs(16#3D#) := x"21";      -- Device ID
            regs(16#3E#) := x"49";      -- Company ID
            regs(16#3F#) := x"82";      -- Configuration 3
        end procedure load_defaults;

        -- value returned for a read of the current pointer
        impure function read_reg return std_logic_vector is
        begin
            case pointer is
                when 16#08# => return tach_set(7 downto 0);
                when 16#09# => return tach_set(15 downto 8);
                when others => return regs(pointer);
            end case;
        end function read_reg;

    begin
        if not defaulted then
            load_defaults;
            defaulted := true;
        end if;

------------------------------------------------------------------------
        -- START / repeated START: SDA falls while SCL is high
        if falling_edge(sda_c) and scl_c = '1' then
            phase     := ph_addr;
            bit_cnt   := 0;
            shreg     := (others => '0');
            selected  := false;
            reading   := false;
            have_ptr  := false;
            sda_drive <= 'Z';

        -- STOP: SDA rises while SCL is high
        elsif rising_edge(sda_c) and scl_c = '1' then
            phase     := ph_idle;
            selected  := false;
            sda_drive <= 'Z';

------------------------------------------------------------------------
        -- sample on the rising edge of SCL
        elsif rising_edge(scl_c) then
            case phase is

                when ph_addr | ph_wdata =>
                    shreg   := shreg(6 downto 0) & sda_c;
                    bit_cnt := bit_cnt + 1;

                when ph_rdata_ack =>
                    -- master NACKs to end the read; either way we are done
                    phase := ph_idle;

                when others =>
                    null;
            end case;

------------------------------------------------------------------------
        -- act on the falling edge of SCL
        elsif falling_edge(scl_c) then
            case phase is

                when ph_addr =>
                    if bit_cnt = 8 then
                        if shreg(7 downto 1) = g_addr and enable = '1' then
                            selected  := true;
                            reading   := shreg(0) = '1';
                            sda_drive <= '0';           -- ACK
                        else
                            selected  := false;
                            sda_drive <= 'Z';           -- NACK
                        end if;
                        phase   := ph_addr_ack;
                        bit_cnt := 0;
                    end if;

                when ph_addr_ack =>
                    sda_drive <= 'Z';
                    if not selected then
                        phase := ph_idle;
                    elsif reading then
                        shreg     := read_reg;
                        sda_drive <= '0' when shreg(7) = '0' else 'Z';
                        bit_cnt   := 1;
                        phase     := ph_rdata;
                    else
                        bit_cnt := 0;
                        shreg   := (others => '0');
                        phase   := ph_wdata;
                    end if;

                when ph_wdata =>
                    if bit_cnt = 8 then
                        if have_ptr then
                            regs(pointer) := shreg;
                            n_writes      := n_writes + 1;
                        else
                            pointer  := to_integer(unsigned(shreg));
                            have_ptr := true;
                        end if;
                        sda_drive <= '0';               -- ACK
                        phase     := ph_wdata_ack;
                        bit_cnt   := 0;
                    end if;

                when ph_wdata_ack =>
                    sda_drive <= 'Z';
                    shreg     := (others => '0');
                    bit_cnt   := 0;
                    phase     := ph_wdata;              -- more data may follow

                when ph_rdata =>
                    if bit_cnt = 8 then
                        sda_drive <= 'Z';               -- let the master ACK
                        phase     := ph_rdata_ack;
                        bit_cnt   := 0;
                    else
                        sda_drive <= '0' when shreg(7 - bit_cnt) = '0' else 'Z';
                        bit_cnt   := bit_cnt + 1;
                    end if;

                when others =>
                    sda_drive <= 'Z';

            end case;
        end if;

------------------------------------------------------------------------
        reg_dcy     <= regs(16#22#);
        reg_cfg1    <= regs(16#00#);
        reg_cfg2    <= regs(16#01#);
        reg_cfg4    <= regs(16#04#);
        reg_fanchr  <= regs(16#20#);
        write_count <= n_writes;

    end process slave;

end architecture model;
