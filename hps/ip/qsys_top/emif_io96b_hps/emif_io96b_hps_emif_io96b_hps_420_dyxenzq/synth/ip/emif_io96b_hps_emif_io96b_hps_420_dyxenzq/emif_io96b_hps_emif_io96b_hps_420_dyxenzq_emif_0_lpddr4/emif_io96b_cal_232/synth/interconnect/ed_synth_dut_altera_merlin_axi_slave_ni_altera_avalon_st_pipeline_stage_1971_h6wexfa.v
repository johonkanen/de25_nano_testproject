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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_h6wexfa #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 4,
		parameter USE_PACKETS      = 0,
		parameter USE_EMPTY        = 0,
		parameter EMPTY_WIDTH      = 0,
		parameter CHANNEL_WIDTH    = 0,
		parameter PACKET_WIDTH     = 0,
		parameter ERROR_WIDTH      = 0,
		parameter PIPELINE_READY   = 0,
		parameter SYNC_RESET       = 0
	) (
		input  wire       clk,       
		input  wire       reset,     
		output wire       in_ready,  
		input  wire       in_valid,  
		input  wire [3:0] in_data,   
		input  wire       out_ready, 
		output wire       out_valid, 
		output wire [3:0] out_data   
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
	) my_altera_avalon_st_pipeline_stage_wr (
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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9dx57aHApgUNm4FKPiNVWUpKrBXlJQjuWkU3itr5nx90vpXm00SWJ0spwBfs3bSJePeYGTinirwkR97iiyzJbSVVxWGjnDkHO5GEt05qTwkRsQeq2pDvQh57UOl6P73A9U7fY1/undDdIvupDHWAU6tDv8StXfK0Y/JdY3MoQvUCfVYyZ6qAoZeaHbALlEVnViSi5KdA3iv1nu/bW7lhRNAV2FuooVi31MIi8Px3b3ymS3+bTKSB9qlz8GrGGjLcj4YreeIlX0rCgaI3A11QQbQIg6zFaAZ46pt5u5iMKxz0Y2YEJ5Y46IDooZ18OIynVUcOGwCX0xIdYB0EWplbonDGYwBc2NAvsTrz2xj51k4pBwVJoFtcGkgy8cEE0iOccx2MBB+qvBnbnnpZoPM5OVdK9gKU8VdO7VI29r6pPtmOt5sOK78RkA6X/BAocacTACBzb8YHomBMDUyAhll90GFThoQurreWlYEfeGJUMWnCG0At09u4C8Gm4+CYBYKTpJdFq7EqR6RwFlAF1T/GlaLld/fUZySxluqYNWUmPjqSt9OcufTNkCRLL2SXT6BaE2c03zu2gwMzQ+DMCVcZ6AkM9NhK5nBG0fG8/M/WcpHX/gIvo087j7ajPAlqG5WbYei5NXvNuzV69elMf65O6gYioZEFVFDCH3uzRN7lng7v+fEQ389CV/aecAU5Ym5aB3YLW3vW7x4Rwv/u8uFwnDqW1eVyZ2eFlO7MRaQ/Kc92RBEp78asDgbZKOdf2M++/Tg0ZNI+7PK5S2ncer8g3l"
`endif