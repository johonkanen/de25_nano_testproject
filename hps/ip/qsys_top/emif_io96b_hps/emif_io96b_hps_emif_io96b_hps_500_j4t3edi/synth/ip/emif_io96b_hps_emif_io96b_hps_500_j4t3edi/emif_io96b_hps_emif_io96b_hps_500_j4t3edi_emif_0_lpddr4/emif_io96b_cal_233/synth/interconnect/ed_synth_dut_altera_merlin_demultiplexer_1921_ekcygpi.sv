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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW4RiNePRiHAikOENlTmNvRL8bJ2V9/IfkHBRAyeK9ug9WkQlzMkT8PnQiV4PKKPC4p9/xYipuYQC/KzZYHTduyolvqWkZpAQtiVB/isaS65qgS7a2MibA+MNnnPcCdsRUPeQjlYI9R7yQ0k309YOGTV2WQgTN/jRIeufuFAM+jyDZcD7ZN/4+dJEpSPsFE7ne8u7JSJxjvjfPTjQfKJuel6YAL8X7QbDh500DjJHmrSzPyAISpVJ1arNb3PPMN1IR3m11l5OasDMTSiNdjnsSNSm5MWacpU+rr15YCw5fy5Fq4zA4R4go6ll/qt91ZqB5MmQzKeGbXZ2Z1VOaEqd7fivHnhWAVgszyk3Ybu9EkkUe2ZYdXoq6qQsxXL6lEGToEI8j3KbPvSEanGMmkJJQilPpYM0ny5m7Yk5MMt3BXQmM22BsaiEk7i+ADcQG1F22N5ZpQ0fcrncU0H4+Ir6KMmMoe5rGGTKL5hbpGCtQSiku651d+IOOWRi1OLpm8iAUU9BAt8hA1IvByS+uIb+Cn4XKYSUkNERZiOkMqVNTrwMHQ7Cz89fDxG2Bn9CCiUCVdRLoxMk8PiZIHRJteCNrN1101aIQpoL3aN2ppGq51aP5a6/CyDEA3QEv5YqtQWWsIlS2zw6CybhG9KAkScD4eYfaLllD0eS76sxdB+L/RLOjqgivJfQwTXzSh8/lLqa1KD2JXoJE9a+lZB2hZCWLYQY5HOwTRQUURY8F7F3SwnT22WiDSlO43I+JQKN9i4u4nmtDXXZyrafJ/6ipIATUn7"
`endif