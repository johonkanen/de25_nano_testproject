module emif_io96b_hps_emif_io96b_hps_420_dyxenzq (
		output wire         s0_noc_axi4lite_clock,   // io96b0_to_hps.ch0_axil_clk
		output wire         s0_noc_axi4lite_reset_n, //              .ch0_axil_reset_n
		input  wire [26:0]  s0_noc_axi4lite_awaddr,  //              .ch0_axil_awaddr
		input  wire         s0_noc_axi4lite_awvalid, //              .ch0_axil_awvalid
		output wire         s0_noc_axi4lite_awready, //              .ch0_axil_awready
		input  wire [26:0]  s0_noc_axi4lite_araddr,  //              .ch0_axil_araddr
		input  wire         s0_noc_axi4lite_arvalid, //              .ch0_axil_arvalid
		output wire         s0_noc_axi4lite_arready, //              .ch0_axil_arready
		input  wire [31:0]  s0_noc_axi4lite_wdata,   //              .ch0_axil_wdata
		input  wire         s0_noc_axi4lite_wvalid,  //              .ch0_axil_wvalid
		output wire         s0_noc_axi4lite_wready,  //              .ch0_axil_wready
		output wire [1:0]   s0_noc_axi4lite_rresp,   //              .ch0_axil_rresp
		output wire [31:0]  s0_noc_axi4lite_rdata,   //              .ch0_axil_rdata
		output wire         s0_noc_axi4lite_rvalid,  //              .ch0_axil_rvalid
		input  wire         s0_noc_axi4lite_rready,  //              .ch0_axil_rready
		output wire [1:0]   s0_noc_axi4lite_bresp,   //              .ch0_axil_bresp
		output wire         s0_noc_axi4lite_bvalid,  //              .ch0_axil_bvalid
		input  wire         s0_noc_axi4lite_bready,  //              .ch0_axil_bready
		input  wire [2:0]   s0_noc_axi4lite_awprot,  //              .ch0_axil_awprot
		input  wire [2:0]   s0_noc_axi4lite_arprot,  //              .ch0_axil_arprot
		input  wire [3:0]   s0_noc_axi4lite_wstrb,   //              .ch0_axil_wstrb
		input  wire [39:0]  s0_axi4_awaddr,          //              .axi4_ch0_awaddr
		input  wire [1:0]   s0_axi4_awburst,         //              .axi4_ch0_awburst
		input  wire [6:0]   s0_axi4_awid,            //              .axi4_ch0_awid
		input  wire [7:0]   s0_axi4_awlen,           //              .axi4_ch0_awlen
		input  wire         s0_axi4_awlock,          //              .axi4_ch0_awlock
		input  wire [3:0]   s0_axi4_awqos,           //              .axi4_ch0_awqos
		input  wire [2:0]   s0_axi4_awsize,          //              .axi4_ch0_awsize
		input  wire         s0_axi4_awvalid,         //              .axi4_ch0_awvalid
		input  wire [13:0]  s0_axi4_awuser,          //              .axi4_ch0_awuser
		input  wire [2:0]   s0_axi4_awprot,          //              .axi4_ch0_awprot
		output wire         s0_axi4_awready,         //              .axi4_ch0_awready
		input  wire [39:0]  s0_axi4_araddr,          //              .axi4_ch0_araddr
		input  wire [1:0]   s0_axi4_arburst,         //              .axi4_ch0_arburst
		input  wire [6:0]   s0_axi4_arid,            //              .axi4_ch0_arid
		input  wire [7:0]   s0_axi4_arlen,           //              .axi4_ch0_arlen
		input  wire         s0_axi4_arlock,          //              .axi4_ch0_arlock
		input  wire [3:0]   s0_axi4_arqos,           //              .axi4_ch0_arqos
		input  wire [2:0]   s0_axi4_arsize,          //              .axi4_ch0_arsize
		input  wire         s0_axi4_arvalid,         //              .axi4_ch0_arvalid
		input  wire [13:0]  s0_axi4_aruser,          //              .axi4_ch0_aruser
		input  wire [2:0]   s0_axi4_arprot,          //              .axi4_ch0_arprot
		output wire         s0_axi4_arready,         //              .axi4_ch0_arready
		input  wire [255:0] s0_axi4_wdata,           //              .axi4_ch0_wdata
		input  wire [31:0]  s0_axi4_wstrb,           //              .axi4_ch0_wstrb
		input  wire         s0_axi4_wlast,           //              .axi4_ch0_wlast
		input  wire         s0_axi4_wvalid,          //              .axi4_ch0_wvalid
		output wire         s0_axi4_wready,          //              .axi4_ch0_wready
		input  wire         s0_axi4_bready,          //              .axi4_ch0_bready
		output wire [6:0]   s0_axi4_bid,             //              .axi4_ch0_bid
		output wire [1:0]   s0_axi4_bresp,           //              .axi4_ch0_bresp
		output wire         s0_axi4_bvalid,          //              .axi4_ch0_bvalid
		input  wire         s0_axi4_rready,          //              .axi4_ch0_rready
		output wire [255:0] s0_axi4_rdata,           //              .axi4_ch0_rdata
		output wire [6:0]   s0_axi4_rid,             //              .axi4_ch0_rid
		output wire         s0_axi4_rlast,           //              .axi4_ch0_rlast
		output wire [1:0]   s0_axi4_rresp,           //              .axi4_ch0_rresp
		output wire         s0_axi4_rvalid,          //              .axi4_ch0_rvalid
		output wire         noc_aclk_0,              //              .axi4_ch0_clk
		output wire         noc_rst_n_0,             //              .axi4_ch0_reset_n
		input  wire [31:0]  s0_axi4_wuser,           //              .axi4_ch0_wuser
		output wire [31:0]  s0_axi4_ruser,           //              .axi4_ch0_ruser
		output wire [0:0]   mem_0_cs,                //         mem_0.mem_cs
		output wire [5:0]   mem_0_ca,                //              .mem_ca
		output wire [0:0]   mem_0_cke,               //              .mem_cke
		inout  wire [31:0]  mem_0_dq,                //              .mem_dq
		inout  wire [3:0]   mem_0_dqs_t,             //              .mem_dqs_t
		inout  wire [3:0]   mem_0_dqs_c,             //              .mem_dqs_c
		inout  wire [3:0]   mem_0_dmi,               //              .mem_dmi
		output wire [0:0]   mem_0_ck_t,              //      mem_ck_0.mem_ck_t
		output wire [0:0]   mem_0_ck_c,              //              .mem_ck_c
		output wire         mem_0_reset_n,           //   mem_reset_n.mem_reset_n
		input  wire         oct_rzqin_0,             //         oct_0.oct_rzqin
		input  wire         ref_clk                  //       ref_clk.clk
	);
endmodule

