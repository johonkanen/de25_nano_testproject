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


module cal_arch_fp_atom_inst_comp #(
   parameter IS_USED  = 0,

   parameter BASE_ADDRESS                                    = 0,

   localparam PORT_I_AVM_ADDRESS_WIDTH                        = 22,
   localparam PORT_I_AVM_WRITEDATA_WIDTH                      = 32,
   localparam PORT_O_AVM_READDATA_COMP_WIDTH                  = 32
) (
);
   timeunit 1ns;
   timeprecision 1ps;

   logic                                                      avm_clk;
   logic                                                      avm_rst_n;
   logic [PORT_I_AVM_ADDRESS_WIDTH-1:0]                       i_avm_address;
   logic                                                      i_avm_read;
   logic                                                      i_avm_write;
   logic [PORT_I_AVM_WRITEDATA_WIDTH-1:0]                     i_avm_writedata;
   logic [PORT_O_AVM_READDATA_COMP_WIDTH-1:0]                 o_avm_readdata_comp;

   tennm_compensation_block # (
      .base_address                                         (BASE_ADDRESS)
   ) comp (
      .avm_clk                                              (avm_clk),
      .avm_rst_n                                            (avm_rst_n),
      .i_avm_address                                        (i_avm_address),
      .i_avm_read                                           (i_avm_read),
      .i_avm_write                                          (i_avm_write),
      .i_avm_writedata                                      (i_avm_writedata),
      .o_avm_readdata_comp                                  (o_avm_readdata_comp)
   );

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX4pQRRlPJ+wzFVcAyQFXe6IdjfAI775TmFOBy9GqyXa6wQPbq2mRP9VlocFnGWosJOpnbkFKRVY675pcXpvMQ/7D6kwyFIdAHuvzKsLA2ot07yKhXLgNuoiqez7xirnzsnoI1zMF+g1tVqJw+b8xxLTI5tBze/8XOqgrQcTmZK4EmLy3yAVy00JmGeIULrEWP4GDqgqPvNJsY4WfUSxAzGtzjyGCpuxmmJIaITWSoMC8pY+H4XWE6MKKj/ArbnGJF05y9sBXU8ZXNvuABtJ6hYinsaroh8mWtJzg1n707wgULER89CVnoGHjePiqTLhuC2xhwXsSdrepmxUj4jJPeZr5Vxc2oRO1odOP7dsvoW9xoohhxF1IPNs/ZAS9cP+MCznHu/0rvIWEvxj7t1tbOEu+sGobrF3bMiFGfNLn9yg42oNVCytNwSk45JYmtqLgRlUbWkLlLulMgtG3lz3V6a3HCR6XDgeCEaPknJKygs+fEtwrXIr9hCYXlFMvcSTm88Myx105G9Y/vGPoimpnypx0fP5FXjPxn2i10P2bHwGjE0VK64vSjkZKhEva67tsnktfney2kDfB7WGA8eJX0+AdZLMkBu8BReaYgDbc/X/WIlrNNfoVmYQ4j1Fs36pR0GASYr32h3BnQeuttsP/p5Eeebx/I9Ept6go9FuBTLXSH/DXmmBX2Ut8YHJOChpd9VGWcdoLcVmwHeaBYGz54Xskipa1NoS6QJ+2hsJ8dxsfZ8Xm7hk/YCEywh4Hz6guYA3Au+d6pEmAZxVSHOVvkHt"
`endif