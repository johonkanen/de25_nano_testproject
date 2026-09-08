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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9h3nWj04w/zCV+gxx1kFjPwr42c+wh9viQCcXe8AdUB+HG9kFmXLWB4teTAazeuYuyNN3cihTIPcdr6lIWE/4KmE4wPDHe1eUH8M1N4QnHBz1/623ugjhsPacmVcSgQCPcfXVtRrkty7jsn7mPRzqlvVuwhm/DBR+rATS3FHAql0W79WgG+4ojlEuu8R4oxRnMIwCs8wqdQMkxqU2gAo4z9UCTK3rRHjhZpykFv1h1DcwSCfV6L8niZh0au+/9WClx5hwgB9usGkdmNOOy4bfIQd6xkLnhzQV0CWpRFqyEW4+z59T3U8x0yETuXqBgXiCQAcpSvymtFtmhcYT1B3kbnhgmuw80H0sa4d4bCgQm3XuAQMnalCzAIu7g5sVV1Idf+za3/k8/MHu+fd0nDmd6cKAw4qTAdVQRIia2Ck4t395Ogknb+wUZ4C+7f+6kkwbTg/062nCIm6mivxfsP2NARo0ZjAMJFREWqoagsfovx33ejk+gM54L5eFupLAwFJlCzISw8+vrrlk0Uy/+oQKzE9RnHu+Afr4H8WeHoX4qyC3wopUliQxeN9/TeS10EJl7lEdY8yY5xfxthnF77iLdyE51Y3MxGmtM0Gi/wZKiM5CfoJO6+V4tGToSAXiVQYPr8C/sXuhA0loNp/B1bTYUExmP0H8tM+f4S4sshkb6AvdE/FEQiYKdo0V5tP3dTFsP7bHGTpGXOnaJaASn2CuzvVqoh44/+OxtyPmncQlMNwBNR+ot6UuXkqaGhS4146I6Rc1QmlxqiUm9Npy8Dj9+"
`endif