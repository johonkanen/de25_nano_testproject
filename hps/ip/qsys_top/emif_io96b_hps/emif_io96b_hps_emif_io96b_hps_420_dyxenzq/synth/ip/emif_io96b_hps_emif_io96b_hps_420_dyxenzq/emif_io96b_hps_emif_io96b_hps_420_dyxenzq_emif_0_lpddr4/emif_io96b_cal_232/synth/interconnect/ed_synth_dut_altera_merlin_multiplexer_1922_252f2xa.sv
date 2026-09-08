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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc/W7SNTffHH6368wVF5T7z8b0Rf8bQxG+LmkwiDVrHV9iCWKxB3evl/JFV/0P0gf5Mz7XMWIxlqPw3qvgSjLmhqyNfKE0mnV82W+oHOa68Lq2r4Tm7oe5IpEVjdn8zBkNwqasF6Ay5MqfPOhpQZs5hFXXKwQhG/FAv4hGYglg7F6r9H+9yKWREGwl3PVSKP8XYx6cDZNGWFS5sr7IBGgRI5JYZAHcTa1NEsi2uQoSbHXULEDHt4k+SJql4WUGsoCA08rwtyMG4GqdaKMJc/CMkSPv3SMecWmoM1orFwwtehDLUHdijqurkt2Q9s2kRd1B+1Mn31X2Mn65tIZheRW9dT9ASdMhUyPqWK+DDSTO1aKvxSq2x6mD97JVDtrcJKfzhn1QYZX/00PZKXtxLKj1ATkx8zKjI8YRPvhizIebAKEiBSK4PEEwFiN8h025qyxoUe0jU5eOGR7C1TLSu758iguF+7/9oOHGo8xtbVcayGe+Ux4wwBlJvDgdP5fDnM2+pZNJd70PbiUqb8s8hGka1wom+w3z7E69OcEc2Qc6LlTS5moTleNbILHk9eCLBwvmrF2wYLT4t/lPQlSQFhloyd5+KoaQJVClK9qbGBko9/Hocq74mhEj9Jsyvw0mKvy9zfRXmraJwiQZUVbmqSaA0NW1w77Gi5Kbt6TU0w67NeUeCpwUQFMcm0W0PuQs+F6ZFkV9Lr9adynLL/zL4LZAbSM1G5aLg/bYBaIrIN/z9mpQW4pqUjO8YG0lBiiQTHOA5QHh3pI61PpRQklLSq9NWN"
`endif