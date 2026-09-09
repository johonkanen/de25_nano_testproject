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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW5F7pmxmBUZ/a3Wzsm/KwNHEwV0KuQ5bwUYHAyJT/WsLLHutoaQtX+JV0pYPXkiSFzFpkMwR74zwz0HNLN90qbsfYwrO3aCnZnHGS01k2vEIxeBycfcEk6HqqpaQ04kUIfGKdTcwdz3+vTK8l9ityQBABqFMJOkAVayDMTdDcKVsE1KQs/b2PTiWdjYLNOauzEHNX1U2B6IymTLt0tp01qgoDRm1g6cMJZR+OGKk3lYWMOo8CxZTjjyFjkDHce0syKIAnVFlvJZXATo+gRalzr5exH4NVZvXcUHtnbTqVK0KDURzymrc9RMSfqQXEaROVjcvloL96Sblrah60cX3IMDxKyFPoP2y/K2kx1IE6IN+RtRxwU+1MRmRJXueMi8SOwEzA3u/Nv6qDaAvqiBmjtlSuYid7Ott1BtxWUDArVuAMZF6TxuGT51Cb0QizxB10RSkUOdt6yvBcZNWh+vDGAUuhJtpEzrD6GOkXtZB/NxGUNmZ8mR49Q2GLNo0/t9SjFOqfaU6oIuvZu8UNxwuKazUMgPKuTq69N6CUyXRxsSL8nEsz9I3OZoaPOzW6PqdigVq4U5d17OtV0HVsicR5aKOVbVHUCGzOkFPhK7i25CjZcoR6KyT4p3cNTxocyW+UmjpJQnDXwrS02vApInG07PHZ2XIjlZgRxTTSNf2K+vTY2J7Y66J5TYEsXYocrMLg8jneLUaODkj6VOc34VKY4jvd67i3QVM/WshtHat5SOAuzaXz9vg/Rmg7WY/iOIdmWZQT7LZz4YyvyyI9yTs0lD"
`endif