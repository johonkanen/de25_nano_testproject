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

module rd_comp_sel_kt2puei #(
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

rd_pri_mux_kt2puei pri_mux (
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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW6R4bKUzTzPzvAll7JizfFRKLDfxD7Y+9D+8r99vPRvXCD/iqTndd/0j6XYncu4Dt/DpgU/pRFsY6ReGGlqFuqdc0kW/7jY89m0QWP2pC9wM3GTj58FbdbWJl6oxoKJ1BdY2PZY6GCJ8uiOtdnyxoKyhVnSFiH9719ByCJFT0kkJoxieRy7iEZNqioe4bohea6USInjzluOxgXekILfgHciiIncKBI8vQs24BL4+nY17bdtTPS+Bvct4Lyawj8u5dX4l7uH9yMGgCw5pOGaXttD93spx/XHmf2Ekx2J/JXG4atXxKRBCoy0nMIyMcEj0vqAlLXk9S573U5jPJlvFGIzRxVlv0In1rNIDLWgBZr3NfhrsJ6ZYXR7Us/t6hxXO19uEygJbiqjTMMnzgRPmdYTFagFBhyHrujjs7k9rnB6U92sGR6dk/B0+sNvg3zMvgHBuhnSyNK3KMTu9QAnn+eSZjCd7yneDKh5UTY0lnFqipkr3CAe35UT5shyp4QpENpc2pPTL305J3QVikvlQ4/OgxeXEE465tMkquUhyL+6u9SdS2TC/aTYD5mb5U9JQ6oIVbWuigOvqaJDdXh5uEYg+RaipQQk7zDG2h79RdUwJJKJGXOyMJI6zkcwbruY9w5q4eaRlPGfo3LX4sfx7A4ApBM8NT4+jZQPgGiWOjKhjj3rdVrBvb/BphxDZduvdQNkERp1H69utSnLheLAuhFhbCuPmuYnF10fzIj7oJBzqITE+bProgd8/tA/JL6pyx5/LhDFXcnN4uruGdYffHIQ"
`endif