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


// a generic clock divider to be used in simulation
module clk_div #(
  parameter RATIO = 2
) (
  input wire clk_input,
  output wire clk_output
);
  localparam WIDTH = $clog2(RATIO);
  logic [WIDTH-1:0] r_reg;

  initial r_reg = 0;

  always @(posedge clk_input)
    r_reg <= r_reg + 1;

  assign clk_output = r_reg[WIDTH-1];
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1oZhcez56yx28yUV2L09i5r3yrB4/SXmwc8wW0Xz+1bddAWphGqWpiiAgaZQFh+z9pIF00Hx33tc7ZTS3PF8TDNx2Z+FqlCDCFuxi62FX/5G2OFMc4bm3rkwBX4DgTUC+Jtlca2MVJXZRtOYWC5AVd+GdlyAFRrx6sre8eimOA0JCKmQU9SjVsKztoS+9WEbRgDvS0Dm42Cyya4dgtXQCESfd1Byxut+uwtpX0Fi1VvwgN2qEmliKX/vNKoywA7z5nsjkqKASPbUsZHQXLOKkKzacCcWR0/9G1HY6sq8eurgUbfKx3naMz/qGyIA7SE9PWHavPFVKHBPoyH7UX/+C7l7snq5N4RxUb4az2FyjBAZTfeTG7hd5jY/TCO+dp6aqMIxcgB8fdlp29Hy+r3i14roT8ARqHtosnqVxprnKEGYTyspmP4jl9HJbvvlhW8cf9zw59TRVP1fUbaFQghB3wC6qa1cVUapUe3gBz5Kg59IYiikmpTARfilpXF/Rvf2lTIrvalgFlBSar8FAfyk6qWlkV64XrKAUuNZnygOKdbloOSApKUVhV2rofGxKpf1srfRKR89EoreUoOOXBtAIXm4HQyUEXlofNST8W+13r2CHAe9BeiDzd2PGZi7+db8M7xGy+A1Fzc6K4qM3sl/ldOEknnEkW7TLRBao5lHwX7SUwt+b98sAqhYiqL5AGHJsbkgUKEmHdDSnHC2/jbXbUS9DvqcoEvnncjkWjr5tzm+7awopIEDVnh1Qs6q0pXo+SG0zSMY+QIqmi34BdW3jSH"
`endif