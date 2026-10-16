------------------------------------------------------------------------
-- led_blinkers - the LED blinkers' static part: the patterns' time base,
-- the PWM, the modes that are not patterns, and where the pattern modules
-- plug in (blinkers/blinker_slot.vhd; the modules blinkers/blinker_*.vhd,
-- their common ports blinkers/blinker_pkg.vhd).
--
-- Ported from ~/dev/pr_testing (hw/led_blinkers.vhd), without the partial
-- reconfiguration partition for now - see docs/partial_reconfiguration_plan.md
-- for how u_slot becomes a reconfigurable region.
--
-- mode (register 13):
--   0 software   the LEDs are sw_leds as given (de25_nano_uart_top: LED
--                register 5 on LED[6:0], the heartbeat on LED[7])
--   1 off
--   2 counter, 3 scanner, 4 breathing, 5 sparkle
--   6, 7         treated as off
-- Each LED's brightness 0..255 is shown by PWM (~1 kHz, 256 steps). levels
-- is every LED's brightness now (LED n in bits 8n+7..8n) and id the module
-- shown (0 in modes 0 and 1), for the register file and the web GUI.
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity led_blinkers is
    generic(
        g_clock_hz : positive := 50_000_000
    );
    port(
        clock : in std_logic;
        reset : in std_logic;

        mode    : in  unsigned(2 downto 0);
        sw_leds : in  std_logic_vector(7 downto 0);

        leds   : out std_logic_vector(7 downto 0);
        levels : out std_logic_vector(63 downto 0);
        id     : out std_logic_vector(31 downto 0)
    );
end entity led_blinkers;

architecture rtl of led_blinkers is

    constant mode_software : natural := 0;

    constant frame_clocks : positive := g_clock_hz / 50;                  -- 20 ms
    constant pwm_clocks   : positive := maximum(1, g_clock_hz / 256000);  -- 256 steps at ~1 kHz

    signal frame_count : natural range 0 to frame_clocks - 1 := 0;
    signal frame       : std_logic := '0';
    signal pwm_count   : natural range 0 to pwm_clocks - 1 := 0;
    signal pwm_phase   : unsigned(7 downto 0) := (others => '0');

    signal slot_levels : std_logic_vector(63 downto 0);
    signal slot_id     : std_logic_vector(31 downto 0);
    signal shown       : std_logic_vector(63 downto 0);

begin

    -- the time bases: the patterns' frame, the PWM's phase
    timing : process(clock)
    begin
        if rising_edge(clock) then
            frame <= '0';
            if frame_count = frame_clocks - 1 then
                frame_count <= 0;
                frame       <= '1';
            else
                frame_count <= frame_count + 1;
            end if;

            if pwm_count = pwm_clocks - 1 then
                pwm_count <= 0;
                pwm_phase <= pwm_phase + 1;
            else
                pwm_count <= pwm_count + 1;
            end if;

            if reset = '1' then
                frame_count <= 0;
                frame       <= '0';
                pwm_count   <= 0;
            end if;
        end if;
    end process;

    u_slot : entity work.blinker_slot
        port map(clock => clock, reset => reset, frame => frame, sel => mode,
                 levels => slot_levels, id => slot_id);

    -- what the LEDs show: the register, nothing, or the module's brightness
    -- (blinker_slot already gives 0 for modes 1, 6 and 7)
    shown <= (63 downto 56 => sw_leds(7), 55 downto 48 => sw_leds(6),
              47 downto 40 => sw_leds(5), 39 downto 32 => sw_leds(4),
              31 downto 24 => sw_leds(3), 23 downto 16 => sw_leds(2),
              15 downto 8  => sw_leds(1), 7 downto 0   => sw_leds(0))
             when to_integer(mode) = mode_software else slot_levels;

    outputs : process(clock)
    begin
        if rising_edge(clock) then
            for i in 0 to 7 loop
                if to_integer(mode) = mode_software then
                    leds(i) <= sw_leds(i);
                elsif unsigned(shown(8 * i + 7 downto 8 * i)) > pwm_phase then
                    leds(i) <= '1';
                else
                    leds(i) <= '0';
                end if;
            end loop;
            levels <= shown;
            if to_integer(mode) = mode_software then
                id <= (others => '0');
            else
                id <= slot_id;
            end if;
        end if;
    end process;

end architecture rtl;
