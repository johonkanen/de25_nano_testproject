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
			agilex_hps_uart1_cts_n                : in    std_logic                     := 'X';             -- cts_n
			agilex_hps_uart1_dcd_n                : in    std_logic                     := 'X';             -- dcd_n
			agilex_hps_uart1_dsr_n                : in    std_logic                     := 'X';             -- dsr_n
			agilex_hps_uart1_dtr_n                : out   std_logic;                                        -- dtr_n
			agilex_hps_uart1_out1_n               : out   std_logic;                                        -- out1_n
			agilex_hps_uart1_out2_n               : out   std_logic;                                        -- out2_n
			agilex_hps_uart1_ri_n                 : in    std_logic                     := 'X';             -- ri_n
			agilex_hps_uart1_rts_n                : out   std_logic;                                        -- rts_n
			agilex_hps_uart1_rx                   : in    std_logic                     := 'X';             -- rx
			agilex_hps_uart1_tx                   : out   std_logic;                                        -- tx
			h2f_user0_clk_clk                     : out   std_logic;                                        -- clk
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

	u0 : component hps_subsys
		port map (
			h2f_reset_reset                       => CONNECTED_TO_h2f_reset_reset,                       --                 h2f_reset.reset
			lwhps2fpga_axi_clock_clk              => CONNECTED_TO_lwhps2fpga_axi_clock_clk,              --      lwhps2fpga_axi_clock.clk
			lwhps2fpga_axi_reset_reset            => CONNECTED_TO_lwhps2fpga_axi_reset_reset,            --      lwhps2fpga_axi_reset.reset
			lwhps2fpga_awid                       => CONNECTED_TO_lwhps2fpga_awid,                       --                lwhps2fpga.awid
			lwhps2fpga_awaddr                     => CONNECTED_TO_lwhps2fpga_awaddr,                     --                          .awaddr
			lwhps2fpga_awlen                      => CONNECTED_TO_lwhps2fpga_awlen,                      --                          .awlen
			lwhps2fpga_awsize                     => CONNECTED_TO_lwhps2fpga_awsize,                     --                          .awsize
			lwhps2fpga_awburst                    => CONNECTED_TO_lwhps2fpga_awburst,                    --                          .awburst
			lwhps2fpga_awlock                     => CONNECTED_TO_lwhps2fpga_awlock,                     --                          .awlock
			lwhps2fpga_awcache                    => CONNECTED_TO_lwhps2fpga_awcache,                    --                          .awcache
			lwhps2fpga_awprot                     => CONNECTED_TO_lwhps2fpga_awprot,                     --                          .awprot
			lwhps2fpga_awvalid                    => CONNECTED_TO_lwhps2fpga_awvalid,                    --                          .awvalid
			lwhps2fpga_awready                    => CONNECTED_TO_lwhps2fpga_awready,                    --                          .awready
			lwhps2fpga_wdata                      => CONNECTED_TO_lwhps2fpga_wdata,                      --                          .wdata
			lwhps2fpga_wstrb                      => CONNECTED_TO_lwhps2fpga_wstrb,                      --                          .wstrb
			lwhps2fpga_wlast                      => CONNECTED_TO_lwhps2fpga_wlast,                      --                          .wlast
			lwhps2fpga_wvalid                     => CONNECTED_TO_lwhps2fpga_wvalid,                     --                          .wvalid
			lwhps2fpga_wready                     => CONNECTED_TO_lwhps2fpga_wready,                     --                          .wready
			lwhps2fpga_bid                        => CONNECTED_TO_lwhps2fpga_bid,                        --                          .bid
			lwhps2fpga_bresp                      => CONNECTED_TO_lwhps2fpga_bresp,                      --                          .bresp
			lwhps2fpga_bvalid                     => CONNECTED_TO_lwhps2fpga_bvalid,                     --                          .bvalid
			lwhps2fpga_bready                     => CONNECTED_TO_lwhps2fpga_bready,                     --                          .bready
			lwhps2fpga_arid                       => CONNECTED_TO_lwhps2fpga_arid,                       --                          .arid
			lwhps2fpga_araddr                     => CONNECTED_TO_lwhps2fpga_araddr,                     --                          .araddr
			lwhps2fpga_arlen                      => CONNECTED_TO_lwhps2fpga_arlen,                      --                          .arlen
			lwhps2fpga_arsize                     => CONNECTED_TO_lwhps2fpga_arsize,                     --                          .arsize
			lwhps2fpga_arburst                    => CONNECTED_TO_lwhps2fpga_arburst,                    --                          .arburst
			lwhps2fpga_arlock                     => CONNECTED_TO_lwhps2fpga_arlock,                     --                          .arlock
			lwhps2fpga_arcache                    => CONNECTED_TO_lwhps2fpga_arcache,                    --                          .arcache
			lwhps2fpga_arprot                     => CONNECTED_TO_lwhps2fpga_arprot,                     --                          .arprot
			lwhps2fpga_arvalid                    => CONNECTED_TO_lwhps2fpga_arvalid,                    --                          .arvalid
			lwhps2fpga_arready                    => CONNECTED_TO_lwhps2fpga_arready,                    --                          .arready
			lwhps2fpga_rid                        => CONNECTED_TO_lwhps2fpga_rid,                        --                          .rid
			lwhps2fpga_rdata                      => CONNECTED_TO_lwhps2fpga_rdata,                      --                          .rdata
			lwhps2fpga_rresp                      => CONNECTED_TO_lwhps2fpga_rresp,                      --                          .rresp
			lwhps2fpga_rlast                      => CONNECTED_TO_lwhps2fpga_rlast,                      --                          .rlast
			lwhps2fpga_rvalid                     => CONNECTED_TO_lwhps2fpga_rvalid,                     --                          .rvalid
			lwhps2fpga_rready                     => CONNECTED_TO_lwhps2fpga_rready,                     --                          .rready
			agilex_hps_uart1_cts_n                => CONNECTED_TO_agilex_hps_uart1_cts_n,                --          agilex_hps_uart1.cts_n
			agilex_hps_uart1_dcd_n                => CONNECTED_TO_agilex_hps_uart1_dcd_n,                --                          .dcd_n
			agilex_hps_uart1_dsr_n                => CONNECTED_TO_agilex_hps_uart1_dsr_n,                --                          .dsr_n
			agilex_hps_uart1_dtr_n                => CONNECTED_TO_agilex_hps_uart1_dtr_n,                --                          .dtr_n
			agilex_hps_uart1_out1_n               => CONNECTED_TO_agilex_hps_uart1_out1_n,               --                          .out1_n
			agilex_hps_uart1_out2_n               => CONNECTED_TO_agilex_hps_uart1_out2_n,               --                          .out2_n
			agilex_hps_uart1_ri_n                 => CONNECTED_TO_agilex_hps_uart1_ri_n,                 --                          .ri_n
			agilex_hps_uart1_rts_n                => CONNECTED_TO_agilex_hps_uart1_rts_n,                --                          .rts_n
			agilex_hps_uart1_rx                   => CONNECTED_TO_agilex_hps_uart1_rx,                   --                          .rx
			agilex_hps_uart1_tx                   => CONNECTED_TO_agilex_hps_uart1_tx,                   --                          .tx
			h2f_user0_clk_clk                     => CONNECTED_TO_h2f_user0_clk_clk,                     --             h2f_user0_clk.clk
			hps_io_hps_osc_clk                    => CONNECTED_TO_hps_io_hps_osc_clk,                    --                    hps_io.hps_osc_clk
			hps_io_sdmmc_data0                    => CONNECTED_TO_hps_io_sdmmc_data0,                    --                          .sdmmc_data0
			hps_io_sdmmc_data1                    => CONNECTED_TO_hps_io_sdmmc_data1,                    --                          .sdmmc_data1
			hps_io_sdmmc_cclk                     => CONNECTED_TO_hps_io_sdmmc_cclk,                     --                          .sdmmc_cclk
			hps_io_sdmmc_data2                    => CONNECTED_TO_hps_io_sdmmc_data2,                    --                          .sdmmc_data2
			hps_io_sdmmc_data3                    => CONNECTED_TO_hps_io_sdmmc_data3,                    --                          .sdmmc_data3
			hps_io_sdmmc_cmd                      => CONNECTED_TO_hps_io_sdmmc_cmd,                      --                          .sdmmc_cmd
			hps_io_emac0_tx_clk                   => CONNECTED_TO_hps_io_emac0_tx_clk,                   --                          .emac0_tx_clk
			hps_io_emac0_tx_ctl                   => CONNECTED_TO_hps_io_emac0_tx_ctl,                   --                          .emac0_tx_ctl
			hps_io_emac0_rx_clk                   => CONNECTED_TO_hps_io_emac0_rx_clk,                   --                          .emac0_rx_clk
			hps_io_emac0_rx_ctl                   => CONNECTED_TO_hps_io_emac0_rx_ctl,                   --                          .emac0_rx_ctl
			hps_io_emac0_txd0                     => CONNECTED_TO_hps_io_emac0_txd0,                     --                          .emac0_txd0
			hps_io_emac0_txd1                     => CONNECTED_TO_hps_io_emac0_txd1,                     --                          .emac0_txd1
			hps_io_emac0_rxd0                     => CONNECTED_TO_hps_io_emac0_rxd0,                     --                          .emac0_rxd0
			hps_io_emac0_rxd1                     => CONNECTED_TO_hps_io_emac0_rxd1,                     --                          .emac0_rxd1
			hps_io_emac0_txd2                     => CONNECTED_TO_hps_io_emac0_txd2,                     --                          .emac0_txd2
			hps_io_emac0_txd3                     => CONNECTED_TO_hps_io_emac0_txd3,                     --                          .emac0_txd3
			hps_io_emac0_rxd2                     => CONNECTED_TO_hps_io_emac0_rxd2,                     --                          .emac0_rxd2
			hps_io_emac0_rxd3                     => CONNECTED_TO_hps_io_emac0_rxd3,                     --                          .emac0_rxd3
			hps_io_mdio0_mdio                     => CONNECTED_TO_hps_io_mdio0_mdio,                     --                          .mdio0_mdio
			hps_io_mdio0_mdc                      => CONNECTED_TO_hps_io_mdio0_mdc,                      --                          .mdio0_mdc
			hps_io_gpio40                         => CONNECTED_TO_hps_io_gpio40,                         --                          .gpio40
			hps_io_gpio41                         => CONNECTED_TO_hps_io_gpio41,                         --                          .gpio41
			f2h_irq1_in_irq                       => CONNECTED_TO_f2h_irq1_in_irq,                       --               f2h_irq1_in.irq
			f2h_irq0_in_irq                       => CONNECTED_TO_f2h_irq0_in_irq,                       --               f2h_irq0_in.irq
			emif_hps_emif_mem_0_mem_cs            => CONNECTED_TO_emif_hps_emif_mem_0_mem_cs,            --       emif_hps_emif_mem_0.mem_cs
			emif_hps_emif_mem_0_mem_ca            => CONNECTED_TO_emif_hps_emif_mem_0_mem_ca,            --                          .mem_ca
			emif_hps_emif_mem_0_mem_cke           => CONNECTED_TO_emif_hps_emif_mem_0_mem_cke,           --                          .mem_cke
			emif_hps_emif_mem_0_mem_dq            => CONNECTED_TO_emif_hps_emif_mem_0_mem_dq,            --                          .mem_dq
			emif_hps_emif_mem_0_mem_dqs_t         => CONNECTED_TO_emif_hps_emif_mem_0_mem_dqs_t,         --                          .mem_dqs_t
			emif_hps_emif_mem_0_mem_dqs_c         => CONNECTED_TO_emif_hps_emif_mem_0_mem_dqs_c,         --                          .mem_dqs_c
			emif_hps_emif_mem_0_mem_dmi           => CONNECTED_TO_emif_hps_emif_mem_0_mem_dmi,           --                          .mem_dmi
			emif_hps_emif_mem_ck_0_mem_ck_t       => CONNECTED_TO_emif_hps_emif_mem_ck_0_mem_ck_t,       --    emif_hps_emif_mem_ck_0.mem_ck_t
			emif_hps_emif_mem_ck_0_mem_ck_c       => CONNECTED_TO_emif_hps_emif_mem_ck_0_mem_ck_c,       --                          .mem_ck_c
			emif_hps_emif_mem_reset_n_mem_reset_n => CONNECTED_TO_emif_hps_emif_mem_reset_n_mem_reset_n, -- emif_hps_emif_mem_reset_n.mem_reset_n
			emif_hps_emif_oct_0_oct_rzqin         => CONNECTED_TO_emif_hps_emif_oct_0_oct_rzqin,         --       emif_hps_emif_oct_0.oct_rzqin
			emif_hps_emif_ref_clk_clk             => CONNECTED_TO_emif_hps_emif_ref_clk_clk,             --     emif_hps_emif_ref_clk.clk
			ninit_done_reset                      => CONNECTED_TO_ninit_done_reset                       --                ninit_done.reset
		);

