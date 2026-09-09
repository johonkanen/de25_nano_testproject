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



module stdfn_inst_fa_c2p_ssm #(
   parameter IS_USED  = 0,

   parameter SSM_C2P_DATA_MODE                               = "SSM_C2P_DATA_MODE_BYPASS",
   parameter FA_CORE_PERIPH_CLK_SEL_DATA_MODE                = "FA_CORE_PERIPH_CLK_SEL_DATA_MODE_UNUSED",
   parameter SSM_P2C_DATA_MODE                               = "SSM_P2C_DATA_MODE_BYPASS",
   localparam PORT_I_SSM_C2P_WIDTH                            = 40,
   localparam PORT_O_SSM_C2P_WIDTH                            = 40,
   localparam PORT_I_SSM_P2C_WIDTH                            = 20,
   localparam PORT_O_SSM_P2C_WIDTH                            = 20
) (
   input                                                      i_core_clk,
   input [PORT_I_SSM_C2P_WIDTH-1:0]                           i_ssm_c2p,
   output [PORT_O_SSM_C2P_WIDTH-1:0]                           o_ssm_c2p,
   input                                                      i_phy_clk_fr,
   input                                                      i_phy_clk_sync,
   input [PORT_I_SSM_P2C_WIDTH-1:0]                           i_ssm_p2c,
   output [PORT_O_SSM_P2C_WIDTH-1:0]                           o_ssm_p2c
);
   timeunit 1ns;
   timeprecision 1ps;

   tennm_ssm_c2p_fabric_adaptor # (
      .ssm_c2p_data_mode                                    (SSM_C2P_DATA_MODE),
      .fa_core_periph_clk_sel_data_mode                     (FA_CORE_PERIPH_CLK_SEL_DATA_MODE)
   ) fa_c2p_ssm (
      .i_core_clk                                           (i_core_clk),
      .i_phy_clk_fr                                         (i_phy_clk_fr),
      .i_phy_clk_sync                                       (i_phy_clk_sync),
      .i_ssm_c2p                                            (i_ssm_c2p),
      .o_ssm_c2p                                            (o_ssm_c2p)
   );
   tennm_ssm_p2c_fabric_adaptor # (
      .ssm_p2c_data_mode                                    (SSM_P2C_DATA_MODE),
      .fa_core_periph_clk_sel_data_mode                     (FA_CORE_PERIPH_CLK_SEL_DATA_MODE)
   ) fa_p2c_ssm (
      .i_core_clk                                           (i_core_clk),
      .i_phy_clk_fr                                         (i_phy_clk_fr),
      .i_phy_clk_sync                                       (i_phy_clk_sync),
      .i_ssm_p2c                                            (i_ssm_p2c),
      .o_ssm_p2c                                            (o_ssm_p2c)
   );

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX4F3MG4dWmH9QAeyzKv36I1HrX+XuwetmIav7aiTaqCCC3Rte5WF4JN7nG8IO7UfI985Dy8wrYx457tsbRZE42P+/C4te6bkSBUZI73lCkyKKA8kXRmWTDcH+wgbJN3+UdYpQR6Z1jMynVs8eisTmWqeXKATQRz/B1sJY8J8kHZE/XVxbJ5K476GePuYSqtSrHKMNzdgao50g/DxR7Tw8V80q0XIwxFn0HHCu8tI2sBMCuA4xES3JIvlOTDmObm4o+MVqGRlQRsdMU0j19fyj4hpF6c4EhN7coqD8pO4dZj4KTBM11kL++SZROoYtRmLuCJA2tPwfhFYdIyf0IKPvVrdr1B5bxnwRPFNwmQEGD0mV5cU0FY9VsxFjcp8JC/qTuYwMKNUfy+2qkY4Hcv09ZfH3HLP5F8hs0dXBk7wtqknFgzRnObKLx6CNfUaygcMrVdo1+kdBZbYWrC05WwUnJ5V/Bxotyrvv1g/e4GtcmNFgTE7o4SULHKExVT3Wmg+hhN56TVMIixJdjpPB9rLzuQgUW98v82getaOERwu9OteGasltbxUIP8WTckEkuMwsoGN8IiQM/UaAKKLR/wE6/mSVyfHkAEtdAZoRbwkqnZDVbQ9fiVIjZb5CkWQSvTNgLULZR52I2PIVThEPv0nC2doXZ8Yegn80WyOVFqlupXNLffH4vhxBAzbGfYkPMCmvPDVxYmRU03iWxy9pA1LeehMItP60kw1fN4JydBwc9PcAu3Bq6Bp3N799KD+d2nNvHhKg81dxm+BZdzcdrTfLu/"
`endif