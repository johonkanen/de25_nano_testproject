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
module ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_sc_fifo_1971_o34766q #(
		parameter SYMBOLS_PER_BEAT    = 1,
		parameter BITS_PER_SYMBOL     = 125,
		parameter FIFO_DEPTH          = 1,
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
		input  wire         clk,       
		input  wire         reset,     
		input  wire [124:0] in_data,   
		input  wire         in_valid,  
		output wire         in_ready,  
		output wire [124:0] out_data,  
		output wire         out_valid, 
		input  wire         out_ready  
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
	) my_altera_avalon_sc_fifo_wr (
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
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX6gA+H/Zxxaw3nGUIWUE5SIVrkviZPKG3QfIz/146Dnff5gmwpLa+nLf0Fa8KOmei+kYMfeQsUNS+e49TwZwUG1vRK5f1ziEckkDJnqcNuU9MJ8PVcW/tTGnYgP1kJNsX7251X5UlsTMTs0Sgxn1IIQNzmcekHUkQuQu1xQvJRZpXaNEfMNWE9rHIdoM3boBtVz67RbRV9qtDGaSCEsMwWcmi0GDtfg2qSq7JkpKwyxk6zyA19fnfLiKL3UMXD+vw7B5DA92vihFcIUOo1kR3umV8QwCQUuAt+d98uX3+/tx+CMjSqKhsHAnN081SBUPmW7H8cvjAgYkCjk/AK5UxXJAH6RNiFRENL/aYCEW2p/y+RRWeGHd7zreJ3Z1vl08q2ORuEdkTWsVoXSzpqep5/UaJyKoZ/pYtkgQFg1v/EyJT2WpwVGGNhqxu5XLUPBC74vvSSBUWoDGfULYRAQgJ/fR73A5MMMpqvSQUvnmyH4olObh/9vK4G8cIVlsgdYt6u2RZS7tgF8laKLTFnCO8I2ot/exXP/oCF13/3ply3GPiy6A7I+oyFHA4Mt7ny/DRlQQTeyAOfdX5lb3Kz7A++dmxrG63lz4+gN9o0tZh7HnjZrOM79lfprf5cR6DC7OfiaTkWSUK+C0R2I23z3d4dAmYdi3i21exXhmG4H1K6kdgV705OLcA+GiS9GEDk847P7XVWN86q74R973q7XrGot6OQoFI4WZDuaS15i0xz4qrJX/eww3AljTuAZXDL5O5SXg5jL/d9Wosw5dSMYm8ho"
`endif