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
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1q0fU2BYv0fUrAErFBSn6YsxFv26LStpHPE+G7GDmKCBVCEpS6PphP3nsskNybQO69eU5bu+bJkYmA1JwVuAQTkTlpkDNv7BLqeyQ6F6QiFNEJeZe18Bmcv1xsBr7OoxUSMtBpO+0Kso75bEsBoysxbqOu5geSac1e5oLIOBj7OaL08p9ygE+j/mxf4Yi67i78oT3hxoDOAsuILd/KQth9/f7O3yfDHs4qn5/NMuIkhRg2d+n9mJifoST09hOYDPFhHZIUpHqXkHeJqvYKX4oHEh9hSJMeQzqyibalbeFnIA/aTNRatf39tPy+psbmiQV3YfJy2aXAPDPcnXhX/gqf0mwBXOAPuGmK+6Yq/UIWR5JjWcWjo6+iVfTnPjCbq5sk3sDF7BOVSb3ENSM/majmN3JYQkq4Exg0lrJlYQ0AglIX7PGVoyjjb+4Q7XXOOF0qfzD8OGVIRGwxhl9yZIKkEGoHOmjLSz9MlfKF6NxBQC+R/C+VAFmeF00zmxuZvJPPj1XDXIEnESJ4q1vQ4Tc2dQWIwdFQHXdJtegfeNI6FMkEgR7CcOMLAlPEdBT9b2VMGSDSM1yCKO+fz1woEUiu9sFfm79QIppRxdnTE+P4Pc9eAGFS0yzWvRDTBeLwBQPQAeWnUteN9Tkj8g7HSWIGRg48XTJ3dfAgok7J3BycpEy01d2EzPksiFve2WtbymwvdcP9qvJFCY+/tlX6OIkhi+X9PmHZBr4ERcDWCVxRbWvgh55f+JOYlhZ74WiBCUUuM/DESBL1i0wGTpbsaJ64j"
`endif