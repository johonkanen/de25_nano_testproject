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
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1o28tPxmzWWJMvsyXibcbK2GwwUp1VLK9wRSHKbKh0AY9xeRtyZl448UsTuVJSQLa4WoRpumRt+zrtYUx6KpdCoy/SKFH706hFdK0MJG448x0tqofJEoOLxdz8Fa/LD8rWFdzo3r26Hs7V4fWmuozlsmTUNuzfp6YX0TJgBCikz18yMU23Vn+whKF2Mm95rjrWRoaDST5AA34kLeDlmhS8DI+g1+0tn6ujVtUZGJ3UbdL4nrN9fK+KTStv4YMhoh0zJstKQLsI7ghg7+1hU1QATCpefsu+1tp4HuezTnlSpNLn3imsueADwf0+ql+/IHlPYIivNOdJKx25cEI+E6lpiB6QpKpslJ/kMeGvcFtBahZPKlwTFN2dVeT+kMFw7LeKZYhYPftLCH2T+qUUSSUvOlMkntS3oTBaMEVyQ363yPA2yHVA/z7UvYirPO9b8Q4NAaFl1FMijFEEXLyOl3h/s/EZFI/sapnfDSZWSEVsYLwKRTAFF9Tlwk4Sunly4elgwPOoD4iMqHhGfCJ2vpaSfzLIyiUCuH2I+irIsRC8QGzMTSkv9gEIb7FDpuwt6Tz4fcOJV14Ma3HDI7xzFnXfaw7p2XHUKtucMtZXIYvOyy/MxVsBZ4Wi+BZNHrXdGtb934UsNd4VaAMw7jbgrlexLx/pXxPdDXE9Mb68RLNclF1SYu0lB7kg/JLThpoXYD9Tf7tUqSjFlxKQs5J7LoFsSvhZIiarCma0Gq5dgd4wgy8x0lxcqaCj6fWNGzUDHh+1f86BJ0BBPO5xZJaqg+1NP"
`endif