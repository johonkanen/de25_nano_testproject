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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc+ZaHNg3r21+nwjNgQyaWbLYl9ZsbhBac7IQ86o8Mwti6YRK7Y6I6uYhFIxJoD6DQHvt2BPmPZ42lzchdiQVIrSig3JskaxMk+0jK4s6IxW5DdzkhDESgA/IQHRMZhHVeQSBGBlZwvbPVuzAOxVTgangdqIwGxGNXWYGI13AkbObS92BMUCxRR3phM0/ExOvXsXLa9TrbQDhp1DYqnxpxYuer8Q22b26q1qZg3x8kiRqZy2VoRa73OKpG41HWIZbhjkU5qvnZFKbUM8hJzO8pfKiHpb6gaqmvgtwsjZh+jHBw+NTnxxlNDfmeHfBEhOUP3/Mck/Z6aPwFwBu9JS43OS76rMNuyx6syjGVvPNLK/kvP2oabYJ1J+5VTTcYhxgB7OlGxWcq/ukfyYZAnz5g4QBmDeCPd5y13oHBT5MwFVb4EoTOGmb2ZWJSG6nta0tXaGeUAzL5g0YayvIruRkGBL9p1kBIH+2vumdrvSHf1OenYzpQ8n4L/3boYARRG68WvYBjsJ7QQ6zkOykyXjysFa3YXNoOXfYIwV0iqMQC3mgbkTeA+HfJHJgyzrwDCIhku7ZxmaWJ1sSu09lqdEevosKbjM9ONMx3Tf1Y74d5jq+8Rk2nMAp3cVJpcfginVQbhiC78zkX6HCmawx0z/Fmd7Pu8HOeri918/h7onvoegq67AYja+dKDGSrK9HYWzEFV45S5vS3Jvs0/y4SEXILBIjRGbU/d7O6s4MfYfLEhDpxjsT5srwNb9QjpqNtj26qHvX7SNOjwTM9wxmFQKsfK+"
`endif