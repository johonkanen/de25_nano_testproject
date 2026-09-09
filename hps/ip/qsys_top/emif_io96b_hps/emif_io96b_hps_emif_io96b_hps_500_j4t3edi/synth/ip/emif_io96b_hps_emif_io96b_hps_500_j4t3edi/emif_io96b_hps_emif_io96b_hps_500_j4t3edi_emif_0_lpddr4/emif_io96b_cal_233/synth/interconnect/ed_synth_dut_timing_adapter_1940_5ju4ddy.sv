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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW6snx80qPSgf/x/1gOFiFFe8xMGhGk5FLjwyIOXgb9JJMjrBzX34Vznme+FzHPg4OrMvgjkgwrFyaHx5iDyElVJVwWJhSiZMoIol4UWVEWAG635gsu4rDUWrzrosBYNYOURDq8VaABJjw9Aw5MITwE2wHrLjfOJr5CIyeSnPBUEvo8SwZTEAn7wbSXdDF4N3gjjNZyViHHHCY911+QdFvbhxhlkW2bd/y0O7YXyeTxFQjArA6qYKnBKmLaadVIunwcup572/g35iUG2vBbUD1/BWBOYRYKO0MWgUtecNKy2d/Jd+6R0N/SaIOgCm9DYacZ02ab8W38b72ab7pLiS4R4PFRetqS5KNth+U82mnavmKBjUjAF7MfKvIuelm3Ewa1XgWzvYxfg6sCq6JxocpfJ0BUdMqnjrwppMiAhN8d3gbQ02uK4oKkFrLYK+H4ojsVetj8BszyRfgBBIlpA5As+kJvzOe5j/33m0JMAVmc0REUNZpf0MSC4iQT5DEqHJEwbo0V7qcTgDCNfQro87nBYEQlIGUYlhROrajG3mgXkzAhadwGDKGSwfPxx5gjiWTu9t9aqHvdOK+P4Gr8dxqCIzn3npn6Gq1yw1FpEA7rahxOlMUhCe+73PB3/QLZL4qfZSKihtasVvYPO1G2iSBjCPE0SUdgLWQI6xv7Rn8/FYR71C5utglZfPBsrPMOWcGYOe08N4ooJoO5YdsmonkE8s+eHqKNJfwUankuHvbfBbA/3ofhztrmBvxmlarnPW20uAlivzGSJmQXq+bTHWLFt"
`endif