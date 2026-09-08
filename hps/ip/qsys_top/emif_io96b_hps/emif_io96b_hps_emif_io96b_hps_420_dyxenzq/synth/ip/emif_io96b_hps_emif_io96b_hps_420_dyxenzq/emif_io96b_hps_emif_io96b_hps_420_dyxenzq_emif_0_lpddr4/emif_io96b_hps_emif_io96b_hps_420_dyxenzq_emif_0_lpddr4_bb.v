module emif_io96b_hps_emif_io96b_hps_420_dyxenzq_emif_0_lpddr4 (
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
		input  wire [39:0]  s0_axi4_awaddr,          //              .axi4_ch0_awaddr,  Write Address , channel 0.
		input  wire [1:0]   s0_axi4_awburst,         //              .axi4_ch0_awburst, Write Burst Type, channel 0.
		input  wire [6:0]   s0_axi4_awid,            //              .axi4_ch0_awid,    Write Address ID, channel 0.
		input  wire [7:0]   s0_axi4_awlen,           //              .axi4_ch0_awlen,   Write Burst Length, channel 0.
		input  wire         s0_axi4_awlock,          //              .axi4_ch0_awlock,  Write Lock Type, channel 0.
		input  wire [3:0]   s0_axi4_awqos,           //              .axi4_ch0_awqos,   Write Quality of Service, channel 0.
		input  wire [2:0]   s0_axi4_awsize,          //              .axi4_ch0_awsize,  Write Burst Size, channel 0.
		input  wire         s0_axi4_awvalid,         //              .axi4_ch0_awvalid, Write Address Valid, channel 0.
		input  wire [13:0]  s0_axi4_awuser,          //              .axi4_ch0_awuser,  Write Address User Signal, channel 0.
		input  wire [2:0]   s0_axi4_awprot,          //              .axi4_ch0_awprot,  Write Protection Type, channel 0.
		output wire         s0_axi4_awready,         //              .axi4_ch0_awready, Write Address Ready, channel 0.
		input  wire [39:0]  s0_axi4_araddr,          //              .axi4_ch0_araddr,  Read Address , channel 0.
		input  wire [1:0]   s0_axi4_arburst,         //              .axi4_ch0_arburst, Read Burst Type, channel 0.
		input  wire [6:0]   s0_axi4_arid,            //              .axi4_ch0_arid,    Read Address ID, channel 0.
		input  wire [7:0]   s0_axi4_arlen,           //              .axi4_ch0_arlen,   Read Burst Length, channel 0.
		input  wire         s0_axi4_arlock,          //              .axi4_ch0_arlock,  Read Lock Type, channel 0.
		input  wire [3:0]   s0_axi4_arqos,           //              .axi4_ch0_arqos,   Read Quality of Service, channel 0.
		input  wire [2:0]   s0_axi4_arsize,          //              .axi4_ch0_arsize,  Read Burst Size, channel 0.
		input  wire         s0_axi4_arvalid,         //              .axi4_ch0_arvalid, Read Address Valid, channel 0.
		input  wire [13:0]  s0_axi4_aruser,          //              .axi4_ch0_aruser,  Read Address User Signal, channel 0.
		input  wire [2:0]   s0_axi4_arprot,          //              .axi4_ch0_arprot,  Read Protection Type, channel 0.
		output wire         s0_axi4_arready,         //              .axi4_ch0_arready, Read Address Ready, channel 0.
		input  wire [255:0] s0_axi4_wdata,           //              .axi4_ch0_wdata,   Write Data , channel 0.
		input  wire [31:0]  s0_axi4_wstrb,           //              .axi4_ch0_wstrb,   Write Strobes, channel 0.
		input  wire         s0_axi4_wlast,           //              .axi4_ch0_wlast,   Write Last, channel 0.
		input  wire         s0_axi4_wvalid,          //              .axi4_ch0_wvalid,  Write Valid, channel 0.
		output wire         s0_axi4_wready,          //              .axi4_ch0_wready,  Write Ready, channel 0.
		input  wire         s0_axi4_bready,          //              .axi4_ch0_bready,  Write Response Ready, channel 0.
		output wire [6:0]   s0_axi4_bid,             //              .axi4_ch0_bid,     Write Response ID, channel 0.
		output wire [1:0]   s0_axi4_bresp,           //              .axi4_ch0_bresp,   Write Response , channel 0.
		output wire         s0_axi4_bvalid,          //              .axi4_ch0_bvalid,  Write Response Valid, channel 0.
		input  wire         s0_axi4_rready,          //              .axi4_ch0_rready,  Read Ready, channel 0.
		output wire [255:0] s0_axi4_rdata,           //              .axi4_ch0_rdata,   Read Data, channel 0.
		output wire [6:0]   s0_axi4_rid,             //              .axi4_ch0_rid,     Read ID , channel 0.
		output wire         s0_axi4_rlast,           //              .axi4_ch0_rlast,   Read Last, channel 0.
		output wire [1:0]   s0_axi4_rresp,           //              .axi4_ch0_rresp,   Read Response, channel 0.
		output wire         s0_axi4_rvalid,          //              .axi4_ch0_rvalid,  Read Valid, channel 0.
		output wire         noc_aclk_0,              //              .axi4_ch0_clk
		output wire         noc_rst_n_0,             //              .axi4_ch0_reset_n
		input  wire [31:0]  s0_axi4_wuser,           //              .axi4_ch0_wuser,   Write User Signal, channel 0.
		output wire [31:0]  s0_axi4_ruser,           //              .axi4_ch0_ruser,   Read User Signal, channel 0.
		output wire [0:0]   mem_0_cs,                //         mem_0.mem_cs,           Chip Select channel 0.
		output wire [5:0]   mem_0_ca,                //              .mem_ca,           Command/Address Bus channel 0.
		output wire [0:0]   mem_0_cke,               //              .mem_cke,          Clock Enable channel 0.
		inout  wire [31:0]  mem_0_dq,                //              .mem_dq,           Data (read/write) channel 0.
		inout  wire [3:0]   mem_0_dqs_t,             //              .mem_dqs_t,        Data Strobe (true) channel 0.
		inout  wire [3:0]   mem_0_dqs_c,             //              .mem_dqs_c,        Data Strobe (complement) channel 0.
		inout  wire [3:0]   mem_0_dmi,               //              .mem_dmi,          Data Mask/Data Inversion channel 0.
		output wire [0:0]   mem_0_ck_t,              //      mem_ck_0.mem_ck_t,         CK Clock (true) channel 0.
		output wire [0:0]   mem_0_ck_c,              //              .mem_ck_c,         CK Clock (complement) channel 0.
		output wire         mem_0_reset_n,           //   mem_reset_n.mem_reset_n,      Asynchronous Reset channel 0.
		input  wire         oct_rzqin_0,             //         oct_0.oct_rzqin,        Calibrated On-Chip Termination (OCT) input pin channel 0.
		input  wire         ref_clk                  //       ref_clk.clk,              PLL reference clock input.
	);
endmodule

