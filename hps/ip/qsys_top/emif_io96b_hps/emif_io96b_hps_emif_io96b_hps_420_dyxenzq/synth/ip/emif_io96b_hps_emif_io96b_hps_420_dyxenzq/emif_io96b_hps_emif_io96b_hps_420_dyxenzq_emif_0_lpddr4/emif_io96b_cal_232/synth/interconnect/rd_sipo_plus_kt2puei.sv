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

module rd_sipo_plus_kt2puei #(
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
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1qIc3oxOpDeaHzNk+lvZIukMEGHylArCMUNqe0dIS0bn73ckkHYpj0dStLEFXJed5jEbQj9ulKT8R6GW88xhudLrrXT6qereBzx3wm6hnyGSoLNNto7xW3C7YIKDMuLFJbBqATUSTdCF12cJHZU6kb/m1kZNbgmkgdlN0aNh5w1J8vOlu6pnC2ct5mO6Ez7WPwRCN9wN9XkDBlpyyquUSMDZ5Q13jxkTUkeT2lfFi1iS7MC0raUhsyuBykywopieBPxANRlp+aA/MSWh1oUR1r1fjtQLEgbtxO2+LWNfWAtwSrRKCKJpbGXa+J86KET6I6pqzAW2iBNniZ9jDBP7WGU0tMvkS1Imzh/2rPGUUtVEMLD3n9axaUXy4mWnfI8SzzZC8FpgnCJpffiE+XRSHvzKkiJFTxUjzMqBR9Gz6Tu8MSfa2Z6wMsh9OzfsW4WNXSv7g410PDSnB9yy122ct0Mh3j7egn3CM+DDmYsk5KMLwrmZyD79cAAUT7GjM0FfJhFqxUA8SgnKR0ff+dAXyph1IG0oqWvWK8YepEd6YaCmLgjoU5q5zUjfMlCOxkYuQ6rAOZko/yW4DMGsZiTdCbtE399sDCt5BlzzAUKg6qUCnc/GORtkY0nNML8s/73dj1hnS00IUGMARUdH8x5W1bGjSPcknhrJy6+H7k75ZuPSVk/o3OWMyhL2qQElN1r3/31NdEZKTHflGbyzw+jTB91HaZKzrkhfufAhuc9Cj2Sqn/f+Wdo5Kv46o9CP9ABbiezkEiSjMjjLYChhaKyiKhl"
`endif