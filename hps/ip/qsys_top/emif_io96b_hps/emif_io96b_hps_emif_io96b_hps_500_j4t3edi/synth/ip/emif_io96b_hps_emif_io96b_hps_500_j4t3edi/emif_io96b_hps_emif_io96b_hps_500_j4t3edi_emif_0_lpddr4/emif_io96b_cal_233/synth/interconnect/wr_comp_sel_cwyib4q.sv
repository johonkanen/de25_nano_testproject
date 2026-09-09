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

module wr_comp_sel_cwyib4q #(
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

wr_pri_mux_cwyib4q pri_mux (
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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW6AvZ+MHHeEJpiEuDunS4RMAfNGmf2RRwudkylsGjbBUMR+shR2nXh0cEJKuORwxxTGAn1dktzTMoPZvBY/pmkuldEl+YpqDnFZ6edMLpyPQ3BIXSlpNDFIBGl6muHhO3y0PX5jDyGKXaY7c5gOv8lL5wQy2lmAj+RKkVyE0HdVHvy3t7m87xBZ/egc+CfB/boLhPIS8Bas9jGMQmLP7lj3EAat5IEKGF3BMXA5Obvj4ytYCaqAHXhADGYPhBBj3hmjMUOOkL13fdoiQ9HWbD/TWZg9zFFRYBzx+fO3s5b/oauMO+582rxjabWvvVe7b7td7TziPhI/ocWaFyTNDQDhcj9DYtP1cnxc2FIFnvbGxNPgR6GweFJZTW6OP5gHjrEQRfzyiM7yE0ZWWp2aXjvuh15c3cCZt75kX1usG8xOeceCEdLNu2SjTlxXN5KHKBMzVfeMj9gF9wP1Tb9T5h6RqHogFz+bA+Bp09NdGq+tLJSpwh9/7GK7oWM3YQc0pe+EE47akShEX6PbOscqnar7vQfeOivta33Koq1io5ULBhsoPqyHmN41d7/ou/PlwOGRqsNNqOnKGHCQVW5uoOBSs5iu1xynDjaGrqRZ4gD+LTCM4/O4RV5ivaeAh1OF+/oqxbiti/EtJhETbsBTJA6C5HeQSQ1NfKeYT6FwLRFqAc1F4HP6dbtG76DkikbOiL+caX0q77f3MpBvqhLME8KxlbJ9aaYbsBbGripQxaM32ffb5nDmEhTI/d+PUJ1iQAa2rkg5TT5cyolgVG+7KihV"
`endif