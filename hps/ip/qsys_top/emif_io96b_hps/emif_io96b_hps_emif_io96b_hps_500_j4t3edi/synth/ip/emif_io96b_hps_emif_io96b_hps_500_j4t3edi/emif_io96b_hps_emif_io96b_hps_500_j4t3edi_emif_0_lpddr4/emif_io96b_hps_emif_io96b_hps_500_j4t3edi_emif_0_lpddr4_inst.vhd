	component emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4 is
		port (
			s0_noc_axi4lite_clock   : out   std_logic;                                         -- ch0_axil_clk
			s0_noc_axi4lite_reset_n : out   std_logic;                                         -- ch0_axil_reset_n
			s0_noc_axi4lite_awaddr  : in    std_logic_vector(26 downto 0)  := (others => 'X'); -- ch0_axil_awaddr
			s0_noc_axi4lite_awvalid : in    std_logic                      := 'X';             -- ch0_axil_awvalid
			s0_noc_axi4lite_awready : out   std_logic;                                         -- ch0_axil_awready
			s0_noc_axi4lite_araddr  : in    std_logic_vector(26 downto 0)  := (others => 'X'); -- ch0_axil_araddr
			s0_noc_axi4lite_arvalid : in    std_logic                      := 'X';             -- ch0_axil_arvalid
			s0_noc_axi4lite_arready : out   std_logic;                                         -- ch0_axil_arready
			s0_noc_axi4lite_wdata   : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- ch0_axil_wdata
			s0_noc_axi4lite_wvalid  : in    std_logic                      := 'X';             -- ch0_axil_wvalid
			s0_noc_axi4lite_wready  : out   std_logic;                                         -- ch0_axil_wready
			s0_noc_axi4lite_rresp   : out   std_logic_vector(1 downto 0);                      -- ch0_axil_rresp
			s0_noc_axi4lite_rdata   : out   std_logic_vector(31 downto 0);                     -- ch0_axil_rdata
			s0_noc_axi4lite_rvalid  : out   std_logic;                                         -- ch0_axil_rvalid
			s0_noc_axi4lite_rready  : in    std_logic                      := 'X';             -- ch0_axil_rready
			s0_noc_axi4lite_bresp   : out   std_logic_vector(1 downto 0);                      -- ch0_axil_bresp
			s0_noc_axi4lite_bvalid  : out   std_logic;                                         -- ch0_axil_bvalid
			s0_noc_axi4lite_bready  : in    std_logic                      := 'X';             -- ch0_axil_bready
			s0_noc_axi4lite_awprot  : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- ch0_axil_awprot
			s0_noc_axi4lite_arprot  : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- ch0_axil_arprot
			s0_noc_axi4lite_wstrb   : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- ch0_axil_wstrb
			s0_axi4_awaddr          : in    std_logic_vector(39 downto 0)  := (others => 'X'); -- axi4_ch0_awaddr
			s0_axi4_awburst         : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- axi4_ch0_awburst
			s0_axi4_awid            : in    std_logic_vector(6 downto 0)   := (others => 'X'); -- axi4_ch0_awid
			s0_axi4_awlen           : in    std_logic_vector(7 downto 0)   := (others => 'X'); -- axi4_ch0_awlen
			s0_axi4_awlock          : in    std_logic                      := 'X';             -- axi4_ch0_awlock
			s0_axi4_awqos           : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- axi4_ch0_awqos
			s0_axi4_awsize          : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- axi4_ch0_awsize
			s0_axi4_awvalid         : in    std_logic                      := 'X';             -- axi4_ch0_awvalid
			s0_axi4_awuser          : in    std_logic_vector(13 downto 0)  := (others => 'X'); -- axi4_ch0_awuser
			s0_axi4_awprot          : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- axi4_ch0_awprot
			s0_axi4_awready         : out   std_logic;                                         -- axi4_ch0_awready
			s0_axi4_araddr          : in    std_logic_vector(39 downto 0)  := (others => 'X'); -- axi4_ch0_araddr
			s0_axi4_arburst         : in    std_logic_vector(1 downto 0)   := (others => 'X'); -- axi4_ch0_arburst
			s0_axi4_arid            : in    std_logic_vector(6 downto 0)   := (others => 'X'); -- axi4_ch0_arid
			s0_axi4_arlen           : in    std_logic_vector(7 downto 0)   := (others => 'X'); -- axi4_ch0_arlen
			s0_axi4_arlock          : in    std_logic                      := 'X';             -- axi4_ch0_arlock
			s0_axi4_arqos           : in    std_logic_vector(3 downto 0)   := (others => 'X'); -- axi4_ch0_arqos
			s0_axi4_arsize          : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- axi4_ch0_arsize
			s0_axi4_arvalid         : in    std_logic                      := 'X';             -- axi4_ch0_arvalid
			s0_axi4_aruser          : in    std_logic_vector(13 downto 0)  := (others => 'X'); -- axi4_ch0_aruser
			s0_axi4_arprot          : in    std_logic_vector(2 downto 0)   := (others => 'X'); -- axi4_ch0_arprot
			s0_axi4_arready         : out   std_logic;                                         -- axi4_ch0_arready
			s0_axi4_wdata           : in    std_logic_vector(255 downto 0) := (others => 'X'); -- axi4_ch0_wdata
			s0_axi4_wstrb           : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- axi4_ch0_wstrb
			s0_axi4_wlast           : in    std_logic                      := 'X';             -- axi4_ch0_wlast
			s0_axi4_wvalid          : in    std_logic                      := 'X';             -- axi4_ch0_wvalid
			s0_axi4_wready          : out   std_logic;                                         -- axi4_ch0_wready
			s0_axi4_bready          : in    std_logic                      := 'X';             -- axi4_ch0_bready
			s0_axi4_bid             : out   std_logic_vector(6 downto 0);                      -- axi4_ch0_bid
			s0_axi4_bresp           : out   std_logic_vector(1 downto 0);                      -- axi4_ch0_bresp
			s0_axi4_bvalid          : out   std_logic;                                         -- axi4_ch0_bvalid
			s0_axi4_rready          : in    std_logic                      := 'X';             -- axi4_ch0_rready
			s0_axi4_rdata           : out   std_logic_vector(255 downto 0);                    -- axi4_ch0_rdata
			s0_axi4_rid             : out   std_logic_vector(6 downto 0);                      -- axi4_ch0_rid
			s0_axi4_rlast           : out   std_logic;                                         -- axi4_ch0_rlast
			s0_axi4_rresp           : out   std_logic_vector(1 downto 0);                      -- axi4_ch0_rresp
			s0_axi4_rvalid          : out   std_logic;                                         -- axi4_ch0_rvalid
			noc_aclk_0              : out   std_logic;                                         -- axi4_ch0_clk
			noc_rst_n_0             : out   std_logic;                                         -- axi4_ch0_reset_n
			s0_axi4_wuser           : in    std_logic_vector(31 downto 0)  := (others => 'X'); -- axi4_ch0_wuser
			s0_axi4_ruser           : out   std_logic_vector(31 downto 0);                     -- axi4_ch0_ruser
			mem_0_cs                : out   std_logic_vector(0 downto 0);                      -- mem_cs
			mem_0_ca                : out   std_logic_vector(5 downto 0);                      -- mem_ca
			mem_0_cke               : out   std_logic_vector(0 downto 0);                      -- mem_cke
			mem_0_dq                : inout std_logic_vector(31 downto 0)  := (others => 'X'); -- mem_dq
			mem_0_dqs_t             : inout std_logic_vector(3 downto 0)   := (others => 'X'); -- mem_dqs_t
			mem_0_dqs_c             : inout std_logic_vector(3 downto 0)   := (others => 'X'); -- mem_dqs_c
			mem_0_dmi               : inout std_logic_vector(3 downto 0)   := (others => 'X'); -- mem_dmi
			mem_0_ck_t              : out   std_logic_vector(0 downto 0);                      -- mem_ck_t
			mem_0_ck_c              : out   std_logic_vector(0 downto 0);                      -- mem_ck_c
			mem_0_reset_n           : out   std_logic;                                         -- mem_reset_n
			oct_rzqin_0             : in    std_logic                      := 'X';             -- oct_rzqin
			ref_clk                 : in    std_logic                      := 'X'              -- clk
		);
	end component emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4;

	u0 : component emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4
		port map (
			s0_noc_axi4lite_clock   => CONNECTED_TO_s0_noc_axi4lite_clock,   -- io96b0_to_hps.ch0_axil_clk
			s0_noc_axi4lite_reset_n => CONNECTED_TO_s0_noc_axi4lite_reset_n, --              .ch0_axil_reset_n
			s0_noc_axi4lite_awaddr  => CONNECTED_TO_s0_noc_axi4lite_awaddr,  --              .ch0_axil_awaddr
			s0_noc_axi4lite_awvalid => CONNECTED_TO_s0_noc_axi4lite_awvalid, --              .ch0_axil_awvalid
			s0_noc_axi4lite_awready => CONNECTED_TO_s0_noc_axi4lite_awready, --              .ch0_axil_awready
			s0_noc_axi4lite_araddr  => CONNECTED_TO_s0_noc_axi4lite_araddr,  --              .ch0_axil_araddr
			s0_noc_axi4lite_arvalid => CONNECTED_TO_s0_noc_axi4lite_arvalid, --              .ch0_axil_arvalid
			s0_noc_axi4lite_arready => CONNECTED_TO_s0_noc_axi4lite_arready, --              .ch0_axil_arready
			s0_noc_axi4lite_wdata   => CONNECTED_TO_s0_noc_axi4lite_wdata,   --              .ch0_axil_wdata
			s0_noc_axi4lite_wvalid  => CONNECTED_TO_s0_noc_axi4lite_wvalid,  --              .ch0_axil_wvalid
			s0_noc_axi4lite_wready  => CONNECTED_TO_s0_noc_axi4lite_wready,  --              .ch0_axil_wready
			s0_noc_axi4lite_rresp   => CONNECTED_TO_s0_noc_axi4lite_rresp,   --              .ch0_axil_rresp
			s0_noc_axi4lite_rdata   => CONNECTED_TO_s0_noc_axi4lite_rdata,   --              .ch0_axil_rdata
			s0_noc_axi4lite_rvalid  => CONNECTED_TO_s0_noc_axi4lite_rvalid,  --              .ch0_axil_rvalid
			s0_noc_axi4lite_rready  => CONNECTED_TO_s0_noc_axi4lite_rready,  --              .ch0_axil_rready
			s0_noc_axi4lite_bresp   => CONNECTED_TO_s0_noc_axi4lite_bresp,   --              .ch0_axil_bresp
			s0_noc_axi4lite_bvalid  => CONNECTED_TO_s0_noc_axi4lite_bvalid,  --              .ch0_axil_bvalid
			s0_noc_axi4lite_bready  => CONNECTED_TO_s0_noc_axi4lite_bready,  --              .ch0_axil_bready
			s0_noc_axi4lite_awprot  => CONNECTED_TO_s0_noc_axi4lite_awprot,  --              .ch0_axil_awprot
			s0_noc_axi4lite_arprot  => CONNECTED_TO_s0_noc_axi4lite_arprot,  --              .ch0_axil_arprot
			s0_noc_axi4lite_wstrb   => CONNECTED_TO_s0_noc_axi4lite_wstrb,   --              .ch0_axil_wstrb
			s0_axi4_awaddr          => CONNECTED_TO_s0_axi4_awaddr,          --              .axi4_ch0_awaddr
			s0_axi4_awburst         => CONNECTED_TO_s0_axi4_awburst,         --              .axi4_ch0_awburst
			s0_axi4_awid            => CONNECTED_TO_s0_axi4_awid,            --              .axi4_ch0_awid
			s0_axi4_awlen           => CONNECTED_TO_s0_axi4_awlen,           --              .axi4_ch0_awlen
			s0_axi4_awlock          => CONNECTED_TO_s0_axi4_awlock,          --              .axi4_ch0_awlock
			s0_axi4_awqos           => CONNECTED_TO_s0_axi4_awqos,           --              .axi4_ch0_awqos
			s0_axi4_awsize          => CONNECTED_TO_s0_axi4_awsize,          --              .axi4_ch0_awsize
			s0_axi4_awvalid         => CONNECTED_TO_s0_axi4_awvalid,         --              .axi4_ch0_awvalid
			s0_axi4_awuser          => CONNECTED_TO_s0_axi4_awuser,          --              .axi4_ch0_awuser
			s0_axi4_awprot          => CONNECTED_TO_s0_axi4_awprot,          --              .axi4_ch0_awprot
			s0_axi4_awready         => CONNECTED_TO_s0_axi4_awready,         --              .axi4_ch0_awready
			s0_axi4_araddr          => CONNECTED_TO_s0_axi4_araddr,          --              .axi4_ch0_araddr
			s0_axi4_arburst         => CONNECTED_TO_s0_axi4_arburst,         --              .axi4_ch0_arburst
			s0_axi4_arid            => CONNECTED_TO_s0_axi4_arid,            --              .axi4_ch0_arid
			s0_axi4_arlen           => CONNECTED_TO_s0_axi4_arlen,           --              .axi4_ch0_arlen
			s0_axi4_arlock          => CONNECTED_TO_s0_axi4_arlock,          --              .axi4_ch0_arlock
			s0_axi4_arqos           => CONNECTED_TO_s0_axi4_arqos,           --              .axi4_ch0_arqos
			s0_axi4_arsize          => CONNECTED_TO_s0_axi4_arsize,          --              .axi4_ch0_arsize
			s0_axi4_arvalid         => CONNECTED_TO_s0_axi4_arvalid,         --              .axi4_ch0_arvalid
			s0_axi4_aruser          => CONNECTED_TO_s0_axi4_aruser,          --              .axi4_ch0_aruser
			s0_axi4_arprot          => CONNECTED_TO_s0_axi4_arprot,          --              .axi4_ch0_arprot
			s0_axi4_arready         => CONNECTED_TO_s0_axi4_arready,         --              .axi4_ch0_arready
			s0_axi4_wdata           => CONNECTED_TO_s0_axi4_wdata,           --              .axi4_ch0_wdata
			s0_axi4_wstrb           => CONNECTED_TO_s0_axi4_wstrb,           --              .axi4_ch0_wstrb
			s0_axi4_wlast           => CONNECTED_TO_s0_axi4_wlast,           --              .axi4_ch0_wlast
			s0_axi4_wvalid          => CONNECTED_TO_s0_axi4_wvalid,          --              .axi4_ch0_wvalid
			s0_axi4_wready          => CONNECTED_TO_s0_axi4_wready,          --              .axi4_ch0_wready
			s0_axi4_bready          => CONNECTED_TO_s0_axi4_bready,          --              .axi4_ch0_bready
			s0_axi4_bid             => CONNECTED_TO_s0_axi4_bid,             --              .axi4_ch0_bid
			s0_axi4_bresp           => CONNECTED_TO_s0_axi4_bresp,           --              .axi4_ch0_bresp
			s0_axi4_bvalid          => CONNECTED_TO_s0_axi4_bvalid,          --              .axi4_ch0_bvalid
			s0_axi4_rready          => CONNECTED_TO_s0_axi4_rready,          --              .axi4_ch0_rready
			s0_axi4_rdata           => CONNECTED_TO_s0_axi4_rdata,           --              .axi4_ch0_rdata
			s0_axi4_rid             => CONNECTED_TO_s0_axi4_rid,             --              .axi4_ch0_rid
			s0_axi4_rlast           => CONNECTED_TO_s0_axi4_rlast,           --              .axi4_ch0_rlast
			s0_axi4_rresp           => CONNECTED_TO_s0_axi4_rresp,           --              .axi4_ch0_rresp
			s0_axi4_rvalid          => CONNECTED_TO_s0_axi4_rvalid,          --              .axi4_ch0_rvalid
			noc_aclk_0              => CONNECTED_TO_noc_aclk_0,              --              .axi4_ch0_clk
			noc_rst_n_0             => CONNECTED_TO_noc_rst_n_0,             --              .axi4_ch0_reset_n
			s0_axi4_wuser           => CONNECTED_TO_s0_axi4_wuser,           --              .axi4_ch0_wuser
			s0_axi4_ruser           => CONNECTED_TO_s0_axi4_ruser,           --              .axi4_ch0_ruser
			mem_0_cs                => CONNECTED_TO_mem_0_cs,                --         mem_0.mem_cs
			mem_0_ca                => CONNECTED_TO_mem_0_ca,                --              .mem_ca
			mem_0_cke               => CONNECTED_TO_mem_0_cke,               --              .mem_cke
			mem_0_dq                => CONNECTED_TO_mem_0_dq,                --              .mem_dq
			mem_0_dqs_t             => CONNECTED_TO_mem_0_dqs_t,             --              .mem_dqs_t
			mem_0_dqs_c             => CONNECTED_TO_mem_0_dqs_c,             --              .mem_dqs_c
			mem_0_dmi               => CONNECTED_TO_mem_0_dmi,               --              .mem_dmi
			mem_0_ck_t              => CONNECTED_TO_mem_0_ck_t,              --      mem_ck_0.mem_ck_t
			mem_0_ck_c              => CONNECTED_TO_mem_0_ck_c,              --              .mem_ck_c
			mem_0_reset_n           => CONNECTED_TO_mem_0_reset_n,           --   mem_reset_n.mem_reset_n
			oct_rzqin_0             => CONNECTED_TO_oct_rzqin_0,             --         oct_0.oct_rzqin
			ref_clk                 => CONNECTED_TO_ref_clk                  --       ref_clk.clk
		);

