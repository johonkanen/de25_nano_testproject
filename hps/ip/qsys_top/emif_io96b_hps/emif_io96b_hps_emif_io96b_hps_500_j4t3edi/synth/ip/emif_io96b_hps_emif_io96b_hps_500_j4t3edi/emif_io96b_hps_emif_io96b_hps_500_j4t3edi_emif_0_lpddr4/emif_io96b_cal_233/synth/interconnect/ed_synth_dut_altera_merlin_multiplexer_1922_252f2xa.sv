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



module ed_synth_dut_altera_merlin_multiplexer_1922_252f2xa
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
    localparam PIPELINE_ARB     = 0;
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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW4iKP/RO76nbKSzSpDHagsmlxM04nZTuu7+K7JbMoAGFPBySTLJMDwsZLVgt0NFyyPAac66M19BDko0mR5Kw+Of2PyN9u3zaQT8bNQR7i7XPbwrJqCLfg+UGbM0axEM3xYsFUkyhB64DyMsWbgZaEJVr9dAeoWwwsoGfMh1wM79gjj7jcAGwrGJQQo+qcdi69MUMlz7aEhoWczE4/Vw8CXmotWarMmco3kG9eX4eJu/qR5V4OozMjeM3CApSutp2OMGa0xcVE5RcnpTOmlBcF5lQpHJ1Y7wpBnRmAKHDdjnNXY9KjJfd6cRW4KiSdTnefV90Xqs0I1Xzh1dzPt/CcGFdbQgTXh8PeS/WG0N0YbtKjDo3P/cJ8YOIOO9wEnfToEq1q6l9htjyVQ6WT2p0pKs2jZ+Si0kGaHDufsAjkhVXrSeZD9uoMxL9Ec2HNwW5CEE0+FvLkazho/RmWlwnoKK5KnmmzC3f1zG0wm3IZF9PQ8Tj0gZADIUxfcaC6xjYcfViXeAAQkh+aF+QrM0F9PkNGmV39fl5GFm4SKWDZvDVOa3Tj1ajpvb74i2utWIK/12YrQWIJXdIo0gtGPPebsH5LA8S7nc0ybWTVOUgO3jDnBujYWW2B5+4nw/l/uGhONkIZBs9wpmIq5QrdRFpPp0SSiU+Q3TAQ7LgVVJZqPGO9/qriS4dS2ufAjxjEIHVTtMEdAtngbE1cZRvpz2aUrdBypFl6mwxcqkejUwVFb41uunkYOJlkB1si+gkHB0782zO23tA2Py4oc2GQn0F3Bj"
`endif