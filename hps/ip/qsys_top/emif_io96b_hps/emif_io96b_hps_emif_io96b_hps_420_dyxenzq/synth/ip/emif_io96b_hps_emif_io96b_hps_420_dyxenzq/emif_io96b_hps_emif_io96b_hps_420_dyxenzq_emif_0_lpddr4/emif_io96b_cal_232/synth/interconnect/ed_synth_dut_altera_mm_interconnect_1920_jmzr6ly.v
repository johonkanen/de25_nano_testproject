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
module ed_synth_dut_altera_mm_interconnect_1920_jmzr6ly (
		input  wire [31:0] jamb_master_address,                                      
		output wire        jamb_master_waitrequest,                                  
		input  wire [3:0]  jamb_master_byteenable,                                   
		input  wire        jamb_master_read,                                         
		output wire [31:0] jamb_master_readdata,                                     
		output wire        jamb_master_readdatavalid,                                
		input  wire        jamb_master_write,                                        
		input  wire [31:0] jamb_master_writedata,                                    
		output wire [31:0] arbit_s0_axi4lite_awaddr,                                 
		output wire [2:0]  arbit_s0_axi4lite_awprot,                                 
		output wire        arbit_s0_axi4lite_awvalid,                                
		input  wire        arbit_s0_axi4lite_awready,                                
		output wire [31:0] arbit_s0_axi4lite_wdata,                                  
		output wire [3:0]  arbit_s0_axi4lite_wstrb,                                  
		output wire        arbit_s0_axi4lite_wvalid,                                 
		input  wire        arbit_s0_axi4lite_wready,                                 
		input  wire [1:0]  arbit_s0_axi4lite_bresp,                                  
		input  wire        arbit_s0_axi4lite_bvalid,                                 
		output wire        arbit_s0_axi4lite_bready,                                 
		output wire [31:0] arbit_s0_axi4lite_araddr,                                 
		output wire [2:0]  arbit_s0_axi4lite_arprot,                                 
		output wire        arbit_s0_axi4lite_arvalid,                                
		input  wire        arbit_s0_axi4lite_arready,                                
		input  wire [31:0] arbit_s0_axi4lite_rdata,                                  
		input  wire [1:0]  arbit_s0_axi4lite_rresp,                                  
		input  wire        arbit_s0_axi4lite_rvalid,                                 
		output wire        arbit_s0_axi4lite_rready,                                 
		input  wire        arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset,    
		input  wire        jamb_master_translator_reset_reset_bridge_in_reset_reset, 
		input  wire        clk_bridge_out_clk_clk,                                   
		input  wire        clk_bridge_out_clk_3_clk                                  
	);

	wire          jamb_master_translator_avalon_universal_master_0_waitrequest;   
	wire   [31:0] jamb_master_translator_avalon_universal_master_0_readdata;      
	wire          jamb_master_translator_avalon_universal_master_0_debugaccess;   
	wire   [31:0] jamb_master_translator_avalon_universal_master_0_address;       
	wire          jamb_master_translator_avalon_universal_master_0_read;          
	wire    [3:0] jamb_master_translator_avalon_universal_master_0_byteenable;    
	wire          jamb_master_translator_avalon_universal_master_0_readdatavalid; 
	wire          jamb_master_translator_avalon_universal_master_0_lock;          
	wire          jamb_master_translator_avalon_universal_master_0_write;         
	wire   [31:0] jamb_master_translator_avalon_universal_master_0_writedata;     
	wire    [2:0] jamb_master_translator_avalon_universal_master_0_burstcount;    
	wire          cmd_mux_src_valid;                                              
	wire  [123:0] cmd_mux_src_data;                                               
	wire          cmd_mux_src_ready;                                              
	wire    [1:0] cmd_mux_src_channel;                                            
	wire          cmd_mux_src_startofpacket;                                      
	wire          cmd_mux_src_endofpacket;                                        
	wire          cmd_mux_001_src_valid;                                          
	wire  [123:0] cmd_mux_001_src_data;                                           
	wire          cmd_mux_001_src_ready;                                          
	wire    [1:0] cmd_mux_001_src_channel;                                        
	wire          cmd_mux_001_src_startofpacket;                                  
	wire          cmd_mux_001_src_endofpacket;                                    
	wire          jamb_master_agent_cp_valid;                                     
	wire  [123:0] jamb_master_agent_cp_data;                                      
	wire          jamb_master_agent_cp_ready;                                     
	wire          jamb_master_agent_cp_startofpacket;                             
	wire          jamb_master_agent_cp_endofpacket;                               
	wire          arbit_s0_axi4lite_agent_write_rp_valid;                         
	wire  [123:0] arbit_s0_axi4lite_agent_write_rp_data;                          
	wire          arbit_s0_axi4lite_agent_write_rp_ready;                         
	wire          arbit_s0_axi4lite_agent_write_rp_startofpacket;                 
	wire          arbit_s0_axi4lite_agent_write_rp_endofpacket;                   
	wire          router_001_src_valid;                                           
	wire  [123:0] router_001_src_data;                                            
	wire          router_001_src_ready;                                           
	wire    [1:0] router_001_src_channel;                                         
	wire          router_001_src_startofpacket;                                   
	wire          router_001_src_endofpacket;                                     
	wire          arbit_s0_axi4lite_agent_read_rp_valid;                          
	wire  [123:0] arbit_s0_axi4lite_agent_read_rp_data;                           
	wire          arbit_s0_axi4lite_agent_read_rp_ready;                          
	wire          arbit_s0_axi4lite_agent_read_rp_startofpacket;                  
	wire          arbit_s0_axi4lite_agent_read_rp_endofpacket;                    
	wire          router_002_src_valid;                                           
	wire  [123:0] router_002_src_data;                                            
	wire          router_002_src_ready;                                           
	wire    [1:0] router_002_src_channel;                                         
	wire          router_002_src_startofpacket;                                   
	wire          router_002_src_endofpacket;                                     
	wire          router_src_valid;                                               
	wire  [123:0] router_src_data;                                                
	wire          router_src_ready;                                               
	wire    [1:0] router_src_channel;                                             
	wire          router_src_startofpacket;                                       
	wire          router_src_endofpacket;                                         
	wire  [123:0] jamb_master_limiter_cmd_src_data;                               
	wire          jamb_master_limiter_cmd_src_ready;                              
	wire    [1:0] jamb_master_limiter_cmd_src_channel;                            
	wire          jamb_master_limiter_cmd_src_startofpacket;                      
	wire          jamb_master_limiter_cmd_src_endofpacket;                        
	wire          rsp_mux_src_valid;                                              
	wire  [123:0] rsp_mux_src_data;                                               
	wire          rsp_mux_src_ready;                                              
	wire    [1:0] rsp_mux_src_channel;                                            
	wire          rsp_mux_src_startofpacket;                                      
	wire          rsp_mux_src_endofpacket;                                        
	wire          jamb_master_limiter_rsp_src_valid;                              
	wire  [123:0] jamb_master_limiter_rsp_src_data;                               
	wire          jamb_master_limiter_rsp_src_ready;                              
	wire    [1:0] jamb_master_limiter_rsp_src_channel;                            
	wire          jamb_master_limiter_rsp_src_startofpacket;                      
	wire          jamb_master_limiter_rsp_src_endofpacket;                        
	wire          cmd_demux_src0_valid;                                           
	wire  [123:0] cmd_demux_src0_data;                                            
	wire          cmd_demux_src0_ready;                                           
	wire    [1:0] cmd_demux_src0_channel;                                         
	wire          cmd_demux_src0_startofpacket;                                   
	wire          cmd_demux_src0_endofpacket;                                     
	wire          crosser_out_valid;                                              
	wire  [123:0] crosser_out_data;                                               
	wire          crosser_out_ready;                                              
	wire    [1:0] crosser_out_channel;                                            
	wire          crosser_out_startofpacket;                                      
	wire          crosser_out_endofpacket;                                        
	wire          cmd_demux_src1_valid;                                           
	wire  [123:0] cmd_demux_src1_data;                                            
	wire          cmd_demux_src1_ready;                                           
	wire    [1:0] cmd_demux_src1_channel;                                         
	wire          cmd_demux_src1_startofpacket;                                   
	wire          cmd_demux_src1_endofpacket;                                     
	wire          crosser_001_out_valid;                                          
	wire  [123:0] crosser_001_out_data;                                           
	wire          crosser_001_out_ready;                                          
	wire    [1:0] crosser_001_out_channel;                                        
	wire          crosser_001_out_startofpacket;                                  
	wire          crosser_001_out_endofpacket;                                    
	wire          rsp_demux_src0_valid;                                           
	wire  [123:0] rsp_demux_src0_data;                                            
	wire          rsp_demux_src0_ready;                                           
	wire    [1:0] rsp_demux_src0_channel;                                         
	wire          rsp_demux_src0_startofpacket;                                   
	wire          rsp_demux_src0_endofpacket;                                     
	wire          crosser_002_out_valid;                                          
	wire  [123:0] crosser_002_out_data;                                           
	wire          crosser_002_out_ready;                                          
	wire    [1:0] crosser_002_out_channel;                                        
	wire          crosser_002_out_startofpacket;                                  
	wire          crosser_002_out_endofpacket;                                    
	wire          rsp_demux_001_src0_valid;                                       
	wire  [123:0] rsp_demux_001_src0_data;                                        
	wire          rsp_demux_001_src0_ready;                                       
	wire    [1:0] rsp_demux_001_src0_channel;                                     
	wire          rsp_demux_001_src0_startofpacket;                               
	wire          rsp_demux_001_src0_endofpacket;                                 
	wire          crosser_003_out_valid;                                          
	wire  [123:0] crosser_003_out_data;                                           
	wire          crosser_003_out_ready;                                          
	wire    [1:0] crosser_003_out_channel;                                        
	wire          crosser_003_out_startofpacket;                                  
	wire          crosser_003_out_endofpacket;                                    
	wire    [1:0] jamb_master_limiter_cmd_valid_data;                             

	ed_synth_dut_altera_merlin_master_translator_192_lykd4la #(
		.AV_ADDRESS_W                (32),
		.AV_DATA_W                   (32),
		.AV_BURSTCOUNT_W             (1),
		.AV_BYTEENABLE_W             (4),
		.UAV_ADDRESS_W               (32),
		.UAV_BURSTCOUNT_W            (3),
		.USE_READ                    (1),
		.USE_WRITE                   (1),
		.USE_BEGINBURSTTRANSFER      (0),
		.USE_BEGINTRANSFER           (0),
		.USE_CHIPSELECT              (0),
		.USE_BURSTCOUNT              (0),
		.USE_READDATAVALID           (1),
		.USE_WAITREQUEST             (1),
		.USE_READRESPONSE            (0),
		.USE_WRITERESPONSE           (0),
		.AV_SYMBOLS_PER_WORD         (4),
		.AV_ADDRESS_SYMBOLS          (1),
		.AV_BURSTCOUNT_SYMBOLS       (0),
		.AV_CONSTANT_BURST_BEHAVIOR  (0),
		.UAV_CONSTANT_BURST_BEHAVIOR (0),
		.AV_LINEWRAPBURSTS           (0),
		.AV_REGISTERINCOMINGSIGNALS  (0),
		.SYNC_RESET                  (0),
		.WAITREQUEST_ALLOWANCE       (0),
		.USE_OUTPUTENABLE            (0)
	) jamb_master_translator (
		.clk                    (clk_bridge_out_clk_clk),                                         
		.reset                  (jamb_master_translator_reset_reset_bridge_in_reset_reset),       
		.uav_address            (jamb_master_translator_avalon_universal_master_0_address),       
		.uav_burstcount         (jamb_master_translator_avalon_universal_master_0_burstcount),    
		.uav_read               (jamb_master_translator_avalon_universal_master_0_read),          
		.uav_write              (jamb_master_translator_avalon_universal_master_0_write),         
		.uav_waitrequest        (jamb_master_translator_avalon_universal_master_0_waitrequest),   
		.uav_readdatavalid      (jamb_master_translator_avalon_universal_master_0_readdatavalid), 
		.uav_byteenable         (jamb_master_translator_avalon_universal_master_0_byteenable),    
		.uav_readdata           (jamb_master_translator_avalon_universal_master_0_readdata),      
		.uav_writedata          (jamb_master_translator_avalon_universal_master_0_writedata),     
		.uav_lock               (jamb_master_translator_avalon_universal_master_0_lock),          
		.uav_debugaccess        (jamb_master_translator_avalon_universal_master_0_debugaccess),   
		.av_address             (jamb_master_address),                                            
		.av_waitrequest         (jamb_master_waitrequest),                                        
		.av_byteenable          (jamb_master_byteenable),                                         
		.av_read                (jamb_master_read),                                               
		.av_readdata            (jamb_master_readdata),                                           
		.av_readdatavalid       (jamb_master_readdatavalid),                                      
		.av_write               (jamb_master_write),                                              
		.av_writedata           (jamb_master_writedata),                                          
		.av_burstcount          (1'b1),                                                           
		.av_beginbursttransfer  (1'b0),                                                           
		.av_begintransfer       (1'b0),                                                           
		.av_chipselect          (1'b0),                                                           
		.av_lock                (1'b0),                                                           
		.av_debugaccess         (1'b0),                                                           
		.uav_outputenable       (1'b0),                                                           
		.uav_clken              (),                                                               
		.av_clken               (1'b1),                                                           
		.uav_response           (2'b00),                                                          
		.av_response            (),                                                               
		.uav_writeresponsevalid (1'b0),                                                           
		.av_writeresponsevalid  ()                                                                
	);

	ed_synth_dut_altera_merlin_master_agent_1921_2inlndi #(
		.PKT_WUNIQUE               (110),
		.PKT_DOMAIN_H              (109),
		.PKT_DOMAIN_L              (108),
		.PKT_SNOOP_H               (107),
		.PKT_SNOOP_L               (104),
		.PKT_BARRIER_H             (103),
		.PKT_BARRIER_L             (102),
		.PKT_ORI_BURST_SIZE_H      (101),
		.PKT_ORI_BURST_SIZE_L      (99),
		.PKT_RESPONSE_STATUS_H     (98),
		.PKT_RESPONSE_STATUS_L     (97),
		.PKT_QOS_H                 (86),
		.PKT_QOS_L                 (86),
		.PKT_DATA_SIDEBAND_H       (84),
		.PKT_DATA_SIDEBAND_L       (84),
		.PKT_ADDR_SIDEBAND_H       (83),
		.PKT_ADDR_SIDEBAND_L       (83),
		.PKT_BURST_TYPE_H          (82),
		.PKT_BURST_TYPE_L          (81),
		.PKT_CACHE_H               (96),
		.PKT_CACHE_L               (93),
		.PKT_THREAD_ID_H           (89),
		.PKT_THREAD_ID_L           (89),
		.PKT_BURST_SIZE_H          (80),
		.PKT_BURST_SIZE_L          (78),
		.PKT_TRANS_EXCLUSIVE       (73),
		.PKT_TRANS_LOCK            (72),
		.PKT_BEGIN_BURST           (85),
		.PKT_PROTECTION_H          (92),
		.PKT_PROTECTION_L          (90),
		.PKT_BURSTWRAP_H           (77),
		.PKT_BURSTWRAP_L           (77),
		.PKT_BYTE_CNT_H            (76),
		.PKT_BYTE_CNT_L            (74),
		.PKT_ADDR_H                (67),
		.PKT_ADDR_L                (36),
		.PKT_TRANS_COMPRESSED_READ (68),
		.PKT_TRANS_POSTED          (69),
		.PKT_TRANS_WRITE           (70),
		.PKT_TRANS_READ            (71),
		.PKT_DATA_H                (31),
		.PKT_DATA_L                (0),
		.PKT_BYTEEN_H              (35),
		.PKT_BYTEEN_L              (32),
		.PKT_SRC_ID_H              (87),
		.PKT_SRC_ID_L              (87),
		.PKT_DEST_ID_H             (88),
		.PKT_DEST_ID_L             (88),
		.PKT_POISON_H              (111),
		.PKT_POISON_L              (111),
		.PKT_DATACHK_H             (112),
		.PKT_DATACHK_L             (112),
		.PKT_ADDRCHK_H             (113),
		.PKT_ADDRCHK_L             (113),
		.PKT_SAI_H                 (114),
		.PKT_SAI_L                 (114),
		.ST_DATA_W                 (124),
		.ST_CHANNEL_W              (2),
		.AV_BURSTCOUNT_W           (3),
		.SUPPRESS_0_BYTEEN_RSP     (0),
		.ID                        (0),
		.BURSTWRAP_VALUE           (1),
		.CACHE_VALUE               (0),
		.SECURE_ACCESS_BIT         (1),
		.USE_READRESPONSE          (0),
		.USE_WRITERESPONSE         (0),
		.DOMAIN_VALUE              (3),
		.BARRIER_VALUE             (0),
		.SNOOP_VALUE               (0),
		.WUNIQUE_VALUE             (0),
		.SYNC_RESET                (0),
		.USE_PKT_DATACHK           (0),
		.USE_PKT_ADDRCHK           (0),
		.ROLE_BASED_USER           (0)
	) jamb_master_agent (
		.clk                   (clk_bridge_out_clk_clk),                                         
		.reset                 (jamb_master_translator_reset_reset_bridge_in_reset_reset),       
		.av_address            (jamb_master_translator_avalon_universal_master_0_address),       
		.av_write              (jamb_master_translator_avalon_universal_master_0_write),         
		.av_read               (jamb_master_translator_avalon_universal_master_0_read),          
		.av_writedata          (jamb_master_translator_avalon_universal_master_0_writedata),     
		.av_readdata           (jamb_master_translator_avalon_universal_master_0_readdata),      
		.av_waitrequest        (jamb_master_translator_avalon_universal_master_0_waitrequest),   
		.av_readdatavalid      (jamb_master_translator_avalon_universal_master_0_readdatavalid), 
		.av_byteenable         (jamb_master_translator_avalon_universal_master_0_byteenable),    
		.av_burstcount         (jamb_master_translator_avalon_universal_master_0_burstcount),    
		.av_debugaccess        (jamb_master_translator_avalon_universal_master_0_debugaccess),   
		.av_lock               (jamb_master_translator_avalon_universal_master_0_lock),          
		.cp_valid              (jamb_master_agent_cp_valid),                                     
		.cp_data               (jamb_master_agent_cp_data),                                      
		.cp_startofpacket      (jamb_master_agent_cp_startofpacket),                             
		.cp_endofpacket        (jamb_master_agent_cp_endofpacket),                               
		.cp_ready              (jamb_master_agent_cp_ready),                                     
		.rp_valid              (jamb_master_limiter_rsp_src_valid),                              
		.rp_data               (jamb_master_limiter_rsp_src_data),                               
		.rp_channel            (jamb_master_limiter_rsp_src_channel),                            
		.rp_startofpacket      (jamb_master_limiter_rsp_src_startofpacket),                      
		.rp_endofpacket        (jamb_master_limiter_rsp_src_endofpacket),                        
		.rp_ready              (jamb_master_limiter_rsp_src_ready),                              
		.av_response           (),                                                               
		.av_writeresponsevalid ()                                                                
	);

	ed_synth_dut_altera_merlin_axi_slave_ni_1971_kt2puei #(
		.PKT_QOS_H                   (86),
		.PKT_QOS_L                   (86),
		.PKT_THREAD_ID_H             (89),
		.PKT_THREAD_ID_L             (89),
		.PKT_RESPONSE_STATUS_H       (98),
		.PKT_RESPONSE_STATUS_L       (97),
		.PKT_BEGIN_BURST             (85),
		.PKT_CACHE_H                 (96),
		.PKT_CACHE_L                 (93),
		.PKT_DATA_SIDEBAND_H         (84),
		.PKT_DATA_SIDEBAND_L         (84),
		.PKT_ADDR_SIDEBAND_H         (83),
		.PKT_ADDR_SIDEBAND_L         (83),
		.PKT_BURST_TYPE_H            (82),
		.PKT_BURST_TYPE_L            (81),
		.PKT_PROTECTION_H            (92),
		.PKT_PROTECTION_L            (90),
		.PKT_BURST_SIZE_H            (80),
		.PKT_BURST_SIZE_L            (78),
		.PKT_BURSTWRAP_H             (77),
		.PKT_BURSTWRAP_L             (77),
		.PKT_BYTE_CNT_H              (76),
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
		.PKT_SRC_ID_H                (87),
		.PKT_SRC_ID_L                (87),
		.PKT_DEST_ID_H               (88),
		.PKT_DEST_ID_L               (88),
		.PKT_ORI_BURST_SIZE_L        (99),
		.PKT_ORI_BURST_SIZE_H        (101),
		.PKT_DOMAIN_L                (108),
		.PKT_DOMAIN_H                (109),
		.PKT_SNOOP_L                 (104),
		.PKT_SNOOP_H                 (107),
		.PKT_BARRIER_L               (102),
		.PKT_BARRIER_H               (103),
		.PKT_WUNIQUE                 (110),
		.PKT_EOP_OOO                 (115),
		.PKT_SOP_OOO                 (116),
		.PKT_POISON_H                (111),
		.PKT_POISON_L                (111),
		.PKT_DATACHK_H               (112),
		.PKT_DATACHK_L               (112),
		.PKT_ADDRCHK_H               (113),
		.PKT_ADDRCHK_L               (113),
		.PKT_SAI_H                   (114),
		.PKT_SAI_L                   (114),
		.SAI_WIDTH                   (1),
		.ADDRCHK_WIDTH               (1),
		.ADDR_USER_WIDTH             (1),
		.DATA_USER_WIDTH             (1),
		.ST_DATA_W                   (124),
		.ADDR_WIDTH                  (32),
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
	) arbit_s0_axi4lite_agent (
		.aclk                   (clk_bridge_out_clk_3_clk),                               
		.aresetn                (~arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset), 
		.read_cp_valid          (cmd_mux_001_src_valid),                                  
		.read_cp_ready          (cmd_mux_001_src_ready),                                  
		.read_cp_data           (cmd_mux_001_src_data),                                   
		.read_cp_channel        (cmd_mux_001_src_channel),                                
		.read_cp_startofpacket  (cmd_mux_001_src_startofpacket),                          
		.read_cp_endofpacket    (cmd_mux_001_src_endofpacket),                            
		.write_cp_ready         (cmd_mux_src_ready),                                      
		.write_cp_valid         (cmd_mux_src_valid),                                      
		.write_cp_data          (cmd_mux_src_data),                                       
		.write_cp_channel       (cmd_mux_src_channel),                                    
		.write_cp_startofpacket (cmd_mux_src_startofpacket),                              
		.write_cp_endofpacket   (cmd_mux_src_endofpacket),                                
		.read_rp_ready          (arbit_s0_axi4lite_agent_read_rp_ready),                  
		.read_rp_valid          (arbit_s0_axi4lite_agent_read_rp_valid),                  
		.read_rp_data           (arbit_s0_axi4lite_agent_read_rp_data),                   
		.read_rp_startofpacket  (arbit_s0_axi4lite_agent_read_rp_startofpacket),          
		.read_rp_endofpacket    (arbit_s0_axi4lite_agent_read_rp_endofpacket),            
		.write_rp_ready         (arbit_s0_axi4lite_agent_write_rp_ready),                 
		.write_rp_valid         (arbit_s0_axi4lite_agent_write_rp_valid),                 
		.write_rp_data          (arbit_s0_axi4lite_agent_write_rp_data),                  
		.write_rp_startofpacket (arbit_s0_axi4lite_agent_write_rp_startofpacket),         
		.write_rp_endofpacket   (arbit_s0_axi4lite_agent_write_rp_endofpacket),           
		.awaddr                 (arbit_s0_axi4lite_awaddr),                               
		.awprot                 (arbit_s0_axi4lite_awprot),                               
		.awvalid                (arbit_s0_axi4lite_awvalid),                              
		.awready                (arbit_s0_axi4lite_awready),                              
		.wdata                  (arbit_s0_axi4lite_wdata),                                
		.wstrb                  (arbit_s0_axi4lite_wstrb),                                
		.wvalid                 (arbit_s0_axi4lite_wvalid),                               
		.wready                 (arbit_s0_axi4lite_wready),                               
		.bresp                  (arbit_s0_axi4lite_bresp),                                
		.bvalid                 (arbit_s0_axi4lite_bvalid),                               
		.bready                 (arbit_s0_axi4lite_bready),                               
		.araddr                 (arbit_s0_axi4lite_araddr),                               
		.arprot                 (arbit_s0_axi4lite_arprot),                               
		.arvalid                (arbit_s0_axi4lite_arvalid),                              
		.arready                (arbit_s0_axi4lite_arready),                              
		.rdata                  (arbit_s0_axi4lite_rdata),                                
		.rresp                  (arbit_s0_axi4lite_rresp),                                
		.rvalid                 (arbit_s0_axi4lite_rvalid),                               
		.rready                 (arbit_s0_axi4lite_rready),                               
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

	ed_synth_dut_altera_merlin_router_1921_wqohhgi router (
		.sink_ready         (jamb_master_agent_cp_ready),                               
		.sink_valid         (jamb_master_agent_cp_valid),                               
		.sink_data          (jamb_master_agent_cp_data),                                
		.sink_startofpacket (jamb_master_agent_cp_startofpacket),                       
		.sink_endofpacket   (jamb_master_agent_cp_endofpacket),                         
		.clk                (clk_bridge_out_clk_clk),                                   
		.reset              (jamb_master_translator_reset_reset_bridge_in_reset_reset), 
		.src_ready          (router_src_ready),                                         
		.src_valid          (router_src_valid),                                         
		.src_data           (router_src_data),                                          
		.src_channel        (router_src_channel),                                       
		.src_startofpacket  (router_src_startofpacket),                                 
		.src_endofpacket    (router_src_endofpacket)                                    
	);

	ed_synth_dut_altera_merlin_router_1921_2jqun3q router_001 (
		.sink_ready         (arbit_s0_axi4lite_agent_write_rp_ready),                
		.sink_valid         (arbit_s0_axi4lite_agent_write_rp_valid),                
		.sink_data          (arbit_s0_axi4lite_agent_write_rp_data),                 
		.sink_startofpacket (arbit_s0_axi4lite_agent_write_rp_startofpacket),        
		.sink_endofpacket   (arbit_s0_axi4lite_agent_write_rp_endofpacket),          
		.clk                (clk_bridge_out_clk_3_clk),                              
		.reset              (arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset), 
		.src_ready          (router_001_src_ready),                                  
		.src_valid          (router_001_src_valid),                                  
		.src_data           (router_001_src_data),                                   
		.src_channel        (router_001_src_channel),                                
		.src_startofpacket  (router_001_src_startofpacket),                          
		.src_endofpacket    (router_001_src_endofpacket)                             
	);

	ed_synth_dut_altera_merlin_router_1921_2jqun3q router_002 (
		.sink_ready         (arbit_s0_axi4lite_agent_read_rp_ready),                 
		.sink_valid         (arbit_s0_axi4lite_agent_read_rp_valid),                 
		.sink_data          (arbit_s0_axi4lite_agent_read_rp_data),                  
		.sink_startofpacket (arbit_s0_axi4lite_agent_read_rp_startofpacket),         
		.sink_endofpacket   (arbit_s0_axi4lite_agent_read_rp_endofpacket),           
		.clk                (clk_bridge_out_clk_3_clk),                              
		.reset              (arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset), 
		.src_ready          (router_002_src_ready),                                  
		.src_valid          (router_002_src_valid),                                  
		.src_data           (router_002_src_data),                                   
		.src_channel        (router_002_src_channel),                                
		.src_startofpacket  (router_002_src_startofpacket),                          
		.src_endofpacket    (router_002_src_endofpacket)                             
	);

	ed_synth_dut_altera_merlin_traffic_limiter_1921_bk6lvda #(
		.SYNC_RESET                           (0),
		.PKT_DEST_ID_H                        (88),
		.PKT_DEST_ID_L                        (88),
		.PKT_SRC_ID_H                         (87),
		.PKT_SRC_ID_L                         (87),
		.PKT_BYTE_CNT_H                       (76),
		.PKT_BYTE_CNT_L                       (74),
		.PKT_BYTEEN_H                         (35),
		.PKT_BYTEEN_L                         (32),
		.PKT_TRANS_POSTED                     (69),
		.PKT_TRANS_WRITE                      (70),
		.PKT_TRANS_SEQ_H                      (123),
		.PKT_TRANS_SEQ_L                      (117),
		.MAX_OUTSTANDING_RESPONSES            (6),
		.PIPELINED                            (0),
		.ST_DATA_W                            (124),
		.ST_CHANNEL_W                         (2),
		.VALID_WIDTH                          (2),
		.ENFORCE_ORDER                        (1),
		.PREVENT_HAZARDS                      (1),
		.SUPPORTS_POSTED_WRITES               (1),
		.SUPPORTS_NONPOSTED_WRITES            (0),
		.REORDER                              (0),
		.ENABLE_CONCURRENT_SUBORDINATE_ACCESS (0),
		.NO_REPEATED_IDS_BETWEEN_SUBORDINATES (0),
		.ENABLE_OOO                           (0)
	) jamb_master_limiter (
		.clk                    (clk_bridge_out_clk_clk),                                   
		.reset                  (jamb_master_translator_reset_reset_bridge_in_reset_reset), 
		.cmd_sink_ready         (router_src_ready),                                         
		.cmd_sink_valid         (router_src_valid),                                         
		.cmd_sink_data          (router_src_data),                                          
		.cmd_sink_channel       (router_src_channel),                                       
		.cmd_sink_startofpacket (router_src_startofpacket),                                 
		.cmd_sink_endofpacket   (router_src_endofpacket),                                   
		.cmd_src_ready          (jamb_master_limiter_cmd_src_ready),                        
		.cmd_src_data           (jamb_master_limiter_cmd_src_data),                         
		.cmd_src_channel        (jamb_master_limiter_cmd_src_channel),                      
		.cmd_src_startofpacket  (jamb_master_limiter_cmd_src_startofpacket),                
		.cmd_src_endofpacket    (jamb_master_limiter_cmd_src_endofpacket),                  
		.rsp_sink_ready         (rsp_mux_src_ready),                                        
		.rsp_sink_valid         (rsp_mux_src_valid),                                        
		.rsp_sink_channel       (rsp_mux_src_channel),                                      
		.rsp_sink_data          (rsp_mux_src_data),                                         
		.rsp_sink_startofpacket (rsp_mux_src_startofpacket),                                
		.rsp_sink_endofpacket   (rsp_mux_src_endofpacket),                                  
		.rsp_src_ready          (jamb_master_limiter_rsp_src_ready),                        
		.rsp_src_valid          (jamb_master_limiter_rsp_src_valid),                        
		.rsp_src_data           (jamb_master_limiter_rsp_src_data),                         
		.rsp_src_channel        (jamb_master_limiter_rsp_src_channel),                      
		.rsp_src_startofpacket  (jamb_master_limiter_rsp_src_startofpacket),                
		.rsp_src_endofpacket    (jamb_master_limiter_rsp_src_endofpacket),                  
		.cmd_src_valid          (jamb_master_limiter_cmd_valid_data)                        
	);

	ed_synth_dut_altera_merlin_demultiplexer_1921_ekcygpi cmd_demux (
		.clk                (clk_bridge_out_clk_clk),                                   
		.reset              (jamb_master_translator_reset_reset_bridge_in_reset_reset), 
		.sink_ready         (jamb_master_limiter_cmd_src_ready),                        
		.sink_channel       (jamb_master_limiter_cmd_src_channel),                      
		.sink_data          (jamb_master_limiter_cmd_src_data),                         
		.sink_startofpacket (jamb_master_limiter_cmd_src_startofpacket),                
		.sink_endofpacket   (jamb_master_limiter_cmd_src_endofpacket),                  
		.sink_valid         (jamb_master_limiter_cmd_valid_data),                       
		.src0_ready         (cmd_demux_src0_ready),                                     
		.src0_valid         (cmd_demux_src0_valid),                                     
		.src0_data          (cmd_demux_src0_data),                                      
		.src0_channel       (cmd_demux_src0_channel),                                   
		.src0_startofpacket (cmd_demux_src0_startofpacket),                             
		.src0_endofpacket   (cmd_demux_src0_endofpacket),                               
		.src1_ready         (cmd_demux_src1_ready),                                     
		.src1_valid         (cmd_demux_src1_valid),                                     
		.src1_data          (cmd_demux_src1_data),                                      
		.src1_channel       (cmd_demux_src1_channel),                                   
		.src1_startofpacket (cmd_demux_src1_startofpacket),                             
		.src1_endofpacket   (cmd_demux_src1_endofpacket)                                
	);

	ed_synth_dut_altera_merlin_multiplexer_1922_7b7u3ni cmd_mux (
		.clk                 (clk_bridge_out_clk_3_clk),                              
		.reset               (arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset), 
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

	ed_synth_dut_altera_merlin_multiplexer_1922_7b7u3ni cmd_mux_001 (
		.clk                 (clk_bridge_out_clk_3_clk),                              
		.reset               (arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset), 
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

	ed_synth_dut_altera_merlin_demultiplexer_1921_rcor4va rsp_demux (
		.clk                (clk_bridge_out_clk_3_clk),                              
		.reset              (arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset), 
		.sink_ready         (router_001_src_ready),                                  
		.sink_channel       (router_001_src_channel),                                
		.sink_data          (router_001_src_data),                                   
		.sink_startofpacket (router_001_src_startofpacket),                          
		.sink_endofpacket   (router_001_src_endofpacket),                            
		.sink_valid         (router_001_src_valid),                                  
		.src0_ready         (rsp_demux_src0_ready),                                  
		.src0_valid         (rsp_demux_src0_valid),                                  
		.src0_data          (rsp_demux_src0_data),                                   
		.src0_channel       (rsp_demux_src0_channel),                                
		.src0_startofpacket (rsp_demux_src0_startofpacket),                          
		.src0_endofpacket   (rsp_demux_src0_endofpacket)                             
	);

	ed_synth_dut_altera_merlin_demultiplexer_1921_rcor4va rsp_demux_001 (
		.clk                (clk_bridge_out_clk_3_clk),                              
		.reset              (arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset), 
		.sink_ready         (router_002_src_ready),                                  
		.sink_channel       (router_002_src_channel),                                
		.sink_data          (router_002_src_data),                                   
		.sink_startofpacket (router_002_src_startofpacket),                          
		.sink_endofpacket   (router_002_src_endofpacket),                            
		.sink_valid         (router_002_src_valid),                                  
		.src0_ready         (rsp_demux_001_src0_ready),                              
		.src0_valid         (rsp_demux_001_src0_valid),                              
		.src0_data          (rsp_demux_001_src0_data),                               
		.src0_channel       (rsp_demux_001_src0_channel),                            
		.src0_startofpacket (rsp_demux_001_src0_startofpacket),                      
		.src0_endofpacket   (rsp_demux_001_src0_endofpacket)                         
	);

	ed_synth_dut_altera_merlin_multiplexer_1922_ctb2miq rsp_mux (
		.clk                 (clk_bridge_out_clk_clk),                                   
		.reset               (jamb_master_translator_reset_reset_bridge_in_reset_reset), 
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
		.sink0_endofpacket   (crosser_002_out_endofpacket),                              
		.sink1_ready         (crosser_003_out_ready),                                    
		.sink1_valid         (crosser_003_out_valid),                                    
		.sink1_channel       (crosser_003_out_channel),                                  
		.sink1_data          (crosser_003_out_data),                                     
		.sink1_startofpacket (crosser_003_out_startofpacket),                            
		.sink1_endofpacket   (crosser_003_out_endofpacket)                               
	);

	ed_synth_dut_hs_clk_xer_1940_4s7hdhy #(
		.DATA_WIDTH          (124),
		.BITS_PER_SYMBOL     (124),
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
		.in_clk            (clk_bridge_out_clk_clk),                                   
		.in_reset          (jamb_master_translator_reset_reset_bridge_in_reset_reset), 
		.out_clk           (clk_bridge_out_clk_3_clk),                                 
		.out_reset         (arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset),    
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

	ed_synth_dut_hs_clk_xer_1940_4s7hdhy #(
		.DATA_WIDTH          (124),
		.BITS_PER_SYMBOL     (124),
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
		.in_clk            (clk_bridge_out_clk_clk),                                   
		.in_reset          (jamb_master_translator_reset_reset_bridge_in_reset_reset), 
		.out_clk           (clk_bridge_out_clk_3_clk),                                 
		.out_reset         (arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset),    
		.in_ready          (cmd_demux_src1_ready),                                     
		.in_valid          (cmd_demux_src1_valid),                                     
		.in_startofpacket  (cmd_demux_src1_startofpacket),                             
		.in_endofpacket    (cmd_demux_src1_endofpacket),                               
		.in_channel        (cmd_demux_src1_channel),                                   
		.in_data           (cmd_demux_src1_data),                                      
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

	ed_synth_dut_hs_clk_xer_1940_4s7hdhy #(
		.DATA_WIDTH          (124),
		.BITS_PER_SYMBOL     (124),
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
		.in_clk            (clk_bridge_out_clk_3_clk),                                 
		.in_reset          (arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset),    
		.out_clk           (clk_bridge_out_clk_clk),                                   
		.out_reset         (jamb_master_translator_reset_reset_bridge_in_reset_reset), 
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

	ed_synth_dut_hs_clk_xer_1940_4s7hdhy #(
		.DATA_WIDTH          (124),
		.BITS_PER_SYMBOL     (124),
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
		.in_clk            (clk_bridge_out_clk_3_clk),                                 
		.in_reset          (arbit_s0_axi4lite_aresetn_reset_bridge_in_reset_reset),    
		.out_clk           (clk_bridge_out_clk_clk),                                   
		.out_reset         (jamb_master_translator_reset_reset_bridge_in_reset_reset), 
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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc8jdrM+GYeDbK+21k4g5ZlSCa/gzWbYkGD+3bJj1lVrSvb9p7zP/ZrtR10zUy41jgUyRD0mnT6iQa2SzVE3Yznhg1AxXOkF4rRBugpCvzLpzKHAasrXlSTmcsY1bsFCJjNruV1y+VntcsAjJ2GFgDny9ZzgZrZOJEQCEj+v7YZ+yq0FVu/Tmn6M+zAB9HrzvtJuSxRFMmzplLmFLfYCHQfmYhWPsApOw/UWlVSLGSQDXgP6TTOVfHmwZS3WWi/0QuwMCrq+9CzVhjAzxNoUOQwrnphbmckMeFx3DJy30akYb58Y8Q1TYlrNI/y9bMLQcswMAtaCaXNZEflhNXRrIvEovr/TriwJoSVF2IK/BiBcyz37D49qekT0ySD1NVai8fxwgNDebSjEd5EMyK+ernZ3+6QJllZCbv2bJfA2UQO+1+FLNEfsW6Og9FCQcY8lf++mBgrW/eAhF83fjVAs3EmBrOsarMWVv9tAVuler4utnDoDelj6as5KyyyeYi9Ju1RezW7QdTbGK7n88MxEzRWAGxc5ipU9pveHvSyfigUKsEqh7trTt0YzKu9IL/lQt8bqTGN7buOUpwm6qjBjWD94r5xZhghHzNDJr51e+jVUq/X23IGSFXIl6XhaJRMkWar0ioC9dKoOVlS9UqZ682wNUr1QRY8fMGe3BdOFVLvc3agf2dvp0+7hCMfS4ec/SBiVt/qtucvI/X+y+aA1rnE4FzuIapgXF2ssNjJDQzpylLp3vQO8Z5oidjtm3EWkotzM+TzYjj2wOR5rGDZ1IXi0"
`endif