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


module ff_macro_p2c # (
 parameter DATA_WIDTH = 256,
 parameter NUM_FLOPS = 1 // based on number of flops you need in 1 dir 
 ) (
 input logic clk,

 input [DATA_WIDTH -1:0] in_data ,

 output [DATA_WIDTH -1:0] out_data

);


 (* altera_attribute = {"-name FORCE_HYPER_REGISTER_FOR_PERIPHERY_CORE_TRANSFER ON"} *)
    reg [DATA_WIDTH-1:0] in_data_reg [NUM_FLOPS:0];    

    assign in_data_reg[0] = in_data;


    genvar i;
    
    generate 
    for (i=0 ; i<NUM_FLOPS ; i=i+1 ) begin : hps_p2c_ff
      always @(posedge clk) begin
          in_data_reg[i+1] <= in_data_reg[i];
      end
    end
    endgenerate

    assign out_data = in_data_reg[NUM_FLOPS];



    
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "xNJlgkakk7uiTmEjO9UCOiW8WFpugeSW63QHtS30B9QJksAJwiQ+9GCGkSbdthDdQaRLBfJoWNG4xd1Le5ZmK7wx83gQgGT5VNieh4JzpDR7c52fcCtIuIUgjxvJ413zJyrPayuh+cwviqihsXTZbiXvFsNV5MnOjxhWWlON/Pbi4Zww3xgB7RzxmTleesxsCL+HFph8ANHKuqt1d55T9R8660IFIV+4x0PSz2jci8mSakbPjTkdpVxB0KUaPkDyJYBi8Jlz4Cxrl4BijxY50w0qhKTNTImwCDdJ2k+uTgUHFcqOSIMjJrp+hJIlKuSitGGzGObe18LhJFVXNxNvwknzbTTg9VUmFHzktYQYt1+feaAMfrCU/y4V1ri5gIt8iOi9p+7WFIK3/Lztfzt8t5VH7J6DRMSj+eGDBpHUdJKvbmduewnUhYkWac8rK1weV36uo1k6xd6LygArAgqzrYDV1nL74NDMUuf7Np4plsSZ9GTvbPwOVIJUjnmHC4d3DhA1Ov/XN//0AK1xjxLRcYIBAsZLkx0fhfXcEi5tMVUxJ6mYUAerG6E9mX+E7+ctmPeLMyZ9Ke8kUdVpW/r3e7zTSxeus9iAq97eBor/QiHVnK54i1LOR6mV5ldN/R9GFwsa8mjuXZetK9xXq7dCcT6xtfDMGns5JIsxjCvct0yMXecTRDlB0hRS2VjgtumuhuV9Xw1esGKLP5Wu8mT/4OM2HTLccU2+i7o7lwOg202M5CG7T8Rr/5iVaaDRY7V5DGbNbAhlZzHFSG3HtwHmTkVpAbDou2zn/5d3e+88n+Xv0dGMXNNhaXFP0srY9dPqqyhKPCRUJVblt2hck2rfM/sYtu+7pvo+Ogdd2xXwHLa+ZBI5shIdI07e8GzlQtZ2qMjdFataWL12VFNvcrMlGPDaZhe+j8zhT3y/8ZlMX2gEqEHi2G84qRyKdFl4F81cXR+1sGniuMTUNBfQgJiroZvvzf/cy1He/gKZXA43dT/lkt253tsDWms/8kSV0j8N"
`endif