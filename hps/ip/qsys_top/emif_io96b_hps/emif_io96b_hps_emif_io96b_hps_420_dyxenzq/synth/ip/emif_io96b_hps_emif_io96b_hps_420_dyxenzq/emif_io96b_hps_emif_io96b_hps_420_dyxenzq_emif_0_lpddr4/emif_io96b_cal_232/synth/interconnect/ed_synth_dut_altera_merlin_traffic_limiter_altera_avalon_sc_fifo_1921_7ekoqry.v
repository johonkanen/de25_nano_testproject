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
module ed_synth_dut_altera_merlin_traffic_limiter_altera_avalon_sc_fifo_1921_7ekoqry #(
		parameter SYMBOLS_PER_BEAT    = 1,
		parameter BITS_PER_SYMBOL     = 4,
		parameter FIFO_DEPTH          = 6,
		parameter CHANNEL_WIDTH       = 0,
		parameter ERROR_WIDTH         = 0,
		parameter USE_PACKETS         = 0,
		parameter USE_FILL_LEVEL      = 0,
		parameter EMPTY_LATENCY       = 1,
		parameter USE_MEMORY_BLOCKS   = 0,
		parameter USE_STORE_FORWARD   = 0,
		parameter USE_ALMOST_FULL_IF  = 0,
		parameter USE_ALMOST_EMPTY_IF = 0,
		parameter EMPTY_WIDTH         = 1,
		parameter SYNC_RESET          = 0
	) (
		input  wire       clk,       
		input  wire       reset,     
		input  wire [3:0] in_data,   
		input  wire       in_valid,  
		output wire       in_ready,  
		output wire [3:0] out_data,  
		output wire       out_valid, 
		input  wire       out_ready  
	);

	generate
		if (EMPTY_WIDTH != 1)
		begin
		// synthesis translate_off
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
		//  synthesis translate_on
			instantiated_with_wrong_parameters_error_see_comment_above
					empty_width_check ( .error(1'b1) );
		end
		if (SYNC_RESET != 0)
		begin
		//  synthesis translate_off
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
		//  synthesis translate_on
			instantiated_with_wrong_parameters_error_see_comment_above
					sync_reset_check ( .error(1'b1) );
		end
	endgenerate

	ed_synth_dut_altera_avalon_sc_fifo_1931_fzgstwy #(
		.SYMBOLS_PER_BEAT    (SYMBOLS_PER_BEAT),
		.BITS_PER_SYMBOL     (BITS_PER_SYMBOL),
		.FIFO_DEPTH          (FIFO_DEPTH),
		.CHANNEL_WIDTH       (CHANNEL_WIDTH),
		.ERROR_WIDTH         (ERROR_WIDTH),
		.USE_PACKETS         (USE_PACKETS),
		.USE_FILL_LEVEL      (USE_FILL_LEVEL),
		.EMPTY_LATENCY       (EMPTY_LATENCY),
		.USE_MEMORY_BLOCKS   (USE_MEMORY_BLOCKS),
		.USE_STORE_FORWARD   (USE_STORE_FORWARD),
		.USE_ALMOST_FULL_IF  (USE_ALMOST_FULL_IF),
		.USE_ALMOST_EMPTY_IF (USE_ALMOST_EMPTY_IF),
		.EMPTY_WIDTH         (1),
		.SYNC_RESET          (0)
	) my_altera_avalon_sc_fifo_dest_id_fifo (
		.clk               (clk),                                  
		.reset             (reset),                                
		.in_data           (in_data),                              
		.in_valid          (in_valid),                             
		.in_ready          (in_ready),                             
		.out_data          (out_data),                             
		.out_valid         (out_valid),                            
		.out_ready         (out_ready),                            
		.csr_address       (2'b00),                                
		.csr_read          (1'b0),                                 
		.csr_write         (1'b0),                                 
		.csr_readdata      (),                                     
		.csr_writedata     (32'b00000000000000000000000000000000), 
		.almost_full_data  (),                                     
		.almost_empty_data (),                                     
		.in_startofpacket  (1'b0),                                 
		.in_endofpacket    (1'b0),                                 
		.out_startofpacket (),                                     
		.out_endofpacket   (),                                     
		.in_empty          (1'b0),                                 
		.out_empty         (),                                     
		.in_error          (1'b0),                                 
		.out_error         (),                                     
		.in_channel        (1'b0),                                 
		.out_channel       ()                                      
	);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc8NYsbJVFV0oSCN/SuzTS9Pyqf3P3cGhfglvVEledaGE7gjw+mYJ/yqY1I1knNVDd3ULt9OftGC6VnhgfAXpDvGxGTEA4zXkQpXySLqCXoBVOjKNVHlybsR7BZSP0ZMSMj7ZgrXq3MP6MPvVnX2BhO2vjrf01eSsPHcZDXmLs74BuP4y0p2CoNRi5NBT/PRLNOYzC0S3uco33dKnIuqX3tpXvW/K+VfDki9ZBkgQ8Az1ngc2Wg9s5f3ReM8XAiIZiJFiYC2I9ubX8n6Ahf0NSpRhy0fKpFWSO9u0oOWIl5LW/uq+zL3/UBpgJ8ns4EFf45KdsESAaSBsj4ET9ehs0MwfqAe9Scisq54GhiuyVYX/ZdGgzpWjNYSHcOGYeLeVsI4uhontbGa/kJk3Hy6Ei72Mwi1ZrEbswDcwzcKvFwM80aGq6EkEGO23b5BCoKTq7uqIjYroy1jOUltN+/EdqzNhgaGNP+synazwXcvDEP1a+lhW22RiDIUJasQZ55lxrsD1jKWxwbNoGnAtfKd6Z/coAg7pDNDTTVD7GDnXuHvsd4/ecrhU4eTRt3BihIcTrDElXP1vfEEKjHMJa4pH9uegFFqwteEw9LokGWJzFYsRE4oML+Fui0jnrHpXKevWhVZES2YgkYlp9Bm7x2FtfF8BYa6xeDAqzrB6YcBLoVkifUu3ApguBJ2USbCtZsbM0rA2yDoTDZt0Jsv2GM6UTkYp1I1SEL4wOxagyNY5FVG6FLBP2aQbMyIV25y6AlxHYQIQNVJUhdSdSpVmG5jKZPu"
`endif