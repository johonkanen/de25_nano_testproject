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
module ed_synth_dut_altera_merlin_burst_adapter_altera_avalon_st_pipeline_stage_1931_glj62si #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 188,
		parameter USE_PACKETS      = 1,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 2,
		parameter PACKET_WIDTH     = 2,
		parameter ERROR_WIDTH      = 0,
		parameter PIPELINE_READY   = 1,
		parameter SYNC_RESET       = 0
	) (
		input  wire         clk,               
		input  wire         reset,             
		output wire         in_ready,          
		input  wire         in_valid,          
		input  wire         in_startofpacket,  
		input  wire         in_endofpacket,    
		input  wire [187:0] in_data,           
		input  wire [1:0]   in_channel,        
		input  wire         out_ready,         
		output wire         out_valid,         
		output wire         out_startofpacket, 
		output wire         out_endofpacket,   
		output wire [187:0] out_data,          
		output wire [1:0]   out_channel        
	);

	ed_synth_dut_altera_avalon_st_pipeline_stage_1930_bv2ucky #(
		.SYMBOLS_PER_BEAT (SYMBOLS_PER_BEAT),
		.BITS_PER_SYMBOL  (BITS_PER_SYMBOL),
		.USE_PACKETS      (USE_PACKETS),
		.USE_EMPTY        (USE_EMPTY),
		.EMPTY_WIDTH      (EMPTY_WIDTH),
		.CHANNEL_WIDTH    (CHANNEL_WIDTH),
		.PACKET_WIDTH     (PACKET_WIDTH),
		.ERROR_WIDTH      (ERROR_WIDTH),
		.PIPELINE_READY   (PIPELINE_READY),
		.SYNC_RESET       (SYNC_RESET)
	) my_altera_avalon_st_pipeline_stage (
		.clk               (clk),               
		.reset             (reset),             
		.in_ready          (in_ready),          
		.in_valid          (in_valid),          
		.in_startofpacket  (in_startofpacket),  
		.in_endofpacket    (in_endofpacket),    
		.in_data           (in_data),           
		.in_channel        (in_channel),        
		.out_ready         (out_ready),         
		.out_valid         (out_valid),         
		.out_startofpacket (out_startofpacket), 
		.out_endofpacket   (out_endofpacket),   
		.out_data          (out_data),          
		.out_channel       (out_channel),       
		.in_empty          (1'b0),              
		.out_empty         (),                  
		.out_error         (),                  
		.in_error          (1'b0)               
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9F7KM8cUvVVMrKrqiXHmf6YFRo7mlWBwQ0c0wxIP2NgH0nk/IRN6Zh9FXSUQ1jS6R7Mefp1igGxaxiOq4h3YyUr38yZ2QXvrICzZ9khJ2lnscdlYuPCGTP9xRWQ/KBQmyLWV9H/Aub8WCyHlJAr6MZQ76wUxIvNhJOvRhf9pqwBWxoY9/nffMK43eZXdnffMiEYPP8+RurfnsjEujf5paaOzZzmnMrAj8xzly43bQ8ucXiOkEGAKHBUq4Qi6yjdWhnM20daF4eW/sMtQwdx+HhT67mpxrED4FR+mmgTX+JDuXL6V+DFpce85hcR1zC7f+pEOwOkDH9WCH/9llQOs46A26lH3D15hlW0xFBwqURw/Won7orng2tpcehbPj4cCaw97PCr+B3Kp+3kS17vZoE6vEHy15TwwWkFKpVEN3qdYREiCYoG/wMD7uc7npd1x3aqdvRRnE5N1nR/IIXCC0UlM9L6us/94bB/B2TaFWkRmaq6n4ZKKv0akrORLIdTxp30z7vIyQw641WAmm2XsvmTBKabUccOF99aADuR/kbuWpN7oIi08b1YQ5I6BfiAD61XwZnYozrGKlYxP2BdYvQiZErl7KceB3H2GUorOY+Gjw7yx747B45mv6ItF/1pXoCSv8L3/VdXYtQAQ7HNmrYujJFW97yy1VlI1UDYpgCkB77CWX5ExjUsC3dpHn7C81xlqtHr1r223B9i8C60KND1oykhPk7r/VEXCwwvTGT6DhiGZSrzMqfOwfQwBOXa3FKLNK7azrZUynnoUgPRe0r"
`endif