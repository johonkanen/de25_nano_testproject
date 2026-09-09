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





 


`timescale 1ns / 100ps



// altera message_off 13469

module ed_synth_dut_channel_adapter_1921_fkajlia 
(
 output reg         in_ready,
 input              in_valid,
 input     [8-1: 0] in_data,
 input              in_startofpacket,
 input              in_endofpacket,
 input               out_ready,
 output reg          out_valid,
 output reg [8-1: 0] out_data,
 output reg [8-1: 0] out_channel,
 output reg          out_startofpacket,
 output reg          out_endofpacket,
 input              clk,
 input              reset_n
 
 
);

    wire in_channel;
    assign in_channel =0 ;

   always @* begin
      in_ready = out_ready;
      out_valid = in_valid;
      out_data = in_data;
      out_startofpacket = in_startofpacket;
      out_endofpacket = in_endofpacket;

      out_channel = 0;
      out_channel = in_channel;

   end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW5hECVUxw9/yT5ektaQjvxvc/81fiSN9NSSysl2oyOhfAoH3FCYnSvjkKlUR05sE4Rh93cBIJsscwBdwiOueQ/e/9xsXC7dVHL7mYfB1sB4eodjPvNce78mBw0VxW2KdIySiKniQm8LkUG35XoYC7EFebCm807wyjJwkGcDjzCmZYQ9iAUrWbPUISwAl3Ipmq8eAD1y2rsWuNQI+LN13E6qpwbwkORuc5Mn682TmXiwhdqMZrAtEDi8S9YlbO/eufckDde/pZXC8c2gkGMYkhZX8S50yOHC+M7y+r6cjQoTuog3QnPjS5mkH+WqdULqOLs1e2e0u28qUMvX/r7CqMi7j0Ta4KXuwBwlqp5JN7j7PZQ7l/OUt06EzpLUUhlLZk1ffa3dy4oPgd6kS6/pf7Rl4s0VaJJ8l0o5yzuQvjAbijTffJ1gr7bNzYLHAGPL2YUWl1mVGgsHiXZshPcx5uo7v4se+g1GfaLi3J9lmaKZWdfz3VAH07Bq4Nr+kPrblrKrFZIosB2Vw/QOtyCusEQsoGL1aKQz7XhbV1pMtU/S0V7GDY7Qk/VWMn8GFyLDDlA2xcGQ6Ax2EIPOG7UNFCDPHn8ePVdrpbpNTTqWjCw4+R97Roq3hAtxUzkMPtFVQcwZqr+HkVDdOSF9Hc+Nq2nDS7uqkYQRu17XU6A3lhM+JfTsOUNU8FlYYIUKVGoEW6zeSCLmkflHYuB0VzVOlQ1fKu5f6DOzL9vH884ER6CRJAR8asWCZGtTMSoZn2TF1YGj0enCIhEnyKsf4qkNgc6o"
`endif