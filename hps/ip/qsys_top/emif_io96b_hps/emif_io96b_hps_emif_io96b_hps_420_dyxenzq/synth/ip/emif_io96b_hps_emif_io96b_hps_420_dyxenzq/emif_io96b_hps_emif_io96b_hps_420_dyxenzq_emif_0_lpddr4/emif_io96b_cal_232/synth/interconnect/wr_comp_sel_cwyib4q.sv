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
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1oYIece43kb5S+D1dZgM0yCkMmG7UDubxoZUseza+ODUSkf75EuZ47kgNiez8I6/57xp/1ZwVESYCw8ulUjRb+fYoMr5lp/GxSdl+DAu2Jsw5Ujip+tAXXmzThNvCF8RuAxwqIz/FHoAfnG8BjW+wskoRIF8bJX77LAVsRXoOU88oDnQymitpDohWnwjSmMgUxTBz2Gad+9qNXyUaPKh4/YJ0/1Jt7Bv4jOxWNwYmq4lcJDD0le+tbKiY/snBcdnokThXIatWAiUvEsDsfqJOqGGW75tqjYFJaFSG/ACM8nHqUHGsS2yEVcNC2Fux8n6nrLZZzLFal2xErbhBTmVptUOjmY+mnlAm8ggXjc81byXHUdqmriXrm4VeoNmLixqjqxxrkFQVRKERzsLLF4Bu1fgLJx9oH3IhOxRhO+EAIZDjsWoNTqKd2g8I7Pm9jLI9K46x6fu/ZsQnqScxEEPUrFlU+JOAgj75HdYhFOOkr+JXOeD1p+navmf8MGTA7VwHOtG+ffyvyieggk4fTShGKPteVSToqzM/CspZ038SdauOzix290zfMWvY0TOIkB4CJLfnklDQ7nJI4+Wff5J0DKyGHvV4wtzGN7z5AneqJec9IWdUK6VCfpDnLRqLNmHC7fM6LMWJDGWIeWyMHSCmILKhHgJLYMoOGAW6r6+8BxKfCVuvT8C1E5R+56IszS/443cg79DLnbllqiq8MihrFN7TtUJvgKTipJY7Fg62J2jA/q7MQBHTttcagpMjWdO/JU40T3fO79R+iy7pM+CVSJ"
`endif