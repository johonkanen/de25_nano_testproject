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


// Copyright 2021 Intel Corporation. 
//
// This reference design file is subject licensed to you by the terms and 
// conditions of the applicable License Terms and Conditions for Hardware 
// Reference Designs and/or Design Examples (either as signed by you or 
// found at https://www.altera.com/common/legal/leg-license_agreement.html ).  
//
// As stated in the license, you agree to only use this reference design 
// solely in conjunction with Intel FPGAs or Intel CPLDs.  
//
// THE REFERENCE DESIGN IS PROVIDED "AS IS" WITHOUT ANY EXPRESS OR IMPLIED
// WARRANTY OF ANY KIND INCLUDING WARRANTIES OF MERCHANTABILITY, 
// NONINFRINGEMENT, OR FITNESS FOR A PARTICULAR PURPOSE. Intel does not 
// warrant or assume responsibility for the accuracy or completeness of any
// information, links or other items within the Reference Design and any 
// accompanying materials.
//
// In the event that you do not agree with such terms and conditions, do not
// use the reference design file.
/////////////////////////////////////////////////////////////////////////////

(* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION OFF" *)
module generic_mlab #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 5
)(
    input clk,
    input [WIDTH-1:0] din,
    input [ADDR_WIDTH-1:0] waddr,
    input we,
    input re,
    input [ADDR_WIDTH-1:0] raddr,
    output [WIDTH-1:0] dout
);

localparam DEPTH = 1 << ADDR_WIDTH;
(* ramstyle = "mlab" *) reg [WIDTH-1:0] mem[0:DEPTH-1];

reg [WIDTH-1:0] dout_r;
always @(posedge clk) begin
    if (we)
        mem[waddr] <= din;
    if (re)
        dout_r <= mem[raddr];
end

assign dout = dout_r;

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "xNJlgkakk7uiTmEjO9UCOiW8WFpugeSW63QHtS30B9QJksAJwiQ+9GCGkSbdthDdQaRLBfJoWNG4xd1Le5ZmK7wx83gQgGT5VNieh4JzpDR7c52fcCtIuIUgjxvJ413zJyrPayuh+cwviqihsXTZbiXvFsNV5MnOjxhWWlON/Pbi4Zww3xgB7RzxmTleesxsCL+HFph8ANHKuqt1d55T9R8660IFIV+4x0PSz2jci8mcbPrYKK8YJrt+hskwTNZ/5/0QATV+drWJSpEUSFcR9UIxALKAPvNfdS9BunCqq4gOnKqj/6PUIAgCC8o40Y6Ia45nbWdhvj97hvQRTaD8VUa5U8qgamoTEi3eJq72NexQ8tBBxiVWitoTCm7WjyYNIMzuVnEXoDZXaW5U8zs+pMKLVwJtPCocQbsyMU7OpTmBbJVCB+0Qq1gLek06qXl5pk58txvq8bNHaG1yr0DvanpEmCRnhWAACK52W0dJRXS7zl24RMXKgTWHJO2+hT1UkrTW4c19SgpdExBC9J8aHgVTuABrGBruch8Bjx+8zQzvH2YA5cvohmItOBg4f6VubHhTK7U9livSgXFD7LVacHDz7+44sEf2U3MxvNoi0Kp6qckHq6F4BspsKFg3PIdbdwtMxDlKImGZtu9eXWCkkKl8idKY8WzBKxXn/qY3jDRs/y7YJFFoF/RZJ5wY7FwM+mkJXR1J+CRg2gtAi+kAgk+EIwR3ZyU4a3HmX/ZOQyTR0paS/Vk0mHviAVUVfT72XVVhiBK1cmy87oUqBdYs6eIkwI1mGvV4jY9g2zLO3G5K5Xvu9hx/+WcTjw29ZZDEJGVR/TppFeEKemnE9K1JlYSM7srlEe2ccCKdE7YzBe/Ed+PLrrKi5+beAvRdfMRZ8CKB1bGyhX7gh+OVdecL9oSKX8yNcnPYpbZ1lZfsB26jSrHPaNTno4OWN3ngONh06i8uCYGT7sBxkTMJUg+Gyb0WwSv2ze6SS983lPwRWuWox8kQh7cKdXIWazhwpxB2"
`endif