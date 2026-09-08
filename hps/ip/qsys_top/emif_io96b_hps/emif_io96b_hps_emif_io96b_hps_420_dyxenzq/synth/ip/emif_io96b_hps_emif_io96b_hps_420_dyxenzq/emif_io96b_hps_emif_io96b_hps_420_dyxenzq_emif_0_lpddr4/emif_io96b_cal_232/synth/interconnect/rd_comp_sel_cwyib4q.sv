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
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1ql0AWb26VLwkX9vH1muwya/3Kdddtq20lR9YoPoLSCDJjP75NzhRJG/PepP79l/26r7mM9rDqN+sp6ty6Z2s4Y1C7xbwz9qBuY+st3Hg9bgdC7Qx6WpRNQrD4D51X0/f2n+FfwkUrkmEq6WXTWIo9E5WviU9K+DZ90LD8jmVLeTNeIMFNGEHIhnSeW/hBG2eUD3FajrJNz0qz2Uu69XDLkSJUSldvJc+3Xyx0JBNZQGluS711LSWsWuBpzlYu4mecflISTXZRjeQJMRzSb7Ih7AIL8W6YiwsnIyLzC5QVQhbWWD4cMT3CLjdAbLIwVbXIqIAA2TBV6cRj7DUyQd9tZyksEn4cBDwa0zqUkLvca1tH5XmcwbZEdOI4nN0bn09i+fiwFmPtBOSvEWtMUjE7Wj8oExq3o6Gyhava0EeD13ISEjY/VcTJWMJwoO+tPm4qSoDxPLUZxHktz2CxI+aLG6pbFf+wGtUKYWIM2OArIoJKPqseRxmnzSa5pzwk1x32Xc87QLsmyWf1hcfqZSaCWjTdP72VonxFhzv7T/6xQLzzKu6ZBEku5cNxMhUO/J/9FHbhmCxW4l0tFYs4m64Ges7/c06BbItkOEhgF8S3zZIk/r8LZ/0sUXqh3nXaE/KZ1xKTwljaAE338vCosmNN1zKQ/e4RDEbBC8Sf+dmuBFAkfaTRLe0IRW6BBFwW1w/pFpl+n7yTe55ygwXzeoR8XiJPN9G+RS+1NZ2s7/Mk/lFM9zccVYJm8eS8WNr1WIOTlQLkQTovdt1ldBouGaK3O"
`endif