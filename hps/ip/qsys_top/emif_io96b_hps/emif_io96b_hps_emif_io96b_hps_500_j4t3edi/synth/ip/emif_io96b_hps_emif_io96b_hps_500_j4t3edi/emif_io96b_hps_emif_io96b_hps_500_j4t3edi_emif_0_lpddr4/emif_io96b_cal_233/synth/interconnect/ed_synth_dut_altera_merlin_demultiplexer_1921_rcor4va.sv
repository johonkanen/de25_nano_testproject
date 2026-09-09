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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW4n+xu5cQU5APtivFMqax5TJZB3lLvTzZkJnmmBWDLeQe7euhGJErn4EEMnqrlyvxppMLBIJ68IXjQUAJNJvaG8f9wQEvYeEcKTHPldb39NnCHbUPYKGl5nUflKSfDza7PHJd5tiA3K3G5HcitH+quI+isfxRLa9axCpo7lxRtj2iEqja1jwHoKTzA2zIzKa31W9W549oj5F22SPj6cxTVf93TRIKVwJMR3ST/k0oEesdrTDVtcZY9MM91xf4KhNw/sfpkWgpOpZlE4JfhyrKtxtMKRhXcgF+Rzw46ZWuGGmx9e8KXHLByPjNE5u60guXYHxpv/zCk3Wx2GYMr75Dw4MHzxSYP3cCrWv8zJdt0Xx/Nz7X2IgTaENVXspUu+FRLtioTQfFxw06iudgD0YecF58Es/NJBlR5KVjScO9NK1YXYmG6MqtdqPY5RIpCQqEiPSHpcUobZ45x6ttct35t+kxnzoJqzM78qIBE4W3+aa3zFl27jsJTfHbI6uzkseiKaQdC46iLtGmQ5QTby7hl4zhcXDagm90sM2pGeailIOq4x2fy/M94O/Hz7uTzZJvD2BQ+y0kqiUCHG0Cw+el/ZkVMlZf7KX5ilpDcNZIEHoFucSRHiI5idezffI1Luc6QE5npkoe8yzQkQjoeKR2FDgWpp8UbRHsU1h2e4Xyzb7Gr2xWzyH8dU/ZOP87kV0wCAkmjB1uWLCHO4t0oRkfZZuIJ12lCxmfWqxm2BbQ1HtPlgrlximlMcIhUrbz43TMco1ak7MCDYP8xiSgIJxTjR"
`endif