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
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1p2e64EnGaNudgky6H/gbV/AiRgaacsDUMsshWTrazyoBnR4Hl3q2DNIkY5UbyQ0poimJmU0aZH2G3Nhl46wOFzlNuAfWg8Vt6D1VT4QZPC7nvqpOc1Sq+aAmBtDnMd5Efq4kuhYC+1wskr0VeV6Hz7/9+ALjm10tMCCiYQ8+E2DI9UFDxiqLeIPKFfjPkx1bWnY18JxqYZhN6jJ4I7pUAGP2NApB6L8jnmxYkNfCupwp8fACNCNSc8RlIF5S7Yp+LzSSUZJJAm7OIqsUNSJ2oak14EFcOaBCgrdUyBc6yfoxUey/N44T7LpbGf3+JnzbBuqpeY/kDtPuIWd1r3CP163yfOdVwEb1swc25W+wlFq9n04zER441rlt2yI4jgN8Qn+iHluLftMOxVjSo3i88XOuuCnsVCELuJRE8LI7+OJL7GQzNjxJmkbZSyI3jF7LHOwfJfV3jbdRrtbVAmHGFivkgR/PAsJ4dtVEJsNKtBX7yGJ64foymJK3vCF4qCz6cZoGJTKwOvM8jHrC4UuhDru0/sgg19xKgdwaTLvBZHzYn3A7NUAO26u/UFBVdyonGuuZCDW9knoBjNfDJYi/Rjvp0ydfHk+/Lg76eHom4K0LAow+Boy1m5A7bBcrjnZIA2YOYKyfU6o5t40dNzC+O3sKGOVPDY1V20FwCcNw+nVRpIhAyY+PZ1xSWS5DdMmTFqub+b2JaDgzHXs3LZAcWJM9FkvszcosHk3iimuNhrdM1vFxfcdiMdQ99qB5ianvpk1SgXS88GEuHy+aUA9+QU"
`endif