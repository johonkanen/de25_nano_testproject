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
--
-- HPS (see hps/README.md): hps_min is a Platform Designer system (agilex
-- HPS + its LPDDR4 EMIF, see hps/hps_min.qsys) with every FPGA<->HPS bridge
-- disabled - it is a standalone ARM host with no memory-mapped path into this
-- entity's register file, entirely independent of the fabric UART/fan
-- logic above. It clocks and resets itself (HPS_CLK_25 in, its own POR),
-- so it needs no generic or port from the rest of this design.
--
-- HPS_UART_TX/RX (IOB15/IOB16 in the HPS pin-mux table) are HPS UART1,
-- the HPS's own console - a second, independent UART from FPGA_UART_TX/RX
-- above, reachable only from software running on the ARM cores (bare-metal
-- or Linux), never from the register interface.
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
        -- PWM. Trimmed on hardware (docs/de25_nano_fan.md): the fan gets
        -- erratic (saturated/spiking TACH readings) below ~18-22, so 30
        -- (~430 rpm) is the lowest duty that soaked cleanly - cold-starts
        -- without the kick and holds steady for 30 s.
        ;g_fan_min_duty : natural range 0 to 255 := 30            -- ~11.8 %
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

        -- ---- HPS (hps_min - see hps/README.md) ----
        -- 'in' ports default to '0'/all-zero so existing testbenches that
        -- instantiate this entity without driving them (hps_min is a
        -- separate, self-clocking subsystem no simulation here touches)
        -- still elaborate; real hardware always drives every physical pin
        -- regardless of these defaults.
        ;HPS_CLK_25        : in    std_logic := '0'
        ;HPS_SD_CLK        : out   std_logic
        ;HPS_SD_CMD        : inout std_logic
        ;HPS_SD_DATA       : inout std_logic_vector(3 downto 0)
        ;HPS_ENET_TX_CLK   : out   std_logic
        ;HPS_ENET_TX_CTL   : out   std_logic
        ;HPS_ENET_RX_CLK   : in    std_logic := '0'
        ;HPS_ENET_RX_CTL   : in    std_logic := '0'
        ;HPS_ENET_TX_DATA  : out   std_logic_vector(3 downto 0)
        ;HPS_ENET_RX_DATA  : in    std_logic_vector(3 downto 0) := (others => '0')
        ;HPS_ENET_MDIO     : inout std_logic
        ;HPS_ENET_MDC      : out   std_logic
        ;HPS_UART_TX       : out   std_logic                  -- HPS UART1 TX (IOB15)
        ;HPS_UART_RX       : in    std_logic := '0'            -- HPS UART1 RX (IOB16)
        ;HPS_KEY           : inout std_logic
        ;HPS_LED           : inout std_logic

        -- ---- HPS LPDDR4 EMIF (hps_min) ----
        ;LPDDR4A_REFCLK_p : in    std_logic := '0'
        ;LPDDR4A_CS_n     : out   std_logic
        ;LPDDR4A_CA       : out   std_logic_vector(5 downto 0)
        ;LPDDR4A_CK       : out   std_logic
        ;LPDDR4A_CKE      : out   std_logic
        ;LPDDR4A_CK_n     : out   std_logic
        ;LPDDR4A_DM       : inout std_logic_vector(3 downto 0)
        ;LPDDR4A_DQ       : inout std_logic_vector(31 downto 0)
        ;LPDDR4A_DQS      : inout std_logic_vector(3 downto 0)
        ;LPDDR4A_DQS_n    : inout std_logic_vector(3 downto 0)
        ;LPDDR4A_RESET_n  : out   std_logic
        ;LPDDR4A_RZQ      : in    std_logic := '0'
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
    component hps_subsys is
        port (
            h2f_reset_reset                       : out   std_logic;                                        -- reset
            lwhps2fpga_axi_clock_clk              : in    std_logic                     := 'X';             -- clk
            lwhps2fpga_axi_reset_reset            : in    std_logic                     := 'X';             -- reset
            lwhps2fpga_awid                       : out   std_logic_vector(3 downto 0);                     -- awid
            lwhps2fpga_awaddr                     : out   std_logic_vector(28 downto 0);                    -- awaddr
            lwhps2fpga_awlen                      : out   std_logic_vector(7 downto 0);                     -- awlen
            lwhps2fpga_awsize                     : out   std_logic_vector(2 downto 0);                     -- awsize
            lwhps2fpga_awburst                    : out   std_logic_vector(1 downto 0);                     -- awburst
            lwhps2fpga_awlock                     : out   std_logic;                                        -- awlock
            lwhps2fpga_awcache                    : out   std_logic_vector(3 downto 0);                     -- awcache
            lwhps2fpga_awprot                     : out   std_logic_vector(2 downto 0);                     -- awprot
            lwhps2fpga_awvalid                    : out   std_logic;                                        -- awvalid
            lwhps2fpga_awready                    : in    std_logic                     := 'X';             -- awready
            lwhps2fpga_wdata                      : out   std_logic_vector(31 downto 0);                    -- wdata
            lwhps2fpga_wstrb                      : out   std_logic_vector(3 downto 0);                     -- wstrb
            lwhps2fpga_wlast                      : out   std_logic;                                        -- wlast
            lwhps2fpga_wvalid                     : out   std_logic;                                        -- wvalid
            lwhps2fpga_wready                     : in    std_logic                     := 'X';             -- wready
            lwhps2fpga_bid                        : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- bid
            lwhps2fpga_bresp                      : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- bresp
            lwhps2fpga_bvalid                     : in    std_logic                     := 'X';             -- bvalid
            lwhps2fpga_bready                     : out   std_logic;                                        -- bready
            lwhps2fpga_arid                       : out   std_logic_vector(3 downto 0);                     -- arid
            lwhps2fpga_araddr                     : out   std_logic_vector(28 downto 0);                    -- araddr
            lwhps2fpga_arlen                      : out   std_logic_vector(7 downto 0);                     -- arlen
            lwhps2fpga_arsize                     : out   std_logic_vector(2 downto 0);                     -- arsize
            lwhps2fpga_arburst                    : out   std_logic_vector(1 downto 0);                     -- arburst
            lwhps2fpga_arlock                     : out   std_logic;                                        -- arlock
            lwhps2fpga_arcache                    : out   std_logic_vector(3 downto 0);                     -- arcache
            lwhps2fpga_arprot                     : out   std_logic_vector(2 downto 0);                     -- arprot
            lwhps2fpga_arvalid                    : out   std_logic;                                        -- arvalid
            lwhps2fpga_arready                    : in    std_logic                     := 'X';             -- arready
            lwhps2fpga_rid                        : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rid
            lwhps2fpga_rdata                      : in    std_logic_vector(31 downto 0) := (others => 'X'); -- rdata
            lwhps2fpga_rresp                      : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- rresp
            lwhps2fpga_rlast                      : in    std_logic                     := 'X';             -- rlast
            lwhps2fpga_rvalid                     : in    std_logic                     := 'X';             -- rvalid
            lwhps2fpga_rready                     : out   std_logic;                                        -- rready
            hps_uart0_cts_n                       : in    std_logic                     := 'X';             -- cts_n
            hps_uart0_dcd_n                       : in    std_logic                     := 'X';             -- dcd_n
            hps_uart0_dsr_n                       : in    std_logic                     := 'X';             -- dsr_n
            hps_uart0_dtr_n                       : out   std_logic;                                        -- dtr_n
            hps_uart0_out1_n                      : out   std_logic;                                        -- out1_n
            hps_uart0_out2_n                      : out   std_logic;                                        -- out2_n
            hps_uart0_ri_n                        : in    std_logic                     := 'X';             -- ri_n
            hps_uart0_rts_n                       : out   std_logic;                                        -- rts_n
            hps_uart0_rx                          : in    std_logic                     := 'X';             -- rx
            hps_uart0_tx                          : out   std_logic;                                        -- tx
            hps_io_hps_osc_clk                    : in    std_logic                     := 'X';             -- hps_osc_clk
            hps_io_sdmmc_data0                    : inout std_logic                     := 'X';             -- sdmmc_data0
            hps_io_sdmmc_data1                    : inout std_logic                     := 'X';             -- sdmmc_data1
            hps_io_sdmmc_cclk                     : out   std_logic;                                        -- sdmmc_cclk
            hps_io_sdmmc_data2                    : inout std_logic                     := 'X';             -- sdmmc_data2
            hps_io_sdmmc_data3                    : inout std_logic                     := 'X';             -- sdmmc_data3
            hps_io_sdmmc_cmd                      : inout std_logic                     := 'X';             -- sdmmc_cmd
            hps_io_emac0_tx_clk                   : out   std_logic;                                        -- emac0_tx_clk
            hps_io_emac0_tx_ctl                   : out   std_logic;                                        -- emac0_tx_ctl
            hps_io_emac0_rx_clk                   : in    std_logic                     := 'X';             -- emac0_rx_clk
            hps_io_emac0_rx_ctl                   : in    std_logic                     := 'X';             -- emac0_rx_ctl
            hps_io_emac0_txd0                     : out   std_logic;                                        -- emac0_txd0
            hps_io_emac0_txd1                     : out   std_logic;                                        -- emac0_txd1
            hps_io_emac0_rxd0                     : in    std_logic                     := 'X';             -- emac0_rxd0
            hps_io_emac0_rxd1                     : in    std_logic                     := 'X';             -- emac0_rxd1
            hps_io_emac0_txd2                     : out   std_logic;                                        -- emac0_txd2
            hps_io_emac0_txd3                     : out   std_logic;                                        -- emac0_txd3
            hps_io_emac0_rxd2                     : in    std_logic                     := 'X';             -- emac0_rxd2
            hps_io_emac0_rxd3                     : in    std_logic                     := 'X';             -- emac0_rxd3
            hps_io_mdio0_mdio                     : inout std_logic                     := 'X';             -- mdio0_mdio
            hps_io_mdio0_mdc                      : out   std_logic;                                        -- mdio0_mdc
            hps_io_uart1_tx                       : out   std_logic;                                        -- uart1_tx
            hps_io_uart1_rx                       : in    std_logic                     := 'X';             -- uart1_rx
            hps_io_gpio40                         : inout std_logic                     := 'X';             -- gpio40
            hps_io_gpio41                         : inout std_logic                     := 'X';             -- gpio41
            f2h_irq1_in_irq                       : in    std_logic_vector(31 downto 0) := (others => 'X'); -- irq
            f2h_irq0_in_irq                       : in    std_logic_vector(31 downto 0) := (others => 'X'); -- irq
            emif_hps_emif_mem_0_mem_cs            : out   std_logic_vector(0 downto 0);                     -- mem_cs
            emif_hps_emif_mem_0_mem_ca            : out   std_logic_vector(5 downto 0);                     -- mem_ca
            emif_hps_emif_mem_0_mem_cke           : out   std_logic_vector(0 downto 0);                     -- mem_cke
            emif_hps_emif_mem_0_mem_dq            : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
            emif_hps_emif_mem_0_mem_dqs_t         : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_t
            emif_hps_emif_mem_0_mem_dqs_c         : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_c
            emif_hps_emif_mem_0_mem_dmi           : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dmi
            emif_hps_emif_mem_ck_0_mem_ck_t       : out   std_logic_vector(0 downto 0);                     -- mem_ck_t
            emif_hps_emif_mem_ck_0_mem_ck_c       : out   std_logic_vector(0 downto 0);                     -- mem_ck_c
            emif_hps_emif_mem_reset_n_mem_reset_n : out   std_logic;                                        -- mem_reset_n
            emif_hps_emif_oct_0_oct_rzqin         : in    std_logic                     := 'X';             -- oct_rzqin
            emif_hps_emif_ref_clk_clk             : in    std_logic                     := 'X';             -- clk
            ninit_done_reset                      : out   std_logic                                         -- reset
        );
    end component hps_subsys;

    -- hps_subsys emits these EMIF signals as 1-bit vectors; the top-level
    -- LPDDR4A_* pins are scalars, so bridge through a signal.
    signal ddr_cs_vec   : std_logic_vector(0 downto 0);
    signal ddr_cke_vec  : std_logic_vector(0 downto 0);
    signal ddr_ck_t_vec : std_logic_vector(0 downto 0);
    signal ddr_ck_c_vec : std_logic_vector(0 downto 0);

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

