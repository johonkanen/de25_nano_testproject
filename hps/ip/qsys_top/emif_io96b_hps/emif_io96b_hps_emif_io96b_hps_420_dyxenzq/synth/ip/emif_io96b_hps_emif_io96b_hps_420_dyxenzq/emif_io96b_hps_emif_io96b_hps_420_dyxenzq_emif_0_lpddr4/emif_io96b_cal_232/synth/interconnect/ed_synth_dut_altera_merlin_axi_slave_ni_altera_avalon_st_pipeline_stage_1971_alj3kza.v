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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9H49BIrSv2YORai8UBCpP5fj4SY1FQcJ17ubBAdkQ7pbMSaMpiTbjhcofGMJoXO+xSXPbiZRfzGkl9DxhbMF/KfSue7tn0Rsf6AjBKj2PN24j9R+qCmnvGhWKdRl+w2VR5pXabNctYmWeDd2vi30D0HZCe6Jtp88dFTdaAby1EBjmUUtesOcYmWMn8LwRngCOiSHlD9CBfvYJUTAG6AX6okxWMOovMK3yk6HGwXGC+LMZDoIHUwzYPWK0h6fJSBpC13DCbAKgpHmtC6S1wFhIffnE+NsMD05bmFa+o2/469DT2zbdmRnnSTJ/vzzxiEIth/+8Pj/N3V0tzxBKhubc3E6c1WurF+M3P6oGwXd4DpkPNLs7buga5dm27d6hL6iKsb2/pWaDtalLPqCDEK/AoVQ2eBRvGEFn6ZMrrBT1LZt8t3yBlZzsEOnPjm+zG4Gt40L34Fkp/G4NidHs/fdEhZgCO7pw6AfKsaQb7LYE8UV9muRy/kq+Q7A3dHmWVcpvSfLzN4OIFPjefOAkJwO0peauH/481BBazhDRepshPNXvBbXzoyR8aqlN6r6UxPmhsK7VdMY0+hw2ZcCaerVaW/dPmF5Qx3U0Yr8Swea6DFHazbHRqgpSJoSCUmJypG5Kol0yHgVcf+9TwINFfZXJg7Wz4G6fo/7YFbZW9PPrGeooKmct1n4+SEc+FuIJx8CLvf7i28aOCvA7SFcDNZb3XX5DK9UApNy5VbkrwbXrAu8SPZ4hTsZKX7dopuBUGio6xW7JyRXqrZPyciv2OB8dh"
`endif