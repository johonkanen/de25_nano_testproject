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


module ff_macro_c2p # (
 parameter DATA_WIDTH = 256,
 parameter NUM_FLOPS = 1 // based on number of flops you need in 1 dir 
 ) (
 input logic clk,

 input [DATA_WIDTH -1:0] in_data ,

 output [DATA_WIDTH -1:0] out_data

);


 (* altera_attribute = {"-name FORCE_HYPER_REGISTER_FOR_CORE_PERIPHERY_TRANSFER ON; -name HYPER_REGISTER_DELAY_CHAIN 350"} *)
    reg [DATA_WIDTH-1:0] in_data_reg [NUM_FLOPS:0];    

    assign in_data_reg[0] = in_data;


    genvar i;
    
    generate 
    for (i=0 ; i<NUM_FLOPS ; i=i+1 ) begin : hps_c2p_ff
      always @(posedge clk) begin
          in_data_reg[i+1] <= in_data_reg[i];
      end
    end
    endgenerate

    assign out_data = in_data_reg[NUM_FLOPS];



    
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "qGpFQTyeB49TiKcJqi+SbFpijxmu4TXeK4ITJEFWP4fPXKh9yaFCbKPq+kx68ePe/yYwWxdqX1e7EH24ET9NTnFQoZQoiJ/oIv2MyWNmI+DEkfevd5fOfIXCW5BhS667nS4GweRodqOHXMpDqeX+jKphchekcZUQb1/1JvT/HUQT9yJdd5Z6kIOR7gUpuJ1TRtPV01tS4Fo+nDv1+mRSA4l6pbsX4MlEisKtJJWy54yrSb3D4rt70rtLJxqeMm4vQkMrb9aGcAviXt1p1Y3uP5c0mQMfS+YoALLJygFhXx/M52DQktFqms5BrdZqZLiyUqH3Spx+RKaalK3wwA3nOiXli7t09A8XuGDF+8nHjZCCfIgHfWcjjNoh0D/91zlJj0CSYzlS/z1sRK3QZjirlyQgdkHJE84boqnIrG8YXoKoeOT1zAsGfq8wsPbbgeDgfpOPxUqQEXngQTgxdmgczi7JkmgmVchc1SwZ9FlOqAmnH72UyUfvZEzlJxUomxLgmzWF+sc4YxOGeuXLiyB4pefY0SuW8vtn8JBfQ8AR5FBsbwLa1XBEpcJv4zieVNZYnuZFioJWERIMaul1DObm2jYHuLLlxCpkpJnztF3qwzphzO/J4YTug+C8fjiTTy++kBYBrq7XeOGLTAh5mmGdLfwjLuyVMgtaKjsYSQRs75lT5syQRinVD3sFSz373/YHbtF7KcYPjZwpw9y76zuXb31Lniac9ktKZjoGE1RI92/wP1rVF44Zq+qzelRkcrcyjVkXRJszurF6HxZ1HTJnBHoHuOQJohxBigMksrCLhkGPta3VeJtsOZ68ae77ropGkFv0w6eenhIpUkqyD1EDgpV2vv5gfMFuIlua+58kCS+I1ptgx3KPgu7mFIk7/3NGbBhhlONSpKZsJIcgRr1hPiblujMC3kgMNtMyh88nKxSUOE3w37jncV9sRxwatLP2LztUmWw/g5ttR/9x8Fymz7+A2B6qYvMqUs0udvujO8NUqzQKjA05AlwHLZJjaCjo"
`endif