------------------------------------------------------------------------
-- Agilex 5 HPS + LPDDR4 EMIF - standalone (bridges disabled), clocks and
-- resets itself. See hps/README.md.
------------------------------------------------------------------------

    -- lwhps2fpga_* is Not wired up yet, will be used later. Everything the
    -- component drives is left open; everything it needs driven back is
    -- tied to a safe idle value.
    -- hps_uart0_* has no board pins (only uart1 is routed - see HPS_UART_TX/RX
    -- above), so it's tied off inactive/idle rather than wired anywhere.
    u0 : component hps_subsys
        port map (
            h2f_reset_reset                       => open,                                --                 h2f_reset.reset
            lwhps2fpga_axi_clock_clk              => core_clock,                           --      lwhps2fpga_axi_clock.clk
            lwhps2fpga_axi_reset_reset            => system_reset,                         --      lwhps2fpga_axi_reset.reset
            lwhps2fpga_awid                       => open,                                 --                lwhps2fpga.awid
            lwhps2fpga_awaddr                     => open,                                 --                          .awaddr
            lwhps2fpga_awlen                      => open,                                 --                          .awlen
            lwhps2fpga_awsize                     => open,                                 --                          .awsize
            lwhps2fpga_awburst                    => open,                                 --                          .awburst
            lwhps2fpga_awlock                     => open,                                 --                          .awlock
            lwhps2fpga_awcache                    => open,                                 --                          .awcache
            lwhps2fpga_awprot                     => open,                                 --                          .awprot
            lwhps2fpga_awvalid                    => open,                                 --                          .awvalid
            lwhps2fpga_awready                    => '0',                                  --                          .awready
            lwhps2fpga_wdata                      => open,                                 --                          .wdata
            lwhps2fpga_wstrb                      => open,                                 --                          .wstrb
            lwhps2fpga_wlast                      => open,                                 --                          .wlast
            lwhps2fpga_wvalid                     => open,                                 --                          .wvalid
            lwhps2fpga_wready                     => '0',                                  --                          .wready
            lwhps2fpga_bid                        => (others => '0'),                      --                          .bid
            lwhps2fpga_bresp                      => (others => '0'),                      --                          .bresp
            lwhps2fpga_bvalid                     => '0',                                  --                          .bvalid
            lwhps2fpga_bready                     => open,                                 --                          .bready
            lwhps2fpga_arid                       => open,                                 --                          .arid
            lwhps2fpga_araddr                     => open,                                 --                          .araddr
            lwhps2fpga_arlen                      => open,                                 --                          .arlen
            lwhps2fpga_arsize                     => open,                                 --                          .arsize
            lwhps2fpga_arburst                    => open,                                 --                          .arburst
            lwhps2fpga_arlock                     => open,                                 --                          .arlock
            lwhps2fpga_arcache                    => open,                                 --                          .arcache
            lwhps2fpga_arprot                     => open,                                 --                          .arprot
            lwhps2fpga_arvalid                    => open,                                 --                          .arvalid
            lwhps2fpga_arready                    => '0',                                  --                          .arready
            lwhps2fpga_rid                        => (others => '0'),                      --                          .rid
            lwhps2fpga_rdata                      => (others => '0'),                      --                          .rdata
            lwhps2fpga_rresp                      => (others => '0'),                      --                          .rresp
            lwhps2fpga_rlast                      => '0',                                  --                          .rlast
            lwhps2fpga_rvalid                     => '0',                                  --                          .rvalid
            lwhps2fpga_rready                     => open,                                 --                          .rready
            hps_uart0_cts_n                       => '0',                                  --                 hps_uart0.cts_n
            hps_uart0_dcd_n                       => '0',                                  --                          .dcd_n
            hps_uart0_dsr_n                       => '0',                                  --                          .dsr_n
            hps_uart0_dtr_n                       => open,                                 --                          .dtr_n
            hps_uart0_out1_n                      => open,                                 --                          .out1_n
            hps_uart0_out2_n                      => open,                                 --                          .out2_n
            hps_uart0_ri_n                        => '1',                                  --                          .ri_n
            hps_uart0_rts_n                       => open,                                 --                          .rts_n
            hps_uart0_rx                          => '1',                                  --                          .rx
            hps_uart0_tx                          => open,                                 --                          .tx
            hps_io_hps_osc_clk                    => HPS_CLK_25,                           --                    hps_io.hps_osc_clk
            hps_io_sdmmc_data0                    => HPS_SD_DATA(0),                       --                          .sdmmc_data0
            hps_io_sdmmc_data1                    => HPS_SD_DATA(1),                       --                          .sdmmc_data1
            hps_io_sdmmc_cclk                     => HPS_SD_CLK,                           --                          .sdmmc_cclk
            hps_io_sdmmc_data2                    => HPS_SD_DATA(2),                       --                          .sdmmc_data2
            hps_io_sdmmc_data3                    => HPS_SD_DATA(3),                       --                          .sdmmc_data3
            hps_io_sdmmc_cmd                      => HPS_SD_CMD,                           --                          .sdmmc_cmd
            hps_io_emac0_tx_clk                   => HPS_ENET_TX_CLK,                      --                          .emac0_tx_clk
            hps_io_emac0_tx_ctl                   => HPS_ENET_TX_CTL,                      --                          .emac0_tx_ctl
            hps_io_emac0_rx_clk                   => HPS_ENET_RX_CLK,                      --                          .emac0_rx_clk
            hps_io_emac0_rx_ctl                   => HPS_ENET_RX_CTL,                      --                          .emac0_rx_ctl
            hps_io_emac0_txd0                     => HPS_ENET_TX_DATA(0),                  --                          .emac0_txd0
            hps_io_emac0_txd1                     => HPS_ENET_TX_DATA(1),                  --                          .emac0_txd1
            hps_io_emac0_rxd0                     => HPS_ENET_RX_DATA(0),                  --                          .emac0_rxd0
            hps_io_emac0_rxd1                     => HPS_ENET_RX_DATA(1),                  --                          .emac0_rxd1
            hps_io_emac0_txd2                     => HPS_ENET_TX_DATA(2),                  --                          .emac0_txd2
            hps_io_emac0_txd3                     => HPS_ENET_TX_DATA(3),                  --                          .emac0_txd3
            hps_io_emac0_rxd2                     => HPS_ENET_RX_DATA(2),                  --                          .emac0_rxd2
            hps_io_emac0_rxd3                     => HPS_ENET_RX_DATA(3),                  --                          .emac0_rxd3
            hps_io_mdio0_mdio                     => HPS_ENET_MDIO,                        --                          .mdio0_mdio
            hps_io_mdio0_mdc                      => HPS_ENET_MDC,                         --                          .mdio0_mdc
            hps_io_uart1_tx                       => HPS_UART_TX,                          --                          .uart1_tx
            hps_io_uart1_rx                       => HPS_UART_RX,                          --                          .uart1_rx
            hps_io_gpio40                         => HPS_KEY,                              --                          .gpio40
            hps_io_gpio41                         => HPS_LED,                              --                          .gpio41
            f2h_irq1_in_irq                       => (others => '0'),                      --               f2h_irq1_in.irq
            f2h_irq0_in_irq                       => (others => '0'),                      --               f2h_irq0_in.irq
            emif_hps_emif_mem_0_mem_cs            => ddr_cs_vec,                           --       emif_hps_emif_mem_0.mem_cs
            emif_hps_emif_mem_0_mem_ca            => LPDDR4A_CA,                           --                          .mem_ca
            emif_hps_emif_mem_0_mem_cke           => ddr_cke_vec,                          --                          .mem_cke
            emif_hps_emif_mem_0_mem_dq            => LPDDR4A_DQ,                           --                          .mem_dq
            emif_hps_emif_mem_0_mem_dqs_t         => LPDDR4A_DQS,                          --                          .mem_dqs_t
            emif_hps_emif_mem_0_mem_dqs_c         => LPDDR4A_DQS_n,                        --                          .mem_dqs_c
            emif_hps_emif_mem_0_mem_dmi           => LPDDR4A_DM,                           --                          .mem_dmi
            emif_hps_emif_mem_ck_0_mem_ck_t       => ddr_ck_t_vec,                         --    emif_hps_emif_mem_ck_0.mem_ck_t
            emif_hps_emif_mem_ck_0_mem_ck_c       => ddr_ck_c_vec,                         --                          .mem_ck_c
            emif_hps_emif_mem_reset_n_mem_reset_n => LPDDR4A_RESET_n,                      -- emif_hps_emif_mem_reset_n.mem_reset_n
            emif_hps_emif_oct_0_oct_rzqin         => LPDDR4A_RZQ,                          --       emif_hps_emif_oct_0.oct_rzqin
            emif_hps_emif_ref_clk_clk             => LPDDR4A_REFCLK_p,                     --     emif_hps_emif_ref_clk.clk
            ninit_done_reset                      => open                                 --                ninit_done.reset
        );

    LPDDR4A_CS_n <= ddr_cs_vec(0);
    LPDDR4A_CKE  <= ddr_cke_vec(0);
    LPDDR4A_CK   <= ddr_ck_t_vec(0);
    LPDDR4A_CK_n <= ddr_ck_c_vec(0);

end rtl;
