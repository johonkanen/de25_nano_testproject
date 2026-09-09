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








// altera message_off 13448

`timescale 1 ns / 1 ns



module ed_synth_dut_altera_merlin_multiplexer_1922_jy53pgi
(
    input                       sink0_valid,
    input [440-1   : 0]  sink0_data,
    input [2-1: 0]  sink0_channel,
    input                       sink0_startofpacket,
    input                       sink0_endofpacket,
    output                      sink0_ready,


    output reg                  src_valid,
    output [440-1    : 0] src_data,
    output [2-1 : 0] src_channel,
    output                      src_startofpacket,
    output                      src_endofpacket,
    input                       src_ready,

    input clk,
    input reset
);
    localparam PAYLOAD_W        = 440 + 2 + 2;
    localparam NUM_INPUTS       = 1;
    localparam SHARE_COUNTER_W  = 1;
    localparam PIPELINE_ARB     = 1;
    localparam ST_DATA_W        = 440;
    localparam ST_CHANNEL_W     = 2;
    localparam PKT_TRANS_LOCK   = 324;
    localparam SYNC_RESET       = 0;

    assign	src_valid			=  sink0_valid;
    assign	src_data			=  sink0_data;
    assign	src_channel			=  sink0_channel;
    assign	src_startofpacket  	        =  sink0_startofpacket;
    assign	src_endofpacket		        =  sink0_endofpacket;
    assign	sink0_ready			=  src_ready;
endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW451TeZgeu5MEjjX2dSWhLuOX/U2GFdAs6og3j2NwVeb8xTeUlx5McTch5p63oiq1yJzB92vs+kg0kANSCbIvoGNiI2A+ciMUmTQNvjm35GapF2HNF6wnalxydyCC4b1sidDnuUQ4aGeCIQaIbrHL3kLn8iqoWvAiMIVtEj/JkPzqvEnX7gt30ChfurbJmPNhyJLTIYaxjj8Zw5zPqg4GJoTOdvlXDdLc0n3zVOTUNoL8oE4de0RutOeKqMH17M0FnourIFub+STcrSJWekgC6DkmLkciE3aZW1GMYqyz3+fUSGa/KqqMJELG+gbF96O0WqbhVp2O0T+kAcGW6+oYJRnSFq5TYggBpyJieZsqtYhh3R7PO9rWcvG4im4juaqG2IE8NLZ4e+4AtwlGsvWj6pyhqjXAUF06TXcumYMwNrCJq2uUH5DDoxBjPuTKkVsjcyhPmQF1HYi8C9lFM7mKSt1MmAcY/faPJL+uhStkwKnLi0e+GCKM3FGb/gbYfr5fa+51Ls908KOmsEKblofJNYtNmabYxqV4nZQ+Djm1tsf5PSZviGzfIPv5x5oZyzSxxagacH6aa1/0Ft1JcWztCT49LLYW9UMpe8XYqSVNUti9+By9K2HAtWGjL1nfIqj72lntG+0364SrcJGxYxDteNpBZR6ioAcF61/CwzdEbc7CjKlyFHRzKyYAgKjT1wHEmg2NuvCzu1IwRt5XPKlX42mhORFHVhO/6+NxTi8SpR2Yon4ddxHxv7qOZlJR62pIb6ApazJ8ZbABMRuUWSuGPQ"
`endif