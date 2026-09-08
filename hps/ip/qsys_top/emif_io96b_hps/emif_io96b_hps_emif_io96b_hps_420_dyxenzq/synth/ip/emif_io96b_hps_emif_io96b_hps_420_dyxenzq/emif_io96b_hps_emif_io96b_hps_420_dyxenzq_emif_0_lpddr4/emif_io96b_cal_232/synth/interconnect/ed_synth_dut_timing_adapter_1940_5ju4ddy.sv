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



module ed_synth_dut_timing_adapter_1940_5ju4ddy #(parameter SYNC_RESET = 0)
(  
 input               in_valid,
 input     [8-1: 0]  in_data,
 input               out_ready,
 output reg          out_valid,
 output reg [8-1: 0] out_data,
 input              clk,
 input              reset_n

 /*AUTOARG*/);

   
   reg [8-1:0]   in_payload;
   reg [8-1:0]   out_payload;
   reg [1-1:0]   ready;   
   reg           in_ready;
   // synthesis translate_off
   always @(negedge in_ready) begin
      $display("%m: The downstream component is backpressuring by deasserting ready, but the upstream component can't be backpressured.");
   end
   // synthesis translate_on   

   always @* begin
     in_payload = {in_data};
     {out_data} = out_payload;
   end

   always_comb begin
     ready[0]    = out_ready;
     out_valid = in_valid;
     out_payload = in_payload;
     in_ready    = ready[0];
   end

generate if(SYNC_RESET == 0) begin

end
else begin
reg internal_sclr;
always @ (posedge clk) begin
internal_sclr <= reset_n;
end

end
endgenerate

endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1pf3PbDvvsSAazsUCWt53nkBn8cqFdGm2KBBv/8ngBZNO1MQHdN1EzJdQEgnCy4pVg4dbsm+u9Qt344qzFtv0VbrtG7TSjoiGbkiD+jZAVwrEcA7KW/VEX/nh2ut9+FzJBR0m22R+6AxCQYVrcnYqpMgGhueNQ9WnbJBBySrBAXMus00Ux+X3bxYQgLkyH0Yp2S0V6aj2ludW3inNt+cUKa4kFb7xfdz7RaZhywm0BgohE/SLcpGcwjVNxVeBAx3dkBLRhESH1h6Rl/6h3/wJPcJnTIDW6PPD6cLuczc41ZgfiG17BD6B4iXi9/vAchcaxmLr2nka3lDYdWzA06RUocXOfaGwCh+US5+XMKEENtCiHr+Dy26S2PrTb7zMVhPsxEQMOPipqM5lhP9R2HQgmK+uV+WJ0KuS6Gd7fi1oiv8jA/oTHt7PpXkzf4BIAmC/SyNgDORkuXEmpUA83oagfyp/jWQKinfd2O19ZsOuSACvJioeBsyWxZadCU1DqU25Go4baJNVqqyyUk5LytWamn+1xKLu8MzO/XvuJcTWU3MAIyesI7EDmwQbRkrWBmA0HUpsjeyGWC/0HIwQ8ykK/JxeTnQq7xfioWg1kvdgId1IbBzYOy5NzpKs/vowgKme1a5BnneeDOfpI2LyThNWy41m/kVzRf4o6JrtvsaOOHMCB+TxrLoxaOlF+u3t6RrnRsVX9FKz/Rb2Kd0wXa1WgxY70JcejkC8ZQ2cjHdjELELjXBZrouWptidI6UxUVdFnEc0DupBsk96z06nN3iw+5"
`endif