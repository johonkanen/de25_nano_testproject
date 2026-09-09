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



module ed_synth_dut_altera_merlin_multiplexer_1922_7b7u3ni
(
    input                       sink0_valid,
    input [124-1   : 0]  sink0_data,
    input [2-1: 0]  sink0_channel,
    input                       sink0_startofpacket,
    input                       sink0_endofpacket,
    output                      sink0_ready,


    output reg                  src_valid,
    output [124-1    : 0] src_data,
    output [2-1 : 0] src_channel,
    output                      src_startofpacket,
    output                      src_endofpacket,
    input                       src_ready,

    input clk,
    input reset
);
    localparam PAYLOAD_W        = 124 + 2 + 2;
    localparam NUM_INPUTS       = 1;
    localparam SHARE_COUNTER_W  = 1;
    localparam PIPELINE_ARB     = 1;
    localparam ST_DATA_W        = 124;
    localparam ST_CHANNEL_W     = 2;
    localparam PKT_TRANS_LOCK   = 72;
    localparam SYNC_RESET       = 0;

    assign	src_valid			=  sink0_valid;
    assign	src_data			=  sink0_data;
    assign	src_channel			=  sink0_channel;
    assign	src_startofpacket  	        =  sink0_startofpacket;
    assign	src_endofpacket		        =  sink0_endofpacket;
    assign	sink0_ready			=  src_ready;
endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW5XrcyqjIrMwUgU1wQMz39e0tO1rtLoXgCsg3TR8AO9gI0YgHQf26nOW3n9nkehV9FikctcDBoqwkov7FgzTl5Cn//lRgXLP9fq7CkqI5i6nPHEOwBadnbHZ4E+MhRkvx7CE+cyBfHdrojjQkuJJvjT2KymsJ3yLVJUsm/o0KFhauz/uYviugz4k0WrreCmekMi2DA+AzcROyeWZPlDXBF+gvgU5hLHjL6F9FWRONuXiFcqX7tIHhP7AUNKnAUUz8phwtiYvfc9xq0JqZ/gBso10thzYtIU2jaoY45mGnKZQ13oy3sPbMNXFNWOqt4FH4lak1XBvibwNRrXfi7TCQHZz3FI1U8+XjbOdqllvLxB2tM0qo3GpEPcX67nMLnbGgiYz6BOaTUljqXYIjELzE6SzD25aZG+emGwYkjxekarApNxNhThSb/YqLQ1qQhW1OsbIb6Mh4GWjA+5Rk0z/aSThHnvh+ozYKaAxbPvoNiNlourh+IFjpy4A2fWM5sn95+TbzoDPAfZbzNrnPABs0f9LyvU5K2VfG5JzFSE60BJfJhADWbd262rk4I6GlzfdzdiXxhQDzk5CnQwp2ULgvjQDzPs3LR0ogBUK40D4jF6ML4MKkYsW97aPtdbE8vErKqbwfHkPzzBaOKXIFr6lj8ei0cX6E4jAnP4QJChheCIx+70SH4Pd6k7Ci1k3/S53aCUJ9gXqoLnlWKZOfF3TBkrOEPmMhNF+IuVGBMuqY56/YJevGxajY7l3PEx7eKj3BcndSt5gcCvX8UzMpyHIM1l"
`endif