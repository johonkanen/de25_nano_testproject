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

module wr_comp_sel_kt2puei #(
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

wr_pri_mux_kt2puei pri_mux (
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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW5JJdyTwvoBsnNTYfZRW0d+aMgSz11h4XHPw68xnu+eLm8TntfSal0amn/rELWLo0SDcfyKxA6Lletpd7p0KBHxdkJrgb2+k41W11JGzmnvmzDwtvAWrcGrnxlXTg5oEVAvuTN4LPrG212MOlnYZ8SmRdfED+bulKlhI99188x+kj8KSYmmPQGvjqVvzoER0yJ7L4ztlluNoY5gaTLmZhMp1E0ii3WwKAbdJLdUOlpDU4r5ItwAPqLtd3dDuK9WU3Igw9iHkCCYE+du/sAVfpJAueHiS3xtIxlZ7fRQZgUVzqi1+TtulXHgZ1nmqksFbbqtJegNuZs1rMRmTTOx9v4NeCbXREFFTxKl3r7lmJvYzvJ35mDDVxIc100aSno5T75mOMShUHFoLVTWHyMYbn15O5Zyht+WDn2f1uA4gyNGX28mBcWFz7XZ+U1k8UUwaxU+ITAdrsGErMZX0Pzs3S+Emd0o4PB9CZT/rhdJo1puhl4f6KUU//Y279H+gcN+ZgZD2eqHGsRw00PG9EncftNTuQMqEGvFwOLKfuVTaTV4vmxsPnBGN6Ckpq19IKjMTpmbPCKGjzxCVI9PeMiW66UZNHGNPo6FHtO9l2LCl0wsRmzq4/j+SZFqLJMxKYIQDqUIX7gGfH8tOh1XXnsFqgvXSeEWhFqJJuuY6MIQe6VMC3BeT+/0oRJVV5NmGORx1T19atFuuT3NS3vdjSRDpCrPY9QKKG7t9BxOZWqhAOJ14bZvdu10MUb9kYli+KNVtZDf2+U3m0Q4x5hdjiGT+TKn"
`endif