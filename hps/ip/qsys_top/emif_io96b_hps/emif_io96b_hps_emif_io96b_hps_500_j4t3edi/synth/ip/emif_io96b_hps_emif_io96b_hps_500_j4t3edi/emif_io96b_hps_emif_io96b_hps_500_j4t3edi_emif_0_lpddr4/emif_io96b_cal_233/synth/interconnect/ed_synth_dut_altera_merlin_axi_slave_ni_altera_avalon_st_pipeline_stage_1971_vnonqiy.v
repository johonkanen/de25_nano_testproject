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
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX43wpu62vCtd+Ycd0G8lY1x6P9F1lNmxSnN4tGboNUBVJmlwtTFgACcn/PsFmtzLc1CMOWUAB+Bm0SXqR82WXon74+ubVDkqMDNmQMthm3b9ZcG04/siNBzHbD+ECKdU4eUTO76zx1kxUZh0h7YTPi5yFkNvEFwA2wnU/FyyJDlYAvq7bRYt1o48rM8J39aUws9eF8S3ZIBFqmLKQfVLev9VGNeWSVOxt8bc0dSGwWnXn4CX/9iuDeZBvSt1XI7nbkKE13uwIbVOa13ELjw0DQb/VV9alsPlen2EvBcIz1Zrg1xbzt1ZQfvx1KII8QG0B5hV1BaDQJEFX3dXI2/CuY6jDgjMSvAnmm/+n2i3u0nyLTBDWkydJb4lGRhSuthS9qoU3TsiLpMEDgss4nlCz/frG+1c+HZ5RiMiuoUEe/NI4qZcSq4B8C3JCLMm1322FM0u4U/yhadMDSz+iWltCgA9lPK3agS8AuUOWng7dFMhpeSIH/guYMByJ6OtNfE+A178X0ypWOHoMc6VOqJjk1/3SXoqJvftgrhtUYjL+75SNOrU8tp1uAYjM7ewj4pqOwyTOAticSvoL1z2z2xhAvyxG1NFWhuKgtg+2o9yqsKSIRJS9f6mtpBoF9EoFeXCG2pwbVYVvmkTTF009Yn08+J92wiff2cA9gFOit+Jg+JI3R5K0EiVZaa52ixqvuN0MxeHI7uBICgDAWt5oyfWICcPi3nhWecbdVAAPN3RLe1gsW5pqFnAS08WAAK4PBQu0kIXNrdTiw8C92TsMW+61y0"
`endif