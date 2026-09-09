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
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX7GcZ3sr4QHGztY9TOml47q5+IzQxP8IpiLcymkU5eQXMS4fBK65ti14oonVXHKziRp8e2WVWRU+GRyFpyzZznjIluBhOZt066rBs4FHQ49kgmIMJyh1tGUM4deEOp2UvxmFYIBVru9cGwhc2CJt43eHNXS7v1MSIuUw7p0VE7N9svjO6jzqTCdDe9xzZLpH1ySqBSeHB5WEv75VaM5bwdrIbYIyGqtr4qSkHTdYXJ8GzXohpuz+N822SznFNyEud+B9M4a+uC4oJZq8tok5T/A34JcpV2rRo34BBczf+Z+dzoM0czO/3IulhFMJhLsS1OiBOCnO0oMv553vt/FV3Q+/lDQou9kcSVIDDrFQzCbIKe5RsVU9qC6PlXVQuWn1ScCQOxj2/5raEpzaACP7uk59ukEQUZxIwrwGSPc91wgsXJRbR6lVaCAW0cb4NcAMWiujmBQDuZgv/12RxJaT6PKju7O25VYybs85KdgAi6an5eUkPz3RSL+AZRNbDc6r9x285yuA4N8b5ywAhtQtseJPsma45wDCZJ3UTKKJC34pkxBeVRTVT2YSyuKacLh6o79yt9XXlvy57smK/VjOonyJ/KISTwKbBs+OKI8ATd3J+Q9PIONJ3eEXdw46poIkrp64bG5hVChy14hQswTxen8D4bLQrtodHNV7DzWKJqjnrUihZp+SaFWpqiWMlAOLu2NPtohCef1n0Y6+S5lzPlOUbNDrSmnkERtHroxgf+oXHbcM9db0/SNDRFzLN34nFDM+tV5r65DAPf9h26pN9jT"
`endif