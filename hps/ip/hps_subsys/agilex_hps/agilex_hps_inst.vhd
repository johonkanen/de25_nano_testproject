	component agilex_hps is
		port (
			h2f_reset_reset                : out   std_logic;                                         -- reset
			lwhps2fpga_axi_clock_clk       : in    std_logic                      := 'X';             -- clk
			lwhps2fpga_axi_reset_reset     : in    std_logic                      := 'X';             -- reset
			lwhps2fpga_awid                : out   std_logic_vector(3 downto 0);                      -- awid
			lwhps2fpga_awaddr              : out   std_logic_vector(28 downto 0);                     -- awaddr
			lwhps2fpga_awlen               : out   std_logic_vector(7 downto 0);                      -- awlen
			lwhps2fpga_awsize              : out   std_logic_vector(2 downto 0);                      -- awsize
			lwhps2fpga_awburst             : out   std_logic_vector(1 downto 0);                      -- awburst
			lwhps2fpga_awlock              : out   std_logic;                                         -- awlock
			lwhps2fpga_awcache             : out   std_logic_vector(3 downto 0);                      -- awcache
			lwhps2fpga_awprot              : out   std_logic_vector(2 downto 0);                      -- awprot
			lwhps2fpga_awvalid             : out   std_logic;                                         -- awvalid
			lwhps2fpga_awready             : in    std_logic                      := 'X';             -- awready
			lwhps2fpga_wdata               : out   std_logic_vector(31 downto 0);                     -- wdata
			lwhps2fpga_wstrb               : out   std_logic_vector(3 downto 0);                      -- wstrb
			lwhps2fpga_wlast               : out   std_logic;                                         -- wlast
			lwhps2fpga_wvalid              : out   std_logic;                                         -- wvalid
			lwhps2fpga_wready              : in    std_logic                      := 'X';             -- wready
			lwhps2fpga_bid                 : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- bid
			lwhps2fpga_bresp               : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- bresp
			lwhps2fpga_bvalid              : in    std_logic                      := 'X';             -- bvalid
			lwhps2fpga_bready              : out   std_logic;                                         -- bready
			lwhps2fpga_arid                : out   std_logic_vector(3 downto 0);                      -- arid
			lwhps2fpga_araddr              : out   std_logic_vector(28 downto 0);                     -- araddr
			lwhps2fpga_arlen               : out   std_logic_vector(7 downto 0);                      -- arlen
			lwhps2fpga_arsize              : out   std_logic_vector(2 downto 0);                      -- arsize
			lwhps2fpga_arburst             : out   std_logic_vector(1 downto 0);                      -- arburst
			lwhps2fpga_arlock              : out   std_logic;                                         -- arlock
			lwhps2fpga_arcache             : out   std_logic_vector(3 downto 0);                      -- arcache
			lwhps2fpga_arprot              : out   std_logic_vector(2 downto 0);                      -- arprot
			lwhps2fpga_arvalid             : out   std_logic;                                         -- arvalid
			lwhps2fpga_arready             : in    std_logic                      := 'X';             -- arready
			lwhps2fpga_rid                 : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- rid
			lwhps2fpga_rdata               : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- rdata
			lwhps2fpga_rresp               : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- rresp
			lwhps2fpga_rlast               : in    std_logic                      := 'X';             -- rlast
			lwhps2fpga_rvalid              : in    std_logic                      := 'X';             -- rvalid
			lwhps2fpga_rready              : out   std_logic;                                         -- rready
			emac0_app_rst_reset_n          : out   std_logic;                                         -- reset_n
			uart1_cts_n                    : in    std_logic                      := 'X';             -- cts_n
			uart1_dcd_n                    : in    std_logic                      := 'X';             -- dcd_n
			uart1_dsr_n                    : in    std_logic                      := 'X';             -- dsr_n
			uart1_dtr_n                    : out   std_logic;                                         -- dtr_n
			uart1_out1_n                   : out   std_logic;                                         -- out1_n
			uart1_out2_n                   : out   std_logic;                                         -- out2_n
			uart1_ri_n                     : in    std_logic                      := 'X';             -- ri_n
			uart1_rts_n                    : out   std_logic;                                         -- rts_n
			uart1_rx                       : in    std_logic                      := 'X';             -- rx
			uart1_tx                       : out   std_logic;                                         -- tx
			h2f_user0_clk_clk              : out   std_logic;                                         -- clk
			hps_io_hps_osc_clk             : in    std_logic                      := 'X';             -- hps_osc_clk
			hps_io_sdmmc_data0             : inout std_logic                      := 'X';             -- sdmmc_data0
			hps_io_sdmmc_data1             : inout std_logic                      := 'X';             -- sdmmc_data1
			hps_io_sdmmc_cclk              : out   std_logic;                                         -- sdmmc_cclk
			hps_io_sdmmc_data2             : inout std_logic                      := 'X';             -- sdmmc_data2
			hps_io_sdmmc_data3             : inout std_logic                      := 'X';             -- sdmmc_data3
			hps_io_sdmmc_cmd               : inout std_logic                      := 'X';             -- sdmmc_cmd
			hps_io_emac0_tx_clk            : out   std_logic;                                         -- emac0_tx_clk
			hps_io_emac0_tx_ctl            : out   std_logic;                                         -- emac0_tx_ctl
			hps_io_emac0_rx_clk            : in    std_logic                      := 'X';             -- emac0_rx_clk
			hps_io_emac0_rx_ctl            : in    std_logic                      := 'X';             -- emac0_rx_ctl
			hps_io_emac0_txd0              : out   std_logic;                                         -- emac0_txd0
			hps_io_emac0_txd1              : out   std_logic;                                         -- emac0_txd1
			hps_io_emac0_rxd0              : in    std_logic                      := 'X';             -- emac0_rxd0
			hps_io_emac0_rxd1              : in    std_logic                      := 'X';             -- emac0_rxd1
			hps_io_emac0_txd2              : out   std_logic;                                         -- emac0_txd2
			hps_io_emac0_txd3              : out   std_logic;                                         -- emac0_txd3
			hps_io_emac0_rxd2              : in    std_logic                      := 'X';             -- emac0_rxd2
			hps_io_emac0_rxd3              : in    std_logic                      := 'X';             -- emac0_rxd3
			hps_io_mdio0_mdio              : inout std_logic                      := 'X';             -- mdio0_mdio
			hps_io_mdio0_mdc               : out   std_logic;                                         -- mdio0_mdc
			hps_io_gpio40                  : inout std_logic                      := 'X';             -- gpio40
			hps_io_gpio41                  : inout std_logic                      := 'X';             -- gpio41
			fpga2hps_interrupt_irq1_irq    : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- irq
			fpga2hps_interrupt_irq0_irq    : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- irq
			io96b0_to_hps_ch0_axil_clk     : in    std_logic                      := 'X';             -- ch0_axil_clk
			io96b0_to_hps_ch0_axil_reset_n : in    std_logic                      := 'X';             -- ch0_axil_reset_n
			io96b0_to_hps_ch0_axil_arready : in    std_logic                      := 'X';             -- ch0_axil_arready
			io96b0_to_hps_ch0_axil_awready : in    std_logic                      := 'X';             -- ch0_axil_awready
			io96b0_to_hps_ch0_axil_bresp   : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- ch0_axil_bresp
			io96b0_to_hps_ch0_axil_bvalid  : in    std_logic                      := 'X';             -- ch0_axil_bvalid
			io96b0_to_hps_ch0_axil_rdata   : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- ch0_axil_rdata
			io96b0_to_hps_ch0_axil_rresp   : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- ch0_axil_rresp
			io96b0_to_hps_ch0_axil_rvalid  : in    std_logic                      := 'X';             -- ch0_axil_rvalid
			io96b0_to_hps_ch0_axil_wready  : in    std_logic                      := 'X';             -- ch0_axil_wready
			io96b0_to_hps_ch0_axil_araddr  : out   std_logic_vector(26 downto 0);                     -- ch0_axil_araddr
			io96b0_to_hps_ch0_axil_arvalid : out   std_logic;                                         -- ch0_axil_arvalid
			io96b0_to_hps_ch0_axil_awaddr  : out   std_logic_vector(26 downto 0);                     -- ch0_axil_awaddr
			io96b0_to_hps_ch0_axil_awvalid : out   std_logic;                                         -- ch0_axil_awvalid
			io96b0_to_hps_ch0_axil_bready  : out   std_logic;                                         -- ch0_axil_bready
			io96b0_to_hps_ch0_axil_rready  : out   std_logic;                                         -- ch0_axil_rready
			io96b0_to_hps_ch0_axil_wdata   : out   std_logic_vector(31 downto 0);                     -- ch0_axil_wdata
			io96b0_to_hps_ch0_axil_wstrb   : out   std_logic_vector(3 downto 0);                      -- ch0_axil_wstrb
			io96b0_to_hps_ch0_axil_wvalid  : out   std_logic;                                         -- ch0_axil_wvalid
			io96b0_to_hps_ch0_axil_arprot  : out   std_logic_vector(2 downto 0);                      -- ch0_axil_arprot
			io96b0_to_hps_ch0_axil_awprot  : out   std_logic_vector(2 downto 0);                      -- ch0_axil_awprot
			io96b0_to_hps_axi4_ch0_clk     : in    std_logic                      := 'X';             -- axi4_ch0_clk
			io96b0_to_hps_axi4_ch0_reset_n : in    std_logic                      := 'X';             -- axi4_ch0_reset_n
			io96b0_to_hps_axi4_ch0_arready : in    std_logic                      := 'X';             -- axi4_ch0_arready
			io96b0_to_hps_axi4_ch0_awready : in    std_logic                      := 'X';             -- axi4_ch0_awready
			io96b0_to_hps_axi4_ch0_bid     : in    std_logic_vector(6 downto 0)   := (others => 'X'); -- axi4_ch0_bid
			io96b0_to_hps_axi4_ch0_bresp   : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- axi4_ch0_bresp
			io96b0_to_hps_axi4_ch0_bvalid  : in    std_logic                      := 'X';             -- axi4_ch0_bvalid
			io96b0_to_hps_axi4_ch0_rdata   : in    std_logic_vector(255 downto 0) := (others => 'X'); -- axi4_ch0_rdata
			io96b0_to_hps_axi4_ch0_rid     : in    std_logic_vector(6 downto 0)   := (others => 'X'); -- axi4_ch0_rid
			io96b0_to_hps_axi4_ch0_rlast   : in    std_logic                      := 'X';             -- axi4_ch0_rlast
			io96b0_to_hps_axi4_ch0_rresp   : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- axi4_ch0_rresp
			io96b0_to_hps_axi4_ch0_ruser   : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- axi4_ch0_ruser
			io96b0_to_hps_axi4_ch0_rvalid  : in    std_logic                      := 'X';             -- axi4_ch0_rvalid
			io96b0_to_hps_axi4_ch0_wready  : in    std_logic                      := 'X';             -- axi4_ch0_wready
			io96b0_to_hps_axi4_ch0_araddr  : out   std_logic_vector(39 downto 0);                     -- axi4_ch0_araddr
			io96b0_to_hps_axi4_ch0_arburst : out   std_logic_vector(1 downto 0);                      -- axi4_ch0_arburst
			io96b0_to_hps_axi4_ch0_arid    : out   std_logic_vector(6 downto 0);                      -- axi4_ch0_arid
			io96b0_to_hps_axi4_ch0_arlen   : out   std_logic_vector(7 downto 0);                      -- axi4_ch0_arlen
			io96b0_to_hps_axi4_ch0_arlock  : out   std_logic;                                         -- axi4_ch0_arlock
			io96b0_to_hps_axi4_ch0_arqos   : out   std_logic_vector(3 downto 0);                      -- axi4_ch0_arqos
			io96b0_to_hps_axi4_ch0_arsize  : out   std_logic_vector(2 downto 0);                      -- axi4_ch0_arsize
			io96b0_to_hps_axi4_ch0_aruser  : out   std_logic_vector(13 downto 0);                     -- axi4_ch0_aruser
			io96b0_to_hps_axi4_ch0_arvalid : out   std_logic;                                         -- axi4_ch0_arvalid
			io96b0_to_hps_axi4_ch0_awaddr  : out   std_logic_vector(39 downto 0);                     -- axi4_ch0_awaddr
			io96b0_to_hps_axi4_ch0_awburst : out   std_logic_vector(1 downto 0);                      -- axi4_ch0_awburst
			io96b0_to_hps_axi4_ch0_awid    : out   std_logic_vector(6 downto 0);                      -- axi4_ch0_awid
			io96b0_to_hps_axi4_ch0_awlen   : out   std_logic_vector(7 downto 0);                      -- axi4_ch0_awlen
			io96b0_to_hps_axi4_ch0_awlock  : out   std_logic;                                         -- axi4_ch0_awlock
			io96b0_to_hps_axi4_ch0_awqos   : out   std_logic_vector(3 downto 0);                      -- axi4_ch0_awqos
			io96b0_to_hps_axi4_ch0_awsize  : out   std_logic_vector(2 downto 0);                      -- axi4_ch0_awsize
			io96b0_to_hps_axi4_ch0_awuser  : out   std_logic_vector(13 downto 0);                     -- axi4_ch0_awuser
			io96b0_to_hps_axi4_ch0_awvalid : out   std_logic;                                         -- axi4_ch0_awvalid
			io96b0_to_hps_axi4_ch0_bready  : out   std_logic;                                         -- axi4_ch0_bready
			io96b0_to_hps_axi4_ch0_rready  : out   std_logic;                                         -- axi4_ch0_rready
			io96b0_to_hps_axi4_ch0_wdata   : out   std_logic_vector(255 downto 0);                    -- axi4_ch0_wdata
			io96b0_to_hps_axi4_ch0_wlast   : out   std_logic;                                         -- axi4_ch0_wlast
			io96b0_to_hps_axi4_ch0_wstrb   : out   std_logic_vector(31 downto 0);                     -- axi4_ch0_wstrb
			io96b0_to_hps_axi4_ch0_wuser   : out   std_logic_vector(31 downto 0);                     -- axi4_ch0_wuser
			io96b0_to_hps_axi4_ch0_wvalid  : out   std_logic;                                         -- axi4_ch0_wvalid
			io96b0_to_hps_axi4_ch0_arprot  : out   std_logic_vector(2 downto 0);                      -- axi4_ch0_arprot
			io96b0_to_hps_axi4_ch0_awprot  : out   std_logic_vector(2 downto 0)                       -- axi4_ch0_awprot
		);
	end component agilex_hps;

	u0 : component agilex_hps
		port map (
			h2f_reset_reset                => CONNECTED_TO_h2f_reset_reset,                --               h2f_reset.reset
			lwhps2fpga_axi_clock_clk       => CONNECTED_TO_lwhps2fpga_axi_clock_clk,       --    lwhps2fpga_axi_clock.clk
			lwhps2fpga_axi_reset_reset     => CONNECTED_TO_lwhps2fpga_axi_reset_reset,     --    lwhps2fpga_axi_reset.reset
			lwhps2fpga_awid                => CONNECTED_TO_lwhps2fpga_awid,                --              lwhps2fpga.awid
			lwhps2fpga_awaddr              => CONNECTED_TO_lwhps2fpga_awaddr,              --                        .awaddr
			lwhps2fpga_awlen               => CONNECTED_TO_lwhps2fpga_awlen,               --                        .awlen
			lwhps2fpga_awsize              => CONNECTED_TO_lwhps2fpga_awsize,              --                        .awsize
			lwhps2fpga_awburst             => CONNECTED_TO_lwhps2fpga_awburst,             --                        .awburst
			lwhps2fpga_awlock              => CONNECTED_TO_lwhps2fpga_awlock,              --                        .awlock
			lwhps2fpga_awcache             => CONNECTED_TO_lwhps2fpga_awcache,             --                        .awcache
			lwhps2fpga_awprot              => CONNECTED_TO_lwhps2fpga_awprot,              --                        .awprot
			lwhps2fpga_awvalid             => CONNECTED_TO_lwhps2fpga_awvalid,             --                        .awvalid
			lwhps2fpga_awready             => CONNECTED_TO_lwhps2fpga_awready,             --                        .awready
			lwhps2fpga_wdata               => CONNECTED_TO_lwhps2fpga_wdata,               --                        .wdata
			lwhps2fpga_wstrb               => CONNECTED_TO_lwhps2fpga_wstrb,               --                        .wstrb
			lwhps2fpga_wlast               => CONNECTED_TO_lwhps2fpga_wlast,               --                        .wlast
			lwhps2fpga_wvalid              => CONNECTED_TO_lwhps2fpga_wvalid,              --                        .wvalid
			lwhps2fpga_wready              => CONNECTED_TO_lwhps2fpga_wready,              --                        .wready
			lwhps2fpga_bid                 => CONNECTED_TO_lwhps2fpga_bid,                 --                        .bid
			lwhps2fpga_bresp               => CONNECTED_TO_lwhps2fpga_bresp,               --                        .bresp
			lwhps2fpga_bvalid              => CONNECTED_TO_lwhps2fpga_bvalid,              --                        .bvalid
			lwhps2fpga_bready              => CONNECTED_TO_lwhps2fpga_bready,              --                        .bready
			lwhps2fpga_arid                => CONNECTED_TO_lwhps2fpga_arid,                --                        .arid
			lwhps2fpga_araddr              => CONNECTED_TO_lwhps2fpga_araddr,              --                        .araddr
			lwhps2fpga_arlen               => CONNECTED_TO_lwhps2fpga_arlen,               --                        .arlen
			lwhps2fpga_arsize              => CONNECTED_TO_lwhps2fpga_arsize,              --                        .arsize
			lwhps2fpga_arburst             => CONNECTED_TO_lwhps2fpga_arburst,             --                        .arburst
			lwhps2fpga_arlock              => CONNECTED_TO_lwhps2fpga_arlock,              --                        .arlock
			lwhps2fpga_arcache             => CONNECTED_TO_lwhps2fpga_arcache,             --                        .arcache
			lwhps2fpga_arprot              => CONNECTED_TO_lwhps2fpga_arprot,              --                        .arprot
			lwhps2fpga_arvalid             => CONNECTED_TO_lwhps2fpga_arvalid,             --                        .arvalid
			lwhps2fpga_arready             => CONNECTED_TO_lwhps2fpga_arready,             --                        .arready
			lwhps2fpga_rid                 => CONNECTED_TO_lwhps2fpga_rid,                 --                        .rid
			lwhps2fpga_rdata               => CONNECTED_TO_lwhps2fpga_rdata,               --                        .rdata
			lwhps2fpga_rresp               => CONNECTED_TO_lwhps2fpga_rresp,               --                        .rresp
			lwhps2fpga_rlast               => CONNECTED_TO_lwhps2fpga_rlast,               --                        .rlast
			lwhps2fpga_rvalid              => CONNECTED_TO_lwhps2fpga_rvalid,              --                        .rvalid
			lwhps2fpga_rready              => CONNECTED_TO_lwhps2fpga_rready,              --                        .rready
			emac0_app_rst_reset_n          => CONNECTED_TO_emac0_app_rst_reset_n,          --           emac0_app_rst.reset_n
			uart1_cts_n                    => CONNECTED_TO_uart1_cts_n,                    --                   uart1.cts_n
			uart1_dcd_n                    => CONNECTED_TO_uart1_dcd_n,                    --                        .dcd_n
			uart1_dsr_n                    => CONNECTED_TO_uart1_dsr_n,                    --                        .dsr_n
			uart1_dtr_n                    => CONNECTED_TO_uart1_dtr_n,                    --                        .dtr_n
			uart1_out1_n                   => CONNECTED_TO_uart1_out1_n,                   --                        .out1_n
			uart1_out2_n                   => CONNECTED_TO_uart1_out2_n,                   --                        .out2_n
			uart1_ri_n                     => CONNECTED_TO_uart1_ri_n,                     --                        .ri_n
			uart1_rts_n                    => CONNECTED_TO_uart1_rts_n,                    --                        .rts_n
			uart1_rx                       => CONNECTED_TO_uart1_rx,                       --                        .rx
			uart1_tx                       => CONNECTED_TO_uart1_tx,                       --                        .tx
			h2f_user0_clk_clk              => CONNECTED_TO_h2f_user0_clk_clk,              --           h2f_user0_clk.clk
			hps_io_hps_osc_clk             => CONNECTED_TO_hps_io_hps_osc_clk,             --                  hps_io.hps_osc_clk
			hps_io_sdmmc_data0             => CONNECTED_TO_hps_io_sdmmc_data0,             --                        .sdmmc_data0
			hps_io_sdmmc_data1             => CONNECTED_TO_hps_io_sdmmc_data1,             --                        .sdmmc_data1
			hps_io_sdmmc_cclk              => CONNECTED_TO_hps_io_sdmmc_cclk,              --                        .sdmmc_cclk
			hps_io_sdmmc_data2             => CONNECTED_TO_hps_io_sdmmc_data2,             --                        .sdmmc_data2
			hps_io_sdmmc_data3             => CONNECTED_TO_hps_io_sdmmc_data3,             --                        .sdmmc_data3
			hps_io_sdmmc_cmd               => CONNECTED_TO_hps_io_sdmmc_cmd,               --                        .sdmmc_cmd
			hps_io_emac0_tx_clk            => CONNECTED_TO_hps_io_emac0_tx_clk,            --                        .emac0_tx_clk
			hps_io_emac0_tx_ctl            => CONNECTED_TO_hps_io_emac0_tx_ctl,            --                        .emac0_tx_ctl
			hps_io_emac0_rx_clk            => CONNECTED_TO_hps_io_emac0_rx_clk,            --                        .emac0_rx_clk
			hps_io_emac0_rx_ctl            => CONNECTED_TO_hps_io_emac0_rx_ctl,            --                        .emac0_rx_ctl
			hps_io_emac0_txd0              => CONNECTED_TO_hps_io_emac0_txd0,              --                        .emac0_txd0
			hps_io_emac0_txd1              => CONNECTED_TO_hps_io_emac0_txd1,              --                        .emac0_txd1
			hps_io_emac0_rxd0              => CONNECTED_TO_hps_io_emac0_rxd0,              --                        .emac0_rxd0
			hps_io_emac0_rxd1              => CONNECTED_TO_hps_io_emac0_rxd1,              --                        .emac0_rxd1
			hps_io_emac0_txd2              => CONNECTED_TO_hps_io_emac0_txd2,              --                        .emac0_txd2
			hps_io_emac0_txd3              => CONNECTED_TO_hps_io_emac0_txd3,              --                        .emac0_txd3
			hps_io_emac0_rxd2              => CONNECTED_TO_hps_io_emac0_rxd2,              --                        .emac0_rxd2
			hps_io_emac0_rxd3              => CONNECTED_TO_hps_io_emac0_rxd3,              --                        .emac0_rxd3
			hps_io_mdio0_mdio              => CONNECTED_TO_hps_io_mdio0_mdio,              --                        .mdio0_mdio
			hps_io_mdio0_mdc               => CONNECTED_TO_hps_io_mdio0_mdc,               --                        .mdio0_mdc
			hps_io_gpio40                  => CONNECTED_TO_hps_io_gpio40,                  --                        .gpio40
			hps_io_gpio41                  => CONNECTED_TO_hps_io_gpio41,                  --                        .gpio41
			fpga2hps_interrupt_irq1_irq    => CONNECTED_TO_fpga2hps_interrupt_irq1_irq,    -- fpga2hps_interrupt_irq1.irq
			fpga2hps_interrupt_irq0_irq    => CONNECTED_TO_fpga2hps_interrupt_irq0_irq,    -- fpga2hps_interrupt_irq0.irq
			io96b0_to_hps_ch0_axil_clk     => CONNECTED_TO_io96b0_to_hps_ch0_axil_clk,     --           io96b0_to_hps.ch0_axil_clk
			io96b0_to_hps_ch0_axil_reset_n => CONNECTED_TO_io96b0_to_hps_ch0_axil_reset_n, --                        .ch0_axil_reset_n
			io96b0_to_hps_ch0_axil_arready => CONNECTED_TO_io96b0_to_hps_ch0_axil_arready, --                        .ch0_axil_arready
			io96b0_to_hps_ch0_axil_awready => CONNECTED_TO_io96b0_to_hps_ch0_axil_awready, --                        .ch0_axil_awready
			io96b0_to_hps_ch0_axil_bresp   => CONNECTED_TO_io96b0_to_hps_ch0_axil_bresp,   --                        .ch0_axil_bresp
			io96b0_to_hps_ch0_axil_bvalid  => CONNECTED_TO_io96b0_to_hps_ch0_axil_bvalid,  --                        .ch0_axil_bvalid
			io96b0_to_hps_ch0_axil_rdata   => CONNECTED_TO_io96b0_to_hps_ch0_axil_rdata,   --                        .ch0_axil_rdata
			io96b0_to_hps_ch0_axil_rresp   => CONNECTED_TO_io96b0_to_hps_ch0_axil_rresp,   --                        .ch0_axil_rresp
			io96b0_to_hps_ch0_axil_rvalid  => CONNECTED_TO_io96b0_to_hps_ch0_axil_rvalid,  --                        .ch0_axil_rvalid
			io96b0_to_hps_ch0_axil_wready  => CONNECTED_TO_io96b0_to_hps_ch0_axil_wready,  --                        .ch0_axil_wready
			io96b0_to_hps_ch0_axil_araddr  => CONNECTED_TO_io96b0_to_hps_ch0_axil_araddr,  --                        .ch0_axil_araddr
			io96b0_to_hps_ch0_axil_arvalid => CONNECTED_TO_io96b0_to_hps_ch0_axil_arvalid, --                        .ch0_axil_arvalid
			io96b0_to_hps_ch0_axil_awaddr  => CONNECTED_TO_io96b0_to_hps_ch0_axil_awaddr,  --                        .ch0_axil_awaddr
			io96b0_to_hps_ch0_axil_awvalid => CONNECTED_TO_io96b0_to_hps_ch0_axil_awvalid, --                        .ch0_axil_awvalid
			io96b0_to_hps_ch0_axil_bready  => CONNECTED_TO_io96b0_to_hps_ch0_axil_bready,  --                        .ch0_axil_bready
			io96b0_to_hps_ch0_axil_rready  => CONNECTED_TO_io96b0_to_hps_ch0_axil_rready,  --                        .ch0_axil_rready
			io96b0_to_hps_ch0_axil_wdata   => CONNECTED_TO_io96b0_to_hps_ch0_axil_wdata,   --                        .ch0_axil_wdata
			io96b0_to_hps_ch0_axil_wstrb   => CONNECTED_TO_io96b0_to_hps_ch0_axil_wstrb,   --                        .ch0_axil_wstrb
			io96b0_to_hps_ch0_axil_wvalid  => CONNECTED_TO_io96b0_to_hps_ch0_axil_wvalid,  --                        .ch0_axil_wvalid
			io96b0_to_hps_ch0_axil_arprot  => CONNECTED_TO_io96b0_to_hps_ch0_axil_arprot,  --                        .ch0_axil_arprot
			io96b0_to_hps_ch0_axil_awprot  => CONNECTED_TO_io96b0_to_hps_ch0_axil_awprot,  --                        .ch0_axil_awprot
			io96b0_to_hps_axi4_ch0_clk     => CONNECTED_TO_io96b0_to_hps_axi4_ch0_clk,     --                        .axi4_ch0_clk
			io96b0_to_hps_axi4_ch0_reset_n => CONNECTED_TO_io96b0_to_hps_axi4_ch0_reset_n, --                        .axi4_ch0_reset_n
			io96b0_to_hps_axi4_ch0_arready => CONNECTED_TO_io96b0_to_hps_axi4_ch0_arready, --                        .axi4_ch0_arready
			io96b0_to_hps_axi4_ch0_awready => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awready, --                        .axi4_ch0_awready
			io96b0_to_hps_axi4_ch0_bid     => CONNECTED_TO_io96b0_to_hps_axi4_ch0_bid,     --                        .axi4_ch0_bid
			io96b0_to_hps_axi4_ch0_bresp   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_bresp,   --                        .axi4_ch0_bresp
			io96b0_to_hps_axi4_ch0_bvalid  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_bvalid,  --                        .axi4_ch0_bvalid
			io96b0_to_hps_axi4_ch0_rdata   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_rdata,   --                        .axi4_ch0_rdata
			io96b0_to_hps_axi4_ch0_rid     => CONNECTED_TO_io96b0_to_hps_axi4_ch0_rid,     --                        .axi4_ch0_rid
			io96b0_to_hps_axi4_ch0_rlast   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_rlast,   --                        .axi4_ch0_rlast
			io96b0_to_hps_axi4_ch0_rresp   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_rresp,   --                        .axi4_ch0_rresp
			io96b0_to_hps_axi4_ch0_ruser   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_ruser,   --                        .axi4_ch0_ruser
			io96b0_to_hps_axi4_ch0_rvalid  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_rvalid,  --                        .axi4_ch0_rvalid
			io96b0_to_hps_axi4_ch0_wready  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_wready,  --                        .axi4_ch0_wready
			io96b0_to_hps_axi4_ch0_araddr  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_araddr,  --                        .axi4_ch0_araddr
			io96b0_to_hps_axi4_ch0_arburst => CONNECTED_TO_io96b0_to_hps_axi4_ch0_arburst, --                        .axi4_ch0_arburst
			io96b0_to_hps_axi4_ch0_arid    => CONNECTED_TO_io96b0_to_hps_axi4_ch0_arid,    --                        .axi4_ch0_arid
			io96b0_to_hps_axi4_ch0_arlen   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_arlen,   --                        .axi4_ch0_arlen
			io96b0_to_hps_axi4_ch0_arlock  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_arlock,  --                        .axi4_ch0_arlock
			io96b0_to_hps_axi4_ch0_arqos   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_arqos,   --                        .axi4_ch0_arqos
			io96b0_to_hps_axi4_ch0_arsize  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_arsize,  --                        .axi4_ch0_arsize
			io96b0_to_hps_axi4_ch0_aruser  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_aruser,  --                        .axi4_ch0_aruser
			io96b0_to_hps_axi4_ch0_arvalid => CONNECTED_TO_io96b0_to_hps_axi4_ch0_arvalid, --                        .axi4_ch0_arvalid
			io96b0_to_hps_axi4_ch0_awaddr  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awaddr,  --                        .axi4_ch0_awaddr
			io96b0_to_hps_axi4_ch0_awburst => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awburst, --                        .axi4_ch0_awburst
			io96b0_to_hps_axi4_ch0_awid    => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awid,    --                        .axi4_ch0_awid
			io96b0_to_hps_axi4_ch0_awlen   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awlen,   --                        .axi4_ch0_awlen
			io96b0_to_hps_axi4_ch0_awlock  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awlock,  --                        .axi4_ch0_awlock
			io96b0_to_hps_axi4_ch0_awqos   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awqos,   --                        .axi4_ch0_awqos
			io96b0_to_hps_axi4_ch0_awsize  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awsize,  --                        .axi4_ch0_awsize
			io96b0_to_hps_axi4_ch0_awuser  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awuser,  --                        .axi4_ch0_awuser
			io96b0_to_hps_axi4_ch0_awvalid => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awvalid, --                        .axi4_ch0_awvalid
			io96b0_to_hps_axi4_ch0_bready  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_bready,  --                        .axi4_ch0_bready
			io96b0_to_hps_axi4_ch0_rready  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_rready,  --                        .axi4_ch0_rready
			io96b0_to_hps_axi4_ch0_wdata   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_wdata,   --                        .axi4_ch0_wdata
			io96b0_to_hps_axi4_ch0_wlast   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_wlast,   --                        .axi4_ch0_wlast
			io96b0_to_hps_axi4_ch0_wstrb   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_wstrb,   --                        .axi4_ch0_wstrb
			io96b0_to_hps_axi4_ch0_wuser   => CONNECTED_TO_io96b0_to_hps_axi4_ch0_wuser,   --                        .axi4_ch0_wuser
			io96b0_to_hps_axi4_ch0_wvalid  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_wvalid,  --                        .axi4_ch0_wvalid
			io96b0_to_hps_axi4_ch0_arprot  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_arprot,  --                        .axi4_ch0_arprot
			io96b0_to_hps_axi4_ch0_awprot  => CONNECTED_TO_io96b0_to_hps_axi4_ch0_awprot   --                        .axi4_ch0_awprot
		);

