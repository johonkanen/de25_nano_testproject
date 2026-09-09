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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW6SZisqcgOheCa9JRvwSosJz5kuKmbUuKrhxj4W6ohGMIq7/sKnewuxwqbZujgERTQvg+UJJ1PtnRd9kJ/sYd72ADlKYa+uF3oOM71uhOpMmNJZRnjgpBt6+3l9MGafUHNNsv0KGcgqyccRgs7PqAWaOLVoCFsSz/HO1i10bZtnY3NTFT33gesB0QZIa+bZSIJjW6D7riBCUzBCu57CceUHjxJUZG/FktVloYMTjzIUvFpJp8gpEaBJvYgG2NheaneuphQj4uI0CO9TGkHxG4ZM8ySIauMu24u1WNLnj15kQr8cTf3KWoUxrhkArdI1Nb4bqn2RyC1gse0bp/vIqrey3YiLEyhD42LC5eeKOMuwpU4lcucSLaeUpa/+Lv7fz4y7JtYH2zwF0ypSmGSeOjX0JcgZV9ZeYYU+Dgjzse3gE8N6ZAt20EUE0QGie1ZYFozQeE9li6q9WB/gig/Rz5RP2Agyoxa+VxFHpqthoBwAKZmBleAns+YTxhVoSxdAefA0fNrzMU/d//rjWZfA3RFqPBJ9bWYvjLYEX6U/RGrhLJuBe0HP21mVvpjtNKAuOjJOFZFSewjlv8SmHMRBCTolsyZCzLt7et+NEcG1EQ7elue8b+cyoHbmypGu/dAfI5aapRVsxUyVupnzeN3/SJtIutjKuitqrbiptg+TICr+8NCdnQMWJmNKCQ5FDmoSzi6MmPQTRbAKczanFl9UWLGRHeeKjWfgZ8riUQqI4J9Svi+RmWohfqjK8iBJXVwC5FWH9Xt8bX94clzlYJr/DqiQ"
`endif