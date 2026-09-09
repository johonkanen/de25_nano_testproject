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

module ed_synth_dut_channel_adapter_1921_5wnzrci 
(
 output reg         in_ready,
 input              in_valid,
 input     [8-1: 0] in_data,
 input [8-1: 0] in_channel,
 input              in_startofpacket,
 input              in_endofpacket,
 input               out_ready,
 output reg          out_valid,
 output reg [8-1: 0] out_data,
 output reg          out_startofpacket,
 output reg          out_endofpacket,
 input              clk,
 input              reset_n
 
 
);

    reg out_channel;

   always @* begin
      in_ready = out_ready;
      out_valid = in_valid;
      out_data = in_data;
      out_startofpacket = in_startofpacket;
      out_endofpacket = in_endofpacket;

      out_channel = in_channel; 

      if (in_channel > 0) begin
         out_valid = 0;
      end
   end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW7oqCPM2JpK3VUaD9jsPBqLY2N7YwZeGSpOidQPH+pzg7HYeNU027vDovcAOEMsVIpTkjOsrkcFSIABc+GWC/NAIw+fIdxv2HKXWmEDIAs+pj6t+NK86D5p7h9G13QdJsutcsRe4CWmEdjUDrgMlcLEGI8ekhSJfWPVEzYCqpC0eV7FtCWNeVyFxtokkctIMVYNm8F6aV5ZW4WkHBrvM9nVmA9LiX2TCyxPouPWkbvDheAvjnrhFq52UEzMgGfxOc48aVZHffsDJVeNWIVbnhyYKvHuLPsMoomTLe2yywPAjBMR1lYZ3dXkbbD2DzqEYiGet8UpU5Or3oGjmqCiv+QMS0YkfD7OjDXvL72G51Ou6T95NKBVOdpVz+CTx77Q1lX/HIptzQ9LiDmEgwa9uc7L+FhR7KChH0qioCHl3jszqUmNATOlfmtM61RXN4F8hVT/ITSe+YcCcIAEf71M3knKgr1le7iycJXYCG4MsflFk7cJbcDNb13FWjHZmZw9iTw6gQPLNSwsc4pxXyCeALNCLFif1W5sF4gIfganUdknExuUb82n6YP7NAMGIqSZoOYY4ynzIX5YiFUwRyjU25o6Jwd73s4wuQBQYMpLWxGqLgVNM8yMAOltOAhDbyxqDKzwbUQNN5X/m3E4BMhH29hCDDVCy2bR8KCJUwYcFJSlgkCSmEgEonfPMJLfl6NXcRBLnrkBMEEpLMGhHQQxkOk1BB1XJJ9q8roGeGtWpeGT//Wd4OvqKzkF06RxPBE6YHm3FUNTMDzLzKCelfPDdKDc"
`endif