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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_vnonqiy #(
		parameter SYMBOLS_PER_BEAT = 1,
		parameter BITS_PER_SYMBOL  = 124,
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
		input  wire [123:0] in_data,           
		input  wire         out_ready,         
		output wire         out_valid,         
		output wire         out_startofpacket, 
		output wire         out_endofpacket,   
		output wire [123:0] out_data           
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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc+FMJ9l8dz0AFyCGDoPQfraw5pcUbcsJbGHTmgq1yAzjRvwXPSRk5erPRMvJQ8WjocxtBrA3G3K/Id6CWuKdcmgDk8a0ARSGlkeL4w68hWOUIln5+xgWuw9Z4rwGSzLy6Qxu4jC9Lot40rHk/egeOFe52TUqjJYwbfDqbzNscD4zukyzZ3P5MZvGK8+kr/9DJl+PZxjrNIff9bIy9D/VgqKSsIdbHRL4gwXVGeggflTWKgFKOLafKbvVMxl+xu/3Rklro8CNt2ou+VqG+0TpAyPm+DgV6qb75k1f2QQ7zWIx+s0UthbnjTSNGkpIuc6rDSEFhzyfevUxlNHAikn4kPJkQWBQ/3t5li5uxSo/EHuXguqoyK4NWc/US0nznnDIBrGfslr4JiPWd0jWx+hIAvtLFUYUe6u4X9K5JCY2O1D5Pqxqz6uQ7b9JbamwT4WNT3HvlIQpUyBcUWshJf/e/bkr2TDtuSrxxLgu/CXV+iu4rxbMy2gvHHpx5dKBLQfrE5UCSv6Whnkbq4YY+apIw9GoJBsAwI+JNccXzoIQH69BAvODSCPBMBPixk7H8CDW9SBLHYyE/GX88TBfhM4/YK644gydl4Wmxtqjpw4cn4YnYNJSvtWsLdyLfcruYeL7feXQWKyOmhzuPf9FrEvOmYUXlg/8dosN2NQIePWDnZQnpOj43OihQWkTaXqJYUCStsTnbEl8mAjU98O7qQYlgyyYYrMLa0J7mVlSeqF2CeH7kFo/9vGizeEj+W27If48aNzfBbpdlDeUsz82p9DLD6H"
`endif