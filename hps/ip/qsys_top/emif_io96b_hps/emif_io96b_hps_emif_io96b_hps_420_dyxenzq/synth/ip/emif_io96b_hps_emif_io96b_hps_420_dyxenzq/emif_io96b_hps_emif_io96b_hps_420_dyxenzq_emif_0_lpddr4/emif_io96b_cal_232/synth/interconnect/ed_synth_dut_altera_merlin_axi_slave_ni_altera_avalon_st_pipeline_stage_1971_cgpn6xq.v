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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_cgpn6xq #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 188,
		parameter USE_PACKETS      = 1,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 0,
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
		input  wire         out_ready,         
		output wire         out_valid,         
		output wire         out_startofpacket, 
		output wire         out_endofpacket,   
		output wire [187:0] out_data           
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
	) my_altera_avalon_st_pipeline_stage_rp (
		.clk               (clk),               
		.reset             (reset),             
		.in_ready          (in_ready),          
		.in_valid          (in_valid),          
		.in_startofpacket  (in_startofpacket),  
		.in_endofpacket    (in_endofpacket),    
		.in_data           (in_data),           
		.out_ready         (out_ready),         
		.out_valid         (out_valid),         
		.out_startofpacket (out_startofpacket), 
		.out_endofpacket   (out_endofpacket),   
		.out_data          (out_data),          
		.in_empty          (1'b0),              
		.out_empty         (),                  
		.out_error         (),                  
		.in_error          (1'b0),              
		.out_channel       (),                  
		.in_channel        (1'b0)               
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9HK5TT5s6Ih2WsyxV0SE4EkPuCNGvhgpLRwyZeCZPv6/b2uemhj1RnlqUydlwWhMhjSeDsTD68SgVrOTl6je4gDjwqKLMKmGqu27TJQhFNaWKaQ9mC5Eg8tzCvig+3G8wqPkD9t3iixDIA9ef2U9rd1Wafap1T7lAdyq+Xj7abkNsyr6rJLWw7dcGBB6WyKNCk2wupbx6Rf5Y5kxZT0r8EwuhX3SniewnzKfmVDGhlf+h94ajhQln5wHOnI2zH8An7HM4AfgAMt6eLnSUHI0Sl7A9HOJydd0jGeKf82L9so7yeU42iaVOSdJQzMdfAwkVp5EcijEQcRzTRtxxGEWxMqBTLWige6Xd39nOd69AxdwXc6RVwjo4uHtztejMtYMndfCUyPJos3ObkDzOmsqEI1ocqncA2Y3Q06dirxkMAYmuUlhLIrBnIKSCIzWLjuIMkxqfANKLfKIVFNUhR5eGBSYfCc6/6cXyA754EeIUVK5ez6A4B/JB62abeTcL/ofA7+5jGMcKxy8dA1Gc9Q9PhYiT1I0sQM5A6W3iANyV9Bu8t1sl5V9Q6cdew6O0FKFR8MKqPyTh/wFqfdB7uCFifG2iflzGI7PmPODAFKAgMX3VzzXg61Uw9FB+bqRvj6y7hxky21BI4j36AOOP4STH4arMmsEHMl8rRPtI5ZFleEVObNKXxGG5ECdfIhPiqTn0TKL+pZir7XphFf/9w7NvZbCr+ylHdkNvm3twxvthJQGbYhwMkPCTCoaR8qcx6GYmyT7wNrJkFxqa7Xy80q72+"
`endif