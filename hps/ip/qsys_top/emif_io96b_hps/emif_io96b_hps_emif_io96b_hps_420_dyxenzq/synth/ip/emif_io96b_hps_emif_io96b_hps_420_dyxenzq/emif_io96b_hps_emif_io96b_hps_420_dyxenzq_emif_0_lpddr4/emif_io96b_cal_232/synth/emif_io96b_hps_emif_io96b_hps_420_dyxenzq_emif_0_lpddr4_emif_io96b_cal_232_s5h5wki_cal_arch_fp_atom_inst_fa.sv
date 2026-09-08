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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc+96bwJRyKwPdrMtYSy7m+X0yzYshDLSxe/WLUb3qsczNZaIWpknYTeedvLKw/e1EnLil9SSlUaAB9RYBjO5BB6xCFjoi9OwEQ0Q52WST0YiB57jUOsXiyNw/1ZUY8o0YzYGzlvDXM1ty7Hn3WnJYLW1WfdBDwhyLWR1/cYX+VG7FQYJxHGlb6SN+stmztbJjnrLUj8iBoLZL+F0l5Ote0peaY0j2vY6Xv/RY2IqJsmpi1/LjrikCDY9fQjkplfr2oCqChH+5qZ+O/Ejg/hKXGxp8quekqCzbplbwa7ZY/oG3h5WhybqEhOz6R0f4UOfGoKHxTFyzuAS6htuJ9YLiBE/ZqaGWbe4S+UmGSEizMJHAmT3ZbwuyWUKqp1AvHI6WqE/hXRI6LI/3+4MaoMTern7Fy27oP8lexuJUK45PT6Mtoy/sD+ZFFP2fG2S72m7Gi9U+4EmXdAYvwVbpoesy+GrvcCBuMN6XlN2PH3XwI5kLMSLbLydOfpe1KRIMeDxktajCoUk3HKgQDT+2L/MWk9/2Pb90MRKAhGT2Ek8QmTo1w/XNHV/Z5mDb2mxm1G0YrQSyUApISqnrANcd6OC/VxLYDUhXU2Sl9KGrF+maS05FaWKomFRC8NiWqZEOYZMi/LpLbEJQLd+Jh+h+CHSTMdntEuCr2hlAJJFq9pYzFMsAOkPRW+5BpBjHCmyVxtDLpdyMXF2tnfV5qPSoO+QEbtX1HgCGMofqg38PyKPy/nsFfpcY59ZK2uphMWteiELe5CwrAxqoOFPyhYhEXkZoAz"
`endif