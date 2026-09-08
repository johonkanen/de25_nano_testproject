// (C) 2001-2026 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



`timescale 1 ps / 1 ps
// altera message_off 24541 13469
module io0_emif_io96b_hps_emif_io96b_hps_420_dyxenzq_emif_0_lpddr4_emif_io96b_cal_232_s5h5wki_arbitrator #(
   AMM_TO_AXIL_INTERCONNECT_ONLY = ""
) ( 

      input          s0_axi4lite_clk,
      input          s0_axi4lite_rst_n,

      input   [26:0] s0_axi4lite_awaddr, 
      input    [2:0] s0_axi4lite_awprot, 
      input          s0_axi4lite_awvalid,
      output         s0_axi4lite_awready,
      input   [31:0] s0_axi4lite_wdata,  
      input    [3:0] s0_axi4lite_wstrb,  
      input          s0_axi4lite_wvalid, 
      output         s0_axi4lite_wready, 
      output   [1:0] s0_axi4lite_bresp,  
      output         s0_axi4lite_bvalid, 
      input          s0_axi4lite_bready, 
      input   [26:0] s0_axi4lite_araddr, 
      input    [2:0] s0_axi4lite_arprot, 
      input          s0_axi4lite_arvalid,
      output         s0_axi4lite_arready,
      output  [31:0] s0_axi4lite_rdata,  
      output   [1:0] s0_axi4lite_rresp,  
      output         s0_axi4lite_rvalid, 
      input          s0_axi4lite_rready,  

      input   [31:0] jamb_master_address,       
      output  [31:0] jamb_master_readdata,      
      input          jamb_master_read,          
      input          jamb_master_write,         
      input   [31:0] jamb_master_writedata,     
      output         jamb_master_waitrequest,   
      output         jamb_master_readdatavalid, 
      input    [3:0] jamb_master_byteenable,     

      output  [26:0] cal_arch_0_s0_axi4lite_axi4_lite_awaddr,                  
      output   [2:0] cal_arch_0_s0_axi4lite_axi4_lite_awprot,                  
      output         cal_arch_0_s0_axi4lite_axi4_lite_awvalid,                 
      input          cal_arch_0_s0_axi4lite_axi4_lite_awready,                 
      output  [31:0] cal_arch_0_s0_axi4lite_axi4_lite_wdata,                   
      output   [3:0] cal_arch_0_s0_axi4lite_axi4_lite_wstrb,                   
      output         cal_arch_0_s0_axi4lite_axi4_lite_wvalid,                  
      input          cal_arch_0_s0_axi4lite_axi4_lite_wready,                  
      input    [1:0] cal_arch_0_s0_axi4lite_axi4_lite_bresp,                   
      input          cal_arch_0_s0_axi4lite_axi4_lite_bvalid,                  
      output         cal_arch_0_s0_axi4lite_axi4_lite_bready,                  
      output  [26:0] cal_arch_0_s0_axi4lite_axi4_lite_araddr,                  
      output   [2:0] cal_arch_0_s0_axi4lite_axi4_lite_arprot,                  
      output         cal_arch_0_s0_axi4lite_axi4_lite_arvalid,                 
      input          cal_arch_0_s0_axi4lite_axi4_lite_arready,                 
      input   [31:0] cal_arch_0_s0_axi4lite_axi4_lite_rdata,                   
      input    [1:0] cal_arch_0_s0_axi4lite_axi4_lite_rresp,                   
      input          cal_arch_0_s0_axi4lite_axi4_lite_rvalid,                  
      output         cal_arch_0_s0_axi4lite_axi4_lite_rready                  

);


	wire   [31:0] mm_interconnect_0_arbit_s0_axi4lite_awaddr;                 
	wire    [1:0] mm_interconnect_0_arbit_s0_axi4lite_bresp;                  
	wire          mm_interconnect_0_arbit_s0_axi4lite_arready;                
	wire   [31:0] mm_interconnect_0_arbit_s0_axi4lite_rdata;                  
	wire    [3:0] mm_interconnect_0_arbit_s0_axi4lite_wstrb;                  
	wire          mm_interconnect_0_arbit_s0_axi4lite_wready;                 
	wire          mm_interconnect_0_arbit_s0_axi4lite_awready;                
	wire          mm_interconnect_0_arbit_s0_axi4lite_rready;                 
	wire          mm_interconnect_0_arbit_s0_axi4lite_bready;                 
	wire          mm_interconnect_0_arbit_s0_axi4lite_wvalid;                 
	wire   [31:0] mm_interconnect_0_arbit_s0_axi4lite_araddr;                 
	wire    [2:0] mm_interconnect_0_arbit_s0_axi4lite_arprot;                 
	wire    [1:0] mm_interconnect_0_arbit_s0_axi4lite_rresp;                  
	wire    [2:0] mm_interconnect_0_arbit_s0_axi4lite_awprot;                 
	wire   [31:0] mm_interconnect_0_arbit_s0_axi4lite_wdata;                  
	wire          mm_interconnect_0_arbit_s0_axi4lite_arvalid;                
	wire          mm_interconnect_0_arbit_s0_axi4lite_bvalid;                 
	wire          mm_interconnect_0_arbit_s0_axi4lite_awvalid;                
	wire          mm_interconnect_0_arbit_s0_axi4lite_rvalid;                 
	wire   [31:0] arbit_m_axi4_ruser;                                         
	wire   [31:0] arbit_m_axi4_wuser;                                         
	wire    [1:0] arbit_m_axi4_awburst;                                       
	wire    [7:0] arbit_m_axi4_arlen;                                         
	wire    [3:0] arbit_m_axi4_arqos;                                         
	wire   [10:0] arbit_m_axi4_awuser;                                        
	wire   [31:0] arbit_m_axi4_wstrb;                                         
	wire          arbit_m_axi4_wready;                                        
	wire    [6:0] arbit_m_axi4_rid;                                           
	wire          arbit_m_axi4_rready;                                        
	wire    [7:0] arbit_m_axi4_awlen;                                         
	wire    [3:0] arbit_m_axi4_awqos;                                         
	wire   [31:0] arbit_m_axi4_araddr;                                        
	wire          arbit_m_axi4_wvalid;                                        
	wire    [2:0] arbit_m_axi4_arprot;                                        
	wire          arbit_m_axi4_arvalid;                                       
	wire    [2:0] arbit_m_axi4_awprot;                                        
	wire  [255:0] arbit_m_axi4_wdata;                                         
	wire    [6:0] arbit_m_axi4_arid;                                          
	wire          arbit_m_axi4_arlock;                                        
	wire          arbit_m_axi4_awlock;                                        
	wire   [31:0] arbit_m_axi4_awaddr;                                        
	wire          arbit_m_axi4_arready;                                       
	wire    [1:0] arbit_m_axi4_bresp;                                         
	wire  [255:0] arbit_m_axi4_rdata;                                         
	wire    [1:0] arbit_m_axi4_arburst;                                       
	wire          arbit_m_axi4_awready;                                       
	wire    [2:0] arbit_m_axi4_arsize;                                        
	wire          arbit_m_axi4_rlast;                                         
	wire          arbit_m_axi4_bready;                                        
	wire          arbit_m_axi4_wlast;                                         
	wire    [1:0] arbit_m_axi4_rresp;                                         
	wire    [6:0] arbit_m_axi4_awid;                                          
	wire    [6:0] arbit_m_axi4_bid;                                           
	wire          arbit_m_axi4_bvalid;                                        
	wire   [10:0] arbit_m_axi4_aruser;                                        
	wire          arbit_m_axi4_rvalid;                                        
	wire    [2:0] arbit_m_axi4_awsize;                                        
	wire          arbit_m_axi4_awvalid;                                       

   altera_reset_synchronizer #(
      .DEPTH      (2),
      .ASYNC_RESET(0)
   ) reset_sync (
      .clk        (s0_axi4lite_clk),
      .reset_in   (~s0_axi4lite_rst_n),
      .reset_out  (s0_axi4lite_rst_sync)
   );

	ed_synth_dut_altera_mm_interconnect_1920_jmzr6ly mm_interconnect_0 (
		.jamb_master_address                                      (jamb_master_address),                         
		.jamb_master_waitrequest                                  (jamb_master_waitrequest),                     
		.jamb_master_byteenable                                   (jamb_master_byteenable),                      
		.jamb_master_read                                         (jamb_master_read),                            
		.jamb_master_readdata                                     (jamb_master_readdata),                        
		.jamb_master_readdatavalid                                (jamb_master_readdatavalid),                   
		.jamb_master_write                                        (jamb_master_write),                           
		.jamb_master_writedata                                    (jamb_master_writedata),                       
		.arbit_s0_axi4lite_awaddr                                 (mm_interconnect_0_arbit_s0_axi4lite_awaddr),  
		.arbit_s0_axi4lite_awprot                                 (mm_interconnect_0_arbit_s0_axi4lite_awprot),  
		.arbit_s0_axi4lite_awvalid                                (mm_interconnect_0_arbit_s0_axi4lite_awvalid), 
		.arbit_s0_axi4lite_awready                                (mm_interconnect_0_arbit_s0_axi4lite_awready), 
		.arbit_s0_axi4lite_wdata                                  (mm_interconnect_0_arbit_s0_axi4lite_wdata),   
		.arbit_s0_axi4lite_wstrb                                  (mm_interconnect_0_arbit_s0_axi4lite_wstrb),   
		.arbit_s0_axi4lite_wvalid                                 (mm_interconnect_0_arbit_s0_axi4lite_wvalid),  
		.arbit_s0_axi4lite_wready                                 (mm_interconnect_0_arbit_s0_axi4lite_wready),  
		.arbit_s0_axi4lite_bresp                                  (mm_interconnect_0_arbit_s0_axi4lite_bresp),   
		.arbit_s0_axi4lite_bvalid                                 (mm_interconnect_0_arbit_s0_axi4lite_bvalid),  
		.arbit_s0_axi4lite_bready                                 (mm_interconnect_0_arbit_s0_axi4lite_bready),  
		.arbit_s0_axi4lite_araddr                                 (mm_interconnect_0_arbit_s0_axi4lite_araddr),  
		.arbit_s0_axi4lite_arprot                                 (mm_interconnect_0_arbit_s0_axi4lite_arprot),  
		.arbit_s0_axi4lite_arvalid                                (mm_interconnect_0_arbit_s0_axi4lite_arvalid), 
		.arbit_s0_axi4lite_arready                                (mm_interconnect_0_arbit_s0_axi4lite_arready), 
		.arbit_s0_axi4lite_rdata                                  (mm_interconnect_0_arbit_s0_axi4lite_rdata),   
		.arbit_s0_axi4lite_rresp                                  (mm_interconnect_0_arbit_s0_axi4lite_rresp),   
		.arbit_s0_axi4lite_rvalid                                 (mm_interconnect_0_arbit_s0_axi4lite_rvalid),  
		.arbit_s0_axi4lite_rready                                 (mm_interconnect_0_arbit_s0_axi4lite_rready),  
		.arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset    (s0_axi4lite_rst_sync),          
		.jamb_master_translator_reset_reset_bridge_in_reset_reset (s0_axi4lite_rst_sync),          
		.clk_bridge_out_clk_clk                                   (s0_axi4lite_clk),                             
		.clk_bridge_out_clk_3_clk                                 (s0_axi4lite_clk)                              
	);

   

   generate
   if (!AMM_TO_AXIL_INTERCONNECT_ONLY) begin: gen_arbit
      ed_synth_dut_intel_axi4lite_injector_100_2yowc3a #(
         .NUM_ACTIVE_AXI4LITE_S_INTERFACES (2),
         .AXI4LITE_QOS                     (0),
         .NUM_ACTIVE_AXI4_S_INTERFACES     (0),
         .BUFFER_AXI4_S_READ_RESPONSES     (0),
         .AXI4_S_TRANSFER_MULTIPLE         (9),
         .INIU_AXI4_ADDR_WIDTH             (32)
      ) arbit (
         .m_axi4_aclk         (s0_axi4lite_clk),                             
         .m_axi4_aresetn      (~s0_axi4lite_rst_sync),         
         .m_axi4_arid         (arbit_m_axi4_arid),                           
         .m_axi4_araddr       (arbit_m_axi4_araddr),                         
         .m_axi4_arlen        (arbit_m_axi4_arlen),                          
         .m_axi4_arsize       (arbit_m_axi4_arsize),                         
         .m_axi4_arburst      (arbit_m_axi4_arburst),                        
         .m_axi4_arlock       (arbit_m_axi4_arlock),                         
         .m_axi4_arprot       (arbit_m_axi4_arprot),                         
         .m_axi4_arqos        (arbit_m_axi4_arqos),                          
         .m_axi4_aruser       (arbit_m_axi4_aruser),                         
         .m_axi4_arvalid      (arbit_m_axi4_arvalid),                        
         .m_axi4_arready      (arbit_m_axi4_arready),                        
         .m_axi4_rid          (arbit_m_axi4_rid),                            
         .m_axi4_rdata        (arbit_m_axi4_rdata),                          
         .m_axi4_rresp        (arbit_m_axi4_rresp),                          
         .m_axi4_rlast        (arbit_m_axi4_rlast),                          
         .m_axi4_ruser        (arbit_m_axi4_ruser),                          
         .m_axi4_rvalid       (arbit_m_axi4_rvalid),                         
         .m_axi4_rready       (arbit_m_axi4_rready),                         
         .m_axi4_awid         (arbit_m_axi4_awid),                           
         .m_axi4_awaddr       (arbit_m_axi4_awaddr),                         
         .m_axi4_awlen        (arbit_m_axi4_awlen),                          
         .m_axi4_awsize       (arbit_m_axi4_awsize),                         
         .m_axi4_awburst      (arbit_m_axi4_awburst),                        
         .m_axi4_awlock       (arbit_m_axi4_awlock),                         
         .m_axi4_awprot       (arbit_m_axi4_awprot),                         
         .m_axi4_awqos        (arbit_m_axi4_awqos),                          
         .m_axi4_awuser       (arbit_m_axi4_awuser),                         
         .m_axi4_awvalid      (arbit_m_axi4_awvalid),                        
         .m_axi4_awready      (arbit_m_axi4_awready),                        
         .m_axi4_wdata        (arbit_m_axi4_wdata),                          
         .m_axi4_wstrb        (arbit_m_axi4_wstrb),                          
         .m_axi4_wlast        (arbit_m_axi4_wlast),                          
         .m_axi4_wuser        (arbit_m_axi4_wuser),                          
         .m_axi4_wvalid       (arbit_m_axi4_wvalid),                         
         .m_axi4_wready       (arbit_m_axi4_wready),                         
         .m_axi4_bid          (arbit_m_axi4_bid),                            
         .m_axi4_bresp        (arbit_m_axi4_bresp),                          
         .m_axi4_bvalid       (arbit_m_axi4_bvalid),                         
         .m_axi4_bready       (arbit_m_axi4_bready),                         
         .s0_axi4lite_aclk    (s0_axi4lite_clk),                             
         .s0_axi4lite_aresetn (~s0_axi4lite_rst_sync),         
         .s0_axi4lite_awaddr  (mm_interconnect_0_arbit_s0_axi4lite_awaddr),  
         .s0_axi4lite_awvalid (mm_interconnect_0_arbit_s0_axi4lite_awvalid), 
         .s0_axi4lite_awready (mm_interconnect_0_arbit_s0_axi4lite_awready), 
         .s0_axi4lite_wdata   (mm_interconnect_0_arbit_s0_axi4lite_wdata),   
         .s0_axi4lite_wstrb   (mm_interconnect_0_arbit_s0_axi4lite_wstrb),   
         .s0_axi4lite_wvalid  (mm_interconnect_0_arbit_s0_axi4lite_wvalid),  
         .s0_axi4lite_wready  (mm_interconnect_0_arbit_s0_axi4lite_wready),  
         .s0_axi4lite_bresp   (mm_interconnect_0_arbit_s0_axi4lite_bresp),   
         .s0_axi4lite_bvalid  (mm_interconnect_0_arbit_s0_axi4lite_bvalid),  
         .s0_axi4lite_bready  (mm_interconnect_0_arbit_s0_axi4lite_bready),  
         .s0_axi4lite_araddr  (mm_interconnect_0_arbit_s0_axi4lite_araddr),  
         .s0_axi4lite_arvalid (mm_interconnect_0_arbit_s0_axi4lite_arvalid), 
         .s0_axi4lite_arready (mm_interconnect_0_arbit_s0_axi4lite_arready), 
         .s0_axi4lite_rdata   (mm_interconnect_0_arbit_s0_axi4lite_rdata),   
         .s0_axi4lite_rresp   (mm_interconnect_0_arbit_s0_axi4lite_rresp),   
         .s0_axi4lite_rvalid  (mm_interconnect_0_arbit_s0_axi4lite_rvalid),  
         .s0_axi4lite_rready  (mm_interconnect_0_arbit_s0_axi4lite_rready),  
         .s0_axi4lite_awprot  (mm_interconnect_0_arbit_s0_axi4lite_awprot),  
         .s0_axi4lite_arprot  (mm_interconnect_0_arbit_s0_axi4lite_arprot),  
         .s1_axi4lite_aclk    (s0_axi4lite_clk),                             
         .s1_axi4lite_aresetn (~s0_axi4lite_rst_sync),         
         .s1_axi4lite_awaddr  (s0_axi4lite_awaddr),                          
         .s1_axi4lite_awvalid (s0_axi4lite_awvalid),                         
         .s1_axi4lite_awready (s0_axi4lite_awready),                         
         .s1_axi4lite_wdata   (s0_axi4lite_wdata),                           
         .s1_axi4lite_wstrb   (s0_axi4lite_wstrb),                           
         .s1_axi4lite_wvalid  (s0_axi4lite_wvalid),                          
         .s1_axi4lite_wready  (s0_axi4lite_wready),                          
         .s1_axi4lite_bresp   (s0_axi4lite_bresp),                           
         .s1_axi4lite_bvalid  (s0_axi4lite_bvalid),                          
         .s1_axi4lite_bready  (s0_axi4lite_bready),                          
         .s1_axi4lite_araddr  (s0_axi4lite_araddr),                          
         .s1_axi4lite_arvalid (s0_axi4lite_arvalid),                         
         .s1_axi4lite_arready (s0_axi4lite_arready),                         
         .s1_axi4lite_rdata   (s0_axi4lite_rdata),                           
         .s1_axi4lite_rresp   (s0_axi4lite_rresp),                           
         .s1_axi4lite_rvalid  (s0_axi4lite_rvalid),                          
         .s1_axi4lite_rready  (s0_axi4lite_rready),                          
         .s1_axi4lite_awprot  (s0_axi4lite_awprot),                          
         .s1_axi4lite_arprot  (s0_axi4lite_arprot)                           
      );

      ed_synth_dut_altera_mm_interconnect_1920_5sovoyi mm_interconnect_1 (
         .arbit_m_axi4_awid                                        (arbit_m_axi4_awid),                                          
         .arbit_m_axi4_awaddr                                      (arbit_m_axi4_awaddr),                                        
         .arbit_m_axi4_awlen                                       (arbit_m_axi4_awlen),                                         
         .arbit_m_axi4_awsize                                      (arbit_m_axi4_awsize),                                        
         .arbit_m_axi4_awburst                                     (arbit_m_axi4_awburst),                                       
         .arbit_m_axi4_awlock                                      (arbit_m_axi4_awlock),                                        
         .arbit_m_axi4_awprot                                      (arbit_m_axi4_awprot),                                        
         .arbit_m_axi4_awuser                                      (arbit_m_axi4_awuser),                                        
         .arbit_m_axi4_awqos                                       (arbit_m_axi4_awqos),                                         
         .arbit_m_axi4_awvalid                                     (arbit_m_axi4_awvalid),                                       
         .arbit_m_axi4_awready                                     (arbit_m_axi4_awready),                                       
         .arbit_m_axi4_wdata                                       (arbit_m_axi4_wdata),                                         
         .arbit_m_axi4_wstrb                                       (arbit_m_axi4_wstrb),                                         
         .arbit_m_axi4_wlast                                       (arbit_m_axi4_wlast),                                         
         .arbit_m_axi4_wvalid                                      (arbit_m_axi4_wvalid),                                        
         .arbit_m_axi4_wuser                                       (arbit_m_axi4_wuser),                                         
         .arbit_m_axi4_wready                                      (arbit_m_axi4_wready),                                        
         .arbit_m_axi4_bid                                         (arbit_m_axi4_bid),                                           
         .arbit_m_axi4_bresp                                       (arbit_m_axi4_bresp),                                         
         .arbit_m_axi4_bvalid                                      (arbit_m_axi4_bvalid),                                        
         .arbit_m_axi4_bready                                      (arbit_m_axi4_bready),                                        
         .arbit_m_axi4_arid                                        (arbit_m_axi4_arid),                                          
         .arbit_m_axi4_araddr                                      (arbit_m_axi4_araddr),                                        
         .arbit_m_axi4_arlen                                       (arbit_m_axi4_arlen),                                         
         .arbit_m_axi4_arsize                                      (arbit_m_axi4_arsize),                                        
         .arbit_m_axi4_arburst                                     (arbit_m_axi4_arburst),                                       
         .arbit_m_axi4_arlock                                      (arbit_m_axi4_arlock),                                        
         .arbit_m_axi4_arprot                                      (arbit_m_axi4_arprot),                                        
         .arbit_m_axi4_aruser                                      (arbit_m_axi4_aruser),                                        
         .arbit_m_axi4_arqos                                       (arbit_m_axi4_arqos),                                         
         .arbit_m_axi4_arvalid                                     (arbit_m_axi4_arvalid),                                       
         .arbit_m_axi4_arready                                     (arbit_m_axi4_arready),                                       
         .arbit_m_axi4_rid                                         (arbit_m_axi4_rid),                                           
         .arbit_m_axi4_rdata                                       (arbit_m_axi4_rdata),                                         
         .arbit_m_axi4_rresp                                       (arbit_m_axi4_rresp),                                         
         .arbit_m_axi4_rlast                                       (arbit_m_axi4_rlast),                                         
         .arbit_m_axi4_rvalid                                      (arbit_m_axi4_rvalid),                                        
         .arbit_m_axi4_rready                                      (arbit_m_axi4_rready),                                        
         .arbit_m_axi4_ruser                                       (arbit_m_axi4_ruser),                                         
         .cal_arch_0_s0_axi4lite_axi4_lite_awaddr                  (cal_arch_0_s0_axi4lite_axi4_lite_awaddr),  
         .cal_arch_0_s0_axi4lite_axi4_lite_awprot                  (cal_arch_0_s0_axi4lite_axi4_lite_awprot),  
         .cal_arch_0_s0_axi4lite_axi4_lite_awvalid                 (cal_arch_0_s0_axi4lite_axi4_lite_awvalid), 
         .cal_arch_0_s0_axi4lite_axi4_lite_awready                 (cal_arch_0_s0_axi4lite_axi4_lite_awready), 
         .cal_arch_0_s0_axi4lite_axi4_lite_wdata                   (cal_arch_0_s0_axi4lite_axi4_lite_wdata),   
         .cal_arch_0_s0_axi4lite_axi4_lite_wstrb                   (cal_arch_0_s0_axi4lite_axi4_lite_wstrb),   
         .cal_arch_0_s0_axi4lite_axi4_lite_wvalid                  (cal_arch_0_s0_axi4lite_axi4_lite_wvalid),  
         .cal_arch_0_s0_axi4lite_axi4_lite_wready                  (cal_arch_0_s0_axi4lite_axi4_lite_wready),  
         .cal_arch_0_s0_axi4lite_axi4_lite_bresp                   (cal_arch_0_s0_axi4lite_axi4_lite_bresp),   
         .cal_arch_0_s0_axi4lite_axi4_lite_bvalid                  (cal_arch_0_s0_axi4lite_axi4_lite_bvalid),  
         .cal_arch_0_s0_axi4lite_axi4_lite_bready                  (cal_arch_0_s0_axi4lite_axi4_lite_bready),  
         .cal_arch_0_s0_axi4lite_axi4_lite_araddr                  (cal_arch_0_s0_axi4lite_axi4_lite_araddr),  
         .cal_arch_0_s0_axi4lite_axi4_lite_arprot                  (cal_arch_0_s0_axi4lite_axi4_lite_arprot),  
         .cal_arch_0_s0_axi4lite_axi4_lite_arvalid                 (cal_arch_0_s0_axi4lite_axi4_lite_arvalid), 
         .cal_arch_0_s0_axi4lite_axi4_lite_arready                 (cal_arch_0_s0_axi4lite_axi4_lite_arready), 
         .cal_arch_0_s0_axi4lite_axi4_lite_rdata                   (cal_arch_0_s0_axi4lite_axi4_lite_rdata),   
         .cal_arch_0_s0_axi4lite_axi4_lite_rresp                   (cal_arch_0_s0_axi4lite_axi4_lite_rresp),   
         .cal_arch_0_s0_axi4lite_axi4_lite_rvalid                  (cal_arch_0_s0_axi4lite_axi4_lite_rvalid),  
         .cal_arch_0_s0_axi4lite_axi4_lite_rready                  (cal_arch_0_s0_axi4lite_axi4_lite_rready),  
         .arbit_m_axi4_aresetn_reset_bridge_in_reset_reset         (s0_axi4lite_rst_sync),                         
         .cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset (s0_axi4lite_rst_sync),                             
         .clk_bridge_out_clk_2_clk                                 (s0_axi4lite_clk),                                            
         .clk_bridge_out_clk_1_clk                                 (s0_axi4lite_clk)                                             
      );

   end else begin: gen_connect_axil_output_intf
      assign cal_arch_0_s0_axi4lite_axi4_lite_awaddr    = mm_interconnect_0_arbit_s0_axi4lite_awaddr; 
      assign cal_arch_0_s0_axi4lite_axi4_lite_awprot    = mm_interconnect_0_arbit_s0_axi4lite_awprot; 
      assign cal_arch_0_s0_axi4lite_axi4_lite_awvalid   = mm_interconnect_0_arbit_s0_axi4lite_awvalid;
      assign mm_interconnect_0_arbit_s0_axi4lite_awready = cal_arch_0_s0_axi4lite_axi4_lite_awready;
      assign cal_arch_0_s0_axi4lite_axi4_lite_wdata     = mm_interconnect_0_arbit_s0_axi4lite_wdata;  
      assign cal_arch_0_s0_axi4lite_axi4_lite_wstrb     = mm_interconnect_0_arbit_s0_axi4lite_wstrb;  
      assign cal_arch_0_s0_axi4lite_axi4_lite_wvalid    = mm_interconnect_0_arbit_s0_axi4lite_wvalid; 
      assign mm_interconnect_0_arbit_s0_axi4lite_wready = cal_arch_0_s0_axi4lite_axi4_lite_wready; 
      assign mm_interconnect_0_arbit_s0_axi4lite_bresp  = cal_arch_0_s0_axi4lite_axi4_lite_bresp;  
      assign mm_interconnect_0_arbit_s0_axi4lite_bvalid = cal_arch_0_s0_axi4lite_axi4_lite_bvalid; 
      assign cal_arch_0_s0_axi4lite_axi4_lite_bready    = mm_interconnect_0_arbit_s0_axi4lite_bready; 
      assign cal_arch_0_s0_axi4lite_axi4_lite_araddr    = mm_interconnect_0_arbit_s0_axi4lite_araddr; 
      assign cal_arch_0_s0_axi4lite_axi4_lite_arprot    = mm_interconnect_0_arbit_s0_axi4lite_arprot; 
      assign cal_arch_0_s0_axi4lite_axi4_lite_arvalid   = mm_interconnect_0_arbit_s0_axi4lite_arvalid;
      assign mm_interconnect_0_arbit_s0_axi4lite_arready = cal_arch_0_s0_axi4lite_axi4_lite_arready;
      assign mm_interconnect_0_arbit_s0_axi4lite_rdata  = cal_arch_0_s0_axi4lite_axi4_lite_rdata;
      assign mm_interconnect_0_arbit_s0_axi4lite_rresp  = cal_arch_0_s0_axi4lite_axi4_lite_rresp;
      assign mm_interconnect_0_arbit_s0_axi4lite_rvalid = cal_arch_0_s0_axi4lite_axi4_lite_rvalid;
      assign cal_arch_0_s0_axi4lite_axi4_lite_rready    = mm_interconnect_0_arbit_s0_axi4lite_rready; 
   end
   endgenerate



endmodule




