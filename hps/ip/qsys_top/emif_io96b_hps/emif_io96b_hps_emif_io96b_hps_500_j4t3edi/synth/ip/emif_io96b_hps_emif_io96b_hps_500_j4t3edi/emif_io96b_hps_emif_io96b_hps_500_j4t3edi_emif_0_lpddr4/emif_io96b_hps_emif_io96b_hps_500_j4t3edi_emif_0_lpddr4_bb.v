module emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4 (
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
		input  wire [39:0]  s0_axi4_awaddr,          //              .axi4_ch0_awaddr,  Write address
		input  wire [1:0]   s0_axi4_awburst,         //              .axi4_ch0_awburst, Write burst type<ul><li>'b00 = Reserved (FIXED is not supported)</li><li>'b01 = INCR</li><li>'b10 = WRAP</li><li>'b11 = Reserved</li></ul>
		input  wire [6:0]   s0_axi4_awid,            //              .axi4_ch0_awid,    Write address ID
		input  wire [7:0]   s0_axi4_awlen,           //              .axi4_ch0_awlen,   Write burst length. Represents the total number of transfers in a burst.
		input  wire         s0_axi4_awlock,          //              .axi4_ch0_awlock,  Write lock type. Used to control exclusive access<ul><li>'b0 = Normal Access</li><li>'b1 = Exclusive Access</li></ul>
		input  wire [3:0]   s0_axi4_awqos,           //              .axi4_ch0_awqos,   Write quality of service. Supported priority values range from 0-3, with 0 as the lowest priority.<br><b>Only bits[3:2] are used, bits[1:0] are ignored.</b><br>Value of this whole signal is ignored if parameter 'Enable Fixed Priority' (Identifier: CTRL_FIXED_PRIORITY_EN) is true.
		input  wire [2:0]   s0_axi4_awsize,          //              .axi4_ch0_awsize,  Write burst size. Represents the size of each transfer in a burst where the size is 2^(This signal value).
		input  wire         s0_axi4_awvalid,         //              .axi4_ch0_awvalid, Write address valid
		input  wire [13:0]  s0_axi4_awuser,          //              .axi4_ch0_awuser,  Write address user signal<ul><li>[0]: Enable/Disable Auto-precharge. Drive 1 to enable and an auto-precharge will be issued after the write command is completed. Value of this signal is ignored if parameter 'Force Auto-Precharge' (Identifier: CTRL_AUTO_PRECHARGE_EN) is true</li><li>[1]: ALLSTRB: When <b>ALL</b> write strobes (WSTRB) will be driven for <b>EVERY</b> transfer of the burst, this signal can be driven 1 to improve controller performance.<br><b>When using this feature, only a maximum of 16 transfers per burst are supported</b><br>Value of this signal is ignored if parameter 'Enable All Strobe' (Identifier: CTRL_ALL_STRB_EN) is false</li><li>[13:2]: Not connected, drive 0</li></ul>
		input  wire [2:0]   s0_axi4_awprot,          //              .axi4_ch0_awprot,  Write protection type.<br><b>Not supported, drive 0.</b>
		output wire         s0_axi4_awready,         //              .axi4_ch0_awready, Write address ready
		input  wire [39:0]  s0_axi4_araddr,          //              .axi4_ch0_araddr,  Read address
		input  wire [1:0]   s0_axi4_arburst,         //              .axi4_ch0_arburst, Read burst type<ul><li>'b00 = Reserved (FIXED is not supported)</li><li>'b01 = INCR</li><li>'b10 = WRAP</li><li>'b11 = Reserved</li></ul>
		input  wire [6:0]   s0_axi4_arid,            //              .axi4_ch0_arid,    Read address ID
		input  wire [7:0]   s0_axi4_arlen,           //              .axi4_ch0_arlen,   Read burst length. Represents the total number of transfers in a burst.
		input  wire         s0_axi4_arlock,          //              .axi4_ch0_arlock,  Read lock type. Used to control exclusive access<ul><li>'b0 = Normal Access</li><li>'b1 = Exclusive Access</li></ul>
		input  wire [3:0]   s0_axi4_arqos,           //              .axi4_ch0_arqos,   Read quality of service. Supported priority values range from 0-3, with 0 as the lowest priority.<br><b>Only bits[3:2] are used, bits[1:0] are ignored.</b><br>Value of this whole signal is ignored if parameter 'Enable Fixed Priority' (Identifier: CTRL_FIXED_PRIORITY_EN) is true.
		input  wire [2:0]   s0_axi4_arsize,          //              .axi4_ch0_arsize,  Read burst size. Represents the size of each transfer in a burst where the size is 2^(This signal value).
		input  wire         s0_axi4_arvalid,         //              .axi4_ch0_arvalid, Read address valid
		input  wire [13:0]  s0_axi4_aruser,          //              .axi4_ch0_aruser,  Read address user signal<ul><li>[0]: Enable/Disable Auto-precharge. Drive 1 to enable and an auto-precharge will be issued after the read command is completed. Value of this signal is ignored if parameter 'Force Auto-Precharge' (Identifier: CTRL_AUTO_PRECHARGE_EN) is true</li><li>[13:1]: Not connected, drive 0</li></ul>
		input  wire [2:0]   s0_axi4_arprot,          //              .axi4_ch0_arprot,  Read protection type.<br><b>Not supported, drive 0.</b>
		output wire         s0_axi4_arready,         //              .axi4_ch0_arready, Read address ready
		input  wire [255:0] s0_axi4_wdata,           //              .axi4_ch0_wdata,   Write data
		input  wire [31:0]  s0_axi4_wstrb,           //              .axi4_ch0_wstrb,   Write strobes. Indicates which bytes of the write data are valid.
		input  wire         s0_axi4_wlast,           //              .axi4_ch0_wlast,   Write last. Indicates the last transfer in a write burst.
		input  wire         s0_axi4_wvalid,          //              .axi4_ch0_wvalid,  Write valid
		output wire         s0_axi4_wready,          //              .axi4_ch0_wready,  Write ready
		input  wire         s0_axi4_bready,          //              .axi4_ch0_bready,  Write response ready
		output wire [6:0]   s0_axi4_bid,             //              .axi4_ch0_bid,     Write response ID
		output wire [1:0]   s0_axi4_bresp,           //              .axi4_ch0_bresp,   Write response. One response is sent for the entire burst<ul><li>'b00 = OKAY - Write command was successfully processed, or exclusive write command was not processed as exclusive.</li><li>'b01 = EXOKAY - Exclusive write command was successfully processed.</li><li>'b10 = SUBERR - Subordinate has received the write command but there is an error in the transaction.</li><li>'b11 = DECERR - Subordinate does not exist and/or there is an error with the transaction.</li></ul>
		output wire         s0_axi4_bvalid,          //              .axi4_ch0_bvalid,  Write response valid
		input  wire         s0_axi4_rready,          //              .axi4_ch0_rready,  Read ready
		output wire [255:0] s0_axi4_rdata,           //              .axi4_ch0_rdata,   Read data
		output wire [6:0]   s0_axi4_rid,             //              .axi4_ch0_rid,     Read ID
		output wire         s0_axi4_rlast,           //              .axi4_ch0_rlast,   Read last. Indicates the last transfer in a read burst.
		output wire [1:0]   s0_axi4_rresp,           //              .axi4_ch0_rresp,   Read response. One response is sent with each burst, indicating the status of that burst<ul><li>'b00 = OKAY - Read command was successfully processed, or exclusive read command was not processed as exclusive.</li><li>'b01 = EXOKAY - Exclusive read command was successfully processed.</li><li>'b10 = SUBERR - Subordinate has received the read command but there is an error in the transaction.</li><li>'b11 = DECERR - Subordinate does not exist and/or there is an error with the transaction.</li></ul>
		output wire         s0_axi4_rvalid,          //              .axi4_ch0_rvalid,  Read valid
		output wire         noc_aclk_0,              //              .axi4_ch0_clk
		output wire         noc_rst_n_0,             //              .axi4_ch0_reset_n
		input  wire [31:0]  s0_axi4_wuser,           //              .axi4_ch0_wuser,   Write user signal. Only applicable to the x40/x72 lockstep cases. The additional user bits to be written are sent on this interface. If a x36 interface is used, then only the lowest 32-bits are connected.
		output wire [31:0]  s0_axi4_ruser,           //              .axi4_ch0_ruser,   Read user signal. Only applicable to the x40/x72 lockstep cases. These are the additional user bits received on this interface. If a x36 interface is used, then only the lowest 32-bits are connected.
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

