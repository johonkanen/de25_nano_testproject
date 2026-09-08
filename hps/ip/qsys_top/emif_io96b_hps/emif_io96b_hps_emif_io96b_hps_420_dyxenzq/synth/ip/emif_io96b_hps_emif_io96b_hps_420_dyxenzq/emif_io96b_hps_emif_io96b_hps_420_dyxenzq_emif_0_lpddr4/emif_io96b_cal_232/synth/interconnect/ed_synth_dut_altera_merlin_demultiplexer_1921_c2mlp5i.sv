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
module ed_synth_dut_altera_merlin_demultiplexer_1921_c2mlp5i
(
    input  [1-1      : 0]   sink_valid,
    input  [440-1    : 0]   sink_data, 
    input  [2-1 : 0]   sink_channel, 
    input                         sink_startofpacket,
    input                         sink_endofpacket,
    output                        sink_ready,

    output reg                      src0_valid,
    output reg [440-1    : 0] src0_data, 
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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc+trayT8d3pMElwnl680DGsj4pMed5DX4y1G7KacM0k7+mSVYrVZ6ADkqMf79KmzdaJq+Gp6fjvoSEs27hc9A1iWnjW0Ac9dm5hVLaGlSNh9PqPzNxs52OEXtojITofDdPqmMLhz0oac8buKOz72MysdCAdSdmup0oBNxrr4B9zasgjVGowe6BEyLoteq9ACoGHn8xZl67yeStUu+RmJfsl+w0VfiNMo25tZjzq8eXiue7RQfodkYuwnFMMbZDhCrH7QxzI8uzVjQFf2gLV1KixvYT0SJAcZtQtJWlcPuwMI85Hoe/yH2FYiBURPYEL5Cci6jgmaqCl0G5q0QnTNOmgs69LimmmK6UmrZbhUBwkVHYCtmCPVhg8iN44ZpXo9PIE+ivEbFzrnWGx05KpkzDiflqY6xtycCCza8+84ViYgbJhq0Iy+zJzpKpG7u/P18mMWGHqGYMHMDjQX4PxSiYQnJ/I8bIqABzQKPhFdzv2mAM1edNxzEMUSLBoP3/yMNxNrk6Stk7LLkkUJA6EYvPX40c4u4h+uuEzMCxtGJtasfKzN1Ed+XEN+vmJU9bIn584q08EfG/KhyB03J9nS4+lIm/UfJRF4ZB47tBR7Qp0W8LqqqkndqNQEJKr7ANFxqXrT14nJ7eCw9Uel5QrAYHP+aM5imtY3HvhmJd1TWeiAh/kMIuYEG4pBImnKmMUTJbx4zOuu6/YhwWWzj1Api2LanMWIq0ucHbfBocgOtRP0pU5GDUQ+uztKHG2svwqG9wYGpMRjcqHblvn9vLXQi2j"
`endif