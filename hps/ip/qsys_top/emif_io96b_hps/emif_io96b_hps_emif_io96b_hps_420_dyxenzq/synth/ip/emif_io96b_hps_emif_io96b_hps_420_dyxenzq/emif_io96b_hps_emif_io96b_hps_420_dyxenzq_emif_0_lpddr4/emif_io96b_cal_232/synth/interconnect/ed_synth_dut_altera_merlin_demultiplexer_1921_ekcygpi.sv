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
module ed_synth_dut_altera_merlin_demultiplexer_1921_ekcygpi
(
    input  [2-1      : 0]   sink_valid,
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

    output reg                      src1_valid,
    output reg [124-1    : 0] src1_data, 
    output reg [2-1 : 0] src1_channel, 
    output reg                      src1_startofpacket,
    output reg                      src1_endofpacket,
    input                           src1_ready,


    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input clk,
    (*altera_attribute = "-name MESSAGE_DISABLE 15610" *) 
    input reset

);

    localparam NUM_OUTPUTS = 2;
    wire [NUM_OUTPUTS - 1 : 0] ready_vector;

    always @* begin
        src0_data          = sink_data;
        src0_startofpacket = sink_startofpacket;
        src0_endofpacket   = sink_endofpacket;
        src0_channel       = sink_channel >> NUM_OUTPUTS;

        src0_valid         = sink_channel[0] && sink_valid[0];

        src1_data          = sink_data;
        src1_startofpacket = sink_startofpacket;
        src1_endofpacket   = sink_endofpacket;
        src1_channel       = sink_channel >> NUM_OUTPUTS;

        src1_valid         = sink_channel[1] && sink_valid[1];

    end

    assign ready_vector[0] = src0_ready;
    assign ready_vector[1] = src1_ready;

    assign sink_ready = |(sink_channel & ready_vector);

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9i18JuWPol+nIsg1hsuYZ0Hy4/wpGqiTt9vZ9F9Hl854NYVBTcXkC75jbJo01zeZmKMxZdeq+gXVY2zuOuXc6SrHQg7xedEGEp/moaFiGDIvcjUI1os0xyBXQGV6TVa3gBrlo6pcrboBbJA0MCvF4F9GBDWIGT5SuwNE/wBZ9ycqYCoFqLixF8atyZ5jRCQgqzpkETPcWwlM0vblSHrVCV+eurEcv9OAPKV0Xa0qIHRNAoR8SGcuD3EjZtEvo5VKY0l/iGl2h+MuaxSSMV8QlhvYLZZm0ZXmAJuWYk9iqI5mAlmUsadmBcuSihratonvgvGTNzKsnYAjdHcjhtXX5g/MZ0hmOpTzki3qTXM4YhOU41V0PP6V5nT+TTFhPpITB7qNTsGetggB9WQyzdyJdOYltWcHNHFa47Ghqr1asjWvEFqOKr+i/6X+wROD03NqZ84T3I6iSfGjwiF4JOYEk5LH8Op031zZXesM7nHxkcSUWYyourdtngw3AWh6dNYkiw+CrVYAgf3pGhcwg6P0n73pX8n9aGasrNd4DvHfJEymCkGubOpFqGpLK7Qwb4tgcYN4jnTS3zF21zQ2WBNkqGMlBc8EC3kwToJfY5aKvY3FZ9GZ+p/F3GxhB7NVwpJ48jxZvTUUxwftm7cnNkrtsuXjYfuJSPjhfhX+Zpwyd59fYa/9yqcSA7A67jt6GUoETbEzZBOilDUgrnKORtfPBVjPfqPcHbQogJixlhumiav9Q1/yhmGiYees5EoZ50BzxxwXDFPtXsAdDDvGczwn9v"
`endif