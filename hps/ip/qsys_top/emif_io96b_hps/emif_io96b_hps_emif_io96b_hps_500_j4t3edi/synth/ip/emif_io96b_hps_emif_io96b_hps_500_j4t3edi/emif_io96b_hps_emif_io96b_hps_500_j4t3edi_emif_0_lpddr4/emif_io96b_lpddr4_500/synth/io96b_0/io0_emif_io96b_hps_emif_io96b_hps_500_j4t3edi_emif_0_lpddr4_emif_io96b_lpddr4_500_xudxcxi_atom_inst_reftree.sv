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



module io0_emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_phy_arch_fp_atom_inst_reftree #(
) (
   input   logic pin_to_reftree,
   output  logic reftree_to_pll
);
   timeunit 1ns;
   timeprecision 1ps;

   logic     self_clk_in;
   logic     self_clk_out;
   logic     tp_clk;
   logic     btm_clk;

   assign reftree_to_pll = self_clk_out;

   assign self_clk_in = pin_to_reftree;


   tennm_reftree_bal # (
   ) reftree (
      .self_clk_in                    (self_clk_in),
      .self_clk_out                   (self_clk_out),
      .tp_clk                         (tp_clk),
      .btm_clk                        (btm_clk)
   );

endmodule


