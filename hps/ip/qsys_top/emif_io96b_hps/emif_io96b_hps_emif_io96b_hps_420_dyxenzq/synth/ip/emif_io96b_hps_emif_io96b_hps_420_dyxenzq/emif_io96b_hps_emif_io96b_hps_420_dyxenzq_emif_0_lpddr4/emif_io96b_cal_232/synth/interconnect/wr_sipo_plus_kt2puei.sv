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

module wr_sipo_plus_kt2puei #(
    parameter DEPTH = 1, 
    parameter TOTAL_W = 35,
    parameter ID_W    =10
) (
    input clk,
    input rst,
    input in_valid,
    input [TOTAL_W-2:0] in_data, 
    output in_ready,
    input [DEPTH-1:0] clr, 
    output [DEPTH-1:0] shift_occurred, 
    output [TOTAL_W-1:0] dout0

);

logic [TOTAL_W-1:0] mem[DEPTH-1:0];




logic shift_in;



assign shift_in  = in_ready & in_valid;




always @ (posedge clk) begin
    if (shift_in)
        mem[1-1][TOTAL_W-2:0] <= in_data[TOTAL_W-2:0];

end

always @ (posedge clk) begin

    if (rst)
        mem[0][TOTAL_W-1] <= 0;
    else if (shift_in)
        mem[0][TOTAL_W-1] <= 1 & (! clr[0]);
    else if (clr[0])
        mem[0][TOTAL_W-1] <= 0;

end

assign in_ready = !(  mem[0][TOTAL_W-1]  );

assign dout0 = mem[0];

endmodule
    


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1oN0XaZGCZG/5FwVITT6UFiKlJvfqfDOCgv0vXbYZLm1TkgcmhrGtWKIQMCuQMX4UtiDjF0m4mi2ueFrlOMc81kI5YJwbVAUa+4Glb+CljMC1ojUgaZZBjkNvQwLxGUxVWpyjDxGeYrHCiRKfvpdv8q1dGVzbloSAauCmJHjrJOuE9h65p/vmU2F9O8RL+/QHFxQ24Pb5anYrU91bzEwe0H4zqrcpSSxfOnWdemIk/SNctipBm2stzMhYNckcCIkl+qCEbzdUszF2kuYUKo/PgBhwF8gzvqgzd2QY2p0CKuB/MFjpqTiOaOaP8KAOrOTUQiMbiGH8O1C1D8CeV1et8O6t9hcEFiUSqrJDqWvFoMhYr4JYHPNGezFrkq3pPNgTxa5knbwEA8tHhhkaAIxs8Tmpj0/lV4w+LBHosmBoKU6WQR49D0TOrVSWfroADJ3NU29qB4EJImAALFBodQkv8s5Syv+Ep115aPTe0pV2It0ABtE4akbFotpsDIsP0po1PZrvGnN2aqy6udE2JwgX1mkw33aTzCGGS9t3dtgepCGySikyspP+jNPVoxk9L/VleUnTKZWICzsGYucOMw/1/p6EQq71ekM0+ofBCc7FWqq6dFSJSRT6l6eY1kpXRUQ1sUGqKhVEGOP7FvkL2gYcJj0yjBjkRsZYh6SAVqQ5HGRMaan8/3Lr/TxdBe8L+igkgsMPPW9QWLJO8Yc2KB87bokTS6c51G7vRjiRTA36WzF7FIbZjwFJRXSarSXKQTDsD4D2v5dstH52TDtSeFa6TI"
`endif