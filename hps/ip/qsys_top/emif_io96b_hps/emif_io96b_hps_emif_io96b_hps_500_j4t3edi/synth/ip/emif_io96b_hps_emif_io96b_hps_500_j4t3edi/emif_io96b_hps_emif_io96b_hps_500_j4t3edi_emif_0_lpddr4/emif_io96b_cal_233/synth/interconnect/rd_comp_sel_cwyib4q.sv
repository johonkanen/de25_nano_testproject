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




`timescale 1ps/1ps

module rd_comp_sel_cwyib4q #(
    parameter WIDTH=10,
    parameter PIPELINE_OUT=0,
    parameter PIPELINE_CMP=0
) (
    input           clk,
input [WIDTH:0] in_0, 

    input [WIDTH-1:0] base,
    input [1-1:0] shift_occurred, 
    input [1-1:0] clr,    
    output logic sel,
    output logic [1-1:0] sel_index
);
logic [1-1:0] equal,equal_reg;
logic sel_int;
logic [1-1:0] sel_index_int;
logic [1-1:0] shift_occurred_reg;


compare_eq #( .WIDTH (WIDTH) ) com0 ( .in_a(in_0[WIDTH-1:0]), .in_b(base), .equal(equal[0]) );



generate 
    if (PIPELINE_CMP) begin : PIPELINE_CMP_OUT
        always @ (posedge clk) begin
            equal_reg <= equal;
            shift_occurred_reg <= shift_occurred;
        end
    end
    else begin : NO_PIPELINE_CMP_OUT
        assign equal_reg = equal;
        assign shift_occurred_reg = shift_occurred;
    end
endgenerate

rd_pri_mux_cwyib4q pri_mux (
.in0             (equal_reg[0] && in_0[WIDTH]),

    .shift_index_out (shift_occurred_reg),
    .sel             (sel_int),
    .sel_index       (sel_index_int),
    .clr             (clr)

);

generate
    if (PIPELINE_OUT) begin
        always @ (posedge clk) begin
            sel       <= sel_int;
            sel_index <= sel_index_int;
        end
    end
    else begin
        assign sel = sel_int;
        assign sel_index = sel_index_int;
    end
endgenerate 
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW7W8QWYDlwk4ymUnbmB9Vrl/WEjLi0uwt8fhGIZNjon+uu9m8Pax+CSpkVEakpPyTFHrPJUr4YSl70uP8cgYwSWtl1pg1mClJpk6rLFMcIW1mTKi/h6sYm9pK4XrDwbltompYhriVV74Da9CRQV92Fvt6On3ps08ncWswKchWv9PqouMXLCQ3Xpf+lrFN600UCyMFb0IIFSTmqcEeNVTlCKLtdjEdCP0/vPGK7AlQPeVCB3LQtlvE7ThYo1UlKuTMGAOSkGtCxast4mkZl2Zqo9OgK4iPQNtYVFI+y1eJ0vRIdrKouGJvgMmZ//5qB1w9MJ6ISHjnKmAlgCP0DGzeKGyXiTsjPcy6gwkTvUPudAYmEVOm6NSTIQNUzjXzqhl2v4OD+uFIRe3nkBqEeXXk5YIQ+rgQTD4R0PBo570orDh9Os/VtEPSe9N8SpsaFuxP/A1Wp8/l9rQeaIgD7LyK9lqAWRzpcyOw/IlUviKqw4Sj/nAA0p8i+EQM5vXOr5iUsnfe+btKWrmYmLwtTwU2LBD8cu3IbvyOLgDS6uLJsYmlUqdeQ65rolFHu+gq7LiJ3fY7rO4g1Xxxr2hIPT9jC+o/ZTKbPcELeErtjmFTpMmcOt6B8m7rKfDruwWwKzAJVoj9L5L/sGTHhyquDOP6kchhScLWO90eOCqydWDzhntmm+8yXjK4mAd7EJU/EEkk0mAC45CEVDv2lnxngz/eUp1CJ8wPXZxanHmRSj3h4r98tFZL3zZa6eP7hKAa411DurlgcQ7yLGU38T1AM2hj7T"
`endif