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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW4iG1/NSuqkSyzwW9SLxZ9ASp95tUPyVDryEOzVjlzk8XAQrj8zOkAI/1p5C/EW4KTkWhoj2FTdpwgnR31Jr9D+QXsd6EQpEp+zAK704dxnb01T80MKa8IUNCS5Y28XFBpC7HhBp1GSBepAwCvovrk/qiIiaW2ilylwR7ARhJEHvCdNByq4WlBSVVL5jdK7py3rQdLblUrU6NKDJQ225iMrYW2cqJGeQHa9rhZGbf7WY/YFuux51dSj7wxzhs6OXt7q73aUNr/O61NzUE+8SvcRUixaZFsnVyiRPgIHvoHTnoBPuCmwyvUKULnb/ADObGRhRqVlCSF47KRYzlQ0xQDkFXuQpc8heZuyQMY/sfTAAeKzj9IDQ5Rb7hQ4ZR5XPorS1M4xUrHjyGvfKVtBMYEcgNmO0EazJYYDRwq0Iqj59jTqh8L2vfnAG65aRoP2k08QqSc1LbGo/IN/+ltyV7qun6Anec0XXSO5BdTptb7prHydCkLr9oCQmex8KHlUUQcWhbAMp9jPPRnC9BCfAO+NlmdjUnm1FBKoJoYa1SuNzrCjMaiNeqwm8BvZ3VuPrHtNprZdrteTpp9Bq3narctA/mqNDMBjLLXyLtS01LK8PTmorrl3KggbodjUqtUXceehRF3myzpYEH4EFn/JiWHzILEP123rtUwzmemiy0EfEFadTw/daZyZKsL/EADui0ZBfjPzYfuPp22ZxvnAkFEi8HotaFPYp4I16VCdO/LJlSi6cto3dsYfBDvxEvLWIxth0g82Saavx+CcRWAiZ25s"
`endif