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






`timescale 1 ns / 1 ns



// altera message_off 16753
module ed_synth_dut_altera_merlin_demultiplexer_1921_rcor4va
(
    input  [1-1      : 0]   sink_valid,
    input  [124-1    : 0]   sink_data, 
    input  [2-1 : 0]   sink_channel, 
    input                         sink_startofpacket,
    input                         sink_endofpacket,
    output                        sink_ready,

    output reg                      src0_valid,
    output reg [124-1    : 0] src0_data, 
    output reg [2-1 : 0] src0_channel, 
    output reg                      src0_startofpacket,
    output reg                      src0_endofpacket,
    input                           src0_ready,


    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input clk,
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input reset

);

    localparam NUM_OUTPUTS = 1;
    wire [NUM_OUTPUTS - 1 : 0] ready_vector;

    always @* begin
        src0_data          = sink_data;
        src0_startofpacket = sink_startofpacket;
        src0_endofpacket   = sink_endofpacket;
        src0_channel       = sink_channel >> NUM_OUTPUTS;

        src0_valid         = sink_channel[0] && sink_valid;

    end

    assign ready_vector[0] = src0_ready;

    assign sink_ready = |(sink_channel & {{1{1'b0}},{ready_vector[NUM_OUTPUTS - 1 : 0]}});

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc+PAwVkQdRG3xEdi8HYjsruK4hgqScc3YfcCXoC6MFfQtbYEqYBgFY8vXQfogRlmDBpGftMWPlNqPNxVouy8fWbFJSttyG+2sjLV1RKXGY+Vf+/tPxdYcns1NVNFn9S2IKSRvFgecHGaQk0eAbPqAHkS63PRxBWDuty3lyx5yHKeenNrcILGwLT9iPPK/toJNi/jkyqDbn4NNP8KYp3AqejCxytjWHPSSlxcUo6Mpkew6iGF+vhSAdfU+Fq0ytcOB+h6wD8WR4tjCeHcr1LP6oiuLdL6orNB+lnUgTH2zLhxghLJnyFhrDrf1zX/KxVzxK7FL3ogObTHVuknjh+4amX4DsMdocop+Wb4qQzjmNLBms6sEekErb7yzyzB7t3GrpPnPbB/6G25J+AUKy4a/68sfEtQciJs7vNuJxBPgbWi5hoA4EPnlHStT5nC3VrDisWLDZUnvuTO+NPnaN8gAylEZlwedJbGQRe0bqm9l0ekZA55MQFB6RiqJj5F9t7Um5BM8/yDGdACHo6sOXOR69m58iqo+x6HRSajTNDA/kDZezgjXS54YWmla9KgyxplSGaRVNj+/hTm0M5Xxpay7SorDFwRNgiyL+noSFPpn3TjLaD278Yr0+OY3+7Y+b7GafYRfR5W1Spw01EslnDTX0c3b4zn4w3NXL0xshTXLbyDIZejDlKDUliwNaXxBVFGmserC5bEv8KBRyBM6X33PHTaTJNV3UEFFMFXoPkKnacij9W5z/swycWry/Sngq+idgq1fYG4t5479obH45FSKH4"
`endif