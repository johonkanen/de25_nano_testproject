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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc+FYcUwYthreGoiHlN5WGUudc9HqLogRLx0XsQDZ2er6D8vwT7TVkIdvsO3eaTOb5OFEdm20haZnkdbosROg3xGs0D+F2iRVAwI/a4dA+6RGIpDJ/z3IHA5+ouRsXa2OarOHsXp3i494H1bwF9HZ5WV1ch4DyIMLFhE3kUca/RdVtkpsktPnjwigwih02oDUAaqonEG+iS5a2nfuZ+t2mGQVuYl61KEI3V1mqRJO76QLXkaf9thftFV7Cxm0xVGA6t4ILHW/6d6/EIyqDRpM1sda/I2L+YSBpKs6sPkJa03V0JeT34OZUMz/SYZk7CectRbWy+72kqvtg81gKVtXhvHrciOd4syZf/b3hW0rZp4Ulh4gOPL2WGBSXTb7mI9un/lTPlbIo0wayZDubw5OnEDhe6vmxqb34coTidgPieOLxk7H626epZIjGgGCAWtVpbjgyO50H6J2FTXwIsTVP93JkBoDeJia8X9wfaA9a2StMag2U0eJIt8LvotRW0o3rVcrx51WORoq5XblF9vHXdLfa7hExwyNLi9RZ0uESYyPsHfCufJtwlqiW63xSgCWQP9avx7G/Pj413oNIO67d8ss/phytl1ZTszrcMuKCRrlmmjXlc91GwsWhJVFC91M1valzA8e3KzKC0HUthr+WF86bAI9zv5Hnt+UynIp1czYCH6jlZVRdciqsOJ0SnfUelutJgVz2DljNeQIKNg1+tIknJY+ckky+UZBVXfXJvIRvKOPwd7f5aXlSAZIvByES09ey3ouGiEp9ipPPS1p4KX"
`endif