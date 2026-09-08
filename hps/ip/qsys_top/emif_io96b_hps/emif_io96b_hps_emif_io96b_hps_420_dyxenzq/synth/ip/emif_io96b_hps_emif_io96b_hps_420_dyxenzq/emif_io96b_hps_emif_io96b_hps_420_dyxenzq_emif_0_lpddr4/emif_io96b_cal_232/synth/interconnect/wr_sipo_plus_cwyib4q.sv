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

module wr_sipo_plus_cwyib4q #(
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
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1qBdQO5im4Ah3vuC25x3YE1KozKOFSmtYFdUohKICyusv13oK9dyNzeOzgB4Nio4jv6f/r3aNWVRpwNrTdOsE4JCo+uxy/lf9SlXAp6zhO+Splfvy1jWXOtZokH+I9sWNqoFPb9PzwTzzdi0szzusTSYLTFkITme3/brcOyUMH9EKzAXCuQySSPTGMd6MUwW+fCAQ6Fn7p/Sk3G+nJlWPbmPEfbgfHCqkdC26assanmymUUAJWnRY0l+tPSQIWCpWHm6KuPaEKsYF3t1hOZyxJ25Cr8Yn7iAkyWQC3BQROG92m+GHQY2OP+++nwMgA9KVRtAMshcnvq++DBhsBiZbe/PoIQKA+1KHAig+MVS1PAMuQTpxM5Pvmk7PA8A7DmqznyNij/E/nH3IQ/vEFWohAAoI7Wq4MJ1UukAhcaMNyTQWTY9jNqqoRra7Qk+lIzpkAMPeZAaMLeKailxOWi2TyDqtxLGixtnyukJTEKM/Ra/op0gNjWo1/h52xAwcSirDrpNM6W1Mo4jPCb0OyemdSGCJOAngCVdVZtbOmv21+8IrAhdNn7vpNgXt9RmZXwq0inZ4xMjx6CCwt3zc2BYgQkWCiIQAbdRw9vd2dYWoDgj2klr26gWGqN7HR3zWOvb1LMujUvLIBc0yNTDz/ZjX+fqDStuACGrxzQIU9uPDoOENOGroDISFgJZ0p5ZzHPua5EwXvcxvbppUKVHmAh4FhdUdy38dv2j7gwvqOJyULxh4foAvLAgage8KmfjQ9fKlq30BRqqr/sU+nQJMHVhvvM"
`endif