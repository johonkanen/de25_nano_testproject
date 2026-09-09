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
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX5oSVJoIutHvqKwCjkwtU0qXdvdNjHHrP3gPRJ28k8YUu2kZxqrW25NbUz3GZcptPNw/O+IH1m/xyDo04VeFoNeLB6FKwElagsTXD9mTUehSXy0Ga1eQYe6gAbxe1Ys05XxkWSJ9QKpbI2zGp5tsidPS8Psw+OjgSrHvJq9bdRhgJBw1GkXjQ8Vyd9XxUuDu+koM9+5qOLXNWL33dlOTZJvaCnQnc2ovmXKa+iWvsermtehkBOoE0GAc92Dkm9K+IDypsc+bLa88HxbuXbkepPkqkYHGcPIBo7FlDg+juAcRjSurBQihV+R9KFrhI4VoB2ncJg5uyz+WuiCIlAr2VTDNmJJC5aq8uH6jDyMQm2VNai+ikIiLWu+SbX5QxSqABrNMNwmFDhYTlwVuVYOsAZoVuzLmoRaVTandLcSv6xSMEYI8A7t1xDyJJeXVK937NWAo46AFt/2CqLssCBgcqBV+EArw+6PfVBMRb+fr92OiWhVMVrqX+oWaY8ZktZWQzvh1XDK8DgtnmcBRX381pogFXruIh6KYOOywhHQuhyze6MvP4ChGwoHsS92/Ha8ke+7alzaJdtnNl2PcDnGClcTTis6heZ8h+Xg39zFuRdX6hTyUM14+eNuRgI5LpiZI+a5WpVjxd91juMBDo6hAAJUOCSvCKQA36RIV/GNhJWsU0RPTbHOiDgUdvZScZiDI7vrJt56VuoDI3j9t1Bz2JVNImP2OMtjO426jizTQVMtbC94uIWuaM6pRnuh8c0Z/ssa4pPuRF5nvEQR6Qcp4IIJ"
`endif