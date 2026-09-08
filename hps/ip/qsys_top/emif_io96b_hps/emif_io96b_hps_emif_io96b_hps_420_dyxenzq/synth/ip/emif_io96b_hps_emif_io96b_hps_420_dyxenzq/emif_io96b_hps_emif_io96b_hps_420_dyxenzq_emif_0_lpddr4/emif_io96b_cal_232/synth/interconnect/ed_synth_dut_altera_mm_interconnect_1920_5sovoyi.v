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
module ed_synth_dut_altera_mm_interconnect_1920_5sovoyi (
		input  wire [6:0]   arbit_m_axi4_awid,                                        
		input  wire [31:0]  arbit_m_axi4_awaddr,                                      
		input  wire [7:0]   arbit_m_axi4_awlen,                                       
		input  wire [2:0]   arbit_m_axi4_awsize,                                      
		input  wire [1:0]   arbit_m_axi4_awburst,                                     
		input  wire [0:0]   arbit_m_axi4_awlock,                                      
		input  wire [2:0]   arbit_m_axi4_awprot,                                      
		input  wire [10:0]  arbit_m_axi4_awuser,                                      
		input  wire [3:0]   arbit_m_axi4_awqos,                                       
		input  wire         arbit_m_axi4_awvalid,                                     
		output wire         arbit_m_axi4_awready,                                     
		input  wire [255:0] arbit_m_axi4_wdata,                                       
		input  wire [31:0]  arbit_m_axi4_wstrb,                                       
		input  wire         arbit_m_axi4_wlast,                                       
		input  wire         arbit_m_axi4_wvalid,                                      
		input  wire [31:0]  arbit_m_axi4_wuser,                                       
		output wire         arbit_m_axi4_wready,                                      
		output wire [6:0]   arbit_m_axi4_bid,                                         
		output wire [1:0]   arbit_m_axi4_bresp,                                       
		output wire         arbit_m_axi4_bvalid,                                      
		input  wire         arbit_m_axi4_bready,                                      
		input  wire [6:0]   arbit_m_axi4_arid,                                        
		input  wire [31:0]  arbit_m_axi4_araddr,                                      
		input  wire [7:0]   arbit_m_axi4_arlen,                                       
		input  wire [2:0]   arbit_m_axi4_arsize,                                      
		input  wire [1:0]   arbit_m_axi4_arburst,                                     
		input  wire [0:0]   arbit_m_axi4_arlock,                                      
		input  wire [2:0]   arbit_m_axi4_arprot,                                      
		input  wire [10:0]  arbit_m_axi4_aruser,                                      
		input  wire [3:0]   arbit_m_axi4_arqos,                                       
		input  wire         arbit_m_axi4_arvalid,                                     
		output wire         arbit_m_axi4_arready,                                     
		output wire [6:0]   arbit_m_axi4_rid,                                         
		output wire [255:0] arbit_m_axi4_rdata,                                       
		output wire [1:0]   arbit_m_axi4_rresp,                                       
		output wire         arbit_m_axi4_rlast,                                       
		output wire         arbit_m_axi4_rvalid,                                      
		input  wire         arbit_m_axi4_rready,                                      
		output wire [31:0]  arbit_m_axi4_ruser,                                       
		output wire [26:0]  cal_arch_0_s0_axi4lite_axi4_lite_awaddr,                  
		output wire [2:0]   cal_arch_0_s0_axi4lite_axi4_lite_awprot,                  
		output wire         cal_arch_0_s0_axi4lite_axi4_lite_awvalid,                 
		input  wire         cal_arch_0_s0_axi4lite_axi4_lite_awready,                 
		output wire [31:0]  cal_arch_0_s0_axi4lite_axi4_lite_wdata,                   
		output wire [3:0]   cal_arch_0_s0_axi4lite_axi4_lite_wstrb,                   
		output wire         cal_arch_0_s0_axi4lite_axi4_lite_wvalid,                  
		input  wire         cal_arch_0_s0_axi4lite_axi4_lite_wready,                  
		input  wire [1:0]   cal_arch_0_s0_axi4lite_axi4_lite_bresp,                   
		input  wire         cal_arch_0_s0_axi4lite_axi4_lite_bvalid,                  
		output wire         cal_arch_0_s0_axi4lite_axi4_lite_bready,                  
		output wire [26:0]  cal_arch_0_s0_axi4lite_axi4_lite_araddr,                  
		output wire [2:0]   cal_arch_0_s0_axi4lite_axi4_lite_arprot,                  
		output wire         cal_arch_0_s0_axi4lite_axi4_lite_arvalid,                 
		input  wire         cal_arch_0_s0_axi4lite_axi4_lite_arready,                 
		input  wire [31:0]  cal_arch_0_s0_axi4lite_axi4_lite_rdata,                   
		input  wire [1:0]   cal_arch_0_s0_axi4lite_axi4_lite_rresp,                   
		input  wire         cal_arch_0_s0_axi4lite_axi4_lite_rvalid,                  
		output wire         cal_arch_0_s0_axi4lite_axi4_lite_rready,                  
		input  wire         arbit_m_axi4_aresetn_reset_bridge_in_reset_reset,         
		input  wire         cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset, 
		input  wire         clk_bridge_out_clk_2_clk,                                 
		input  wire         clk_bridge_out_clk_1_clk                                  
	);

	wire   [31:0] arbit_m_axi4_translator_m0_ruser;                                        
	wire   [31:0] arbit_m_axi4_translator_m0_wuser;                                        
	wire    [1:0] arbit_m_axi4_translator_m0_awburst;                                      
	wire    [3:0] arbit_m_axi4_translator_m0_arregion;                                     
	wire   [10:0] arbit_m_axi4_translator_m0_awuser;                                       
	wire    [7:0] arbit_m_axi4_translator_m0_arlen;                                        
	wire    [3:0] arbit_m_axi4_translator_m0_arqos;                                        
	wire   [31:0] arbit_m_axi4_translator_m0_wstrb;                                        
	wire          arbit_m_axi4_translator_m0_wready;                                       
	wire    [6:0] arbit_m_axi4_translator_m0_rid;                                          
	wire          arbit_m_axi4_translator_m0_rready;                                       
	wire    [7:0] arbit_m_axi4_translator_m0_awlen;                                        
	wire    [3:0] arbit_m_axi4_translator_m0_awqos;                                        
	wire    [3:0] arbit_m_axi4_translator_m0_arcache;                                      
	wire          arbit_m_axi4_translator_m0_wvalid;                                       
	wire   [31:0] arbit_m_axi4_translator_m0_araddr;                                       
	wire    [2:0] arbit_m_axi4_translator_m0_arprot;                                       
	wire    [2:0] arbit_m_axi4_translator_m0_awprot;                                       
	wire  [255:0] arbit_m_axi4_translator_m0_wdata;                                        
	wire          arbit_m_axi4_translator_m0_arvalid;                                      
	wire    [3:0] arbit_m_axi4_translator_m0_awcache;                                      
	wire    [6:0] arbit_m_axi4_translator_m0_arid;                                         
	wire    [0:0] arbit_m_axi4_translator_m0_arlock;                                       
	wire    [0:0] arbit_m_axi4_translator_m0_awlock;                                       
	wire   [31:0] arbit_m_axi4_translator_m0_awaddr;                                       
	wire    [1:0] arbit_m_axi4_translator_m0_bresp;                                        
	wire          arbit_m_axi4_translator_m0_arready;                                      
	wire  [255:0] arbit_m_axi4_translator_m0_rdata;                                        
	wire          arbit_m_axi4_translator_m0_awready;                                      
	wire    [1:0] arbit_m_axi4_translator_m0_arburst;                                      
	wire    [2:0] arbit_m_axi4_translator_m0_arsize;                                       
	wire          arbit_m_axi4_translator_m0_bready;                                       
	wire          arbit_m_axi4_translator_m0_rlast;                                        
	wire          arbit_m_axi4_translator_m0_wlast;                                        
	wire    [3:0] arbit_m_axi4_translator_m0_awregion;                                     
	wire   [31:0] arbit_m_axi4_translator_m0_buser;                                        
	wire    [1:0] arbit_m_axi4_translator_m0_rresp;                                        
	wire    [6:0] arbit_m_axi4_translator_m0_awid;                                         
	wire    [6:0] arbit_m_axi4_translator_m0_bid;                                          
	wire          arbit_m_axi4_translator_m0_bvalid;                                       
	wire    [2:0] arbit_m_axi4_translator_m0_awsize;                                       
	wire          arbit_m_axi4_translator_m0_awvalid;                                      
	wire   [10:0] arbit_m_axi4_translator_m0_aruser;                                       
	wire          arbit_m_axi4_translator_m0_rvalid;                                       
	wire          rsp_mux_src_valid;                                                       
	wire  [439:0] rsp_mux_src_data;                                                        
	wire          rsp_mux_src_ready;                                                       
	wire    [1:0] rsp_mux_src_channel;                                                     
	wire          rsp_mux_src_startofpacket;                                               
	wire          rsp_mux_src_endofpacket;                                                 
	wire          rsp_mux_001_src_valid;                                                   
	wire  [439:0] rsp_mux_001_src_data;                                                    
	wire          rsp_mux_001_src_ready;                                                   
	wire    [1:0] rsp_mux_001_src_channel;                                                 
	wire          rsp_mux_001_src_startofpacket;                                           
	wire          rsp_mux_001_src_endofpacket;                                             
	wire          arbit_m_axi4_agent_write_cp_valid;                                       
	wire  [439:0] arbit_m_axi4_agent_write_cp_data;                                        
	wire          arbit_m_axi4_agent_write_cp_ready;                                       
	wire          arbit_m_axi4_agent_write_cp_startofpacket;                               
	wire          arbit_m_axi4_agent_write_cp_endofpacket;                                 
	wire          router_src_valid;                                                        
	wire  [439:0] router_src_data;                                                         
	wire          router_src_ready;                                                        
	wire    [1:0] router_src_channel;                                                      
	wire          router_src_startofpacket;                                                
	wire          router_src_endofpacket;                                                  
	wire          arbit_m_axi4_agent_read_cp_valid;                                        
	wire  [439:0] arbit_m_axi4_agent_read_cp_data;                                         
	wire          arbit_m_axi4_agent_read_cp_ready;                                        
	wire          arbit_m_axi4_agent_read_cp_startofpacket;                                
	wire          arbit_m_axi4_agent_read_cp_endofpacket;                                  
	wire          router_001_src_valid;                                                    
	wire  [439:0] router_001_src_data;                                                     
	wire          router_001_src_ready;                                                    
	wire    [1:0] router_001_src_channel;                                                  
	wire          router_001_src_startofpacket;                                            
	wire          router_001_src_endofpacket;                                              
	wire          cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_valid;                   
	wire  [187:0] cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_data;                    
	wire          cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_ready;                   
	wire          cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_startofpacket;           
	wire          cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_endofpacket;             
	wire          cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_valid;                    
	wire  [187:0] cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_data;                     
	wire          cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_ready;                    
	wire          cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_startofpacket;            
	wire          cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_endofpacket;              
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_valid;         
	wire  [187:0] cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_data;          
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_ready;         
	wire    [1:0] cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_channel;       
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_startofpacket; 
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_endofpacket;   
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_valid;         
	wire  [187:0] cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_data;          
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_ready;         
	wire    [1:0] cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_channel;       
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_startofpacket; 
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_endofpacket;   
	wire          router_002_src_valid;                                                    
	wire  [187:0] router_002_src_data;                                                     
	wire          router_002_src_ready;                                                    
	wire    [1:0] router_002_src_channel;                                                  
	wire          router_002_src_startofpacket;                                            
	wire          router_002_src_endofpacket;                                              
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_valid;         
	wire  [439:0] cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_data;          
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_ready;         
	wire    [1:0] cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_channel;       
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_startofpacket; 
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_endofpacket;   
	wire          router_003_src_valid;                                                    
	wire  [187:0] router_003_src_data;                                                     
	wire          router_003_src_ready;                                                    
	wire    [1:0] router_003_src_channel;                                                  
	wire          router_003_src_startofpacket;                                            
	wire          router_003_src_endofpacket;                                              
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_valid;         
	wire  [439:0] cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_data;          
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_ready;         
	wire    [1:0] cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_channel;       
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_startofpacket; 
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_endofpacket;   
	wire          cmd_mux_src_valid;                                                       
	wire  [439:0] cmd_mux_src_data;                                                        
	wire          cmd_mux_src_ready;                                                       
	wire    [1:0] cmd_mux_src_channel;                                                     
	wire          cmd_mux_src_startofpacket;                                               
	wire          cmd_mux_src_endofpacket;                                                 
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_valid;         
	wire  [187:0] cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_data;          
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_ready;         
	wire    [1:0] cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_channel;       
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_startofpacket; 
	wire          cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_endofpacket;   
	wire          cmd_mux_001_src_valid;                                                   
	wire  [439:0] cmd_mux_001_src_data;                                                    
	wire          cmd_mux_001_src_ready;                                                   
	wire    [1:0] cmd_mux_001_src_channel;                                                 
	wire          cmd_mux_001_src_startofpacket;                                           
	wire          cmd_mux_001_src_endofpacket;                                             
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_valid;         
	wire  [187:0] cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_data;          
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_ready;         
	wire    [1:0] cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_channel;       
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_startofpacket; 
	wire          cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_endofpacket;   
	wire          cmd_demux_src0_valid;                                                    
	wire  [439:0] cmd_demux_src0_data;                                                     
	wire          cmd_demux_src0_ready;                                                    
	wire    [1:0] cmd_demux_src0_channel;                                                  
	wire          cmd_demux_src0_startofpacket;                                            
	wire          cmd_demux_src0_endofpacket;                                              
	wire          crosser_out_valid;                                                       
	wire  [439:0] crosser_out_data;                                                        
	wire          crosser_out_ready;                                                       
	wire    [1:0] crosser_out_channel;                                                     
	wire          crosser_out_startofpacket;                                               
	wire          crosser_out_endofpacket;                                                 
	wire          cmd_demux_001_src0_valid;                                                
	wire  [439:0] cmd_demux_001_src0_data;                                                 
	wire          cmd_demux_001_src0_ready;                                                
	wire    [1:0] cmd_demux_001_src0_channel;                                              
	wire          cmd_demux_001_src0_startofpacket;                                        
	wire          cmd_demux_001_src0_endofpacket;                                          
	wire          crosser_001_out_valid;                                                   
	wire  [439:0] crosser_001_out_data;                                                    
	wire          crosser_001_out_ready;                                                   
	wire    [1:0] crosser_001_out_channel;                                                 
	wire          crosser_001_out_startofpacket;                                           
	wire          crosser_001_out_endofpacket;                                             
	wire          rsp_demux_src0_valid;                                                    
	wire  [439:0] rsp_demux_src0_data;                                                     
	wire          rsp_demux_src0_ready;                                                    
	wire    [1:0] rsp_demux_src0_channel;                                                  
	wire          rsp_demux_src0_startofpacket;                                            
	wire          rsp_demux_src0_endofpacket;                                              
	wire          crosser_002_out_valid;                                                   
	wire  [439:0] crosser_002_out_data;                                                    
	wire          crosser_002_out_ready;                                                   
	wire    [1:0] crosser_002_out_channel;                                                 
	wire          crosser_002_out_startofpacket;                                           
	wire          crosser_002_out_endofpacket;                                             
	wire          rsp_demux_001_src0_valid;                                                
	wire  [439:0] rsp_demux_001_src0_data;                                                 
	wire          rsp_demux_001_src0_ready;                                                
	wire    [1:0] rsp_demux_001_src0_channel;                                              
	wire          rsp_demux_001_src0_startofpacket;                                        
	wire          rsp_demux_001_src0_endofpacket;                                          
	wire          crosser_003_out_valid;                                                   
	wire  [439:0] crosser_003_out_data;                                                    
	wire          crosser_003_out_ready;                                                   
	wire    [1:0] crosser_003_out_channel;                                                 
	wire          crosser_003_out_startofpacket;                                           
	wire          crosser_003_out_endofpacket;                                             

	ed_synth_dut_altera_merlin_axi_translator_1931_d46vvwa #(
		.USE_S0_AWID                       (1),
		.USE_S0_AWREGION                   (0),
		.USE_M0_AWREGION                   (1),
		.USE_S0_AWLEN                      (1),
		.USE_S0_AWSIZE                     (1),
		.USE_S0_AWBURST                    (1),
		.USE_S0_AWLOCK                     (1),
		.USE_M0_AWLOCK                     (1),
		.USE_S0_AWCACHE                    (0),
		.USE_M0_AWCACHE                    (1),
		.USE_M0_AWPROT                     (1),
		.USE_S0_AWQOS                      (1),
		.USE_M0_AWQOS                      (1),
		.USE_S0_WSTRB                      (1),
		.USE_M0_WLAST                      (1),
		.USE_S0_BID                        (1),
		.USE_S0_BRESP                      (1),
		.USE_M0_BRESP                      (1),
		.USE_S0_ARID                       (1),
		.USE_S0_ARREGION                   (0),
		.USE_M0_ARREGION                   (1),
		.USE_S0_ARLEN                      (1),
		.USE_S0_ARSIZE                     (1),
		.USE_S0_ARBURST                    (1),
		.USE_S0_ARLOCK                     (1),
		.USE_M0_ARLOCK                     (1),
		.USE_M0_ARCACHE                    (1),
		.USE_M0_ARQOS                      (1),
		.USE_M0_ARPROT                     (1),
		.USE_S0_ARCACHE                    (0),
		.USE_S0_ARQOS                      (1),
		.USE_S0_RID                        (1),
		.USE_S0_RRESP                      (1),
		.USE_M0_RRESP                      (1),
		.USE_S0_RLAST                      (1),
		.M0_ID_WIDTH                       (7),
		.DATA_WIDTH                        (256),
		.M0_SAI_WIDTH                      (4),
		.S0_SAI_WIDTH                      (4),
		.M0_USER_ADDRCHK_WIDTH             (4),
		.S0_USER_ADDRCHK_WIDTH             (4),
		.S0_ID_WIDTH                       (7),
		.M0_ADDR_WIDTH                     (32),
		.S0_WRITE_ADDR_USER_WIDTH          (11),
		.S0_READ_ADDR_USER_WIDTH           (11),
		.M0_WRITE_ADDR_USER_WIDTH          (11),
		.M0_READ_ADDR_USER_WIDTH           (11),
		.S0_WRITE_DATA_USER_WIDTH          (32),
		.S0_WRITE_RESPONSE_DATA_USER_WIDTH (1),
		.S0_READ_DATA_USER_WIDTH           (32),
		.M0_WRITE_DATA_USER_WIDTH          (32),
		.M0_WRITE_RESPONSE_DATA_USER_WIDTH (32),
		.M0_READ_DATA_USER_WIDTH           (32),
		.S0_ADDR_WIDTH                     (32),
		.USE_S0_AWUSER                     (1),
		.USE_S0_ARUSER                     (1),
		.USE_S0_WUSER                      (1),
		.USE_S0_RUSER                      (1),
		.USE_S0_BUSER                      (0),
		.USE_M0_AWUSER                     (1),
		.USE_M0_ARUSER                     (1),
		.USE_M0_WUSER                      (1),
		.USE_M0_RUSER                      (1),
		.USE_M0_BUSER                      (1),
		.M0_AXI_VERSION                    ("AXI4"),
		.M0_BURST_LENGTH_WIDTH             (8),
		.S0_BURST_LENGTH_WIDTH             (8),
		.M0_LOCK_WIDTH                     (1),
		.S0_LOCK_WIDTH                     (1),
		.S0_AXI_VERSION                    ("AXI4"),
		.ACE_LITE_SUPPORT                  (0),
		.USE_M0_AWUSER_ADDRCHK             (0),
		.USE_M0_AWUSER_SAI                 (0),
		.USE_M0_ARUSER_ADDRCHK             (0),
		.USE_M0_ARUSER_SAI                 (0),
		.USE_M0_WUSER_DATACHK              (0),
		.USE_M0_WUSER_POISON               (0),
		.USE_M0_RUSER_DATACHK              (0),
		.USE_M0_RUSER_POISON               (0),
		.USE_S0_AWUSER_ADDRCHK             (0),
		.USE_S0_AWUSER_SAI                 (0),
		.USE_S0_ARUSER_ADDRCHK             (0),
		.USE_S0_ARUSER_SAI                 (0),
		.USE_S0_WUSER_DATACHK              (0),
		.USE_S0_WUSER_POISON               (0),
		.USE_S0_RUSER_DATACHK              (0),
		.USE_S0_RUSER_POISON               (0),
		.ROLE_BASED_USER                   (0)
	) arbit_m_axi4_translator (
		.aclk              (clk_bridge_out_clk_2_clk),                          
		.aresetn           (~arbit_m_axi4_aresetn_reset_bridge_in_reset_reset), 
		.m0_awid           (arbit_m_axi4_translator_m0_awid),                   
		.m0_awaddr         (arbit_m_axi4_translator_m0_awaddr),                 
		.m0_awlen          (arbit_m_axi4_translator_m0_awlen),                  
		.m0_awsize         (arbit_m_axi4_translator_m0_awsize),                 
		.m0_awburst        (arbit_m_axi4_translator_m0_awburst),                
		.m0_awlock         (arbit_m_axi4_translator_m0_awlock),                 
		.m0_awcache        (arbit_m_axi4_translator_m0_awcache),                
		.m0_awprot         (arbit_m_axi4_translator_m0_awprot),                 
		.m0_awuser         (arbit_m_axi4_translator_m0_awuser),                 
		.m0_awqos          (arbit_m_axi4_translator_m0_awqos),                  
		.m0_awregion       (arbit_m_axi4_translator_m0_awregion),               
		.m0_awvalid        (arbit_m_axi4_translator_m0_awvalid),                
		.m0_awready        (arbit_m_axi4_translator_m0_awready),                
		.m0_wdata          (arbit_m_axi4_translator_m0_wdata),                  
		.m0_wstrb          (arbit_m_axi4_translator_m0_wstrb),                  
		.m0_wlast          (arbit_m_axi4_translator_m0_wlast),                  
		.m0_wvalid         (arbit_m_axi4_translator_m0_wvalid),                 
		.m0_wuser          (arbit_m_axi4_translator_m0_wuser),                  
		.m0_wready         (arbit_m_axi4_translator_m0_wready),                 
		.m0_bid            (arbit_m_axi4_translator_m0_bid),                    
		.m0_bresp          (arbit_m_axi4_translator_m0_bresp),                  
		.m0_buser          (arbit_m_axi4_translator_m0_buser),                  
		.m0_bvalid         (arbit_m_axi4_translator_m0_bvalid),                 
		.m0_bready         (arbit_m_axi4_translator_m0_bready),                 
		.m0_arid           (arbit_m_axi4_translator_m0_arid),                   
		.m0_araddr         (arbit_m_axi4_translator_m0_araddr),                 
		.m0_arlen          (arbit_m_axi4_translator_m0_arlen),                  
		.m0_arsize         (arbit_m_axi4_translator_m0_arsize),                 
		.m0_arburst        (arbit_m_axi4_translator_m0_arburst),                
		.m0_arlock         (arbit_m_axi4_translator_m0_arlock),                 
		.m0_arcache        (arbit_m_axi4_translator_m0_arcache),                
		.m0_arprot         (arbit_m_axi4_translator_m0_arprot),                 
		.m0_aruser         (arbit_m_axi4_translator_m0_aruser),                 
		.m0_arqos          (arbit_m_axi4_translator_m0_arqos),                  
		.m0_arregion       (arbit_m_axi4_translator_m0_arregion),               
		.m0_arvalid        (arbit_m_axi4_translator_m0_arvalid),                
		.m0_arready        (arbit_m_axi4_translator_m0_arready),                
		.m0_rid            (arbit_m_axi4_translator_m0_rid),                    
		.m0_rdata          (arbit_m_axi4_translator_m0_rdata),                  
		.m0_rresp          (arbit_m_axi4_translator_m0_rresp),                  
		.m0_rlast          (arbit_m_axi4_translator_m0_rlast),                  
		.m0_rvalid         (arbit_m_axi4_translator_m0_rvalid),                 
		.m0_rready         (arbit_m_axi4_translator_m0_rready),                 
		.m0_ruser          (arbit_m_axi4_translator_m0_ruser),                  
		.s0_awid           (arbit_m_axi4_awid),                                 
		.s0_awaddr         (arbit_m_axi4_awaddr),                               
		.s0_awlen          (arbit_m_axi4_awlen),                                
		.s0_awsize         (arbit_m_axi4_awsize),                               
		.s0_awburst        (arbit_m_axi4_awburst),                              
		.s0_awlock         (arbit_m_axi4_awlock),                               
		.s0_awprot         (arbit_m_axi4_awprot),                               
		.s0_awuser         (arbit_m_axi4_awuser),                               
		.s0_awqos          (arbit_m_axi4_awqos),                                
		.s0_awvalid        (arbit_m_axi4_awvalid),                              
		.s0_awready        (arbit_m_axi4_awready),                              
		.s0_wdata          (arbit_m_axi4_wdata),                                
		.s0_wstrb          (arbit_m_axi4_wstrb),                                
		.s0_wlast          (arbit_m_axi4_wlast),                                
		.s0_wvalid         (arbit_m_axi4_wvalid),                               
		.s0_wuser          (arbit_m_axi4_wuser),                                
		.s0_wready         (arbit_m_axi4_wready),                               
		.s0_bid            (arbit_m_axi4_bid),                                  
		.s0_bresp          (arbit_m_axi4_bresp),                                
		.s0_bvalid         (arbit_m_axi4_bvalid),                               
		.s0_bready         (arbit_m_axi4_bready),                               
		.s0_arid           (arbit_m_axi4_arid),                                 
		.s0_araddr         (arbit_m_axi4_araddr),                               
		.s0_arlen          (arbit_m_axi4_arlen),                                
		.s0_arsize         (arbit_m_axi4_arsize),                               
		.s0_arburst        (arbit_m_axi4_arburst),                              
		.s0_arlock         (arbit_m_axi4_arlock),                               
		.s0_arprot         (arbit_m_axi4_arprot),                               
		.s0_aruser         (arbit_m_axi4_aruser),                               
		.s0_arqos          (arbit_m_axi4_arqos),                                
		.s0_arvalid        (arbit_m_axi4_arvalid),                              
		.s0_arready        (arbit_m_axi4_arready),                              
		.s0_rid            (arbit_m_axi4_rid),                                  
		.s0_rdata          (arbit_m_axi4_rdata),                                
		.s0_rresp          (arbit_m_axi4_rresp),                                
		.s0_rlast          (arbit_m_axi4_rlast),                                
		.s0_rvalid         (arbit_m_axi4_rvalid),                               
		.s0_rready         (arbit_m_axi4_rready),                               
		.s0_ruser          (arbit_m_axi4_ruser),                                
		.m0_awuser_addrchk (),                                                  
		.m0_awuser_sai     (),                                                  
		.m0_wuser_datachk  (),                                                  
		.m0_wuser_poison   (),                                                  
		.m0_aruser_addrchk (),                                                  
		.m0_aruser_sai     (),                                                  
		.m0_ruser_datachk  (32'b00000000000000000000000000000000),              
		.m0_ruser_poison   (4'b0000),                                           
		.s0_awcache        (4'b0000),                                           
		.s0_awuser_addrchk (4'b0000),                                           
		.s0_awuser_sai     (4'b0000),                                           
		.s0_awregion       (4'b0000),                                           
		.s0_wuser_datachk  (32'b00000000000000000000000000000000),              
		.s0_wuser_poison   (4'b0000),                                           
		.s0_buser          (),                                                  
		.s0_arcache        (4'b0000),                                           
		.s0_aruser_addrchk (4'b0000),                                           
		.s0_aruser_sai     (4'b0000),                                           
		.s0_arregion       (4'b0000),                                           
		.s0_ruser_datachk  (),                                                  
		.s0_ruser_poison   (),                                                  
		.s0_wid            (7'b0000000),                                        
		.s0_ardomain       (2'b00),                                             
		.s0_arsnoop        (4'b0000),                                           
		.s0_arbar          (2'b00),                                             
		.s0_awdomain       (2'b00),                                             
		.s0_awsnoop        (3'b000),                                            
		.s0_awbar          (2'b00),                                             
		.s0_awunique       (1'b0),                                              
		.m0_wid            (),                                                  
		.m0_ardomain       (),                                                  
		.m0_arsnoop        (),                                                  
		.m0_arbar          (),                                                  
		.m0_awdomain       (),                                                  
		.m0_awsnoop        (),                                                  
		.m0_awbar          (),                                                  
		.m0_awunique       ()                                                   
	);

	ed_synth_dut_altera_merlin_axi_master_ni_1962_2kryw2a #(
		.ID_WIDTH                  (7),
		.ADDR_WIDTH                (32),
		.RDATA_WIDTH               (256),
		.WDATA_WIDTH               (256),
		.ADDR_USER_WIDTH           (11),
		.DATA_USER_WIDTH           (32),
		.AXI_BURST_LENGTH_WIDTH    (8),
		.AXI_LOCK_WIDTH            (1),
		.SAI_WIDTH                 (1),
		.ADDRCHK_WIDTH             (1),
		.USE_PKT_DATACHK           (0),
		.USE_PKT_ADDRCHK           (0),
		.AXI_VERSION               ("AXI4"),
		.ACE_LITE_SUPPORT          (0),
		.ROLE_BASED_USER           (0),
		.WRITE_ISSUING_CAPABILITY  (1),
		.READ_ISSUING_CAPABILITY   (1),
		.PKT_BEGIN_BURST           (398),
		.PKT_CACHE_H               (418),
		.PKT_CACHE_L               (415),
		.PKT_ADDR_SIDEBAND_H       (365),
		.PKT_ADDR_SIDEBAND_L       (355),
		.PKT_PROTECTION_H          (414),
		.PKT_PROTECTION_L          (412),
		.PKT_BURST_SIZE_H          (352),
		.PKT_BURST_SIZE_L          (350),
		.PKT_BURST_TYPE_H          (354),
		.PKT_BURST_TYPE_L          (353),
		.PKT_RESPONSE_STATUS_L     (419),
		.PKT_RESPONSE_STATUS_H     (420),
		.PKT_BURSTWRAP_H           (349),
		.PKT_BURSTWRAP_L           (340),
		.PKT_BYTE_CNT_H            (339),
		.PKT_BYTE_CNT_L            (326),
		.PKT_ADDR_H                (319),
		.PKT_ADDR_L                (288),
		.PKT_TRANS_EXCLUSIVE       (325),
		.PKT_TRANS_LOCK            (324),
		.PKT_TRANS_COMPRESSED_READ (320),
		.PKT_TRANS_POSTED          (321),
		.PKT_TRANS_WRITE           (322),
		.PKT_TRANS_READ            (323),
		.PKT_DATA_H                (255),
		.PKT_DATA_L                (0),
		.PKT_BYTEEN_H              (287),
		.PKT_BYTEEN_L              (256),
		.PKT_SRC_ID_H              (403),
		.PKT_SRC_ID_L              (403),
		.PKT_DEST_ID_H             (404),
		.PKT_DEST_ID_L             (404),
		.PKT_THREAD_ID_H           (411),
		.PKT_THREAD_ID_L           (405),
		.PKT_QOS_L                 (399),
		.PKT_QOS_H                 (402),
		.PKT_ORI_BURST_SIZE_L      (421),
		.PKT_ORI_BURST_SIZE_H      (423),
		.PKT_DATA_SIDEBAND_H       (397),
		.PKT_DATA_SIDEBAND_L       (366),
		.PKT_DOMAIN_H              (431),
		.PKT_DOMAIN_L              (430),
		.PKT_SNOOP_H               (429),
		.PKT_SNOOP_L               (426),
		.PKT_BARRIER_H             (425),
		.PKT_BARRIER_L             (424),
		.PKT_WUNIQUE               (432),
		.PKT_EOP_OOO               (437),
		.PKT_SOP_OOO               (438),
		.PKT_POISON_H              (433),
		.PKT_POISON_L              (433),
		.PKT_DATACHK_H             (434),
		.PKT_DATACHK_L             (434),
		.PKT_ADDRCHK_H             (435),
		.PKT_ADDRCHK_L             (435),
		.PKT_SAI_H                 (436),
		.PKT_SAI_L                 (436),
		.ST_DATA_W                 (440),
		.ST_CHANNEL_W              (2),
		.ID                        (0),
		.SYNC_RESET                (0)
	) arbit_m_axi4_agent (
		.aclk                   (clk_bridge_out_clk_2_clk),                          
		.aresetn                (~arbit_m_axi4_aresetn_reset_bridge_in_reset_reset), 
		.write_cp_valid         (arbit_m_axi4_agent_write_cp_valid),                 
		.write_cp_data          (arbit_m_axi4_agent_write_cp_data),                  
		.write_cp_startofpacket (arbit_m_axi4_agent_write_cp_startofpacket),         
		.write_cp_endofpacket   (arbit_m_axi4_agent_write_cp_endofpacket),           
		.write_cp_ready         (arbit_m_axi4_agent_write_cp_ready),                 
		.write_rp_valid         (rsp_mux_src_valid),                                 
		.write_rp_data          (rsp_mux_src_data),                                  
		.write_rp_channel       (rsp_mux_src_channel),                               
		.write_rp_startofpacket (rsp_mux_src_startofpacket),                         
		.write_rp_endofpacket   (rsp_mux_src_endofpacket),                           
		.write_rp_ready         (rsp_mux_src_ready),                                 
		.read_cp_valid          (arbit_m_axi4_agent_read_cp_valid),                  
		.read_cp_data           (arbit_m_axi4_agent_read_cp_data),                   
		.read_cp_startofpacket  (arbit_m_axi4_agent_read_cp_startofpacket),          
		.read_cp_endofpacket    (arbit_m_axi4_agent_read_cp_endofpacket),            
		.read_cp_ready          (arbit_m_axi4_agent_read_cp_ready),                  
		.read_rp_valid          (rsp_mux_001_src_valid),                             
		.read_rp_data           (rsp_mux_001_src_data),                              
		.read_rp_channel        (rsp_mux_001_src_channel),                           
		.read_rp_startofpacket  (rsp_mux_001_src_startofpacket),                     
		.read_rp_endofpacket    (rsp_mux_001_src_endofpacket),                       
		.read_rp_ready          (rsp_mux_001_src_ready),                             
		.awid                   (arbit_m_axi4_translator_m0_awid),                   
		.awaddr                 (arbit_m_axi4_translator_m0_awaddr),                 
		.awlen                  (arbit_m_axi4_translator_m0_awlen),                  
		.awsize                 (arbit_m_axi4_translator_m0_awsize),                 
		.awburst                (arbit_m_axi4_translator_m0_awburst),                
		.awlock                 (arbit_m_axi4_translator_m0_awlock),                 
		.awcache                (arbit_m_axi4_translator_m0_awcache),                
		.awprot                 (arbit_m_axi4_translator_m0_awprot),                 
		.awuser                 (arbit_m_axi4_translator_m0_awuser),                 
		.awqos                  (arbit_m_axi4_translator_m0_awqos),                  
		.awregion               (arbit_m_axi4_translator_m0_awregion),               
		.awvalid                (arbit_m_axi4_translator_m0_awvalid),                
		.awready                (arbit_m_axi4_translator_m0_awready),                
		.wdata                  (arbit_m_axi4_translator_m0_wdata),                  
		.wstrb                  (arbit_m_axi4_translator_m0_wstrb),                  
		.wlast                  (arbit_m_axi4_translator_m0_wlast),                  
		.wvalid                 (arbit_m_axi4_translator_m0_wvalid),                 
		.wuser                  (arbit_m_axi4_translator_m0_wuser),                  
		.wready                 (arbit_m_axi4_translator_m0_wready),                 
		.bid                    (arbit_m_axi4_translator_m0_bid),                    
		.bresp                  (arbit_m_axi4_translator_m0_bresp),                  
		.buser                  (arbit_m_axi4_translator_m0_buser),                  
		.bvalid                 (arbit_m_axi4_translator_m0_bvalid),                 
		.bready                 (arbit_m_axi4_translator_m0_bready),                 
		.arid                   (arbit_m_axi4_translator_m0_arid),                   
		.araddr                 (arbit_m_axi4_translator_m0_araddr),                 
		.arlen                  (arbit_m_axi4_translator_m0_arlen),                  
		.arsize                 (arbit_m_axi4_translator_m0_arsize),                 
		.arburst                (arbit_m_axi4_translator_m0_arburst),                
		.arlock                 (arbit_m_axi4_translator_m0_arlock),                 
		.arcache                (arbit_m_axi4_translator_m0_arcache),                
		.arprot                 (arbit_m_axi4_translator_m0_arprot),                 
		.aruser                 (arbit_m_axi4_translator_m0_aruser),                 
		.arqos                  (arbit_m_axi4_translator_m0_arqos),                  
		.arregion               (arbit_m_axi4_translator_m0_arregion),               
		.arvalid                (arbit_m_axi4_translator_m0_arvalid),                
		.arready                (arbit_m_axi4_translator_m0_arready),                
		.rid                    (arbit_m_axi4_translator_m0_rid),                    
		.rdata                  (arbit_m_axi4_translator_m0_rdata),                  
		.rresp                  (arbit_m_axi4_translator_m0_rresp),                  
		.rlast                  (arbit_m_axi4_translator_m0_rlast),                  
		.rvalid                 (arbit_m_axi4_translator_m0_rvalid),                 
		.rready                 (arbit_m_axi4_translator_m0_rready),                 
		.ruser                  (arbit_m_axi4_translator_m0_ruser),                  
		.awuser_addrchk         (1'b0),                                              
		.awuser_sai             (1'b0),                                              
		.wuser_datachk          (32'b00000000000000000000000000000000),              
		.wuser_poison           (4'b0000),                                           
		.aruser_addrchk         (1'b0),                                              
		.aruser_sai             (1'b0),                                              
		.ruser_datachk          (),                                                  
		.ruser_poison           (),                                                  
		.wid                    (7'b0000000),                                        
		.arsnoop                (4'b0000),                                           
		.ardomain               (2'b00),                                             
		.arbar                  (2'b00),                                             
		.awsnoop                (3'b000),                                            
		.awdomain               (2'b00),                                             
		.awbar                  (2'b00),                                             
		.awunique               (1'b0)                                               
	);

	ed_synth_dut_altera_merlin_axi_slave_ni_1971_cwyib4q #(
		.PKT_QOS_H                   (150),
		.PKT_QOS_L                   (147),
		.PKT_THREAD_ID_H             (159),
		.PKT_THREAD_ID_L             (153),
		.PKT_RESPONSE_STATUS_H       (168),
		.PKT_RESPONSE_STATUS_L       (167),
		.PKT_BEGIN_BURST             (146),
		.PKT_CACHE_H                 (166),
		.PKT_CACHE_L                 (163),
		.PKT_DATA_SIDEBAND_H         (145),
		.PKT_DATA_SIDEBAND_L         (114),
		.PKT_ADDR_SIDEBAND_H         (113),
		.PKT_ADDR_SIDEBAND_L         (103),
		.PKT_BURST_TYPE_H            (102),
		.PKT_BURST_TYPE_L            (101),
		.PKT_PROTECTION_H            (162),
		.PKT_PROTECTION_L            (160),
		.PKT_BURST_SIZE_H            (100),
		.PKT_BURST_SIZE_L            (98),
		.PKT_BURSTWRAP_H             (97),
		.PKT_BURSTWRAP_L             (88),
		.PKT_BYTE_CNT_H              (87),
		.PKT_BYTE_CNT_L              (74),
		.PKT_ADDR_H                  (67),
		.PKT_ADDR_L                  (36),
		.PKT_TRANS_EXCLUSIVE         (73),
		.PKT_TRANS_LOCK              (72),
		.PKT_TRANS_COMPRESSED_READ   (68),
		.PKT_TRANS_POSTED            (69),
		.PKT_TRANS_WRITE             (70),
		.PKT_TRANS_READ              (71),
		.PKT_DATA_H                  (31),
		.PKT_DATA_L                  (0),
		.PKT_BYTEEN_H                (35),
		.PKT_BYTEEN_L                (32),
		.PKT_SRC_ID_H                (151),
		.PKT_SRC_ID_L                (151),
		.PKT_DEST_ID_H               (152),
		.PKT_DEST_ID_L               (152),
		.PKT_ORI_BURST_SIZE_L        (169),
		.PKT_ORI_BURST_SIZE_H        (171),
		.PKT_DOMAIN_L                (178),
		.PKT_DOMAIN_H                (179),
		.PKT_SNOOP_L                 (174),
		.PKT_SNOOP_H                 (177),
		.PKT_BARRIER_L               (172),
		.PKT_BARRIER_H               (173),
		.PKT_WUNIQUE                 (180),
		.PKT_EOP_OOO                 (185),
		.PKT_SOP_OOO                 (186),
		.PKT_POISON_H                (181),
		.PKT_POISON_L                (181),
		.PKT_DATACHK_H               (182),
		.PKT_DATACHK_L               (182),
		.PKT_ADDRCHK_H               (183),
		.PKT_ADDRCHK_L               (183),
		.PKT_SAI_H                   (184),
		.PKT_SAI_L                   (184),
		.SAI_WIDTH                   (1),
		.ADDRCHK_WIDTH               (1),
		.ADDR_USER_WIDTH             (1),
		.DATA_USER_WIDTH             (1),
		.ST_DATA_W                   (188),
		.ADDR_WIDTH                  (27),
		.RDATA_WIDTH                 (32),
		.WDATA_WIDTH                 (32),
		.ST_CHANNEL_W                (2),
		.AXI_SLAVE_ID_W              (1),
		.ACE_LITE_SUPPORT            (0),
		.PASS_ID_TO_SLAVE            (0),
		.AXI_VERSION                 ("AXI4Lite"),
		.WRITE_ACCEPTANCE_CAPABILITY (1),
		.READ_ACCEPTANCE_CAPABILITY  (1),
		.USE_PKT_DATACHK             (0),
		.USE_PKT_ADDRCHK             (0),
		.SYNC_RESET                  (0),
		.USE_MEMORY_BLOCKS           (0),
		.ROLE_BASED_USER             (0),
		.ENABLE_OOO                  (0),
		.REORDER_BUFFER              (0)
	) cal_arch_0_s0_axi4lite_axi4_lite_agent (
		.aclk                   (clk_bridge_out_clk_1_clk),                                                
		.aresetn                (~cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),               
		.read_cp_valid          (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_valid),         
		.read_cp_ready          (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_ready),         
		.read_cp_data           (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_data),          
		.read_cp_channel        (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_channel),       
		.read_cp_startofpacket  (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_startofpacket), 
		.read_cp_endofpacket    (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_endofpacket),   
		.write_cp_ready         (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_ready),         
		.write_cp_valid         (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_valid),         
		.write_cp_data          (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_data),          
		.write_cp_channel       (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_channel),       
		.write_cp_startofpacket (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_startofpacket), 
		.write_cp_endofpacket   (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_endofpacket),   
		.read_rp_ready          (cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_ready),                    
		.read_rp_valid          (cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_valid),                    
		.read_rp_data           (cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_data),                     
		.read_rp_startofpacket  (cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_startofpacket),            
		.read_rp_endofpacket    (cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_endofpacket),              
		.write_rp_ready         (cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_ready),                   
		.write_rp_valid         (cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_valid),                   
		.write_rp_data          (cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_data),                    
		.write_rp_startofpacket (cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_startofpacket),           
		.write_rp_endofpacket   (cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_endofpacket),             
		.awaddr                 (cal_arch_0_s0_axi4lite_axi4_lite_awaddr),                                 
		.awprot                 (cal_arch_0_s0_axi4lite_axi4_lite_awprot),                                 
		.awvalid                (cal_arch_0_s0_axi4lite_axi4_lite_awvalid),                                
		.awready                (cal_arch_0_s0_axi4lite_axi4_lite_awready),                                
		.wdata                  (cal_arch_0_s0_axi4lite_axi4_lite_wdata),                                  
		.wstrb                  (cal_arch_0_s0_axi4lite_axi4_lite_wstrb),                                  
		.wvalid                 (cal_arch_0_s0_axi4lite_axi4_lite_wvalid),                                 
		.wready                 (cal_arch_0_s0_axi4lite_axi4_lite_wready),                                 
		.bresp                  (cal_arch_0_s0_axi4lite_axi4_lite_bresp),                                  
		.bvalid                 (cal_arch_0_s0_axi4lite_axi4_lite_bvalid),                                 
		.bready                 (cal_arch_0_s0_axi4lite_axi4_lite_bready),                                 
		.araddr                 (cal_arch_0_s0_axi4lite_axi4_lite_araddr),                                 
		.arprot                 (cal_arch_0_s0_axi4lite_axi4_lite_arprot),                                 
		.arvalid                (cal_arch_0_s0_axi4lite_axi4_lite_arvalid),                                
		.arready                (cal_arch_0_s0_axi4lite_axi4_lite_arready),                                
		.rdata                  (cal_arch_0_s0_axi4lite_axi4_lite_rdata),                                  
		.rresp                  (cal_arch_0_s0_axi4lite_axi4_lite_rresp),                                  
		.rvalid                 (cal_arch_0_s0_axi4lite_axi4_lite_rvalid),                                 
		.rready                 (cal_arch_0_s0_axi4lite_axi4_lite_rready),                                 
		.awuser_addrchk         (),                                                                        
		.awuser_sai             (),                                                                        
		.wuser_datachk          (),                                                                        
		.wuser_poison           (),                                                                        
		.aruser_addrchk         (),                                                                        
		.aruser_sai             (),                                                                        
		.ruser_datachk          (4'b0000),                                                                 
		.ruser_poison           (1'b0),                                                                    
		.bid                    (1'b0),                                                                    
		.buser                  (1'b0),                                                                    
		.rid                    (1'b0),                                                                    
		.ruser                  (1'b0),                                                                    
		.rlast                  (1'b0),                                                                    
		.arid                   (),                                                                        
		.arlen                  (),                                                                        
		.arsize                 (),                                                                        
		.arburst                (),                                                                        
		.arlock                 (),                                                                        
		.arcache                (),                                                                        
		.aruser                 (),                                                                        
		.wid                    (),                                                                        
		.wuser                  (),                                                                        
		.wlast                  (),                                                                        
		.awid                   (),                                                                        
		.awlen                  (),                                                                        
		.awsize                 (),                                                                        
		.awburst                (),                                                                        
		.awlock                 (),                                                                        
		.awcache                (),                                                                        
		.awuser                 (),                                                                        
		.awqos                  (),                                                                        
		.awregion               (),                                                                        
		.arqos                  (),                                                                        
		.arregion               (),                                                                        
		.arsnoop                (),                                                                        
		.ardomain               (),                                                                        
		.arbar                  (),                                                                        
		.awsnoop                (),                                                                        
		.awdomain               (),                                                                        
		.awbar                  (),                                                                        
		.awunique               ()                                                                         
	);

	ed_synth_dut_altera_merlin_router_1921_nxsnrbi router (
		.sink_ready         (arbit_m_axi4_agent_write_cp_ready),                
		.sink_valid         (arbit_m_axi4_agent_write_cp_valid),                
		.sink_data          (arbit_m_axi4_agent_write_cp_data),                 
		.sink_startofpacket (arbit_m_axi4_agent_write_cp_startofpacket),        
		.sink_endofpacket   (arbit_m_axi4_agent_write_cp_endofpacket),          
		.clk                (clk_bridge_out_clk_2_clk),                         
		.reset              (arbit_m_axi4_aresetn_reset_bridge_in_reset_reset), 
		.src_ready          (router_src_ready),                                 
		.src_valid          (router_src_valid),                                 
		.src_data           (router_src_data),                                  
		.src_channel        (router_src_channel),                               
		.src_startofpacket  (router_src_startofpacket),                         
		.src_endofpacket    (router_src_endofpacket)                            
	);

	ed_synth_dut_altera_merlin_router_1921_vbaxzva router_001 (
		.sink_ready         (arbit_m_axi4_agent_read_cp_ready),                 
		.sink_valid         (arbit_m_axi4_agent_read_cp_valid),                 
		.sink_data          (arbit_m_axi4_agent_read_cp_data),                  
		.sink_startofpacket (arbit_m_axi4_agent_read_cp_startofpacket),         
		.sink_endofpacket   (arbit_m_axi4_agent_read_cp_endofpacket),           
		.clk                (clk_bridge_out_clk_2_clk),                         
		.reset              (arbit_m_axi4_aresetn_reset_bridge_in_reset_reset), 
		.src_ready          (router_001_src_ready),                             
		.src_valid          (router_001_src_valid),                             
		.src_data           (router_001_src_data),                              
		.src_channel        (router_001_src_channel),                           
		.src_startofpacket  (router_001_src_startofpacket),                     
		.src_endofpacket    (router_001_src_endofpacket)                        
	);

	ed_synth_dut_altera_merlin_router_1921_irryw4q router_002 (
		.sink_ready         (cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_ready),         
		.sink_valid         (cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_valid),         
		.sink_data          (cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_data),          
		.sink_startofpacket (cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_startofpacket), 
		.sink_endofpacket   (cal_arch_0_s0_axi4lite_axi4_lite_agent_write_rp_endofpacket),   
		.clk                (clk_bridge_out_clk_1_clk),                                      
		.reset              (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),      
		.src_ready          (router_002_src_ready),                                          
		.src_valid          (router_002_src_valid),                                          
		.src_data           (router_002_src_data),                                           
		.src_channel        (router_002_src_channel),                                        
		.src_startofpacket  (router_002_src_startofpacket),                                  
		.src_endofpacket    (router_002_src_endofpacket)                                     
	);

	ed_synth_dut_altera_merlin_router_1921_4ytgf2y router_003 (
		.sink_ready         (cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_ready),         
		.sink_valid         (cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_valid),         
		.sink_data          (cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_data),          
		.sink_startofpacket (cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_startofpacket), 
		.sink_endofpacket   (cal_arch_0_s0_axi4lite_axi4_lite_agent_read_rp_endofpacket),   
		.clk                (clk_bridge_out_clk_1_clk),                                     
		.reset              (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),     
		.src_ready          (router_003_src_ready),                                         
		.src_valid          (router_003_src_valid),                                         
		.src_data           (router_003_src_data),                                          
		.src_channel        (router_003_src_channel),                                       
		.src_startofpacket  (router_003_src_startofpacket),                                 
		.src_endofpacket    (router_003_src_endofpacket)                                    
	);

	ed_synth_dut_altera_merlin_burst_adapter_1931_hbsisni #(
		.PKT_ADDR_H                (67),
		.PKT_ADDR_L                (36),
		.PKT_BEGIN_BURST           (146),
		.PKT_BYTE_CNT_H            (87),
		.PKT_BYTE_CNT_L            (74),
		.PKT_BYTEEN_H              (35),
		.PKT_BYTEEN_L              (32),
		.PKT_BURST_SIZE_H          (100),
		.PKT_BURST_SIZE_L          (98),
		.PKT_BURST_TYPE_H          (102),
		.PKT_BURST_TYPE_L          (101),
		.PKT_BURSTWRAP_H           (97),
		.PKT_BURSTWRAP_L           (88),
		.PKT_SAI_H                 (89),
		.PKT_SAI_L                 (89),
		.ROLE_BASED_USER           (0),
		.PKT_TRANS_COMPRESSED_READ (68),
		.PKT_TRANS_WRITE           (70),
		.PKT_TRANS_READ            (71),
		.OUT_NARROW_SIZE           (0),
		.IN_NARROW_SIZE            (1),
		.OUT_FIXED                 (0),
		.OUT_COMPLETE_WRAP         (0),
		.PKT_EOP_OOO               (89),
		.PKT_SOP_OOO               (90),
		.ENABLE_OOO                (0),
		.ST_DATA_W                 (188),
		.ST_CHANNEL_W              (2),
		.OUT_BYTE_CNT_H            (76),
		.OUT_BURSTWRAP_H           (97),
		.COMPRESSED_READ_SUPPORT   (1),
		.BYTEENABLE_SYNTHESIS      (1),
		.PIPE_INPUTS               (0),
		.NO_WRAP_SUPPORT           (0),
		.INCOMPLETE_WRAP_SUPPORT   (0),
		.BURSTWRAP_CONST_MASK      (0),
		.BURSTWRAP_CONST_VALUE     (0),
		.ADAPTER_VERSION           ("13.1"),
		.SYNC_RESET                (0)
	) cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter (
		.clk                   (clk_bridge_out_clk_1_clk),                                                
		.reset                 (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),                
		.sink0_valid           (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_valid),         
		.sink0_data            (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_data),          
		.sink0_channel         (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_channel),       
		.sink0_startofpacket   (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_startofpacket), 
		.sink0_endofpacket     (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_endofpacket),   
		.sink0_ready           (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_ready),         
		.source0_valid         (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_valid),         
		.source0_data          (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_data),          
		.source0_channel       (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_channel),       
		.source0_startofpacket (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_startofpacket), 
		.source0_endofpacket   (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_endofpacket),   
		.source0_ready         (cal_arch_0_s0_axi4lite_axi4_lite_wr_burst_adapter_source0_ready)          
	);

	ed_synth_dut_altera_merlin_burst_adapter_1931_hbsisni #(
		.PKT_ADDR_H                (67),
		.PKT_ADDR_L                (36),
		.PKT_BEGIN_BURST           (146),
		.PKT_BYTE_CNT_H            (87),
		.PKT_BYTE_CNT_L            (74),
		.PKT_BYTEEN_H              (35),
		.PKT_BYTEEN_L              (32),
		.PKT_BURST_SIZE_H          (100),
		.PKT_BURST_SIZE_L          (98),
		.PKT_BURST_TYPE_H          (102),
		.PKT_BURST_TYPE_L          (101),
		.PKT_BURSTWRAP_H           (97),
		.PKT_BURSTWRAP_L           (88),
		.PKT_SAI_H                 (89),
		.PKT_SAI_L                 (89),
		.ROLE_BASED_USER           (0),
		.PKT_TRANS_COMPRESSED_READ (68),
		.PKT_TRANS_WRITE           (70),
		.PKT_TRANS_READ            (71),
		.OUT_NARROW_SIZE           (0),
		.IN_NARROW_SIZE            (1),
		.OUT_FIXED                 (0),
		.OUT_COMPLETE_WRAP         (0),
		.PKT_EOP_OOO               (89),
		.PKT_SOP_OOO               (90),
		.ENABLE_OOO                (0),
		.ST_DATA_W                 (188),
		.ST_CHANNEL_W              (2),
		.OUT_BYTE_CNT_H            (76),
		.OUT_BURSTWRAP_H           (97),
		.COMPRESSED_READ_SUPPORT   (1),
		.BYTEENABLE_SYNTHESIS      (1),
		.PIPE_INPUTS               (0),
		.NO_WRAP_SUPPORT           (0),
		.INCOMPLETE_WRAP_SUPPORT   (0),
		.BURSTWRAP_CONST_MASK      (0),
		.BURSTWRAP_CONST_VALUE     (0),
		.ADAPTER_VERSION           ("13.1"),
		.SYNC_RESET                (0)
	) cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter (
		.clk                   (clk_bridge_out_clk_1_clk),                                                
		.reset                 (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),                
		.sink0_valid           (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_valid),         
		.sink0_data            (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_data),          
		.sink0_channel         (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_channel),       
		.sink0_startofpacket   (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_startofpacket), 
		.sink0_endofpacket     (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_endofpacket),   
		.sink0_ready           (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_ready),         
		.source0_valid         (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_valid),         
		.source0_data          (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_data),          
		.source0_channel       (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_channel),       
		.source0_startofpacket (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_startofpacket), 
		.source0_endofpacket   (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_endofpacket),   
		.source0_ready         (cal_arch_0_s0_axi4lite_axi4_lite_rd_burst_adapter_source0_ready)          
	);

	ed_synth_dut_altera_merlin_demultiplexer_1921_c2mlp5i cmd_demux (
		.clk                (clk_bridge_out_clk_2_clk),                         
		.reset              (arbit_m_axi4_aresetn_reset_bridge_in_reset_reset), 
		.sink_ready         (router_src_ready),                                 
		.sink_channel       (router_src_channel),                               
		.sink_data          (router_src_data),                                  
		.sink_startofpacket (router_src_startofpacket),                         
		.sink_endofpacket   (router_src_endofpacket),                           
		.sink_valid         (router_src_valid),                                 
		.src0_ready         (cmd_demux_src0_ready),                             
		.src0_valid         (cmd_demux_src0_valid),                             
		.src0_data          (cmd_demux_src0_data),                              
		.src0_channel       (cmd_demux_src0_channel),                           
		.src0_startofpacket (cmd_demux_src0_startofpacket),                     
		.src0_endofpacket   (cmd_demux_src0_endofpacket)                        
	);

	ed_synth_dut_altera_merlin_demultiplexer_1921_c2mlp5i cmd_demux_001 (
		.clk                (clk_bridge_out_clk_2_clk),                         
		.reset              (arbit_m_axi4_aresetn_reset_bridge_in_reset_reset), 
		.sink_ready         (router_001_src_ready),                             
		.sink_channel       (router_001_src_channel),                           
		.sink_data          (router_001_src_data),                              
		.sink_startofpacket (router_001_src_startofpacket),                     
		.sink_endofpacket   (router_001_src_endofpacket),                       
		.sink_valid         (router_001_src_valid),                             
		.src0_ready         (cmd_demux_001_src0_ready),                         
		.src0_valid         (cmd_demux_001_src0_valid),                         
		.src0_data          (cmd_demux_001_src0_data),                          
		.src0_channel       (cmd_demux_001_src0_channel),                       
		.src0_startofpacket (cmd_demux_001_src0_startofpacket),                 
		.src0_endofpacket   (cmd_demux_001_src0_endofpacket)                    
	);

	ed_synth_dut_altera_merlin_multiplexer_1922_jy53pgi cmd_mux (
		.clk                 (clk_bridge_out_clk_1_clk),                                 
		.reset               (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset), 
		.src_ready           (cmd_mux_src_ready),                                        
		.src_valid           (cmd_mux_src_valid),                                        
		.src_data            (cmd_mux_src_data),                                         
		.src_channel         (cmd_mux_src_channel),                                      
		.src_startofpacket   (cmd_mux_src_startofpacket),                                
		.src_endofpacket     (cmd_mux_src_endofpacket),                                  
		.sink0_ready         (crosser_out_ready),                                        
		.sink0_valid         (crosser_out_valid),                                        
		.sink0_channel       (crosser_out_channel),                                      
		.sink0_data          (crosser_out_data),                                         
		.sink0_startofpacket (crosser_out_startofpacket),                                
		.sink0_endofpacket   (crosser_out_endofpacket)                                   
	);

	ed_synth_dut_altera_merlin_multiplexer_1922_jy53pgi cmd_mux_001 (
		.clk                 (clk_bridge_out_clk_1_clk),                                 
		.reset               (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset), 
		.src_ready           (cmd_mux_001_src_ready),                                    
		.src_valid           (cmd_mux_001_src_valid),                                    
		.src_data            (cmd_mux_001_src_data),                                     
		.src_channel         (cmd_mux_001_src_channel),                                  
		.src_startofpacket   (cmd_mux_001_src_startofpacket),                            
		.src_endofpacket     (cmd_mux_001_src_endofpacket),                              
		.sink0_ready         (crosser_001_out_ready),                                    
		.sink0_valid         (crosser_001_out_valid),                                    
		.sink0_channel       (crosser_001_out_channel),                                  
		.sink0_data          (crosser_001_out_data),                                     
		.sink0_startofpacket (crosser_001_out_startofpacket),                            
		.sink0_endofpacket   (crosser_001_out_endofpacket)                               
	);

	ed_synth_dut_altera_merlin_demultiplexer_1921_c2mlp5i rsp_demux (
		.clk                (clk_bridge_out_clk_1_clk),                                                
		.reset              (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),                
		.sink_ready         (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_ready),         
		.sink_channel       (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_channel),       
		.sink_data          (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_data),          
		.sink_startofpacket (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_startofpacket), 
		.sink_endofpacket   (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_endofpacket),   
		.sink_valid         (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_valid),         
		.src0_ready         (rsp_demux_src0_ready),                                                    
		.src0_valid         (rsp_demux_src0_valid),                                                    
		.src0_data          (rsp_demux_src0_data),                                                     
		.src0_channel       (rsp_demux_src0_channel),                                                  
		.src0_startofpacket (rsp_demux_src0_startofpacket),                                            
		.src0_endofpacket   (rsp_demux_src0_endofpacket)                                               
	);

	ed_synth_dut_altera_merlin_demultiplexer_1921_c2mlp5i rsp_demux_001 (
		.clk                (clk_bridge_out_clk_1_clk),                                                
		.reset              (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),                
		.sink_ready         (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_ready),         
		.sink_channel       (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_channel),       
		.sink_data          (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_data),          
		.sink_startofpacket (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_startofpacket), 
		.sink_endofpacket   (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_endofpacket),   
		.sink_valid         (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_valid),         
		.src0_ready         (rsp_demux_001_src0_ready),                                                
		.src0_valid         (rsp_demux_001_src0_valid),                                                
		.src0_data          (rsp_demux_001_src0_data),                                                 
		.src0_channel       (rsp_demux_001_src0_channel),                                              
		.src0_startofpacket (rsp_demux_001_src0_startofpacket),                                        
		.src0_endofpacket   (rsp_demux_001_src0_endofpacket)                                           
	);

	ed_synth_dut_altera_merlin_multiplexer_1922_252f2xa rsp_mux (
		.clk                 (clk_bridge_out_clk_2_clk),                         
		.reset               (arbit_m_axi4_aresetn_reset_bridge_in_reset_reset), 
		.src_ready           (rsp_mux_src_ready),                                
		.src_valid           (rsp_mux_src_valid),                                
		.src_data            (rsp_mux_src_data),                                 
		.src_channel         (rsp_mux_src_channel),                              
		.src_startofpacket   (rsp_mux_src_startofpacket),                        
		.src_endofpacket     (rsp_mux_src_endofpacket),                          
		.sink0_ready         (crosser_002_out_ready),                            
		.sink0_valid         (crosser_002_out_valid),                            
		.sink0_channel       (crosser_002_out_channel),                          
		.sink0_data          (crosser_002_out_data),                             
		.sink0_startofpacket (crosser_002_out_startofpacket),                    
		.sink0_endofpacket   (crosser_002_out_endofpacket)                       
	);

	ed_synth_dut_altera_merlin_multiplexer_1922_252f2xa rsp_mux_001 (
		.clk                 (clk_bridge_out_clk_2_clk),                         
		.reset               (arbit_m_axi4_aresetn_reset_bridge_in_reset_reset), 
		.src_ready           (rsp_mux_001_src_ready),                            
		.src_valid           (rsp_mux_001_src_valid),                            
		.src_data            (rsp_mux_001_src_data),                             
		.src_channel         (rsp_mux_001_src_channel),                          
		.src_startofpacket   (rsp_mux_001_src_startofpacket),                    
		.src_endofpacket     (rsp_mux_001_src_endofpacket),                      
		.sink0_ready         (crosser_003_out_ready),                            
		.sink0_valid         (crosser_003_out_valid),                            
		.sink0_channel       (crosser_003_out_channel),                          
		.sink0_data          (crosser_003_out_data),                             
		.sink0_startofpacket (crosser_003_out_startofpacket),                    
		.sink0_endofpacket   (crosser_003_out_endofpacket)                       
	);

	ed_synth_dut_altera_merlin_width_adapter_1933_2qdsena #(
		.IN_PKT_ADDR_H                 (67),
		.IN_PKT_ADDR_L                 (36),
		.IN_PKT_DATA_H                 (31),
		.IN_PKT_DATA_L                 (0),
		.IN_PKT_BYTEEN_H               (35),
		.IN_PKT_BYTEEN_L               (32),
		.IN_PKT_BYTE_CNT_H             (87),
		.IN_PKT_BYTE_CNT_L             (74),
		.IN_PKT_TRANS_COMPRESSED_READ  (68),
		.IN_PKT_TRANS_WRITE            (70),
		.IN_PKT_BURSTWRAP_H            (97),
		.IN_PKT_BURSTWRAP_L            (88),
		.IN_PKT_BURST_SIZE_H           (100),
		.IN_PKT_BURST_SIZE_L           (98),
		.IN_PKT_RESPONSE_STATUS_H      (168),
		.IN_PKT_RESPONSE_STATUS_L      (167),
		.IN_PKT_TRANS_EXCLUSIVE        (73),
		.IN_PKT_BURST_TYPE_H           (102),
		.IN_PKT_BURST_TYPE_L           (101),
		.IN_PKT_ORI_BURST_SIZE_L       (169),
		.IN_PKT_ORI_BURST_SIZE_H       (171),
		.IN_PKT_POISON_H               (76),
		.IN_PKT_POISON_L               (76),
		.IN_PKT_DATACHK_H              (80),
		.IN_PKT_DATACHK_L              (77),
		.IN_PKT_ADDRCHK_H              (84),
		.IN_PKT_ADDRCHK_L              (81),
		.IN_PKT_SAI_H                  (88),
		.IN_PKT_SAI_L                  (85),
		.IN_ST_DATA_W                  (188),
		.OUT_PKT_ADDR_H                (319),
		.OUT_PKT_ADDR_L                (288),
		.OUT_PKT_DATA_H                (255),
		.OUT_PKT_DATA_L                (0),
		.OUT_PKT_BYTEEN_H              (287),
		.OUT_PKT_BYTEEN_L              (256),
		.OUT_PKT_BYTE_CNT_H            (339),
		.OUT_PKT_BYTE_CNT_L            (326),
		.OUT_PKT_TRANS_COMPRESSED_READ (320),
		.OUT_PKT_BURST_SIZE_H          (352),
		.OUT_PKT_BURST_SIZE_L          (350),
		.OUT_PKT_RESPONSE_STATUS_H     (420),
		.OUT_PKT_RESPONSE_STATUS_L     (419),
		.OUT_PKT_TRANS_EXCLUSIVE       (325),
		.OUT_PKT_BURST_TYPE_H          (354),
		.OUT_PKT_BURST_TYPE_L          (353),
		.OUT_PKT_ORI_BURST_SIZE_L      (421),
		.OUT_PKT_ORI_BURST_SIZE_H      (423),
		.OUT_PKT_POISON_H              (74),
		.OUT_PKT_POISON_L              (74),
		.OUT_PKT_DATACHK_H             (78),
		.OUT_PKT_DATACHK_L             (75),
		.OUT_PKT_ADDRCHK_H             (82),
		.OUT_PKT_ADDRCHK_L             (79),
		.OUT_PKT_SAI_H                 (86),
		.OUT_PKT_SAI_L                 (83),
		.OUT_PKT_EOP_OOO               (437),
		.OUT_PKT_SOP_OOO               (438),
		.ENABLE_OOO                    (0),
		.OUT_ST_DATA_W                 (440),
		.ST_CHANNEL_W                  (2),
		.OPTIMIZE_FOR_RSP              (0),
		.RESPONSE_PATH                 (1),
		.CONSTANT_BURST_SIZE           (0),
		.PACKING                       (1),
		.ENABLE_ADDRESS_ALIGNMENT      (1),
		.ROLE_BASED_USER               (0),
		.SYNC_RESET                    (0)
	) cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter (
		.clk                  (clk_bridge_out_clk_1_clk),                                                
		.reset                (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),                
		.in_valid             (router_002_src_valid),                                                    
		.in_channel           (router_002_src_channel),                                                  
		.in_startofpacket     (router_002_src_startofpacket),                                            
		.in_endofpacket       (router_002_src_endofpacket),                                              
		.in_ready             (router_002_src_ready),                                                    
		.in_data              (router_002_src_data),                                                     
		.out_endofpacket      (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_endofpacket),   
		.out_data             (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_data),          
		.out_channel          (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_channel),       
		.out_valid            (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_valid),         
		.out_ready            (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_ready),         
		.out_startofpacket    (cal_arch_0_s0_axi4lite_axi4_lite_wr_rsp_width_adapter_src_startofpacket), 
		.in_command_size_data (3'b000)                                                                   
	);

	ed_synth_dut_altera_merlin_width_adapter_1933_2qdsena #(
		.IN_PKT_ADDR_H                 (67),
		.IN_PKT_ADDR_L                 (36),
		.IN_PKT_DATA_H                 (31),
		.IN_PKT_DATA_L                 (0),
		.IN_PKT_BYTEEN_H               (35),
		.IN_PKT_BYTEEN_L               (32),
		.IN_PKT_BYTE_CNT_H             (87),
		.IN_PKT_BYTE_CNT_L             (74),
		.IN_PKT_TRANS_COMPRESSED_READ  (68),
		.IN_PKT_TRANS_WRITE            (70),
		.IN_PKT_BURSTWRAP_H            (97),
		.IN_PKT_BURSTWRAP_L            (88),
		.IN_PKT_BURST_SIZE_H           (100),
		.IN_PKT_BURST_SIZE_L           (98),
		.IN_PKT_RESPONSE_STATUS_H      (168),
		.IN_PKT_RESPONSE_STATUS_L      (167),
		.IN_PKT_TRANS_EXCLUSIVE        (73),
		.IN_PKT_BURST_TYPE_H           (102),
		.IN_PKT_BURST_TYPE_L           (101),
		.IN_PKT_ORI_BURST_SIZE_L       (169),
		.IN_PKT_ORI_BURST_SIZE_H       (171),
		.IN_PKT_POISON_H               (76),
		.IN_PKT_POISON_L               (76),
		.IN_PKT_DATACHK_H              (80),
		.IN_PKT_DATACHK_L              (77),
		.IN_PKT_ADDRCHK_H              (84),
		.IN_PKT_ADDRCHK_L              (81),
		.IN_PKT_SAI_H                  (88),
		.IN_PKT_SAI_L                  (85),
		.IN_ST_DATA_W                  (188),
		.OUT_PKT_ADDR_H                (319),
		.OUT_PKT_ADDR_L                (288),
		.OUT_PKT_DATA_H                (255),
		.OUT_PKT_DATA_L                (0),
		.OUT_PKT_BYTEEN_H              (287),
		.OUT_PKT_BYTEEN_L              (256),
		.OUT_PKT_BYTE_CNT_H            (339),
		.OUT_PKT_BYTE_CNT_L            (326),
		.OUT_PKT_TRANS_COMPRESSED_READ (320),
		.OUT_PKT_BURST_SIZE_H          (352),
		.OUT_PKT_BURST_SIZE_L          (350),
		.OUT_PKT_RESPONSE_STATUS_H     (420),
		.OUT_PKT_RESPONSE_STATUS_L     (419),
		.OUT_PKT_TRANS_EXCLUSIVE       (325),
		.OUT_PKT_BURST_TYPE_H          (354),
		.OUT_PKT_BURST_TYPE_L          (353),
		.OUT_PKT_ORI_BURST_SIZE_L      (421),
		.OUT_PKT_ORI_BURST_SIZE_H      (423),
		.OUT_PKT_POISON_H              (74),
		.OUT_PKT_POISON_L              (74),
		.OUT_PKT_DATACHK_H             (78),
		.OUT_PKT_DATACHK_L             (75),
		.OUT_PKT_ADDRCHK_H             (82),
		.OUT_PKT_ADDRCHK_L             (79),
		.OUT_PKT_SAI_H                 (86),
		.OUT_PKT_SAI_L                 (83),
		.OUT_PKT_EOP_OOO               (437),
		.OUT_PKT_SOP_OOO               (438),
		.ENABLE_OOO                    (0),
		.OUT_ST_DATA_W                 (440),
		.ST_CHANNEL_W                  (2),
		.OPTIMIZE_FOR_RSP              (0),
		.RESPONSE_PATH                 (1),
		.CONSTANT_BURST_SIZE           (0),
		.PACKING                       (1),
		.ENABLE_ADDRESS_ALIGNMENT      (1),
		.ROLE_BASED_USER               (0),
		.SYNC_RESET                    (0)
	) cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter (
		.clk                  (clk_bridge_out_clk_1_clk),                                                
		.reset                (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),                
		.in_valid             (router_003_src_valid),                                                    
		.in_channel           (router_003_src_channel),                                                  
		.in_startofpacket     (router_003_src_startofpacket),                                            
		.in_endofpacket       (router_003_src_endofpacket),                                              
		.in_ready             (router_003_src_ready),                                                    
		.in_data              (router_003_src_data),                                                     
		.out_endofpacket      (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_endofpacket),   
		.out_data             (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_data),          
		.out_channel          (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_channel),       
		.out_valid            (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_valid),         
		.out_ready            (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_ready),         
		.out_startofpacket    (cal_arch_0_s0_axi4lite_axi4_lite_rd_rsp_width_adapter_src_startofpacket), 
		.in_command_size_data (3'b000)                                                                   
	);

	ed_synth_dut_altera_merlin_width_adapter_1933_sqfzewq #(
		.IN_PKT_ADDR_H                 (319),
		.IN_PKT_ADDR_L                 (288),
		.IN_PKT_DATA_H                 (255),
		.IN_PKT_DATA_L                 (0),
		.IN_PKT_BYTEEN_H               (287),
		.IN_PKT_BYTEEN_L               (256),
		.IN_PKT_BYTE_CNT_H             (339),
		.IN_PKT_BYTE_CNT_L             (326),
		.IN_PKT_TRANS_COMPRESSED_READ  (320),
		.IN_PKT_TRANS_WRITE            (322),
		.IN_PKT_BURSTWRAP_H            (349),
		.IN_PKT_BURSTWRAP_L            (340),
		.IN_PKT_BURST_SIZE_H           (352),
		.IN_PKT_BURST_SIZE_L           (350),
		.IN_PKT_RESPONSE_STATUS_H      (420),
		.IN_PKT_RESPONSE_STATUS_L      (419),
		.IN_PKT_TRANS_EXCLUSIVE        (325),
		.IN_PKT_BURST_TYPE_H           (354),
		.IN_PKT_BURST_TYPE_L           (353),
		.IN_PKT_ORI_BURST_SIZE_L       (421),
		.IN_PKT_ORI_BURST_SIZE_H       (423),
		.IN_PKT_POISON_H               (76),
		.IN_PKT_POISON_L               (76),
		.IN_PKT_DATACHK_H              (80),
		.IN_PKT_DATACHK_L              (77),
		.IN_PKT_ADDRCHK_H              (84),
		.IN_PKT_ADDRCHK_L              (81),
		.IN_PKT_SAI_H                  (88),
		.IN_PKT_SAI_L                  (85),
		.IN_ST_DATA_W                  (440),
		.OUT_PKT_ADDR_H                (67),
		.OUT_PKT_ADDR_L                (36),
		.OUT_PKT_DATA_H                (31),
		.OUT_PKT_DATA_L                (0),
		.OUT_PKT_BYTEEN_H              (35),
		.OUT_PKT_BYTEEN_L              (32),
		.OUT_PKT_BYTE_CNT_H            (87),
		.OUT_PKT_BYTE_CNT_L            (74),
		.OUT_PKT_TRANS_COMPRESSED_READ (68),
		.OUT_PKT_BURST_SIZE_H          (100),
		.OUT_PKT_BURST_SIZE_L          (98),
		.OUT_PKT_RESPONSE_STATUS_H     (168),
		.OUT_PKT_RESPONSE_STATUS_L     (167),
		.OUT_PKT_TRANS_EXCLUSIVE       (73),
		.OUT_PKT_BURST_TYPE_H          (102),
		.OUT_PKT_BURST_TYPE_L          (101),
		.OUT_PKT_ORI_BURST_SIZE_L      (169),
		.OUT_PKT_ORI_BURST_SIZE_H      (171),
		.OUT_PKT_POISON_H              (74),
		.OUT_PKT_POISON_L              (74),
		.OUT_PKT_DATACHK_H             (78),
		.OUT_PKT_DATACHK_L             (75),
		.OUT_PKT_ADDRCHK_H             (82),
		.OUT_PKT_ADDRCHK_L             (79),
		.OUT_PKT_SAI_H                 (86),
		.OUT_PKT_SAI_L                 (83),
		.OUT_PKT_EOP_OOO               (185),
		.OUT_PKT_SOP_OOO               (186),
		.ENABLE_OOO                    (0),
		.OUT_ST_DATA_W                 (188),
		.ST_CHANNEL_W                  (2),
		.OPTIMIZE_FOR_RSP              (0),
		.RESPONSE_PATH                 (0),
		.CONSTANT_BURST_SIZE           (0),
		.PACKING                       (0),
		.ENABLE_ADDRESS_ALIGNMENT      (1),
		.ROLE_BASED_USER               (0),
		.SYNC_RESET                    (0)
	) cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter (
		.clk                  (clk_bridge_out_clk_1_clk),                                                
		.reset                (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),                
		.in_valid             (cmd_mux_src_valid),                                                       
		.in_channel           (cmd_mux_src_channel),                                                     
		.in_startofpacket     (cmd_mux_src_startofpacket),                                               
		.in_endofpacket       (cmd_mux_src_endofpacket),                                                 
		.in_ready             (cmd_mux_src_ready),                                                       
		.in_data              (cmd_mux_src_data),                                                        
		.out_endofpacket      (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_endofpacket),   
		.out_data             (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_data),          
		.out_channel          (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_channel),       
		.out_valid            (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_valid),         
		.out_ready            (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_ready),         
		.out_startofpacket    (cal_arch_0_s0_axi4lite_axi4_lite_wr_cmd_width_adapter_src_startofpacket), 
		.in_command_size_data (3'b000)                                                                   
	);

	ed_synth_dut_altera_merlin_width_adapter_1933_sqfzewq #(
		.IN_PKT_ADDR_H                 (319),
		.IN_PKT_ADDR_L                 (288),
		.IN_PKT_DATA_H                 (255),
		.IN_PKT_DATA_L                 (0),
		.IN_PKT_BYTEEN_H               (287),
		.IN_PKT_BYTEEN_L               (256),
		.IN_PKT_BYTE_CNT_H             (339),
		.IN_PKT_BYTE_CNT_L             (326),
		.IN_PKT_TRANS_COMPRESSED_READ  (320),
		.IN_PKT_TRANS_WRITE            (322),
		.IN_PKT_BURSTWRAP_H            (349),
		.IN_PKT_BURSTWRAP_L            (340),
		.IN_PKT_BURST_SIZE_H           (352),
		.IN_PKT_BURST_SIZE_L           (350),
		.IN_PKT_RESPONSE_STATUS_H      (420),
		.IN_PKT_RESPONSE_STATUS_L      (419),
		.IN_PKT_TRANS_EXCLUSIVE        (325),
		.IN_PKT_BURST_TYPE_H           (354),
		.IN_PKT_BURST_TYPE_L           (353),
		.IN_PKT_ORI_BURST_SIZE_L       (421),
		.IN_PKT_ORI_BURST_SIZE_H       (423),
		.IN_PKT_POISON_H               (76),
		.IN_PKT_POISON_L               (76),
		.IN_PKT_DATACHK_H              (80),
		.IN_PKT_DATACHK_L              (77),
		.IN_PKT_ADDRCHK_H              (84),
		.IN_PKT_ADDRCHK_L              (81),
		.IN_PKT_SAI_H                  (88),
		.IN_PKT_SAI_L                  (85),
		.IN_ST_DATA_W                  (440),
		.OUT_PKT_ADDR_H                (67),
		.OUT_PKT_ADDR_L                (36),
		.OUT_PKT_DATA_H                (31),
		.OUT_PKT_DATA_L                (0),
		.OUT_PKT_BYTEEN_H              (35),
		.OUT_PKT_BYTEEN_L              (32),
		.OUT_PKT_BYTE_CNT_H            (87),
		.OUT_PKT_BYTE_CNT_L            (74),
		.OUT_PKT_TRANS_COMPRESSED_READ (68),
		.OUT_PKT_BURST_SIZE_H          (100),
		.OUT_PKT_BURST_SIZE_L          (98),
		.OUT_PKT_RESPONSE_STATUS_H     (168),
		.OUT_PKT_RESPONSE_STATUS_L     (167),
		.OUT_PKT_TRANS_EXCLUSIVE       (73),
		.OUT_PKT_BURST_TYPE_H          (102),
		.OUT_PKT_BURST_TYPE_L          (101),
		.OUT_PKT_ORI_BURST_SIZE_L      (169),
		.OUT_PKT_ORI_BURST_SIZE_H      (171),
		.OUT_PKT_POISON_H              (74),
		.OUT_PKT_POISON_L              (74),
		.OUT_PKT_DATACHK_H             (78),
		.OUT_PKT_DATACHK_L             (75),
		.OUT_PKT_ADDRCHK_H             (82),
		.OUT_PKT_ADDRCHK_L             (79),
		.OUT_PKT_SAI_H                 (86),
		.OUT_PKT_SAI_L                 (83),
		.OUT_PKT_EOP_OOO               (185),
		.OUT_PKT_SOP_OOO               (186),
		.ENABLE_OOO                    (0),
		.OUT_ST_DATA_W                 (188),
		.ST_CHANNEL_W                  (2),
		.OPTIMIZE_FOR_RSP              (0),
		.RESPONSE_PATH                 (0),
		.CONSTANT_BURST_SIZE           (0),
		.PACKING                       (0),
		.ENABLE_ADDRESS_ALIGNMENT      (1),
		.ROLE_BASED_USER               (0),
		.SYNC_RESET                    (0)
	) cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter (
		.clk                  (clk_bridge_out_clk_1_clk),                                                
		.reset                (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset),                
		.in_valid             (cmd_mux_001_src_valid),                                                   
		.in_channel           (cmd_mux_001_src_channel),                                                 
		.in_startofpacket     (cmd_mux_001_src_startofpacket),                                           
		.in_endofpacket       (cmd_mux_001_src_endofpacket),                                             
		.in_ready             (cmd_mux_001_src_ready),                                                   
		.in_data              (cmd_mux_001_src_data),                                                    
		.out_endofpacket      (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_endofpacket),   
		.out_data             (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_data),          
		.out_channel          (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_channel),       
		.out_valid            (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_valid),         
		.out_ready            (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_ready),         
		.out_startofpacket    (cal_arch_0_s0_axi4lite_axi4_lite_rd_cmd_width_adapter_src_startofpacket), 
		.in_command_size_data (3'b000)                                                                   
	);

	ed_synth_dut_hs_clk_xer_1940_hvja46q #(
		.DATA_WIDTH          (440),
		.BITS_PER_SYMBOL     (440),
		.USE_PACKETS         (1),
		.USE_CHANNEL         (1),
		.CHANNEL_WIDTH       (2),
		.USE_ERROR           (0),
		.ERROR_WIDTH         (1),
		.VALID_SYNC_DEPTH    (2),
		.READY_SYNC_DEPTH    (2),
		.USE_OUTPUT_PIPELINE (0),
		.SYNC_RESET          (0)
	) crosser (
		.in_clk            (clk_bridge_out_clk_2_clk),                                 
		.in_reset          (arbit_m_axi4_aresetn_reset_bridge_in_reset_reset),         
		.out_clk           (clk_bridge_out_clk_1_clk),                                 
		.out_reset         (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset), 
		.in_ready          (cmd_demux_src0_ready),                                     
		.in_valid          (cmd_demux_src0_valid),                                     
		.in_startofpacket  (cmd_demux_src0_startofpacket),                             
		.in_endofpacket    (cmd_demux_src0_endofpacket),                               
		.in_channel        (cmd_demux_src0_channel),                                   
		.in_data           (cmd_demux_src0_data),                                      
		.out_ready         (crosser_out_ready),                                        
		.out_valid         (crosser_out_valid),                                        
		.out_startofpacket (crosser_out_startofpacket),                                
		.out_endofpacket   (crosser_out_endofpacket),                                  
		.out_channel       (crosser_out_channel),                                      
		.out_data          (crosser_out_data),                                         
		.in_empty          (1'b0),                                                     
		.in_error          (1'b0),                                                     
		.out_empty         (),                                                         
		.out_error         ()                                                          
	);

	ed_synth_dut_hs_clk_xer_1940_hvja46q #(
		.DATA_WIDTH          (440),
		.BITS_PER_SYMBOL     (440),
		.USE_PACKETS         (1),
		.USE_CHANNEL         (1),
		.CHANNEL_WIDTH       (2),
		.USE_ERROR           (0),
		.ERROR_WIDTH         (1),
		.VALID_SYNC_DEPTH    (2),
		.READY_SYNC_DEPTH    (2),
		.USE_OUTPUT_PIPELINE (0),
		.SYNC_RESET          (0)
	) crosser_001 (
		.in_clk            (clk_bridge_out_clk_2_clk),                                 
		.in_reset          (arbit_m_axi4_aresetn_reset_bridge_in_reset_reset),         
		.out_clk           (clk_bridge_out_clk_1_clk),                                 
		.out_reset         (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset), 
		.in_ready          (cmd_demux_001_src0_ready),                                 
		.in_valid          (cmd_demux_001_src0_valid),                                 
		.in_startofpacket  (cmd_demux_001_src0_startofpacket),                         
		.in_endofpacket    (cmd_demux_001_src0_endofpacket),                           
		.in_channel        (cmd_demux_001_src0_channel),                               
		.in_data           (cmd_demux_001_src0_data),                                  
		.out_ready         (crosser_001_out_ready),                                    
		.out_valid         (crosser_001_out_valid),                                    
		.out_startofpacket (crosser_001_out_startofpacket),                            
		.out_endofpacket   (crosser_001_out_endofpacket),                              
		.out_channel       (crosser_001_out_channel),                                  
		.out_data          (crosser_001_out_data),                                     
		.in_empty          (1'b0),                                                     
		.in_error          (1'b0),                                                     
		.out_empty         (),                                                         
		.out_error         ()                                                          
	);

	ed_synth_dut_hs_clk_xer_1940_hvja46q #(
		.DATA_WIDTH          (440),
		.BITS_PER_SYMBOL     (440),
		.USE_PACKETS         (1),
		.USE_CHANNEL         (1),
		.CHANNEL_WIDTH       (2),
		.USE_ERROR           (0),
		.ERROR_WIDTH         (1),
		.VALID_SYNC_DEPTH    (2),
		.READY_SYNC_DEPTH    (2),
		.USE_OUTPUT_PIPELINE (0),
		.SYNC_RESET          (0)
	) crosser_002 (
		.in_clk            (clk_bridge_out_clk_1_clk),                                 
		.in_reset          (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset), 
		.out_clk           (clk_bridge_out_clk_2_clk),                                 
		.out_reset         (arbit_m_axi4_aresetn_reset_bridge_in_reset_reset),         
		.in_ready          (rsp_demux_src0_ready),                                     
		.in_valid          (rsp_demux_src0_valid),                                     
		.in_startofpacket  (rsp_demux_src0_startofpacket),                             
		.in_endofpacket    (rsp_demux_src0_endofpacket),                               
		.in_channel        (rsp_demux_src0_channel),                                   
		.in_data           (rsp_demux_src0_data),                                      
		.out_ready         (crosser_002_out_ready),                                    
		.out_valid         (crosser_002_out_valid),                                    
		.out_startofpacket (crosser_002_out_startofpacket),                            
		.out_endofpacket   (crosser_002_out_endofpacket),                              
		.out_channel       (crosser_002_out_channel),                                  
		.out_data          (crosser_002_out_data),                                     
		.in_empty          (1'b0),                                                     
		.in_error          (1'b0),                                                     
		.out_empty         (),                                                         
		.out_error         ()                                                          
	);

	ed_synth_dut_hs_clk_xer_1940_hvja46q #(
		.DATA_WIDTH          (440),
		.BITS_PER_SYMBOL     (440),
		.USE_PACKETS         (1),
		.USE_CHANNEL         (1),
		.CHANNEL_WIDTH       (2),
		.USE_ERROR           (0),
		.ERROR_WIDTH         (1),
		.VALID_SYNC_DEPTH    (2),
		.READY_SYNC_DEPTH    (2),
		.USE_OUTPUT_PIPELINE (0),
		.SYNC_RESET          (0)
	) crosser_003 (
		.in_clk            (clk_bridge_out_clk_1_clk),                                 
		.in_reset          (cal_arch_0_s0_axi4lite_rst_n_reset_bridge_in_reset_reset), 
		.out_clk           (clk_bridge_out_clk_2_clk),                                 
		.out_reset         (arbit_m_axi4_aresetn_reset_bridge_in_reset_reset),         
		.in_ready          (rsp_demux_001_src0_ready),                                 
		.in_valid          (rsp_demux_001_src0_valid),                                 
		.in_startofpacket  (rsp_demux_001_src0_startofpacket),                         
		.in_endofpacket    (rsp_demux_001_src0_endofpacket),                           
		.in_channel        (rsp_demux_001_src0_channel),                               
		.in_data           (rsp_demux_001_src0_data),                                  
		.out_ready         (crosser_003_out_ready),                                    
		.out_valid         (crosser_003_out_valid),                                    
		.out_startofpacket (crosser_003_out_startofpacket),                            
		.out_endofpacket   (crosser_003_out_endofpacket),                              
		.out_channel       (crosser_003_out_channel),                                  
		.out_data          (crosser_003_out_data),                                     
		.in_empty          (1'b0),                                                     
		.in_error          (1'b0),                                                     
		.out_empty         (),                                                         
		.out_error         ()                                                          
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9d8WnHxpJ4xfygFxBpOojAz8JYpbIMEcqIYKpZikmMA5XFT3yb45CWSZr5P0KhNmpCHqkaHVwpktIOutOT9ShZqzinxnUOTOpLBcCIW3ZCiajWj7UXu/IwerIzkOxHP961EQ3KiYGWgmQvCQk78/SH/FjsYK6cEOXd8jzKPd2zUzwxZMQUvtHIheUlDR3h0aFkDK0vOLdvshHIfEOxMfZSEt4X5RihfnWhmxM3mEiiC7J8EWmJwme+j1IokSax9mZbzHeDC24Udw4sVzrUvAtemPkQl0MOD2PBv6mIjfz5gnt2UoccEjS5KtEbsuz1akia5nf7GoAO/Xg7B3+hUGKEx1FVZVUShTB6dymm7z2hqFcjfTtMoFaTAyZP5dwuXJCguZwvyvuPyfj0gFOEOxL6asu9PoGvjZFIE+eYF9js/U8kevm2gXhf+ihJzxa99UbA7zWp4DW/4BP0ldvj/GEAsHt2ccsR5w0Imx3w/GnxqkpMXKvq3VUgpviQvNf7jto38WGV/DhYGEW2M+vdaKmnrfVRJObJMtsK3pKjcE/OY+XTNJkNo6DYH0tqeFJDk5sKgXzbbWiOCh28uYmVo7JXoDxtVZ4rsDBML2WU4vg+HPsxzONG4ezuXK2opPmmuKBE/lF9k0Ss/1p9rI6AfA2QZaDkN6BxDgGnddFfGB+EXpVVZr2ZoFN1MmAR54a/TyE+eo9BfXOnmnO//rYSkyBG/6Kz8uKqL0syRhhLd5A9VkykU3Gc/LU/pXvYBrWP7Pc6LDSK/qWPC9S8JfpFbj1p"
`endif