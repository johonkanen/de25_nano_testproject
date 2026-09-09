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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_alj3kza #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 37,
		parameter USE_PACKETS      = 0,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 0,
		parameter PACKET_WIDTH     = 0,
		parameter ERROR_WIDTH      = 0,
		parameter PIPELINE_READY   = 0,
		parameter SYNC_RESET       = 0
	) (
		input  wire        clk,       
		input  wire        reset,     
		output wire        in_ready,  
		input  wire        in_valid,  
		input  wire [36:0] in_data,   
		input  wire        out_ready, 
		output wire        out_valid, 
		output wire [36:0] out_data   
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
	) my_altera_avalon_st_pipeline_stage_rd (
		.clk               (clk),       
		.reset             (reset),     
		.in_ready          (in_ready),  
		.in_valid          (in_valid),  
		.in_data           (in_data),   
		.out_ready         (out_ready), 
		.out_valid         (out_valid), 
		.out_data          (out_data),  
		.in_startofpacket  (1'b0),      
		.in_endofpacket    (1'b0),      
		.out_startofpacket (),          
		.out_endofpacket   (),          
		.in_empty          (1'b0),      
		.out_empty         (),          
		.out_error         (),          
		.in_error          (1'b0),      
		.out_channel       (),          
		.in_channel        (1'b0)       
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX5pe6YbCJwbx2t0fVLN0J62OsOKAkcBnoB6zWccZeaLV67zLcHrMN8lzgRr4uCmQzKl1tCCUHf4FeZuAQfMlonTWXtH0pNM4J2M1Y7hvAuxgKKMS3U2p+dKAViY4bAR0KhGOV2SBnMYXGd+RTdIjITmi9YWRPrUlHUj7OtxtddqDznGqsXaZwIW3yJbdG8YyTTpkE3KSCx68o0X9EoUpfUjpunzdsmlWYKTtMsFG5KT5vipSeNyZFBs2ma9xHzl16JOqJR+VXHmJW4HoUQmFmK4PkQO7hZDRs0bIw9QIgJ1Y1VULbl/SjnMySnx00GigA2/qs88LRr5+2t059nxkTezZj6LH+EJWrLiE44vvD1Mpf6Hm4ISV0rWcpZjTOpSLWCd3bqdYvY6tlD2uRyO8/7M9P+xg3wWRNVVW+YE2IhJAZhxCqiOR61pkQeMIRxan3TFF0pNbjST5l6/WWtcAziYrOX5DJCARUdnf7PM8/cTI6xunT6Uv59u9HbD4Fg8ToTa6LKiY1ljD05ITiqu5Bs4v3EWvdzwaa4gZhMOEiYjzjrwsXEPGeHISFehiVZ/gZvj6qf/TXnsW2dh8KktkTZ0jnEg4YhiPmdSa2iXwfW9T8wrUXP32fukOyBUXTvUKbKI95L1SxQs5ySvMEg9Qz6Ph49fmJqWXhPXdJJV/Qkrfu7Ynf/7mp/dqnqHe6TZ4jmF0Ul9K2uegGmzM9Leg3nHEqBVrmfc1PD4pwC4pil+6L1QTek1cWHiymP9OTyf2QEvPh4AXDAyaF0uYWqA1TXF"
`endif