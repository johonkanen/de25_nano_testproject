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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc/xGHZsqAcyjy7G0oRM2U+ilU4GMFz/JP9wHRdb6eBPM3rxmoqDqYZUkwlPbWZP0PXLM750Fq68jTGRFoNKro5nSkOnlGfjPFtrI85oqT2MVu0bbxdeNZ8Xoutkmre+uihx3KUOT0RrMenaOC84bEVMksB7mAkas4Aofr3Xj0Y24CprAixOJ1fElCUmAaDhsQ3hpYzhNLQ5dYxckzXID/RFpdFGRRguY4pT4rDkNwHlNOZXcKe8Yt5POxH0t3QAWG1Pu/qDsUPU9AeLYm2F5DGe2VYA9Cb2Gh1afEjDBVPoIoSIHPn3V1xjWSO0vtJw8AQUmYsHZQWp/DiBMgfakUlZmW/I580y7HpoOgXXsDCkXtblczw9UNaum9pMppAfLr9mF5Dh3e2sDU8tG1Lhaah+adisQptiM2OyScRqK9uiC6ypyE1Ifd10RNl0rCRTjnZlj8i9tR1c5ruC2OHbDeC8O5+8a+vQ2mxIVosiaxrJc2rBwqwwYm2Fswas8fcuPYMBSIFfaRq+RZmbekw/AjAi1OwrcWXsiMXXnq0Bpn8ya/vv/JNxUVe7Hb1T41+kuudqROPk4n5VKag/RI6WPnMwr1QAZ1OaUJfTYQOr6w/TZjwP7d31nUacYWxirNPOnsFDgepkZ3Sh3pYPJtjx+3fyw2shxR2/93yp3sAEFLUuGpGs8QyykjlA7SU4nc1y2rM11e2aRQkx8oSGiERIlOt7SXpV+XFyRnP4DxlkDdMXCjoQNKsEqnWt/KQW0Dv13jVSbJXpy76FmUcNqEh0KU9T"
`endif