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


`timescale 1 ps / 1 ps

`ifndef PHY_ARCH_FP_INTERFACE
   `include "emif_io96b_interface.svh"
`endif

`ifndef ZERO_PAD_PORT
`define ZERO_PAD_PORT(IP_PORT_WIDTH, PHYS_SIG_WIDTH, ip_port)                       \
        (   (IP_PORT_WIDTH >= PHYS_SIG_WIDTH)                                       \
          ? ip_port[(PHYS_SIG_WIDTH-1):0]                                           \
          : {'0,ip_port[(IP_PORT_WIDTH-1):0]})
`endif

module emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_arch_top #(
   // ======= HDL params passed down based on IP parameterization -- START ==========
   localparam MEM_NUM_CHANNELS  = 1,
   localparam MEM_NUM_CHANNELS_PER_IO96  = 1,
   localparam MEM_NUM_IO96  = 1,
   localparam MAINBAND_EXPORT_NOC_FA_AXI  = 1,
   localparam MAINBAND_USE_NOC_TNIU  = 0,
   localparam SIDEBAND_EXPORT_IOSSM_NOC_AXIL  = 1,
   localparam SIDEBAND_USE_NOC_TNIU  = 0,
   localparam SIDEBAND_USE_TNIUL_RST  = 1,
   localparam SIDEBAND_USE_FAB_INTF  = 0,
   localparam DEBUG_TOOLS_EN  = 0,
   localparam PHY_I3C_EN  = 0,
   localparam AXI4_ADDR_WIDTH  = 40,
   localparam AXI4_USER_WIDTH  = 32,
   localparam IO0_AXI4_USER_DATA_ENABLE  = 0,
   localparam IO1_AXI4_USER_DATA_ENABLE  = 0,
   localparam IO0_SLIM_BL_EN  = 0,
   localparam IO1_SLIM_BL_EN  = 0,
   localparam IO0_LS_MEM_DQ_WIDTH  = 0,
   localparam IO1_LS_MEM_DQ_WIDTH  = 0,
   localparam ADD_DDR4_DIMM_ADAPTORS  = 0,
   localparam LS_ECC_EN  = 0,
   localparam LS_ECC_AUTOCORRECT_EN  = 0,
   localparam IS_DDR5_RDIMM  = 0,
   localparam S0_AXID_WIDTH  = 7,
   localparam S1_AXID_WIDTH  = 7,
   localparam S2_AXID_WIDTH  = 7,
   localparam S3_AXID_WIDTH  = 7,
   localparam MEM_CK_T_WIDTH  = 1,
   localparam MEM_CK_C_WIDTH  = 1,
   localparam MEM_CKE_WIDTH  = 1,
   localparam MEM_ODT_WIDTH  = 0,
   localparam MEM_CS_N_WIDTH  = 0,
   localparam MEM_C_WIDTH  = 0,
   localparam MEM_A_WIDTH  = 0,
   localparam MEM_BA_WIDTH  = 0,
   localparam MEM_BG_WIDTH  = 0,
   localparam MEM_ACT_N_WIDTH  = 0,
   localparam MEM_PAR_WIDTH  = 0,
   localparam MEM_ALERT_N_WIDTH  = 0,
   localparam MEM_RESET_N_WIDTH  = 1,
   localparam MEM_DQ_WIDTH  = 32,
   localparam MEM_DQS_T_WIDTH  = 4,
   localparam MEM_DQS_C_WIDTH  = 4,
   localparam MEM_DBI_N_WIDTH  = 0,
   localparam MEM_CA_WIDTH  = 6,
   localparam MEM_DM_N_WIDTH  = 0,
   localparam MEM_CS_WIDTH  = 1,
   localparam MEM_WCK_T_WIDTH  = 0,
   localparam MEM_WCK_C_WIDTH  = 0,
   localparam MEM_RDQS_T_WIDTH  = 0,
   localparam MEM_RDQS_C_WIDTH  = 0,
   localparam MEM_DMI_WIDTH  = 4,
   localparam OCT_RZQIN_WIDTH  = 1,
   localparam MEM_LBD_WIDTH  = 0,
   localparam MEM_LBS_WIDTH  = 0,
   localparam I3C_SCL_WIDTH  = 0,
   localparam I3C_SDA_WIDTH  = 0,
   // ======= HDL params passed down based on IP parameterization -- END ==========

   localparam PHY_USE_NOC_INTF         = MAINBAND_EXPORT_NOC_FA_AXI || MAINBAND_USE_NOC_TNIU,
   localparam AXI4_AXUSER_WIDTH        = 14,
   // ======= AXIL parameters ==========
   localparam PORT_AXIL_ADDRESS_WIDTH = 27,
   localparam PORT_AXIL_DATA_WIDTH = 32,

   // ======= Control AXI parameters ==========
   localparam PORT_AXI_AXADDR_WIDTH    = AXI4_ADDR_WIDTH,
   localparam PORT_AXI_AXBURST_WIDTH   = 2,
   localparam PORT_AXI_AXLEN_WIDTH     = 8,
   localparam PORT_AXI_AXQOS_WIDTH     = 4,
   localparam PORT_AXI_AXSIZE_WIDTH    = 3,
   localparam PORT_AXI_AXID_WIDTH      = 7,
   localparam PORT_AXI_AXUSER_WIDTH    = AXI4_AXUSER_WIDTH, 
   localparam PORT_AXI_AXCACHE_WIDTH   = 4,
   localparam PORT_AXI_AXPROT_WIDTH    = 3,
   localparam PORT_AXI_S0_AXID_WIDTH   = S0_AXID_WIDTH,
   localparam PORT_AXI_S1_AXID_WIDTH   = S1_AXID_WIDTH,
   localparam PORT_AXI_S2_AXID_WIDTH   = S2_AXID_WIDTH,
   localparam PORT_AXI_S3_AXID_WIDTH   = S3_AXID_WIDTH,

   localparam AXI4_DATA_WIDTH          = 256,
   localparam PORT_AXI_DATA_WIDTH      = IO1_LS_MEM_DQ_WIDTH == 0 ? AXI4_DATA_WIDTH : 512,
   localparam PORT_AXI_STRB_WIDTH      = PORT_AXI_DATA_WIDTH/8,
   localparam PORT_AXI_INT_STRB_WIDTH  = ADD_DDR4_DIMM_ADAPTORS ? 32 : PORT_AXI_DATA_WIDTH/8,
   localparam PORT_AXI_ID_WIDTH        = PORT_AXI_AXID_WIDTH,
   localparam PORT_AXI_RESP_WIDTH      = 2,
   localparam PORT_AXI_USER_WIDTH      = (AXI4_USER_WIDTH == 0) ? 1 : AXI4_USER_WIDTH, 
   localparam PORT_AXI_FBR_USER_WIDTH_MAX  = 64,
   localparam PORT_AXI_NOC_USER_WIDTH  = 32,
   localparam PORT_AXI_INT_USER_WIDTH  = PHY_USE_NOC_INTF ? PORT_AXI_NOC_USER_WIDTH : PORT_AXI_FBR_USER_WIDTH_MAX,
   localparam PORT_MEM_DQ_WIDTH        = MEM_DQ_WIDTH,
   localparam PORT_MEM_DQS_T_WIDTH     = MEM_DQS_T_WIDTH,
   localparam PORT_MEM_DQS_C_WIDTH     = MEM_DQS_C_WIDTH,
   localparam PORT_MEM_DBI_N_WIDTH     = MEM_DBI_N_WIDTH,
   
   localparam DQ_PER_DQS    = PORT_MEM_DQS_T_WIDTH < 1 ? 1 : (PORT_MEM_DQ_WIDTH / PORT_MEM_DQS_T_WIDTH),
   localparam DQ_PER_DBI    = PORT_MEM_DBI_N_WIDTH < 1 ? 1 : (PORT_MEM_DQ_WIDTH / PORT_MEM_DBI_N_WIDTH),

   localparam IO0_MEM_DQ_WIDTH = IO0_LS_MEM_DQ_WIDTH == 0 ? PORT_MEM_DQ_WIDTH : IO0_LS_MEM_DQ_WIDTH,
   localparam IO1_MEM_DQ_WIDTH = IO1_LS_MEM_DQ_WIDTH == 0 ? PORT_MEM_DQ_WIDTH : IO1_LS_MEM_DQ_WIDTH,
   localparam IO0_MEM_DQS_T_WIDTH = IO0_LS_MEM_DQ_WIDTH == 0 ? PORT_MEM_DQS_T_WIDTH : IO0_LS_MEM_DQ_WIDTH/DQ_PER_DQS,
   localparam IO0_MEM_DQS_C_WIDTH = IO0_LS_MEM_DQ_WIDTH == 0 ? PORT_MEM_DQS_C_WIDTH : IO0_LS_MEM_DQ_WIDTH/DQ_PER_DQS,
   localparam IO0_MEM_DBI_N_WIDTH = IO0_LS_MEM_DQ_WIDTH == 0 || PORT_MEM_DBI_N_WIDTH < 1 ? PORT_MEM_DBI_N_WIDTH : IO0_LS_MEM_DQ_WIDTH/DQ_PER_DBI,
   localparam IO1_MEM_DQS_T_WIDTH = IO1_LS_MEM_DQ_WIDTH == 0 ? PORT_MEM_DQS_T_WIDTH : IO1_LS_MEM_DQ_WIDTH/DQ_PER_DQS,
   localparam IO1_MEM_DQS_C_WIDTH = IO1_LS_MEM_DQ_WIDTH == 0 ? PORT_MEM_DQS_C_WIDTH : IO1_LS_MEM_DQ_WIDTH/DQ_PER_DQS,
   localparam IO1_MEM_DBI_N_WIDTH = IO1_LS_MEM_DQ_WIDTH == 0 || PORT_MEM_DBI_N_WIDTH < 1 ? PORT_MEM_DBI_N_WIDTH : IO1_LS_MEM_DQ_WIDTH/DQ_PER_DBI,


   localparam MEM_CHIP_ID_WIDTH  = MEM_C_WIDTH,
   localparam MEM_BANK_ADDR_WIDTH = MEM_BA_WIDTH,
   localparam MEM_BANK_GROUP_ADDR_WIDTH = MEM_BG_WIDTH

) (
   // Reference clock going to PLL
   input logic                                                 ref_clk,
   
   // Core init signal going into EMIF. Used to generate the reset signal on the core-EMIF interface in fabric modes.
   input logic                                                 core_init_n,

   // User clock going to core (for PHY + hard controller interfaces)
   output logic                                                s0_axi4_clock_out,
   output logic                                                s1_axi4_clock_out,

   // User reset signal going to core (for PHY + hard controller interfaces)
   output logic                                                s0_axi4_reset_n,
   output logic                                                s1_axi4_reset_n,

   // In case of ASYNC mode, the user will drive the async clock. The same clock also is driven as output to usr_clk
   input  logic                                                s0_axi4_clock_in,

   // In case of NOC mode, this clock is used for the TNIU
   // the noc reset is internally tied off -- it exists in hw but not modelled in the netlist (it exists below for qsys representation 
   output logic                                                noc_aclk_0,
   output logic                                                noc_aclk_1,
   output logic                                                noc_rst_n_0,
   output logic                                                noc_rst_n_1,
   output logic                                                noc_aclk_2,
   output logic                                                noc_aclk_3,
   output logic                                                noc_rst_n_2,
   output logic                                                noc_rst_n_3,


   input  logic    [PORT_AXI_AXADDR_WIDTH-1:0]                 s0_axi4_araddr,
   input  logic    [PORT_AXI_AXBURST_WIDTH-1:0]                s0_axi4_arburst,
   input  logic    [PORT_AXI_S0_AXID_WIDTH-1:0]                s0_axi4_arid,
   input  logic    [PORT_AXI_AXLEN_WIDTH-1:0]                  s0_axi4_arlen,
   input  logic                                                s0_axi4_arlock,
   input  logic    [PORT_AXI_AXQOS_WIDTH-1:0]                  s0_axi4_arqos,
   input  logic    [PORT_AXI_AXSIZE_WIDTH-1:0]                 s0_axi4_arsize,
   input  logic    [PORT_AXI_AXUSER_WIDTH-1:0]                 s0_axi4_aruser,
   input  logic                                                s0_axi4_arvalid,
   input  logic    [PORT_AXI_AXPROT_WIDTH-1:0]                 s0_axi4_arprot,
   input  logic    [PORT_AXI_AXADDR_WIDTH-1:0]                 s0_axi4_awaddr,
   input  logic    [PORT_AXI_AXBURST_WIDTH-1:0]                s0_axi4_awburst,
   input  logic    [PORT_AXI_S0_AXID_WIDTH-1:0]                s0_axi4_awid,
   input  logic    [PORT_AXI_AXLEN_WIDTH-1:0]                  s0_axi4_awlen,
   input  logic                                                s0_axi4_awlock,
   input  logic    [PORT_AXI_AXQOS_WIDTH-1:0]                  s0_axi4_awqos,
   input  logic    [PORT_AXI_AXSIZE_WIDTH-1:0]                 s0_axi4_awsize,
   input  logic    [PORT_AXI_AXUSER_WIDTH-1:0]                 s0_axi4_awuser,
   input  logic                                                s0_axi4_awvalid,
   input  logic    [PORT_AXI_AXPROT_WIDTH-1:0]                 s0_axi4_awprot,
   input  logic                                                s0_axi4_bready,
   input  logic                                                s0_axi4_rready,
   input  logic    [PORT_AXI_DATA_WIDTH-1:0]                   s0_axi4_wdata,
   input  logic                                                s0_axi4_wlast,
   input  logic    [PORT_AXI_STRB_WIDTH-1:0]                   s0_axi4_wstrb,
   input  logic    [PORT_AXI_USER_WIDTH-1:0]                   s0_axi4_wuser,
   input  logic                                                s0_axi4_wvalid,
   output logic                                                s0_axi4_arready,
   output logic                                                s0_axi4_awready,
   output logic    [PORT_AXI_S0_AXID_WIDTH-1:0]                s0_axi4_bid,
   output logic    [PORT_AXI_RESP_WIDTH-1:0]                   s0_axi4_bresp,
   output logic                                                s0_axi4_bvalid,
   output logic    [PORT_AXI_DATA_WIDTH-1:0]                   s0_axi4_rdata,
   output logic    [PORT_AXI_S0_AXID_WIDTH-1:0]                s0_axi4_rid,
   output logic                                                s0_axi4_rlast,
   output logic    [PORT_AXI_RESP_WIDTH-1:0]                   s0_axi4_rresp,
   output logic    [PORT_AXI_USER_WIDTH-1:0]                   s0_axi4_ruser,
   output logic                                                s0_axi4_rvalid,
   output logic                                                s0_axi4_wready,

   // AXI4 Interface - Channel 1 
   input  logic    [PORT_AXI_AXADDR_WIDTH-1:0]                 s1_axi4_araddr,
   input  logic    [PORT_AXI_AXBURST_WIDTH-1:0]                s1_axi4_arburst,
   input  logic    [PORT_AXI_S1_AXID_WIDTH-1:0]                s1_axi4_arid,
   input  logic    [PORT_AXI_AXLEN_WIDTH-1:0]                  s1_axi4_arlen,
   input  logic                                                s1_axi4_arlock,
   input  logic    [PORT_AXI_AXQOS_WIDTH-1:0]                  s1_axi4_arqos,
   input  logic    [PORT_AXI_AXSIZE_WIDTH-1:0]                 s1_axi4_arsize,
   input  logic    [PORT_AXI_AXUSER_WIDTH-1:0]                 s1_axi4_aruser,
   input  logic                                                s1_axi4_arvalid,
   input  logic    [PORT_AXI_AXPROT_WIDTH-1:0]                 s1_axi4_arprot,
   input  logic    [PORT_AXI_AXADDR_WIDTH-1:0]                 s1_axi4_awaddr,
   input  logic    [PORT_AXI_AXBURST_WIDTH-1:0]                s1_axi4_awburst,
   input  logic    [PORT_AXI_S1_AXID_WIDTH-1:0]                s1_axi4_awid,
   input  logic    [PORT_AXI_AXLEN_WIDTH-1:0]                  s1_axi4_awlen,
   input  logic                                                s1_axi4_awlock,
   input  logic    [PORT_AXI_AXQOS_WIDTH-1:0]                  s1_axi4_awqos,
   input  logic    [PORT_AXI_AXSIZE_WIDTH-1:0]                 s1_axi4_awsize,
   input  logic    [PORT_AXI_AXUSER_WIDTH-1:0]                 s1_axi4_awuser,
   input  logic                                                s1_axi4_awvalid,
   input  logic    [PORT_AXI_AXPROT_WIDTH-1:0]                 s1_axi4_awprot,
   input  logic                                                s1_axi4_bready,
   input  logic                                                s1_axi4_rready,
   input  logic    [PORT_AXI_DATA_WIDTH-1:0]                   s1_axi4_wdata,
   input  logic                                                s1_axi4_wlast,
   input  logic    [PORT_AXI_STRB_WIDTH-1:0]                   s1_axi4_wstrb,
   input  logic    [PORT_AXI_USER_WIDTH-1:0]                   s1_axi4_wuser,
   input  logic                                                s1_axi4_wvalid,
   output logic                                                s1_axi4_arready,
   output logic                                                s1_axi4_awready,
   output logic    [PORT_AXI_S1_AXID_WIDTH-1:0]                s1_axi4_bid,
   output logic    [PORT_AXI_RESP_WIDTH-1:0]                   s1_axi4_bresp,
   output logic                                                s1_axi4_bvalid,
   output logic    [PORT_AXI_DATA_WIDTH-1:0]                   s1_axi4_rdata,
   output logic    [PORT_AXI_S1_AXID_WIDTH-1:0]                s1_axi4_rid,
   output logic                                                s1_axi4_rlast,
   output logic    [PORT_AXI_RESP_WIDTH-1:0]                   s1_axi4_rresp,
   output logic    [PORT_AXI_USER_WIDTH-1:0]                   s1_axi4_ruser,
   output logic                                                s1_axi4_rvalid,
   output logic                                                s1_axi4_wready,

   // AXI4 Interface - Channel 2 
   input  logic    [PORT_AXI_AXADDR_WIDTH-1:0]                 s2_axi4_araddr,
   input  logic    [PORT_AXI_AXBURST_WIDTH-1:0]                s2_axi4_arburst,
   input  logic    [PORT_AXI_S2_AXID_WIDTH-1:0]                s2_axi4_arid,
   input  logic    [PORT_AXI_AXLEN_WIDTH-1:0]                  s2_axi4_arlen,
   input  logic                                                s2_axi4_arlock,
   input  logic    [PORT_AXI_AXQOS_WIDTH-1:0]                  s2_axi4_arqos,
   input  logic    [PORT_AXI_AXSIZE_WIDTH-1:0]                 s2_axi4_arsize,
   input  logic    [PORT_AXI_AXUSER_WIDTH-1:0]                 s2_axi4_aruser,
   input  logic                                                s2_axi4_arvalid,
   input  logic    [PORT_AXI_AXPROT_WIDTH-1:0]                 s2_axi4_arprot,
   input  logic    [PORT_AXI_AXADDR_WIDTH-1:0]                 s2_axi4_awaddr,
   input  logic    [PORT_AXI_AXBURST_WIDTH-1:0]                s2_axi4_awburst,
   input  logic    [PORT_AXI_S2_AXID_WIDTH-1:0]                s2_axi4_awid,
   input  logic    [PORT_AXI_AXLEN_WIDTH-1:0]                  s2_axi4_awlen,
   input  logic                                                s2_axi4_awlock,
   input  logic    [PORT_AXI_AXQOS_WIDTH-1:0]                  s2_axi4_awqos,
   input  logic    [PORT_AXI_AXSIZE_WIDTH-1:0]                 s2_axi4_awsize,
   input  logic    [PORT_AXI_AXUSER_WIDTH-1:0]                 s2_axi4_awuser,
   input  logic                                                s2_axi4_awvalid,
   input  logic    [PORT_AXI_AXPROT_WIDTH-1:0]                 s2_axi4_awprot,
   input  logic                                                s2_axi4_bready,
   input  logic                                                s2_axi4_rready,
   input  logic    [PORT_AXI_DATA_WIDTH-1:0]                   s2_axi4_wdata,
   input  logic                                                s2_axi4_wlast,
   input  logic    [PORT_AXI_STRB_WIDTH-1:0]                   s2_axi4_wstrb,
   input  logic    [PORT_AXI_USER_WIDTH-1:0]                   s2_axi4_wuser,
   input  logic                                                s2_axi4_wvalid,
   output logic                                                s2_axi4_arready,
   output logic                                                s2_axi4_awready,
   output logic    [PORT_AXI_S2_AXID_WIDTH-1:0]                s2_axi4_bid,
   output logic    [PORT_AXI_RESP_WIDTH-1:0]                   s2_axi4_bresp,
   output logic                                                s2_axi4_bvalid,
   output logic    [PORT_AXI_DATA_WIDTH-1:0]                   s2_axi4_rdata,
   output logic    [PORT_AXI_S2_AXID_WIDTH-1:0]                s2_axi4_rid,
   output logic                                                s2_axi4_rlast,
   output logic    [PORT_AXI_RESP_WIDTH-1:0]                   s2_axi4_rresp,
   output logic    [PORT_AXI_USER_WIDTH-1:0]                   s2_axi4_ruser,
   output logic                                                s2_axi4_rvalid,
   output logic                                                s2_axi4_wready,

   // AXI4 Interface - Channel 3 
   input  logic    [PORT_AXI_AXADDR_WIDTH-1:0]                 s3_axi4_araddr,
   input  logic    [PORT_AXI_AXBURST_WIDTH-1:0]                s3_axi4_arburst,
   input  logic    [PORT_AXI_S3_AXID_WIDTH-1:0]                s3_axi4_arid,
   input  logic    [PORT_AXI_AXLEN_WIDTH-1:0]                  s3_axi4_arlen,
   input  logic                                                s3_axi4_arlock,
   input  logic    [PORT_AXI_AXQOS_WIDTH-1:0]                  s3_axi4_arqos,
   input  logic    [PORT_AXI_AXSIZE_WIDTH-1:0]                 s3_axi4_arsize,
   input  logic    [PORT_AXI_AXUSER_WIDTH-1:0]                 s3_axi4_aruser,
   input  logic                                                s3_axi4_arvalid,
   input  logic    [PORT_AXI_AXPROT_WIDTH-1:0]                 s3_axi4_arprot,
   input  logic    [PORT_AXI_AXADDR_WIDTH-1:0]                 s3_axi4_awaddr,
   input  logic    [PORT_AXI_AXBURST_WIDTH-1:0]                s3_axi4_awburst,
   input  logic    [PORT_AXI_S3_AXID_WIDTH-1:0]                s3_axi4_awid,
   input  logic    [PORT_AXI_AXLEN_WIDTH-1:0]                  s3_axi4_awlen,
   input  logic                                                s3_axi4_awlock,
   input  logic    [PORT_AXI_AXQOS_WIDTH-1:0]                  s3_axi4_awqos,
   input  logic    [PORT_AXI_AXSIZE_WIDTH-1:0]                 s3_axi4_awsize,
   input  logic    [PORT_AXI_AXUSER_WIDTH-1:0]                 s3_axi4_awuser,
   input  logic                                                s3_axi4_awvalid,
   input  logic    [PORT_AXI_AXPROT_WIDTH-1:0]                 s3_axi4_awprot,
   input  logic                                                s3_axi4_bready,
   input  logic                                                s3_axi4_rready,
   input  logic    [PORT_AXI_DATA_WIDTH-1:0]                   s3_axi4_wdata,
   input  logic                                                s3_axi4_wlast,
   input  logic    [PORT_AXI_STRB_WIDTH-1:0]                   s3_axi4_wstrb,
   input  logic    [PORT_AXI_USER_WIDTH-1:0]                   s3_axi4_wuser,
   input  logic                                                s3_axi4_wvalid,
   output logic                                                s3_axi4_arready,
   output logic                                                s3_axi4_awready,
   output logic    [PORT_AXI_S3_AXID_WIDTH-1:0]                s3_axi4_bid,
   output logic    [PORT_AXI_RESP_WIDTH-1:0]                   s3_axi4_bresp,
   output logic                                                s3_axi4_bvalid,
   output logic    [PORT_AXI_DATA_WIDTH-1:0]                   s3_axi4_rdata,
   output logic    [PORT_AXI_S3_AXID_WIDTH-1:0]                s3_axi4_rid,
   output logic                                                s3_axi4_rlast,
   output logic    [PORT_AXI_RESP_WIDTH-1:0]                   s3_axi4_rresp,
   output logic    [PORT_AXI_USER_WIDTH-1:0]                   s3_axi4_ruser,
   output logic                                                s3_axi4_rvalid,
   output logic                                                s3_axi4_wready,

   // AXI4Lite Interface - IO bank 0 
   input       logic                                        s0_axi4lite_clock,
   input       logic                                        s0_axi4lite_reset_n,
   input       logic [PORT_AXIL_ADDRESS_WIDTH-1:0]          s0_axi4lite_awaddr,
   input       logic                                        s0_axi4lite_awvalid,
   output      logic                                        s0_axi4lite_awready,
   input       logic [2:0]                                  s0_axi4lite_awprot,
   input       logic [PORT_AXIL_ADDRESS_WIDTH-1:0]          s0_axi4lite_araddr,
   input       logic                                        s0_axi4lite_arvalid,
   output      logic                                        s0_axi4lite_arready,
   input       logic [2:0]                                  s0_axi4lite_arprot,
   input       logic [PORT_AXIL_DATA_WIDTH-1:0]             s0_axi4lite_wdata,
   input       logic [(PORT_AXIL_DATA_WIDTH/8)-1:0]         s0_axi4lite_wstrb,
   input       logic                                        s0_axi4lite_wvalid,
   output      logic                                        s0_axi4lite_wready,
   output      logic [1:0]                                  s0_axi4lite_rresp,
   output      logic [PORT_AXIL_DATA_WIDTH-1:0]             s0_axi4lite_rdata,
   output      logic                                        s0_axi4lite_rvalid,
   input       logic                                        s0_axi4lite_rready,
   output      logic [1:0]                                  s0_axi4lite_bresp,
   output      logic                                        s0_axi4lite_bvalid,
   input       logic                                        s0_axi4lite_bready,

   input       logic                                        s1_axi4lite_clock,
   input       logic                                        s1_axi4lite_reset_n,
   input       logic [PORT_AXIL_ADDRESS_WIDTH-1:0]          s1_axi4lite_awaddr,
   input       logic                                        s1_axi4lite_awvalid,
   output      logic                                        s1_axi4lite_awready,
   input       logic [2:0]                                  s1_axi4lite_awprot,
   input       logic [PORT_AXIL_ADDRESS_WIDTH-1:0]          s1_axi4lite_araddr,
   input       logic                                        s1_axi4lite_arvalid,
   output      logic                                        s1_axi4lite_arready,
   input       logic [2:0]                                  s1_axi4lite_arprot,
   input       logic [PORT_AXIL_DATA_WIDTH-1:0]             s1_axi4lite_wdata,
   input       logic [(PORT_AXIL_DATA_WIDTH/8)-1:0]         s1_axi4lite_wstrb,
   input       logic                                        s1_axi4lite_wvalid,
   output      logic                                        s1_axi4lite_wready,
   output      logic [1:0]                                  s1_axi4lite_rresp,
   output      logic [PORT_AXIL_DATA_WIDTH-1:0]             s1_axi4lite_rdata,
   output      logic                                        s1_axi4lite_rvalid,
   input       logic                                        s1_axi4lite_rready,
   output      logic [1:0]                                  s1_axi4lite_bresp,
   output      logic                                        s1_axi4lite_bvalid,
   input       logic                                        s1_axi4lite_bready,

   output      logic                                        s0_noc_axi4lite_clock,      
   output      logic                                        s0_noc_axi4lite_reset_n,    
   input       logic [PORT_AXIL_ADDRESS_WIDTH-1:0]          s0_noc_axi4lite_awaddr,   
   input       logic                                        s0_noc_axi4lite_awvalid,  
   output      logic                                        s0_noc_axi4lite_awready,  
   input       logic [PORT_AXIL_ADDRESS_WIDTH-1:0]          s0_noc_axi4lite_araddr,   
   input       logic                                        s0_noc_axi4lite_arvalid,  
   output      logic                                        s0_noc_axi4lite_arready,  
   input       logic [PORT_AXIL_DATA_WIDTH-1:0]             s0_noc_axi4lite_wdata,    
   input       logic                                        s0_noc_axi4lite_wvalid,   
   output      logic                                        s0_noc_axi4lite_wready,   
   output      logic [1:0]                                  s0_noc_axi4lite_rresp,    
   output      logic [PORT_AXIL_DATA_WIDTH-1:0]             s0_noc_axi4lite_rdata,    
   output      logic                                        s0_noc_axi4lite_rvalid,   
   input       logic                                        s0_noc_axi4lite_rready,   
   output      logic [1:0]                                  s0_noc_axi4lite_bresp,    
   output      logic                                        s0_noc_axi4lite_bvalid,   
   input       logic                                        s0_noc_axi4lite_bready,   
   input       logic [2:0]                                  s0_noc_axi4lite_awprot,   
   input       logic [2:0]                                  s0_noc_axi4lite_arprot,   
   input       logic [3:0]                                  s0_noc_axi4lite_wstrb,    

   output      logic                                        s1_noc_axi4lite_clock,      
   output      logic                                        s1_noc_axi4lite_reset_n,    
   input       logic [PORT_AXIL_ADDRESS_WIDTH-1:0]          s1_noc_axi4lite_awaddr,   
   input       logic                                        s1_noc_axi4lite_awvalid,  
   output      logic                                        s1_noc_axi4lite_awready,  
   input       logic [PORT_AXIL_ADDRESS_WIDTH-1:0]          s1_noc_axi4lite_araddr,   
   input       logic                                        s1_noc_axi4lite_arvalid,  
   output      logic                                        s1_noc_axi4lite_arready,  
   input       logic [PORT_AXIL_DATA_WIDTH-1:0]             s1_noc_axi4lite_wdata,    
   input       logic                                        s1_noc_axi4lite_wvalid,   
   output      logic                                        s1_noc_axi4lite_wready,   
   output      logic [1:0]                                  s1_noc_axi4lite_rresp,    
   output      logic [PORT_AXIL_DATA_WIDTH-1:0]             s1_noc_axi4lite_rdata,    
   output      logic                                        s1_noc_axi4lite_rvalid,   
   input       logic                                        s1_noc_axi4lite_rready,   
   output      logic [1:0]                                  s1_noc_axi4lite_bresp,    
   output      logic                                        s1_noc_axi4lite_bvalid,   
   input       logic                                        s1_noc_axi4lite_bready,   
   input       logic [2:0]                                  s1_noc_axi4lite_awprot,   
   input       logic [2:0]                                  s1_noc_axi4lite_arprot,   
   input       logic [3:0]                                  s1_noc_axi4lite_wstrb,



   // Memory Interface
   // MEM Interface - Channel 0 
   output      logic [MEM_CK_T_WIDTH-1:0]                   mem_0_ck_t,
   output      logic [MEM_CK_C_WIDTH-1:0]                   mem_0_ck_c,
   output      logic [MEM_CKE_WIDTH-1:0]                    mem_0_cke,
   output      logic [MEM_ODT_WIDTH-1:0]                    mem_0_odt,
   output      logic [MEM_CS_N_WIDTH-1:0]                   mem_0_cs_n,
   output      logic [MEM_C_WIDTH-1:0]                      mem_0_c,
   output      logic [MEM_A_WIDTH-1:0]                      mem_0_a,
   output      logic [MEM_BA_WIDTH-1:0]                     mem_0_ba,
   output      logic [MEM_BG_WIDTH-1:0]                     mem_0_bg,
   output      logic [MEM_ACT_N_WIDTH-1:0]                  mem_0_act_n,
   output      logic [MEM_PAR_WIDTH-1:0]                    mem_0_par,
   input       logic [MEM_ALERT_N_WIDTH-1:0]                mem_0_alert_n,
   output      logic [MEM_RESET_N_WIDTH-1:0]                mem_0_reset_n,
   inout  tri  logic [PORT_MEM_DQ_WIDTH-1:0]                mem_0_dq,
   inout  tri  logic [PORT_MEM_DQS_T_WIDTH-1:0]             mem_0_dqs_t,
   inout  tri  logic [PORT_MEM_DQS_C_WIDTH-1:0]             mem_0_dqs_c,
   inout  tri  logic [PORT_MEM_DBI_N_WIDTH-1:0]             mem_0_dbi_n,
   output      logic [MEM_CA_WIDTH-1:0]                     mem_0_ca,
   output      logic [MEM_DM_N_WIDTH-1:0]                   mem_0_dm_n,
   output      logic [MEM_CS_WIDTH-1:0]                     mem_0_cs,
   output      logic [MEM_WCK_T_WIDTH-1:0]                  mem_0_wck_t,
   output      logic [MEM_WCK_C_WIDTH-1:0]                  mem_0_wck_c,
   inout  tri  logic [MEM_RDQS_T_WIDTH-1:0]                 mem_0_rdqs_t,
   inout  tri  logic [MEM_RDQS_C_WIDTH-1:0]                 mem_0_rdqs_c,
   inout  tri  logic [MEM_DMI_WIDTH-1:0]                    mem_0_dmi,      
   input       logic [OCT_RZQIN_WIDTH-1:0]                  oct_rzqin_0,

   // MEM Interface - Channel 1 
   output      logic [MEM_CK_T_WIDTH-1:0]                   mem_1_ck_t,
   output      logic [MEM_CK_C_WIDTH-1:0]                   mem_1_ck_c,
   output      logic [MEM_CKE_WIDTH-1:0]                    mem_1_cke,
   output      logic [MEM_ODT_WIDTH-1:0]                    mem_1_odt,
   output      logic [MEM_CS_N_WIDTH-1:0]                   mem_1_cs_n,
   output      logic [MEM_C_WIDTH-1:0]                      mem_1_c,
   output      logic [MEM_A_WIDTH-1:0]                      mem_1_a,
   output      logic [MEM_BA_WIDTH-1:0]                     mem_1_ba,
   output      logic [MEM_BG_WIDTH-1:0]                     mem_1_bg,
   output      logic [MEM_ACT_N_WIDTH-1:0]                  mem_1_act_n,
   output      logic [MEM_PAR_WIDTH-1:0]                    mem_1_par,
   input       logic [MEM_ALERT_N_WIDTH-1:0]                mem_1_alert_n,
   output      logic [MEM_RESET_N_WIDTH-1:0]                mem_1_reset_n,
   inout  tri  logic [PORT_MEM_DQ_WIDTH-1:0]                mem_1_dq,
   inout  tri  logic [PORT_MEM_DQS_T_WIDTH-1:0]             mem_1_dqs_t,
   inout  tri  logic [PORT_MEM_DQS_C_WIDTH-1:0]             mem_1_dqs_c,
   inout  tri  logic [PORT_MEM_DBI_N_WIDTH-1:0]             mem_1_dbi_n,
   output      logic [MEM_CA_WIDTH-1:0]                     mem_1_ca,
   output      logic [MEM_DM_N_WIDTH-1:0]                   mem_1_dm_n,
   output      logic [MEM_CS_WIDTH-1:0]                     mem_1_cs,
   output      logic [MEM_WCK_T_WIDTH-1:0]                  mem_1_wck_t,
   output      logic [MEM_WCK_C_WIDTH-1:0]                  mem_1_wck_c,
   inout  tri  logic [MEM_RDQS_T_WIDTH-1:0]                 mem_1_rdqs_t,
   inout  tri  logic [MEM_RDQS_C_WIDTH-1:0]                 mem_1_rdqs_c,
   inout  tri  logic [MEM_DMI_WIDTH-1:0]                    mem_1_dmi,
   input       logic [OCT_RZQIN_WIDTH-1:0]                  oct_rzqin_1,

   // MEM Interface - Channel 2 
   output      logic [MEM_CK_T_WIDTH-1:0]                   mem_2_ck_t,
   output      logic [MEM_CK_C_WIDTH-1:0]                   mem_2_ck_c,
   output      logic [MEM_CKE_WIDTH-1:0]                    mem_2_cke,
   output      logic [MEM_ODT_WIDTH-1:0]                    mem_2_odt,
   output      logic [MEM_CS_N_WIDTH-1:0]                   mem_2_cs_n,
   output      logic [MEM_C_WIDTH-1:0]                      mem_2_c,
   output      logic [MEM_A_WIDTH-1:0]                      mem_2_a,
   output      logic [MEM_BA_WIDTH-1:0]                     mem_2_ba,
   output      logic [MEM_BG_WIDTH-1:0]                     mem_2_bg,
   output      logic [MEM_ACT_N_WIDTH-1:0]                  mem_2_act_n,
   output      logic [MEM_PAR_WIDTH-1:0]                    mem_2_par,
   input       logic [MEM_ALERT_N_WIDTH-1:0]                mem_2_alert_n,
   output      logic [MEM_RESET_N_WIDTH-1:0]                mem_2_reset_n,
   inout  tri  logic [PORT_MEM_DQ_WIDTH-1:0]                mem_2_dq,
   inout  tri  logic [PORT_MEM_DQS_T_WIDTH-1:0]             mem_2_dqs_t,
   inout  tri  logic [PORT_MEM_DQS_C_WIDTH-1:0]             mem_2_dqs_c,
   inout  tri  logic [PORT_MEM_DBI_N_WIDTH-1:0]             mem_2_dbi_n,
   output      logic [MEM_CA_WIDTH-1:0]                     mem_2_ca,
   output      logic [MEM_DM_N_WIDTH-1:0]                   mem_2_dm_n,
   output      logic [MEM_CS_WIDTH-1:0]                     mem_2_cs,
   output      logic [MEM_WCK_T_WIDTH-1:0]                  mem_2_wck_t,
   output      logic [MEM_WCK_C_WIDTH-1:0]                  mem_2_wck_c,
   inout  tri  logic [MEM_RDQS_T_WIDTH-1:0]                 mem_2_rdqs_t,
   inout  tri  logic [MEM_RDQS_C_WIDTH-1:0]                 mem_2_rdqs_c,
   inout  tri  logic [MEM_DMI_WIDTH-1:0]                    mem_2_dmi,
   input       logic [OCT_RZQIN_WIDTH-1:0]                  oct_rzqin_2,

   // MEM Interface - Channel 3 
   output      logic [MEM_CK_T_WIDTH-1:0]                   mem_3_ck_t,
   output      logic [MEM_CK_C_WIDTH-1:0]                   mem_3_ck_c,
   output      logic [MEM_CKE_WIDTH-1:0]                    mem_3_cke,
   output      logic [MEM_ODT_WIDTH-1:0]                    mem_3_odt,
   output      logic [MEM_CS_N_WIDTH-1:0]                   mem_3_cs_n,
   output      logic [MEM_C_WIDTH-1:0]                      mem_3_c,
   output      logic [MEM_A_WIDTH-1:0]                      mem_3_a,
   output      logic [MEM_BA_WIDTH-1:0]                     mem_3_ba,
   output      logic [MEM_BG_WIDTH-1:0]                     mem_3_bg,
   output      logic [MEM_ACT_N_WIDTH-1:0]                  mem_3_act_n,
   output      logic [MEM_PAR_WIDTH-1:0]                    mem_3_par,
   input       logic [MEM_ALERT_N_WIDTH-1:0]                mem_3_alert_n,
   output      logic [MEM_RESET_N_WIDTH-1:0]                mem_3_reset_n,
   inout  tri  logic [PORT_MEM_DQ_WIDTH-1:0]                mem_3_dq,
   inout  tri  logic [PORT_MEM_DQS_T_WIDTH-1:0]             mem_3_dqs_t,
   inout  tri  logic [PORT_MEM_DQS_C_WIDTH-1:0]             mem_3_dqs_c,
   inout  tri  logic [PORT_MEM_DBI_N_WIDTH-1:0]             mem_3_dbi_n,
   output      logic [MEM_CA_WIDTH-1:0]                     mem_3_ca,
   output      logic [MEM_DM_N_WIDTH-1:0]                   mem_3_dm_n,
   output      logic [MEM_CS_WIDTH-1:0]                     mem_3_cs,
   output      logic [MEM_WCK_T_WIDTH-1:0]                  mem_3_wck_t,
   output      logic [MEM_WCK_C_WIDTH-1:0]                  mem_3_wck_c,
   inout  tri  logic [MEM_RDQS_T_WIDTH-1:0]                 mem_3_rdqs_t,
   inout  tri  logic [MEM_RDQS_C_WIDTH-1:0]                 mem_3_rdqs_c,
   inout  tri  logic [MEM_DMI_WIDTH-1:0]                    mem_3_dmi,
   input       logic [OCT_RZQIN_WIDTH-1:0]                  oct_rzqin_3,


   // LBD/LBS Interfaces
   input       logic [MEM_LBD_WIDTH-1:0]                    mem_lbd_0,
   input       logic [MEM_LBS_WIDTH-1:0]                    mem_lbs_0,

   // I3C Interface -- 1 for the interface
   output      logic                                        i3c_scl_0,
   inout  tri  logic                                        i3c_sda_0

);

   localparam INTF_CALIP_TO_EMIF_WIDTH        = 1342;
   localparam INTF_EMIF_TO_CALIP_WIDTH        = 1315; 
   localparam PARAM_TABLE_WIDTH               = 16384;

   logic ls_io0_usr_clk;
   logic ls_io0_usr_rst_n;


   logic    [INTF_CALIP_TO_EMIF_WIDTH-1:0]              calbus_0;
   logic    [INTF_EMIF_TO_CALIP_WIDTH-1:0]              calbus_readdata_0;
   logic    [2*PARAM_TABLE_WIDTH-1:0]                   calbus_param_table_0;
   logic    [INTF_CALIP_TO_EMIF_WIDTH-1:0]              calbus_1;
   logic    [INTF_EMIF_TO_CALIP_WIDTH-1:0]              calbus_readdata_1;
   logic    [2*PARAM_TABLE_WIDTH-1:0]                   calbus_param_table_1;
   
   AXI_BUS #( 
      .PORT_AXI_AXADDR_WIDTH  (PORT_AXI_AXADDR_WIDTH),
      .PORT_AXI_AXID_WIDTH    (PORT_AXI_AXID_WIDTH),
      .PORT_AXI_AXBURST_WIDTH (PORT_AXI_AXBURST_WIDTH),
      .PORT_AXI_AXLEN_WIDTH   (PORT_AXI_AXLEN_WIDTH),
      .PORT_AXI_AXSIZE_WIDTH  (PORT_AXI_AXSIZE_WIDTH),
      .PORT_AXI_AXUSER_WIDTH  (PORT_AXI_AXUSER_WIDTH),
      .PORT_AXI_DATA_WIDTH    (AXI4_DATA_WIDTH),
      .PORT_AXI_STRB_WIDTH    (PORT_AXI_INT_STRB_WIDTH),
      .PORT_AXI_RESP_WIDTH    (PORT_AXI_RESP_WIDTH),
      .PORT_AXI_ID_WIDTH      (PORT_AXI_ID_WIDTH),
      .PORT_AXI_USER_WIDTH    (PORT_AXI_INT_USER_WIDTH),
      .PORT_AXI_AXPROT_WIDTH  (PORT_AXI_AXPROT_WIDTH),
      .PORT_AXI_AXCACHE_WIDTH (PORT_AXI_AXCACHE_WIDTH),
      .PORT_AXI_AXQOS_WIDTH   (PORT_AXI_AXQOS_WIDTH)
   ) s_axi_to_arch[3:0] (), 
     s_axi_to_tniu[3:0] ();

   //  ==== IO96B ==== 
   //  1 or 2 io96b instances -- split up as "cal" vs "phy"

   //  ---- arch ----
   generate
      begin: arch_emif_0
         if (MEM_NUM_CHANNELS_PER_IO96 == 2) begin: arch0_2ch_per_io 
            // {{{  arch_0 -- 2ch connected (0,1)         
            io0_emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_io96b_top #(
               .PHY_NOC_EN                (PHY_USE_NOC_INTF         ),
               .AXI4_USER_DATA_ENABLE     (IO0_AXI4_USER_DATA_ENABLE),
               .MEM_NUM_CHANNELS_PER_IO96 (MEM_NUM_CHANNELS_PER_IO96),
               .AXI4_DATA_WIDTH           (AXI4_DATA_WIDTH          ),
               .AXI4_ADDR_WIDTH           (AXI4_ADDR_WIDTH          ),
               .PHY_I3C_EN                (PHY_I3C_EN               ),
               .SLIM_BL_EN                (IO0_SLIM_BL_EN           ),
               .AXI4_AXUSER_WIDTH         (AXI4_AXUSER_WIDTH        ),
               .LS_MEM_DQ_WIDTH           (IO0_LS_MEM_DQ_WIDTH      ),
               .MEM_LBD_WIDTH             (MEM_LBD_WIDTH            ),
               .MEM_LBS_WIDTH             (MEM_LBS_WIDTH            ),
               .OCT_RZQIN_WIDTH           (OCT_RZQIN_WIDTH          ),
               .MEM_ACT_N_WIDTH           (MEM_ACT_N_WIDTH          ),
               .MEM_ALERT_N_WIDTH         (MEM_ALERT_N_WIDTH        ),
               .MEM_A_WIDTH               (MEM_A_WIDTH              ),
               .MEM_BANK_ADDR_WIDTH       (MEM_BANK_ADDR_WIDTH      ),
               .MEM_BANK_GROUP_ADDR_WIDTH (MEM_BANK_GROUP_ADDR_WIDTH),
               .MEM_CA_WIDTH              (MEM_CA_WIDTH             ),
               .MEM_CHIP_ID_WIDTH         (MEM_CHIP_ID_WIDTH        ),
               .MEM_CKE_WIDTH             (MEM_CKE_WIDTH            ),
               .MEM_CK_C_WIDTH            (MEM_CK_C_WIDTH           ),
               .MEM_CK_T_WIDTH            (MEM_CK_T_WIDTH           ),
               .MEM_CS_N_WIDTH            (MEM_CS_N_WIDTH           ),
               .MEM_CS_WIDTH              (MEM_CS_WIDTH             ),
               .MEM_DBI_N_WIDTH           (MEM_DBI_N_WIDTH          ),
               .MEM_DMI_WIDTH             (MEM_DMI_WIDTH            ),
               .MEM_DM_N_WIDTH            (MEM_DM_N_WIDTH           ),
               .MEM_DQS_C_WIDTH           (MEM_DQS_C_WIDTH          ),
               .MEM_DQS_T_WIDTH           (MEM_DQS_T_WIDTH          ),
               .MEM_DQ_WIDTH              (MEM_DQ_WIDTH             ),
               .MEM_ODT_WIDTH             (MEM_ODT_WIDTH            ),
               .MEM_PAR_WIDTH             (MEM_PAR_WIDTH            ),
               .MEM_RDQS_C_WIDTH          (MEM_RDQS_C_WIDTH         ),
               .MEM_RDQS_T_WIDTH          (MEM_RDQS_T_WIDTH         ),
               .MEM_RESET_N_WIDTH         (MEM_RESET_N_WIDTH        ),
               .MEM_WCK_C_WIDTH           (MEM_WCK_C_WIDTH          ),
               .MEM_WCK_T_WIDTH           (MEM_WCK_T_WIDTH          )
            ) arch_0 (
               .ref_clk_0            ( ref_clk),
               .core_init_n_0        ( core_init_n),
               .usr_clk_0            ( s0_axi4_clock_out),
               .usr_rst_n_0          ( s0_axi4_reset_n),
               .usr_async_clk_0      ( s0_axi4_clock_in),

               .noc_aclk_0           ( noc_aclk_0),
               .noc_aclk_1           ( noc_aclk_1),
               .noc_rst_n_0          ( noc_rst_n_0),
               .noc_rst_n_1          ( noc_rst_n_1),

               .s0_axi4_araddr       ( s_axi_to_arch[0].araddr),
               .s0_axi4_arburst      ( s_axi_to_arch[0].arburst),
               .s0_axi4_arid         ( s_axi_to_arch[0].arid),
               .s0_axi4_arlen        ( s_axi_to_arch[0].arlen),
               .s0_axi4_arlock       ( s_axi_to_arch[0].arlock),
               .s0_axi4_arqos        ( s_axi_to_arch[0].arqos),
               .s0_axi4_arsize       ( s_axi_to_arch[0].arsize),
               .s0_axi4_aruser       ( s_axi_to_arch[0].aruser),
               .s0_axi4_arvalid      ( s_axi_to_arch[0].arvalid),
               .s0_axi4_arcache      ( s_axi_to_arch[0].arcache),
               .s0_axi4_arprot       ( s_axi_to_arch[0].arprot),
               .s0_axi4_awaddr       ( s_axi_to_arch[0].awaddr),
               .s0_axi4_awburst      ( s_axi_to_arch[0].awburst),
               .s0_axi4_awid         ( s_axi_to_arch[0].awid),
               .s0_axi4_awlen        ( s_axi_to_arch[0].awlen),
               .s0_axi4_awlock       ( s_axi_to_arch[0].awlock),
               .s0_axi4_awqos        ( s_axi_to_arch[0].awqos),
               .s0_axi4_awsize       ( s_axi_to_arch[0].awsize),
               .s0_axi4_awuser       ( s_axi_to_arch[0].awuser),
               .s0_axi4_awvalid      ( s_axi_to_arch[0].awvalid),
               .s0_axi4_awcache      ( s_axi_to_arch[0].awcache),
               .s0_axi4_awprot       ( s_axi_to_arch[0].awprot),
               .s0_axi4_bready       ( s_axi_to_arch[0].bready),
               .s0_axi4_rready       ( s_axi_to_arch[0].rready),
               .s0_axi4_wdata        ( s_axi_to_arch[0].wdata),
               .s0_axi4_wlast        ( s_axi_to_arch[0].wlast),
               .s0_axi4_wstrb        ( s_axi_to_arch[0].wstrb),
               .s0_axi4_wuser        ( s_axi_to_arch[0].wuser),
               .s0_axi4_wvalid       ( s_axi_to_arch[0].wvalid),
               .s0_axi4_arready      ( s_axi_to_arch[0].arready),
               .s0_axi4_awready      ( s_axi_to_arch[0].awready),
               .s0_axi4_bid          ( s_axi_to_arch[0].bid),
               .s0_axi4_bresp        ( s_axi_to_arch[0].bresp),
               .s0_axi4_bvalid       ( s_axi_to_arch[0].bvalid),
               .s0_axi4_rdata        ( s_axi_to_arch[0].rdata),
               .s0_axi4_rid          ( s_axi_to_arch[0].rid),
               .s0_axi4_rlast        ( s_axi_to_arch[0].rlast),
               .s0_axi4_rresp        ( s_axi_to_arch[0].rresp),
               .s0_axi4_ruser        ( s_axi_to_arch[0].ruser),
               .s0_axi4_rvalid       ( s_axi_to_arch[0].rvalid),
               .s0_axi4_wready       ( s_axi_to_arch[0].wready),

               .s1_axi4_araddr       ( s_axi_to_arch[1].araddr),
               .s1_axi4_arburst      ( s_axi_to_arch[1].arburst),
               .s1_axi4_arid         ( s_axi_to_arch[1].arid),
               .s1_axi4_arlen        ( s_axi_to_arch[1].arlen),
               .s1_axi4_arlock       ( s_axi_to_arch[1].arlock),
               .s1_axi4_arqos        ( s_axi_to_arch[1].arqos),
               .s1_axi4_arsize       ( s_axi_to_arch[1].arsize),
               .s1_axi4_aruser       ( s_axi_to_arch[1].aruser),
               .s1_axi4_arvalid      ( s_axi_to_arch[1].arvalid),
               .s1_axi4_arcache      ( s_axi_to_arch[1].arcache),
               .s1_axi4_arprot       ( s_axi_to_arch[1].arprot),
               .s1_axi4_awaddr       ( s_axi_to_arch[1].awaddr),
               .s1_axi4_awburst      ( s_axi_to_arch[1].awburst),
               .s1_axi4_awid         ( s_axi_to_arch[1].awid),
               .s1_axi4_awlen        ( s_axi_to_arch[1].awlen),
               .s1_axi4_awlock       ( s_axi_to_arch[1].awlock),
               .s1_axi4_awqos        ( s_axi_to_arch[1].awqos),
               .s1_axi4_awsize       ( s_axi_to_arch[1].awsize),
               .s1_axi4_awuser       ( s_axi_to_arch[1].awuser),
               .s1_axi4_awvalid      ( s_axi_to_arch[1].awvalid),
               .s1_axi4_awcache      ( s_axi_to_arch[1].awcache),
               .s1_axi4_awprot       ( s_axi_to_arch[1].awprot),
               .s1_axi4_bready       ( s_axi_to_arch[1].bready),
               .s1_axi4_rready       ( s_axi_to_arch[1].rready),
               .s1_axi4_wdata        ( s_axi_to_arch[1].wdata),
               .s1_axi4_wlast        ( s_axi_to_arch[1].wlast),
               .s1_axi4_wstrb        ( s_axi_to_arch[1].wstrb),
               .s1_axi4_wuser        ( s_axi_to_arch[1].wuser),
               .s1_axi4_wvalid       ( s_axi_to_arch[1].wvalid),
               .s1_axi4_arready      ( s_axi_to_arch[1].arready),
               .s1_axi4_awready      ( s_axi_to_arch[1].awready),
               .s1_axi4_bid          ( s_axi_to_arch[1].bid),
               .s1_axi4_bresp        ( s_axi_to_arch[1].bresp),
               .s1_axi4_bvalid       ( s_axi_to_arch[1].bvalid),
               .s1_axi4_rdata        ( s_axi_to_arch[1].rdata),
               .s1_axi4_rid          ( s_axi_to_arch[1].rid),
               .s1_axi4_rlast        ( s_axi_to_arch[1].rlast),
               .s1_axi4_rresp        ( s_axi_to_arch[1].rresp),
               .s1_axi4_ruser        ( s_axi_to_arch[1].ruser),
               .s1_axi4_rvalid       ( s_axi_to_arch[1].rvalid),
               .s1_axi4_wready       ( s_axi_to_arch[1].wready),

               .calbus_0             ( calbus_0),
               .calbus_readdata_0    ( calbus_readdata_0),
               .calbus_param_table_0 ( calbus_param_table_0),

               .mem_ck_t_0           ( mem_0_ck_t),
               .mem_ck_c_0           ( mem_0_ck_c),
               .mem_cke_0            ( mem_0_cke),
               .mem_odt_0            ( mem_0_odt),
               .mem_cs_n_0           ( mem_0_cs_n),
               .mem_c_0              ( mem_0_c),
               .mem_a_0              ( mem_0_a),
               .mem_ba_0             ( mem_0_ba),
               .mem_bg_0             ( mem_0_bg),
               .mem_act_n_0          ( mem_0_act_n),
               .mem_par_0            ( mem_0_par),
               .mem_alert_n_0        ( mem_0_alert_n),
               .mem_reset_n_0        ( mem_0_reset_n),
               .mem_dq_0             ( mem_0_dq),
               .mem_dqs_t_0          ( mem_0_dqs_t),
               .mem_dqs_c_0          ( mem_0_dqs_c),
               .mem_dbi_n_0          ( mem_0_dbi_n),
               .mem_ca_0             ( mem_0_ca),
               .mem_dm_n_0           ( mem_0_dm_n),
               .mem_cs_0             ( mem_0_cs),
               .mem_wck_t_0          ( mem_0_wck_t),
               .mem_wck_c_0          ( mem_0_wck_c),
               .mem_rdqs_t_0         ( mem_0_rdqs_t),
               .mem_rdqs_c_0         ( mem_0_rdqs_c),
               .mem_dmi_0            ( mem_0_dmi),
               .oct_rzqin_0          ( oct_rzqin_0),

               .mem_ck_t_1           ( mem_1_ck_t),
               .mem_ck_c_1           ( mem_1_ck_c),
               .mem_cke_1            ( mem_1_cke),
               .mem_odt_1            ( mem_1_odt),
               .mem_cs_n_1           ( mem_1_cs_n),
               .mem_c_1              ( mem_1_c),
               .mem_a_1              ( mem_1_a),
               .mem_ba_1             ( mem_1_ba),
               .mem_bg_1             ( mem_1_bg),
               .mem_act_n_1          ( mem_1_act_n),
               .mem_par_1            ( mem_1_par),
               .mem_alert_n_1        ( mem_1_alert_n),
               .mem_reset_n_1        ( mem_1_reset_n),
               .mem_dq_1             ( mem_1_dq),
               .mem_dqs_t_1          ( mem_1_dqs_t),
               .mem_dqs_c_1          ( mem_1_dqs_c),
               .mem_dbi_n_1          ( mem_1_dbi_n),
               .mem_ca_1             ( mem_1_ca),
               .mem_dm_n_1           ( mem_1_dm_n),
               .mem_cs_1             ( mem_1_cs),
               .mem_wck_t_1          ( mem_1_wck_t),
               .mem_wck_c_1          ( mem_1_wck_c),
               .mem_rdqs_t_1         ( mem_1_rdqs_t),
               .mem_rdqs_c_1         ( mem_1_rdqs_c),
               .mem_dmi_1            ( mem_1_dmi),
               .oct_rzqin_1          ( oct_rzqin_1),

               .ls_usr_clk_0         ( ),
               .ls_usr_rst_n_0       ( ),

               .mem_lbd_0            ( mem_lbd_0),
               .mem_lbs_0            ( mem_lbs_0),
               .i3c_scl_0            ( i3c_scl_0),
               .i3c_sda_0            ( i3c_sda_0)
            );
         // }}}
         end else begin: arch0_1ch_per_io
         // {{{ arch 0 -- 1ch connected (0)
         io0_emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_io96b_top #(
               .PHY_NOC_EN                (PHY_USE_NOC_INTF         ),
               .AXI4_USER_DATA_ENABLE     (IO0_AXI4_USER_DATA_ENABLE),
               .MEM_NUM_CHANNELS_PER_IO96 (MEM_NUM_CHANNELS_PER_IO96),
               .AXI4_DATA_WIDTH           (AXI4_DATA_WIDTH          ),
               .AXI4_ADDR_WIDTH           (AXI4_ADDR_WIDTH          ),
               .PHY_I3C_EN                (PHY_I3C_EN               ),
               .SLIM_BL_EN                (IO0_SLIM_BL_EN           ),
               .AXI4_AXUSER_WIDTH         (AXI4_AXUSER_WIDTH        ),
               .LS_MEM_DQ_WIDTH           (IO0_LS_MEM_DQ_WIDTH      ),
               .MEM_LBD_WIDTH             (IS_DDR5_RDIMM == 1 ?  MEM_LBD_WIDTH : 0),
               .MEM_LBS_WIDTH             (IS_DDR5_RDIMM == 1 ?  0: MEM_LBS_WIDTH),
               .OCT_RZQIN_WIDTH           (OCT_RZQIN_WIDTH          ),
               .MEM_ACT_N_WIDTH           (MEM_ACT_N_WIDTH          ),
               .MEM_ALERT_N_WIDTH         (MEM_ALERT_N_WIDTH        ),
               .MEM_A_WIDTH               (MEM_A_WIDTH              ),
               .MEM_BANK_ADDR_WIDTH       (MEM_BANK_ADDR_WIDTH      ),
               .MEM_BANK_GROUP_ADDR_WIDTH (MEM_BANK_GROUP_ADDR_WIDTH),
               .MEM_CA_WIDTH              (MEM_CA_WIDTH             ),
               .MEM_CHIP_ID_WIDTH         (MEM_CHIP_ID_WIDTH        ),
               .MEM_CKE_WIDTH             (MEM_CKE_WIDTH            ),
               .MEM_CK_C_WIDTH            (MEM_CK_C_WIDTH           ),
               .MEM_CK_T_WIDTH            (MEM_CK_T_WIDTH           ),
               .MEM_CS_N_WIDTH            (MEM_CS_N_WIDTH           ),
               .MEM_CS_WIDTH              (MEM_CS_WIDTH             ),
               .MEM_DBI_N_WIDTH           (MEM_DBI_N_WIDTH          ),
               .MEM_DMI_WIDTH             (MEM_DMI_WIDTH            ),
               .MEM_DM_N_WIDTH            (MEM_DM_N_WIDTH           ),
               .MEM_DQS_C_WIDTH           (MEM_DQS_C_WIDTH          ),
               .MEM_DQS_T_WIDTH           (MEM_DQS_T_WIDTH          ),
               .MEM_DQ_WIDTH              (MEM_DQ_WIDTH             ),
               .MEM_ODT_WIDTH             (MEM_ODT_WIDTH            ),
               .MEM_PAR_WIDTH             (MEM_PAR_WIDTH            ),
               .MEM_RDQS_C_WIDTH          (MEM_RDQS_C_WIDTH         ),
               .MEM_RDQS_T_WIDTH          (MEM_RDQS_T_WIDTH         ),
               .MEM_RESET_N_WIDTH         (MEM_RESET_N_WIDTH        ),
               .MEM_WCK_C_WIDTH           (MEM_WCK_C_WIDTH          ),
               .MEM_WCK_T_WIDTH           (MEM_WCK_T_WIDTH          )
            ) arch_0 (
               .ref_clk_0            ( ref_clk),
               .core_init_n_0        ( core_init_n),
               .usr_clk_0            ( s0_axi4_clock_out),
               .usr_rst_n_0          ( s0_axi4_reset_n),
               .usr_async_clk_0      ( s0_axi4_clock_in),

               .noc_aclk_0           ( noc_aclk_0),
               .noc_aclk_1           ( ),
               .noc_rst_n_0          ( noc_rst_n_0),
               .noc_rst_n_1          ( ),

               .s0_axi4_araddr       ( s_axi_to_arch[0].araddr),
               .s0_axi4_arburst      ( s_axi_to_arch[0].arburst),
               .s0_axi4_arid         ( s_axi_to_arch[0].arid),
               .s0_axi4_arlen        ( s_axi_to_arch[0].arlen),
               .s0_axi4_arlock       ( s_axi_to_arch[0].arlock),
               .s0_axi4_arqos        ( s_axi_to_arch[0].arqos),
               .s0_axi4_arsize       ( s_axi_to_arch[0].arsize),
               .s0_axi4_aruser       ( s_axi_to_arch[0].aruser),
               .s0_axi4_arvalid      ( s_axi_to_arch[0].arvalid),
               .s0_axi4_arcache      ( s_axi_to_arch[0].arcache),
               .s0_axi4_arprot       ( s_axi_to_arch[0].arprot),
               .s0_axi4_awaddr       ( s_axi_to_arch[0].awaddr),
               .s0_axi4_awburst      ( s_axi_to_arch[0].awburst),
               .s0_axi4_awid         ( s_axi_to_arch[0].awid),
               .s0_axi4_awlen        ( s_axi_to_arch[0].awlen),
               .s0_axi4_awlock       ( s_axi_to_arch[0].awlock),
               .s0_axi4_awqos        ( s_axi_to_arch[0].awqos),
               .s0_axi4_awsize       ( s_axi_to_arch[0].awsize),
               .s0_axi4_awuser       ( s_axi_to_arch[0].awuser),
               .s0_axi4_awvalid      ( s_axi_to_arch[0].awvalid),
               .s0_axi4_awcache      ( s_axi_to_arch[0].awcache),
               .s0_axi4_awprot       ( s_axi_to_arch[0].awprot),
               .s0_axi4_bready       ( s_axi_to_arch[0].bready),
               .s0_axi4_rready       ( s_axi_to_arch[0].rready),
               .s0_axi4_wdata        ( s_axi_to_arch[0].wdata),
               .s0_axi4_wlast        ( s_axi_to_arch[0].wlast),
               .s0_axi4_wstrb        ( s_axi_to_arch[0].wstrb),
               .s0_axi4_wuser        ( s_axi_to_arch[0].wuser),
               .s0_axi4_wvalid       ( s_axi_to_arch[0].wvalid),
               .s0_axi4_arready      ( s_axi_to_arch[0].arready),
               .s0_axi4_awready      ( s_axi_to_arch[0].awready),
               .s0_axi4_bid          ( s_axi_to_arch[0].bid),
               .s0_axi4_bresp        ( s_axi_to_arch[0].bresp),
               .s0_axi4_bvalid       ( s_axi_to_arch[0].bvalid),
               .s0_axi4_rdata        ( s_axi_to_arch[0].rdata),
               .s0_axi4_rid          ( s_axi_to_arch[0].rid),
               .s0_axi4_rlast        ( s_axi_to_arch[0].rlast),
               .s0_axi4_rresp        ( s_axi_to_arch[0].rresp),
               .s0_axi4_ruser        ( s_axi_to_arch[0].ruser),
               .s0_axi4_rvalid       ( s_axi_to_arch[0].rvalid),
               .s0_axi4_wready       ( s_axi_to_arch[0].wready),

               .s1_axi4_araddr       (),
               .s1_axi4_arburst      (),
               .s1_axi4_arid         (),
               .s1_axi4_arlen        (),
               .s1_axi4_arlock       (),
               .s1_axi4_arqos        (),
               .s1_axi4_arsize       (),
               .s1_axi4_aruser       (),
               .s1_axi4_arvalid      (),
               .s1_axi4_arcache      (),
               .s1_axi4_arprot       (),
               .s1_axi4_awaddr       (),
               .s1_axi4_awburst      (),
               .s1_axi4_awid         (),
               .s1_axi4_awlen        (),
               .s1_axi4_awlock       (),
               .s1_axi4_awqos        (),
               .s1_axi4_awsize       (),
               .s1_axi4_awuser       (),
               .s1_axi4_awvalid      (),
               .s1_axi4_awcache      (),
               .s1_axi4_awprot       (),
               .s1_axi4_bready       (),
               .s1_axi4_rready       (),
               .s1_axi4_wdata        (),
               .s1_axi4_wlast        (),
               .s1_axi4_wstrb        (),
               .s1_axi4_wuser        (),
               .s1_axi4_wvalid       (),
               .s1_axi4_arready      (),
               .s1_axi4_awready      (),
               .s1_axi4_bid          (),
               .s1_axi4_bresp        (),
               .s1_axi4_bvalid       (),
               .s1_axi4_rdata        (),
               .s1_axi4_rid          (),
               .s1_axi4_rlast        (),
               .s1_axi4_rresp        (),
               .s1_axi4_ruser        (),
               .s1_axi4_rvalid       (),
               .s1_axi4_wready       (),

               .calbus_0             ( calbus_0),
               .calbus_readdata_0    ( calbus_readdata_0),
               .calbus_param_table_0 ( calbus_param_table_0),

               .mem_ck_t_0           ( mem_0_ck_t),
               .mem_ck_c_0           ( mem_0_ck_c),
               .mem_cke_0            ( mem_0_cke),
               .mem_odt_0            ( mem_0_odt),
               .mem_cs_n_0           ( mem_0_cs_n),
               .mem_c_0              ( mem_0_c),
               .mem_a_0              ( mem_0_a),
               .mem_ba_0             ( mem_0_ba),
               .mem_bg_0             ( mem_0_bg),
               .mem_act_n_0          ( mem_0_act_n),
               .mem_par_0            ( mem_0_par),
               .mem_alert_n_0        ( mem_0_alert_n),
               .mem_reset_n_0        ( mem_0_reset_n),
               .mem_dq_0             ( mem_0_dq),
               .mem_dqs_t_0          ( mem_0_dqs_t),
               .mem_dqs_c_0          ( mem_0_dqs_c),
               .mem_dbi_n_0          ( mem_0_dbi_n),
               .mem_ca_0             ( mem_0_ca),
               .mem_dm_n_0           ( mem_0_dm_n),
               .mem_cs_0             ( mem_0_cs),
               .mem_wck_t_0          ( mem_0_wck_t),
               .mem_wck_c_0          ( mem_0_wck_c),
               .mem_rdqs_t_0         ( mem_0_rdqs_t),
               .mem_rdqs_c_0         ( mem_0_rdqs_c),
               .mem_dmi_0            ( mem_0_dmi),
               .oct_rzqin_0          ( oct_rzqin_0),

               .mem_ck_t_1           (),
               .mem_ck_c_1           (),
               .mem_cke_1            (),
               .mem_odt_1            (),
               .mem_cs_n_1           (),
               .mem_c_1              (),
               .mem_a_1              (),
               .mem_ba_1             (),
               .mem_bg_1             (),
               .mem_act_n_1          (),
               .mem_par_1            (),
               .mem_alert_n_1        (),
               .mem_reset_n_1        (),
               .mem_dq_1             (),
               .mem_dqs_t_1          (),
               .mem_dqs_c_1          (),
               .mem_dbi_n_1          (),
               .mem_ca_1             (),
               .mem_dm_n_1           (),
               .mem_cs_1             (),
               .mem_wck_t_1          (),
               .mem_wck_c_1          (),
               .mem_rdqs_t_1         (),
               .mem_rdqs_c_1         (),
               .mem_dmi_1            (),
               .oct_rzqin_1          (),

               .ls_usr_clk_0         ( ),
               .ls_usr_rst_n_0       ( ),

               .mem_lbd_0            ( mem_lbd_0),
            .mem_lbs_0            ( ),
               .i3c_scl_0            ( i3c_scl_0),
               .i3c_sda_0            ( i3c_sda_0)
            );
         //}}}
         end
      end
         
      begin: arch_emif_1
         if (MEM_NUM_IO96 == 2) begin: arch1_exists
            if (MEM_NUM_CHANNELS_PER_IO96 == 2) begin: arch1_2ch_per_io 
               // {{{ arch_1 -- 2ch connected (2,3)
               io1_emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_io96b_top #(
                  .PHY_NOC_EN                (PHY_USE_NOC_INTF         ),
                  .AXI4_USER_DATA_ENABLE     (IO1_AXI4_USER_DATA_ENABLE),
                  .MEM_NUM_CHANNELS_PER_IO96 (MEM_NUM_CHANNELS_PER_IO96),
                  .AXI4_DATA_WIDTH           (AXI4_DATA_WIDTH          ),
                  .AXI4_ADDR_WIDTH           (AXI4_ADDR_WIDTH          ),
                  .PHY_I3C_EN                (PHY_I3C_EN               ),
                  .SLIM_BL_EN                (IO1_SLIM_BL_EN           ),
                  .AXI4_AXUSER_WIDTH         (AXI4_AXUSER_WIDTH        ),
                  .LS_MEM_DQ_WIDTH           (IO1_LS_MEM_DQ_WIDTH      ),
                  .MEM_LBD_WIDTH             (MEM_LBD_WIDTH            ),
                  .MEM_LBS_WIDTH             (MEM_LBS_WIDTH            ),
                  .OCT_RZQIN_WIDTH           (OCT_RZQIN_WIDTH          ),
                  .MEM_ACT_N_WIDTH           (MEM_ACT_N_WIDTH          ),
                  .MEM_ALERT_N_WIDTH         (MEM_ALERT_N_WIDTH        ),
                  .MEM_A_WIDTH               (MEM_A_WIDTH              ),
                  .MEM_BANK_ADDR_WIDTH       (MEM_BANK_ADDR_WIDTH      ),
                  .MEM_BANK_GROUP_ADDR_WIDTH (MEM_BANK_GROUP_ADDR_WIDTH),
                  .MEM_CA_WIDTH              (MEM_CA_WIDTH             ),
                  .MEM_CHIP_ID_WIDTH         (MEM_CHIP_ID_WIDTH        ),
                  .MEM_CKE_WIDTH             (MEM_CKE_WIDTH            ),
                  .MEM_CK_C_WIDTH            (MEM_CK_C_WIDTH           ),
                  .MEM_CK_T_WIDTH            (MEM_CK_T_WIDTH           ),
                  .MEM_CS_N_WIDTH            (MEM_CS_N_WIDTH           ),
                  .MEM_CS_WIDTH              (MEM_CS_WIDTH             ),
                  .MEM_DBI_N_WIDTH           (MEM_DBI_N_WIDTH          ),
                  .MEM_DMI_WIDTH             (MEM_DMI_WIDTH            ),
                  .MEM_DM_N_WIDTH            (MEM_DM_N_WIDTH           ),
                  .MEM_DQS_C_WIDTH           (MEM_DQS_C_WIDTH          ),
                  .MEM_DQS_T_WIDTH           (MEM_DQS_T_WIDTH          ),
                  .MEM_DQ_WIDTH              (MEM_DQ_WIDTH             ),
                  .MEM_ODT_WIDTH             (MEM_ODT_WIDTH            ),
                  .MEM_PAR_WIDTH             (MEM_PAR_WIDTH            ),
                  .MEM_RDQS_C_WIDTH          (MEM_RDQS_C_WIDTH         ),
                  .MEM_RDQS_T_WIDTH          (MEM_RDQS_T_WIDTH         ),
                  .MEM_RESET_N_WIDTH         (0),
                  .MEM_WCK_C_WIDTH           (MEM_WCK_C_WIDTH          ),
                  .MEM_WCK_T_WIDTH           (MEM_WCK_T_WIDTH          )
               ) arch_1 (
               .ref_clk_0            ( ref_clk),
               .core_init_n_0        ( core_init_n),
               .usr_clk_0            ( s1_axi4_clock_out),
               .usr_rst_n_0          ( s1_axi4_reset_n),
               .usr_async_clk_0      ( s0_axi4_clock_in),

               .noc_aclk_0           ( noc_aclk_2),
               .noc_aclk_1           ( noc_aclk_3),
               .noc_rst_n_0          ( noc_rst_n_2),
               .noc_rst_n_1          ( noc_rst_n_3),

               .s0_axi4_araddr       ( s_axi_to_arch[2].araddr),
               .s0_axi4_arburst      ( s_axi_to_arch[2].arburst),
               .s0_axi4_arid         ( s_axi_to_arch[2].arid),
               .s0_axi4_arlen        ( s_axi_to_arch[2].arlen),
               .s0_axi4_arlock       ( s_axi_to_arch[2].arlock),
               .s0_axi4_arqos        ( s_axi_to_arch[2].arqos),
               .s0_axi4_arsize       ( s_axi_to_arch[2].arsize),
               .s0_axi4_aruser       ( s_axi_to_arch[2].aruser),
               .s0_axi4_arvalid      ( s_axi_to_arch[2].arvalid),
               .s0_axi4_arcache      ( s_axi_to_arch[2].arcache),
               .s0_axi4_arprot       ( s_axi_to_arch[2].arprot),
               .s0_axi4_awaddr       ( s_axi_to_arch[2].awaddr),
               .s0_axi4_awburst      ( s_axi_to_arch[2].awburst),
               .s0_axi4_awid         ( s_axi_to_arch[2].awid),
               .s0_axi4_awlen        ( s_axi_to_arch[2].awlen),
               .s0_axi4_awlock       ( s_axi_to_arch[2].awlock),
               .s0_axi4_awqos        ( s_axi_to_arch[2].awqos),
               .s0_axi4_awsize       ( s_axi_to_arch[2].awsize),
               .s0_axi4_awuser       ( s_axi_to_arch[2].awuser),
               .s0_axi4_awvalid      ( s_axi_to_arch[2].awvalid),
               .s0_axi4_awcache      ( s_axi_to_arch[2].awcache),
               .s0_axi4_awprot       ( s_axi_to_arch[2].awprot),
               .s0_axi4_bready       ( s_axi_to_arch[2].bready),
               .s0_axi4_rready       ( s_axi_to_arch[2].rready),
               .s0_axi4_wdata        ( s_axi_to_arch[2].wdata),
               .s0_axi4_wlast        ( s_axi_to_arch[2].wlast),
               .s0_axi4_wstrb        ( s_axi_to_arch[2].wstrb),
               .s0_axi4_wuser        ( s_axi_to_arch[2].wuser),
               .s0_axi4_wvalid       ( s_axi_to_arch[2].wvalid),
               .s0_axi4_arready      ( s_axi_to_arch[2].arready),
               .s0_axi4_awready      ( s_axi_to_arch[2].awready),
               .s0_axi4_bid          ( s_axi_to_arch[2].bid),
               .s0_axi4_bresp        ( s_axi_to_arch[2].bresp),
               .s0_axi4_bvalid       ( s_axi_to_arch[2].bvalid),
               .s0_axi4_rdata        ( s_axi_to_arch[2].rdata),
               .s0_axi4_rid          ( s_axi_to_arch[2].rid),
               .s0_axi4_rlast        ( s_axi_to_arch[2].rlast),
               .s0_axi4_rresp        ( s_axi_to_arch[2].rresp),
               .s0_axi4_ruser        ( s_axi_to_arch[2].ruser),
               .s0_axi4_rvalid       ( s_axi_to_arch[2].rvalid),
               .s0_axi4_wready       ( s_axi_to_arch[2].wready),

               .s1_axi4_araddr       ( s_axi_to_arch[3].araddr),
               .s1_axi4_arburst      ( s_axi_to_arch[3].arburst),
               .s1_axi4_arid         ( s_axi_to_arch[3].arid),
               .s1_axi4_arlen        ( s_axi_to_arch[3].arlen),
               .s1_axi4_arlock       ( s_axi_to_arch[3].arlock),
               .s1_axi4_arqos        ( s_axi_to_arch[3].arqos),
               .s1_axi4_arsize       ( s_axi_to_arch[3].arsize),
               .s1_axi4_aruser       ( s_axi_to_arch[3].aruser),
               .s1_axi4_arvalid      ( s_axi_to_arch[3].arvalid),
               .s1_axi4_arcache      ( s_axi_to_arch[3].arcache),
               .s1_axi4_arprot       ( s_axi_to_arch[3].arprot),
               .s1_axi4_awaddr       ( s_axi_to_arch[3].awaddr),
               .s1_axi4_awburst      ( s_axi_to_arch[3].awburst),
               .s1_axi4_awid         ( s_axi_to_arch[3].awid),
               .s1_axi4_awlen        ( s_axi_to_arch[3].awlen),
               .s1_axi4_awlock       ( s_axi_to_arch[3].awlock),
               .s1_axi4_awqos        ( s_axi_to_arch[3].awqos),
               .s1_axi4_awsize       ( s_axi_to_arch[3].awsize),
               .s1_axi4_awuser       ( s_axi_to_arch[3].awuser),
               .s1_axi4_awvalid      ( s_axi_to_arch[3].awvalid),
               .s1_axi4_awcache      ( s_axi_to_arch[3].awcache),
               .s1_axi4_awprot       ( s_axi_to_arch[3].awprot),
               .s1_axi4_bready       ( s_axi_to_arch[3].bready),
               .s1_axi4_rready       ( s_axi_to_arch[3].rready),
               .s1_axi4_wdata        ( s_axi_to_arch[3].wdata),
               .s1_axi4_wlast        ( s_axi_to_arch[3].wlast),
               .s1_axi4_wstrb        ( s_axi_to_arch[3].wstrb),
               .s1_axi4_wuser        ( s_axi_to_arch[3].wuser),
               .s1_axi4_wvalid       ( s_axi_to_arch[3].wvalid),
               .s1_axi4_arready      ( s_axi_to_arch[3].arready),
               .s1_axi4_awready      ( s_axi_to_arch[3].awready),
               .s1_axi4_bid          ( s_axi_to_arch[3].bid),
               .s1_axi4_bresp        ( s_axi_to_arch[3].bresp),
               .s1_axi4_bvalid       ( s_axi_to_arch[3].bvalid),
               .s1_axi4_rdata        ( s_axi_to_arch[3].rdata),
               .s1_axi4_rid          ( s_axi_to_arch[3].rid),
               .s1_axi4_rlast        ( s_axi_to_arch[3].rlast),
               .s1_axi4_rresp        ( s_axi_to_arch[3].rresp),
               .s1_axi4_ruser        ( s_axi_to_arch[3].ruser),
               .s1_axi4_rvalid       ( s_axi_to_arch[3].rvalid),
               .s1_axi4_wready       ( s_axi_to_arch[3].wready),

               .calbus_0             ( calbus_1),
               .calbus_readdata_0    ( calbus_readdata_1),
               .calbus_param_table_0 ( calbus_param_table_1),

               .mem_ck_t_0           ( mem_2_ck_t),
               .mem_ck_c_0           ( mem_2_ck_c),
               .mem_cke_0            ( mem_2_cke),
               .mem_odt_0            ( mem_2_odt),
               .mem_cs_n_0           ( mem_2_cs_n),
               .mem_c_0              ( mem_2_c),
               .mem_a_0              ( mem_2_a),
               .mem_ba_0             ( mem_2_ba),
               .mem_bg_0             ( mem_2_bg),
               .mem_act_n_0          ( mem_2_act_n),
               .mem_par_0            ( mem_2_par),
               .mem_alert_n_0        ( mem_2_alert_n),
               .mem_reset_n_0        ( mem_2_reset_n),
               .mem_dq_0             ( mem_2_dq),
               .mem_dqs_t_0          ( mem_2_dqs_t),
               .mem_dqs_c_0          ( mem_2_dqs_c),
               .mem_dbi_n_0          ( mem_2_dbi_n),
               .mem_ca_0             ( mem_2_ca),
               .mem_dm_n_0           ( mem_2_dm_n),
               .mem_cs_0             ( mem_2_cs),
               .mem_wck_t_0          ( mem_2_wck_t),
               .mem_wck_c_0          ( mem_2_wck_c),
               .mem_rdqs_t_0         ( mem_2_rdqs_t),
               .mem_rdqs_c_0         ( mem_2_rdqs_c),
               .mem_dmi_0            ( mem_2_dmi),
               .oct_rzqin_0          ( oct_rzqin_2),

               .mem_ck_t_1           ( mem_3_ck_t),
               .mem_ck_c_1           ( mem_3_ck_c),
               .mem_cke_1            ( mem_3_cke),
               .mem_odt_1            ( mem_3_odt),
               .mem_cs_n_1           ( mem_3_cs_n),
               .mem_c_1              ( mem_3_c),
               .mem_a_1              ( mem_3_a),
               .mem_ba_1             ( mem_3_ba),
               .mem_bg_1             ( mem_3_bg),
               .mem_act_n_1          ( mem_3_act_n),
               .mem_par_1            ( mem_3_par),
               .mem_alert_n_1        ( mem_3_alert_n),
               .mem_reset_n_1        ( mem_3_reset_n),
               .mem_dq_1             ( mem_3_dq),
               .mem_dqs_t_1          ( mem_3_dqs_t),
               .mem_dqs_c_1          ( mem_3_dqs_c),
               .mem_dbi_n_1          ( mem_3_dbi_n),
               .mem_ca_1             ( mem_3_ca),
               .mem_dm_n_1           ( mem_3_dm_n),
               .mem_cs_1             ( mem_3_cs),
               .mem_wck_t_1          ( mem_3_wck_t),
               .mem_wck_c_1          ( mem_3_wck_c),
               .mem_rdqs_t_1         ( mem_3_rdqs_t),
               .mem_rdqs_c_1         ( mem_3_rdqs_c),
               .mem_dmi_1            ( mem_3_dmi),
               .oct_rzqin_1          ( oct_rzqin_3),

               .ls_usr_clk_0         ( ),
               .ls_usr_rst_n_0       ( ),

               .mem_lbd_0            ( ),
               .mem_lbs_0            ( ),
               .i3c_scl_0            ( ),
               .i3c_sda_0            ( )
            ); 
            //}}}
            end else begin: arch1_1ch_per_io
            // {{{ arch 1 -- 1ch connected
            io1_emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_io96b_top #(
                  .PHY_NOC_EN                (PHY_USE_NOC_INTF         ),
                  .AXI4_USER_DATA_ENABLE     (IO1_AXI4_USER_DATA_ENABLE    ),
                  .MEM_NUM_CHANNELS_PER_IO96 (MEM_NUM_CHANNELS_PER_IO96),
                  .AXI4_DATA_WIDTH           (AXI4_DATA_WIDTH          ),
                  .AXI4_ADDR_WIDTH           (AXI4_ADDR_WIDTH          ),
                  .PHY_I3C_EN                (0                        ),
                  .SLIM_BL_EN                (IO1_SLIM_BL_EN),
                  .AXI4_AXUSER_WIDTH         (AXI4_AXUSER_WIDTH        ),
                  .LS_MEM_DQ_WIDTH           (IO1_LS_MEM_DQ_WIDTH          ),
                  .MEM_LBD_WIDTH             (IS_DDR5_RDIMM == 1 ? 0 : MEM_LBD_WIDTH),
                  .MEM_LBS_WIDTH             (IS_DDR5_RDIMM == 1 ? MEM_LBS_WIDTH : 0),
                  .OCT_RZQIN_WIDTH           (OCT_RZQIN_WIDTH          ),
                  .MEM_ACT_N_WIDTH           (MEM_ACT_N_WIDTH          ),
                  .MEM_ALERT_N_WIDTH         (MEM_ALERT_N_WIDTH        ),
                  .MEM_A_WIDTH               (MEM_A_WIDTH              ),
                  .MEM_BANK_ADDR_WIDTH       (MEM_BANK_ADDR_WIDTH      ),
                  .MEM_BANK_GROUP_ADDR_WIDTH (MEM_BANK_GROUP_ADDR_WIDTH),
                  .MEM_CA_WIDTH              (MEM_CA_WIDTH             ),
                  .MEM_CHIP_ID_WIDTH         (MEM_CHIP_ID_WIDTH        ),
                  .MEM_CKE_WIDTH             (MEM_CKE_WIDTH            ),
                  .MEM_CK_C_WIDTH            (IS_DDR5_RDIMM == 1 ? 0 : MEM_CK_C_WIDTH),
                  .MEM_CK_T_WIDTH            (IS_DDR5_RDIMM == 1 ? 0 : MEM_CK_T_WIDTH),
                  .MEM_CS_N_WIDTH            (MEM_CS_N_WIDTH           ),
                  .MEM_CS_WIDTH              (MEM_CS_WIDTH             ),
                  .MEM_DBI_N_WIDTH           (MEM_DBI_N_WIDTH          ),
                  .MEM_DMI_WIDTH             (MEM_DMI_WIDTH            ),
                  .MEM_DM_N_WIDTH            (MEM_DM_N_WIDTH           ),
                  .MEM_DQS_C_WIDTH           (MEM_DQS_C_WIDTH          ),
                  .MEM_DQS_T_WIDTH           (MEM_DQS_T_WIDTH          ),
                  .MEM_DQ_WIDTH              (MEM_DQ_WIDTH             ),
                  .MEM_ODT_WIDTH             (MEM_ODT_WIDTH            ),
                  .MEM_PAR_WIDTH             (MEM_PAR_WIDTH            ),
                  .MEM_RDQS_C_WIDTH          (MEM_RDQS_C_WIDTH         ),
                  .MEM_RDQS_T_WIDTH          (MEM_RDQS_T_WIDTH         ),
                  .MEM_RESET_N_WIDTH         (0                        ),
                  .MEM_WCK_C_WIDTH           (MEM_WCK_C_WIDTH          ),
                  .MEM_WCK_T_WIDTH           (MEM_WCK_T_WIDTH          )
            ) arch_1 (
               .ref_clk_0            ( ref_clk),
               .core_init_n_0        ( core_init_n),
               .usr_clk_0            ( s1_axi4_clock_out),
               .usr_rst_n_0          ( s1_axi4_reset_n),
               .usr_async_clk_0      ( s0_axi4_clock_in),

               .noc_aclk_0           ( noc_aclk_1),
               .noc_aclk_1           ( ),
               .noc_rst_n_0          ( noc_rst_n_1),
               .noc_rst_n_1          ( ),

               .s0_axi4_araddr       ( s_axi_to_arch[1].araddr),
               .s0_axi4_arburst      ( s_axi_to_arch[1].arburst),
               .s0_axi4_arid         ( s_axi_to_arch[1].arid),
               .s0_axi4_arlen        ( s_axi_to_arch[1].arlen),
               .s0_axi4_arlock       ( s_axi_to_arch[1].arlock),
               .s0_axi4_arqos        ( s_axi_to_arch[1].arqos),
               .s0_axi4_arsize       ( s_axi_to_arch[1].arsize),
               .s0_axi4_aruser       ( s_axi_to_arch[1].aruser),
               .s0_axi4_arvalid      ( s_axi_to_arch[1].arvalid),
               .s0_axi4_arcache      ( s_axi_to_arch[1].arcache),
               .s0_axi4_arprot       ( s_axi_to_arch[1].arprot),
               .s0_axi4_awaddr       ( s_axi_to_arch[1].awaddr),
               .s0_axi4_awburst      ( s_axi_to_arch[1].awburst),
               .s0_axi4_awid         ( s_axi_to_arch[1].awid),
               .s0_axi4_awlen        ( s_axi_to_arch[1].awlen),
               .s0_axi4_awlock       ( s_axi_to_arch[1].awlock),
               .s0_axi4_awqos        ( s_axi_to_arch[1].awqos),
               .s0_axi4_awsize       ( s_axi_to_arch[1].awsize),
               .s0_axi4_awuser       ( s_axi_to_arch[1].awuser),
               .s0_axi4_awvalid      ( s_axi_to_arch[1].awvalid),
               .s0_axi4_awcache      ( s_axi_to_arch[1].awcache),
               .s0_axi4_awprot       ( s_axi_to_arch[1].awprot),
               .s0_axi4_bready       ( s_axi_to_arch[1].bready),
               .s0_axi4_rready       ( s_axi_to_arch[1].rready),
               .s0_axi4_wdata        ( s_axi_to_arch[1].wdata),
               .s0_axi4_wlast        ( s_axi_to_arch[1].wlast),
               .s0_axi4_wstrb        ( s_axi_to_arch[1].wstrb),
               .s0_axi4_wuser        ( s_axi_to_arch[1].wuser),
               .s0_axi4_wvalid       ( s_axi_to_arch[1].wvalid),
               .s0_axi4_arready      ( s_axi_to_arch[1].arready),
               .s0_axi4_awready      ( s_axi_to_arch[1].awready),
               .s0_axi4_bid          ( s_axi_to_arch[1].bid),
               .s0_axi4_bresp        ( s_axi_to_arch[1].bresp),
               .s0_axi4_bvalid       ( s_axi_to_arch[1].bvalid),
               .s0_axi4_rdata        ( s_axi_to_arch[1].rdata),
               .s0_axi4_rid          ( s_axi_to_arch[1].rid),
               .s0_axi4_rlast        ( s_axi_to_arch[1].rlast),
               .s0_axi4_rresp        ( s_axi_to_arch[1].rresp),
               .s0_axi4_ruser        ( s_axi_to_arch[1].ruser),
               .s0_axi4_rvalid       ( s_axi_to_arch[1].rvalid),
               .s0_axi4_wready       ( s_axi_to_arch[1].wready),

               .s1_axi4_araddr       (),
               .s1_axi4_arburst      (),
               .s1_axi4_arid         (),
               .s1_axi4_arlen        (),
               .s1_axi4_arlock       (),
               .s1_axi4_arqos        (),
               .s1_axi4_arsize       (),
               .s1_axi4_aruser       (),
               .s1_axi4_arvalid      (),
               .s1_axi4_arcache      (),
               .s1_axi4_arprot       (),
               .s1_axi4_awaddr       (),
               .s1_axi4_awburst      (),
               .s1_axi4_awid         (),
               .s1_axi4_awlen        (),
               .s1_axi4_awlock       (),
               .s1_axi4_awqos        (),
               .s1_axi4_awsize       (),
               .s1_axi4_awuser       (),
               .s1_axi4_awvalid      (),
               .s1_axi4_awcache      (),
               .s1_axi4_awprot       (),
               .s1_axi4_bready       (),
               .s1_axi4_rready       (),
               .s1_axi4_wdata        (),
               .s1_axi4_wlast        (),
               .s1_axi4_wstrb        (),
               .s1_axi4_wuser        (),
               .s1_axi4_wvalid       (),
               .s1_axi4_arready      (),
               .s1_axi4_awready      (),
               .s1_axi4_bid          (),
               .s1_axi4_bresp        (),
               .s1_axi4_bvalid       (),
               .s1_axi4_rdata        (),
               .s1_axi4_rid          (),
               .s1_axi4_rlast        (),
               .s1_axi4_rresp        (),
               .s1_axi4_ruser        (),
               .s1_axi4_rvalid       (),
               .s1_axi4_wready       (),

               .calbus_0             ( calbus_1),
               .calbus_readdata_0    ( calbus_readdata_1),
               .calbus_param_table_0 ( calbus_param_table_1),

               .mem_ck_t_0           ( mem_1_ck_t),
               .mem_ck_c_0           ( mem_1_ck_c),
               .mem_cke_0            ( mem_1_cke),
               .mem_odt_0            ( mem_1_odt),
               .mem_cs_n_0           ( mem_1_cs_n),
               .mem_c_0              ( mem_1_c),
               .mem_a_0              ( mem_1_a),
               .mem_ba_0             ( mem_1_ba),
               .mem_bg_0             ( mem_1_bg),
               .mem_act_n_0          ( mem_1_act_n),
               .mem_par_0            ( mem_1_par),
               .mem_alert_n_0        ( mem_1_alert_n),
               .mem_reset_n_0        ( mem_1_reset_n),
               .mem_dq_0             ( mem_1_dq),
               .mem_dqs_t_0          ( mem_1_dqs_t),
               .mem_dqs_c_0          ( mem_1_dqs_c),
               .mem_dbi_n_0          ( mem_1_dbi_n),
               .mem_ca_0             ( mem_1_ca),
               .mem_dm_n_0           ( mem_1_dm_n),
               .mem_cs_0             ( mem_1_cs),
               .mem_wck_t_0          ( mem_1_wck_t),
               .mem_wck_c_0          ( mem_1_wck_c),
               .mem_rdqs_t_0         ( mem_1_rdqs_t),
               .mem_rdqs_c_0         ( mem_1_rdqs_c),
               .mem_dmi_0            ( mem_1_dmi),
               .oct_rzqin_0          ( oct_rzqin_1),

               .mem_ck_t_1           (),
               .mem_ck_c_1           (),
               .mem_cke_1            (),
               .mem_odt_1            (),
               .mem_cs_n_1           (),
               .mem_c_1              (),
               .mem_a_1              (),
               .mem_ba_1             (),
               .mem_bg_1             (),
               .mem_act_n_1          (),
               .mem_par_1            (),
               .mem_alert_n_1        (),
               .mem_reset_n_1        (),
               .mem_dq_1             (),
               .mem_dqs_t_1          (),
               .mem_dqs_c_1          (),
               .mem_dbi_n_1          (),
               .mem_ca_1             (),
               .mem_dm_n_1           (),
               .mem_cs_1             (),
               .mem_wck_t_1          (),
               .mem_wck_c_1          (),
               .mem_rdqs_t_1         (),
               .mem_rdqs_c_1         (),
               .mem_dmi_1            (),
               .oct_rzqin_1          (),

               .ls_usr_clk_0         ( ls_io0_usr_clk),
               .ls_usr_rst_n_0       ( ls_io0_usr_rst_n),

               .mem_lbd_0            (),
            .mem_lbs_0            (mem_lbs_0),
               .i3c_scl_0            (),
               .i3c_sda_0            ()
            );
            //}}}
            end
         end
      end

   endgenerate

   //  ---- cal
   AXILITE_INTF #( 
      .PORT_AXI_AXADDR_WIDTH  (PORT_AXIL_ADDRESS_WIDTH),
      .PORT_AXI_DATA_WIDTH    (PORT_AXIL_DATA_WIDTH),
      .PORT_AXI_RESP_WIDTH    (2),
      .PORT_AXI_STRB_WIDTH    (4),
      .PORT_AXI_AXPROT_WIDTH  (3)
   ) s0_axilite__cal0 (), 
     s0_axilite__cal1 (),
     m0_axilite__cal0 ();
   
   wire [7:0] cal0__ls_to_cal;
   wire [7:0] cal0__ls_from_cal;
   wire [7:0] cal1__ls_to_cal;
   wire [7:0] cal1__ls_from_cal;

   generate 
      begin: io0
      // {{{ cal_0
      emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_emif_io96b_cal_500_jaonrqy calip_0 (
         .periph_calbus_0             (calbus_0),
         .periph_calbus_readdata_0    (calbus_readdata_0),
         .periph_calbus_param_table_0 (calbus_param_table_0),

         .periph_calbus_1             (),
         .periph_calbus_readdata_1    (1315'b0),
         .periph_calbus_param_table_1 (),

         .pll_calbus_0                (),
         .pll_calbus_readdata_0       (32'b0),

         .pll_calbus_1                (),
         .pll_calbus_readdata_1       (32'b0),

         .pll_calbus_2                (),
         .pll_calbus_readdata_2       (32'b0),

         .ls_to_cal                   (cal0__ls_to_cal),
         .ls_from_cal                 (cal0__ls_from_cal),
         .fbr_c2f_rst_n               (core_init_n),
         .tniul_rst_n                 (noc_rst_n_0),

         .s0_axi4lite_clk             (s0_axilite__cal0.clk),
         .s0_axi4lite_rst_n           (s0_axilite__cal0.rst_n),
         .s0_axi4lite_awaddr          (s0_axilite__cal0.awaddr),
         .s0_axi4lite_awvalid         (s0_axilite__cal0.awvalid),
         .s0_axi4lite_awready         (s0_axilite__cal0.awready),
         .s0_axi4lite_araddr          (s0_axilite__cal0.araddr),
         .s0_axi4lite_arvalid         (s0_axilite__cal0.arvalid),
         .s0_axi4lite_arready         (s0_axilite__cal0.arready),
         .s0_axi4lite_wdata           (s0_axilite__cal0.wdata),
         .s0_axi4lite_wstrb           (s0_axilite__cal0.wstrb),
         .s0_axi4lite_wvalid          (s0_axilite__cal0.wvalid),
         .s0_axi4lite_wready          (s0_axilite__cal0.wready),
         .s0_axi4lite_rresp           (s0_axilite__cal0.rresp),
         .s0_axi4lite_rdata           (s0_axilite__cal0.rdata),
         .s0_axi4lite_rvalid          (s0_axilite__cal0.rvalid),
         .s0_axi4lite_rready          (s0_axilite__cal0.rready),
         .s0_axi4lite_bresp           (s0_axilite__cal0.bresp),
         .s0_axi4lite_bvalid          (s0_axilite__cal0.bvalid),
         .s0_axi4lite_bready          (s0_axilite__cal0.bready),

         .m0_axi4lite_awaddr          (m0_axilite__cal0.awaddr  ),
         .m0_axi4lite_awvalid         (m0_axilite__cal0.awvalid ),                                             
         .m0_axi4lite_awready         (m0_axilite__cal0.awready ),                                         
         .m0_axi4lite_wdata           (m0_axilite__cal0.wdata   ),                                             
         .m0_axi4lite_wstrb           (m0_axilite__cal0.wstrb   ),                                             
         .m0_axi4lite_wvalid          (m0_axilite__cal0.wvalid  ),                                             
         .m0_axi4lite_wready          (m0_axilite__cal0.wready  ),                                         
         .m0_axi4lite_bresp           (m0_axilite__cal0.bresp   ),                                        
         .m0_axi4lite_bvalid          (m0_axilite__cal0.bvalid  ),                                         
         .m0_axi4lite_bready          (m0_axilite__cal0.bready  ),                                             
         .m0_axi4lite_araddr          (m0_axilite__cal0.araddr  ),                                             
         .m0_axi4lite_arvalid         (m0_axilite__cal0.arvalid ),                                             
         .m0_axi4lite_arready         (m0_axilite__cal0.arready ),                                         
         .m0_axi4lite_rdata           (m0_axilite__cal0.rdata   ),         
         .m0_axi4lite_rresp           (m0_axilite__cal0.rresp   ),                                        
         .m0_axi4lite_rvalid          (m0_axilite__cal0.rvalid  ),                                         
         .m0_axi4lite_rready          (m0_axilite__cal0.rready  ),                                             
         .m0_axi4lite_awprot          (m0_axilite__cal0.awprot  ),                                             
         .m0_axi4lite_arprot          (m0_axilite__cal0.arprot  ),                                             

         .s0_noc_axi4lite_clk         (s0_noc_axi4lite_clock),
         .s0_noc_axi4lite_rst_n       (s0_noc_axi4lite_reset_n),
         .s0_noc_axi4lite_awaddr      (s0_noc_axi4lite_awaddr),
         .s0_noc_axi4lite_awvalid     (s0_noc_axi4lite_awvalid),
         .s0_noc_axi4lite_awready     (s0_noc_axi4lite_awready),
         .s0_noc_axi4lite_araddr      (s0_noc_axi4lite_araddr),
         .s0_noc_axi4lite_arvalid     (s0_noc_axi4lite_arvalid),
         .s0_noc_axi4lite_arready     (s0_noc_axi4lite_arready),
         .s0_noc_axi4lite_wdata       (s0_noc_axi4lite_wdata),
         .s0_noc_axi4lite_wvalid      (s0_noc_axi4lite_wvalid),
         .s0_noc_axi4lite_wready      (s0_noc_axi4lite_wready),
         .s0_noc_axi4lite_rresp       (s0_noc_axi4lite_rresp),
         .s0_noc_axi4lite_rdata       (s0_noc_axi4lite_rdata),
         .s0_noc_axi4lite_rvalid      (s0_noc_axi4lite_rvalid),
         .s0_noc_axi4lite_rready      (s0_noc_axi4lite_rready),
         .s0_noc_axi4lite_bresp       (s0_noc_axi4lite_bresp),
         .s0_noc_axi4lite_bvalid      (s0_noc_axi4lite_bvalid),
         .s0_noc_axi4lite_bready      (s0_noc_axi4lite_bready),
         .s0_noc_axi4lite_awprot      (s0_noc_axi4lite_awprot),
         .s0_noc_axi4lite_arprot      (s0_noc_axi4lite_arprot),
         .s0_noc_axi4lite_wstrb       (s0_noc_axi4lite_wstrb)
      );
      //}}}
      end

      if (MEM_NUM_IO96 == 2) begin: io1 
      // {{{ cal_1
      cal_1 calip_1 (
         .periph_calbus_0             (calbus_1),
         .periph_calbus_readdata_0    (calbus_readdata_1),
         .periph_calbus_param_table_0 (calbus_param_table_1),

         .periph_calbus_1             (),
         .periph_calbus_readdata_1    (1315'b0),
         .periph_calbus_param_table_1 (),

         .pll_calbus_0                (),
         .pll_calbus_readdata_0       (32'b0),

         .pll_calbus_1                (),
         .pll_calbus_readdata_1       (32'b0),

         .pll_calbus_2                (),
         .pll_calbus_readdata_2       (32'b0),

         .ls_to_cal                   (cal1__ls_to_cal),
         .ls_from_cal                 (cal1__ls_from_cal),
         .fbr_c2f_rst_n               (core_init_n),
         .tniul_rst_n                 (noc_rst_n_0),

         .s0_axi4lite_clk             (s0_axilite__cal1.clk),
         .s0_axi4lite_rst_n           (s0_axilite__cal1.rst_n),
         .s0_axi4lite_awaddr          (s0_axilite__cal1.awaddr),
         .s0_axi4lite_awvalid         (s0_axilite__cal1.awvalid),
         .s0_axi4lite_awready         (s0_axilite__cal1.awready),
         .s0_axi4lite_araddr          (s0_axilite__cal1.araddr),
         .s0_axi4lite_arvalid         (s0_axilite__cal1.arvalid),
         .s0_axi4lite_arready         (s0_axilite__cal1.arready),
         .s0_axi4lite_wdata           (s0_axilite__cal1.wdata),
         .s0_axi4lite_wstrb           (s0_axilite__cal1.wstrb),
         .s0_axi4lite_wvalid          (s0_axilite__cal1.wvalid),
         .s0_axi4lite_wready          (s0_axilite__cal1.wready),
         .s0_axi4lite_rresp           (s0_axilite__cal1.rresp),
         .s0_axi4lite_rdata           (s0_axilite__cal1.rdata),
         .s0_axi4lite_rvalid          (s0_axilite__cal1.rvalid),
         .s0_axi4lite_rready          (s0_axilite__cal1.rready),
         .s0_axi4lite_bresp           (s0_axilite__cal1.bresp),
         .s0_axi4lite_bvalid          (s0_axilite__cal1.bvalid),
         .s0_axi4lite_bready          (s0_axilite__cal1.bready),

         .m0_axi4lite_awaddr          (),
         .m0_axi4lite_awvalid         (),                                             
         .m0_axi4lite_awready         (1'b0),                                         
         .m0_axi4lite_wdata           (),                                             
         .m0_axi4lite_wstrb           (),                                             
         .m0_axi4lite_wvalid          (),                                             
         .m0_axi4lite_wready          (1'b0),                                         
         .m0_axi4lite_bresp           (2'b00),                                        
         .m0_axi4lite_bvalid          (1'b0),                                         
         .m0_axi4lite_bready          (),                                             
         .m0_axi4lite_araddr          (),                                             
         .m0_axi4lite_arvalid         (),                                             
         .m0_axi4lite_arready         (1'b0),                                         
         .m0_axi4lite_rdata           (32'b00000000000000000000000000000000),         
         .m0_axi4lite_rresp           (2'b00),                                        
         .m0_axi4lite_rvalid          (1'b0),                                         
         .m0_axi4lite_rready          (),                                             
         .m0_axi4lite_awprot          (),                                             
         .m0_axi4lite_arprot          (),                                             

         .s0_noc_axi4lite_clk         (s1_noc_axi4lite_clock),
         .s0_noc_axi4lite_rst_n       (s1_noc_axi4lite_reset_n),
         .s0_noc_axi4lite_awaddr      (s1_noc_axi4lite_awaddr),
         .s0_noc_axi4lite_awvalid     (s1_noc_axi4lite_awvalid),
         .s0_noc_axi4lite_awready     (s1_noc_axi4lite_awready),
         .s0_noc_axi4lite_araddr      (s1_noc_axi4lite_araddr),
         .s0_noc_axi4lite_arvalid     (s1_noc_axi4lite_arvalid),
         .s0_noc_axi4lite_arready     (s1_noc_axi4lite_arready),
         .s0_noc_axi4lite_wdata       (s1_noc_axi4lite_wdata),
         .s0_noc_axi4lite_wvalid      (s1_noc_axi4lite_wvalid),
         .s0_noc_axi4lite_wready      (s1_noc_axi4lite_wready),
         .s0_noc_axi4lite_rresp       (s1_noc_axi4lite_rresp),
         .s0_noc_axi4lite_rdata       (s1_noc_axi4lite_rdata),
         .s0_noc_axi4lite_rvalid      (s1_noc_axi4lite_rvalid),
         .s0_noc_axi4lite_rready      (s1_noc_axi4lite_rready),
         .s0_noc_axi4lite_bresp       (s1_noc_axi4lite_bresp),
         .s0_noc_axi4lite_bvalid      (s1_noc_axi4lite_bvalid),
         .s0_noc_axi4lite_bready      (s1_noc_axi4lite_bready),
         .s0_noc_axi4lite_awprot      (s1_noc_axi4lite_awprot),
         .s0_noc_axi4lite_arprot      (s1_noc_axi4lite_arprot),
         .s0_noc_axi4lite_wstrb       (s1_noc_axi4lite_wstrb)
      );
      //}}}
      end
   endgenerate


   //  ==== TNIUs ====
   //  1 TNIU per channel, if NOC is used
   generate
      if (MAINBAND_USE_NOC_TNIU) begin: t0
      // {{{ tniu_0
         tniu_0 tniu_0 (
            .clk              (noc_aclk_0),            
            .reset            (~noc_rst_n_0),        
            .response_awid    (s_axi_to_tniu[0].awid),    
            .response_awaddr  (s_axi_to_tniu[0].awaddr),  
            .response_awlen   (s_axi_to_tniu[0].awlen),   
            .response_awsize  (s_axi_to_tniu[0].awsize),  
            .response_awburst (s_axi_to_tniu[0].awburst), 
            .response_awlock  (s_axi_to_tniu[0].awlock),  
            .response_awprot  (s_axi_to_tniu[0].awprot),  
            .response_awuser  (s_axi_to_tniu[0].awuser),  
            .response_awvalid (s_axi_to_tniu[0].awvalid), 
            .response_awready (s_axi_to_tniu[0].awready), 
            .response_awqos   (s_axi_to_tniu[0].awqos),   
            .response_wdata   (s_axi_to_tniu[0].wdata),   
            .response_wstrb   (s_axi_to_tniu[0].wstrb),   
            .response_wlast   (s_axi_to_tniu[0].wlast),   
            .response_wvalid  (s_axi_to_tniu[0].wvalid),  
            .response_wready  (s_axi_to_tniu[0].wready),  
            .response_wuser   (s_axi_to_tniu[0].wuser),   
            .response_bid     (s_axi_to_tniu[0].bid),     
            .response_bresp   (s_axi_to_tniu[0].bresp),   
            .response_bvalid  (s_axi_to_tniu[0].bvalid),  
            .response_bready  (s_axi_to_tniu[0].bready),  
            .response_arid    (s_axi_to_tniu[0].arid),    
            .response_araddr  (s_axi_to_tniu[0].araddr),  
            .response_arlen   (s_axi_to_tniu[0].arlen),   
            .response_arsize  (s_axi_to_tniu[0].arsize),  
            .response_arburst (s_axi_to_tniu[0].arburst), 
            .response_arlock  (s_axi_to_tniu[0].arlock),  
            .response_arprot  (s_axi_to_tniu[0].arprot),  
            .response_aruser  (s_axi_to_tniu[0].aruser),  
            .response_arvalid (s_axi_to_tniu[0].arvalid), 
            .response_arready (s_axi_to_tniu[0].arready), 
            .response_arqos   (s_axi_to_tniu[0].arqos),   
            .response_rid     (s_axi_to_tniu[0].rid),     
            .response_rdata   (s_axi_to_tniu[0].rdata),   
            .response_rresp   (s_axi_to_tniu[0].rresp),   
            .response_rlast   (s_axi_to_tniu[0].rlast),   
            .response_rvalid  (s_axi_to_tniu[0].rvalid),  
            .response_rready  (s_axi_to_tniu[0].rready),  
            .response_ruser   (s_axi_to_tniu[0].ruser)    
         );
      /////}}}
      end
      
      if (MAINBAND_USE_NOC_TNIU && MEM_NUM_CHANNELS > 1 ) begin: t1
      // {{{ tniu_1
         tniu_1 tniu_1 (
            .clk              (noc_aclk_1),            
            .reset            (~noc_rst_n_1),        
            .response_awid    (s_axi_to_tniu[1].awid),    
            .response_awaddr  (s_axi_to_tniu[1].awaddr),  
            .response_awlen   (s_axi_to_tniu[1].awlen),   
            .response_awsize  (s_axi_to_tniu[1].awsize),  
            .response_awburst (s_axi_to_tniu[1].awburst), 
            .response_awlock  (s_axi_to_tniu[1].awlock),  
            .response_awprot  (s_axi_to_tniu[1].awprot),  
            .response_awuser  (s_axi_to_tniu[1].awuser),  
            .response_awvalid (s_axi_to_tniu[1].awvalid), 
            .response_awready (s_axi_to_tniu[1].awready), 
            .response_awqos   (s_axi_to_tniu[1].awqos),   
            .response_wdata   (s_axi_to_tniu[1].wdata),   
            .response_wstrb   (s_axi_to_tniu[1].wstrb),   
            .response_wlast   (s_axi_to_tniu[1].wlast),   
            .response_wvalid  (s_axi_to_tniu[1].wvalid),  
            .response_wready  (s_axi_to_tniu[1].wready),  
            .response_wuser   (s_axi_to_tniu[1].wuser),   
            .response_bid     (s_axi_to_tniu[1].bid),     
            .response_bresp   (s_axi_to_tniu[1].bresp),   
            .response_bvalid  (s_axi_to_tniu[1].bvalid),  
            .response_bready  (s_axi_to_tniu[1].bready),  
            .response_arid    (s_axi_to_tniu[1].arid),    
            .response_araddr  (s_axi_to_tniu[1].araddr),  
            .response_arlen   (s_axi_to_tniu[1].arlen),   
            .response_arsize  (s_axi_to_tniu[1].arsize),  
            .response_arburst (s_axi_to_tniu[1].arburst), 
            .response_arlock  (s_axi_to_tniu[1].arlock),  
            .response_arprot  (s_axi_to_tniu[1].arprot),  
            .response_aruser  (s_axi_to_tniu[1].aruser),  
            .response_arvalid (s_axi_to_tniu[1].arvalid), 
            .response_arready (s_axi_to_tniu[1].arready), 
            .response_arqos   (s_axi_to_tniu[1].arqos),   
            .response_rid     (s_axi_to_tniu[1].rid),     
            .response_rdata   (s_axi_to_tniu[1].rdata),   
            .response_rresp   (s_axi_to_tniu[1].rresp),   
            .response_rlast   (s_axi_to_tniu[1].rlast),   
            .response_rvalid  (s_axi_to_tniu[1].rvalid),  
            .response_rready  (s_axi_to_tniu[1].rready),  
            .response_ruser   (s_axi_to_tniu[1].ruser)    
         );
      //}}}
      end
      
      if (MAINBAND_USE_NOC_TNIU && MEM_NUM_CHANNELS > 2 ) begin: t2
      // {{{ tniu_2
         tniu_2 tniu_2 (
            .clk              (noc_aclk_2),            
            .reset            (~noc_rst_n_2),        
            .response_awid    (s_axi_to_tniu[2].awid),    
            .response_awaddr  (s_axi_to_tniu[2].awaddr),  
            .response_awlen   (s_axi_to_tniu[2].awlen),   
            .response_awsize  (s_axi_to_tniu[2].awsize),  
            .response_awburst (s_axi_to_tniu[2].awburst), 
            .response_awlock  (s_axi_to_tniu[2].awlock),  
            .response_awprot  (s_axi_to_tniu[2].awprot),  
            .response_awuser  (s_axi_to_tniu[2].awuser),  
            .response_awvalid (s_axi_to_tniu[2].awvalid), 
            .response_awready (s_axi_to_tniu[2].awready), 
            .response_awqos   (s_axi_to_tniu[2].awqos),   
            .response_wdata   (s_axi_to_tniu[2].wdata),   
            .response_wstrb   (s_axi_to_tniu[2].wstrb),   
            .response_wlast   (s_axi_to_tniu[2].wlast),   
            .response_wvalid  (s_axi_to_tniu[2].wvalid),  
            .response_wready  (s_axi_to_tniu[2].wready),  
            .response_wuser   (s_axi_to_tniu[2].wuser),   
            .response_bid     (s_axi_to_tniu[2].bid),     
            .response_bresp   (s_axi_to_tniu[2].bresp),   
            .response_bvalid  (s_axi_to_tniu[2].bvalid),  
            .response_bready  (s_axi_to_tniu[2].bready),  
            .response_arid    (s_axi_to_tniu[2].arid),    
            .response_araddr  (s_axi_to_tniu[2].araddr),  
            .response_arlen   (s_axi_to_tniu[2].arlen),   
            .response_arsize  (s_axi_to_tniu[2].arsize),  
            .response_arburst (s_axi_to_tniu[2].arburst), 
            .response_arlock  (s_axi_to_tniu[2].arlock),  
            .response_arprot  (s_axi_to_tniu[2].arprot),  
            .response_aruser  (s_axi_to_tniu[2].aruser),  
            .response_arvalid (s_axi_to_tniu[2].arvalid), 
            .response_arready (s_axi_to_tniu[2].arready), 
            .response_arqos   (s_axi_to_tniu[2].arqos),   
            .response_rid     (s_axi_to_tniu[2].rid),     
            .response_rdata   (s_axi_to_tniu[2].rdata),   
            .response_rresp   (s_axi_to_tniu[2].rresp),   
            .response_rlast   (s_axi_to_tniu[2].rlast),   
            .response_rvalid  (s_axi_to_tniu[2].rvalid),  
            .response_rready  (s_axi_to_tniu[2].rready),  
            .response_ruser   (s_axi_to_tniu[2].ruser)    
         );
      //}}}
      end
      
      if (MAINBAND_USE_NOC_TNIU && MEM_NUM_CHANNELS > 3 ) begin: t3
      // {{{ tniu_3
         tniu_3 tniu_3 (
            .clk              (noc_aclk_3),            
            .reset            (~noc_rst_n_3),        
            .response_awid    (s_axi_to_tniu[3].awid),    
            .response_awaddr  (s_axi_to_tniu[3].awaddr),  
            .response_awlen   (s_axi_to_tniu[3].awlen),   
            .response_awsize  (s_axi_to_tniu[3].awsize),  
            .response_awburst (s_axi_to_tniu[3].awburst), 
            .response_awlock  (s_axi_to_tniu[3].awlock),  
            .response_awprot  (s_axi_to_tniu[3].awprot),  
            .response_awuser  (s_axi_to_tniu[3].awuser),  
            .response_awvalid (s_axi_to_tniu[3].awvalid), 
            .response_awready (s_axi_to_tniu[3].awready), 
            .response_awqos   (s_axi_to_tniu[3].awqos),   
            .response_wdata   (s_axi_to_tniu[3].wdata),   
            .response_wstrb   (s_axi_to_tniu[3].wstrb),   
            .response_wlast   (s_axi_to_tniu[3].wlast),   
            .response_wvalid  (s_axi_to_tniu[3].wvalid),  
            .response_wready  (s_axi_to_tniu[3].wready),  
            .response_wuser   (s_axi_to_tniu[3].wuser),   
            .response_bid     (s_axi_to_tniu[3].bid),     
            .response_bresp   (s_axi_to_tniu[3].bresp),   
            .response_bvalid  (s_axi_to_tniu[3].bvalid),  
            .response_bready  (s_axi_to_tniu[3].bready),  
            .response_arid    (s_axi_to_tniu[3].arid),    
            .response_araddr  (s_axi_to_tniu[3].araddr),  
            .response_arlen   (s_axi_to_tniu[3].arlen),   
            .response_arsize  (s_axi_to_tniu[3].arsize),  
            .response_arburst (s_axi_to_tniu[3].arburst), 
            .response_arlock  (s_axi_to_tniu[3].arlock),  
            .response_arprot  (s_axi_to_tniu[3].arprot),  
            .response_aruser  (s_axi_to_tniu[3].aruser),  
            .response_arvalid (s_axi_to_tniu[3].arvalid), 
            .response_arready (s_axi_to_tniu[3].arready), 
            .response_arqos   (s_axi_to_tniu[3].arqos),   
            .response_rid     (s_axi_to_tniu[3].rid),     
            .response_rdata   (s_axi_to_tniu[3].rdata),   
            .response_rresp   (s_axi_to_tniu[3].rresp),   
            .response_rlast   (s_axi_to_tniu[3].rlast),   
            .response_rvalid  (s_axi_to_tniu[3].rvalid),  
            .response_rready  (s_axi_to_tniu[3].rready),  
            .response_ruser   (s_axi_to_tniu[3].ruser)    
         );      
      // }}}
      end
   endgenerate

   generate
      if (!ADD_DDR4_DIMM_ADAPTORS) begin: non_lockstep
         // ######## MAINBAND ############
         // arbitration between axi being a NOC axi vs fabric axi is done internally in the IP 
         if (MAINBAND_USE_NOC_TNIU) begin: connect_arch_axis_to_tnius
            // s0   {{{
            assign s_axi_to_tniu[0].arready  = s_axi_to_arch[0].arready ;
            assign s_axi_to_tniu[0].awready  = s_axi_to_arch[0].awready ;
            assign s_axi_to_tniu[0].bid      = s_axi_to_arch[0].bid     ;
            assign s_axi_to_tniu[0].bresp    = s_axi_to_arch[0].bresp   ;
            assign s_axi_to_tniu[0].bvalid   = s_axi_to_arch[0].bvalid  ;
            assign s_axi_to_tniu[0].rdata    = s_axi_to_arch[0].rdata   ;
            assign s_axi_to_tniu[0].rid      = s_axi_to_arch[0].rid     ;
            assign s_axi_to_tniu[0].rlast    = s_axi_to_arch[0].rlast   ;
            assign s_axi_to_tniu[0].rresp    = s_axi_to_arch[0].rresp   ;
            assign s_axi_to_tniu[0].ruser    = s_axi_to_arch[0].ruser   ;
            assign s_axi_to_tniu[0].rvalid   = s_axi_to_arch[0].rvalid  ;
            assign s_axi_to_tniu[0].wready   = s_axi_to_arch[0].wready  ;

            assign s_axi_to_arch[0].awid     = s_axi_to_tniu[0].awid    ;
            assign s_axi_to_arch[0].awaddr   = s_axi_to_tniu[0].awaddr  ;
            assign s_axi_to_arch[0].awlen    = s_axi_to_tniu[0].awlen   ;
            assign s_axi_to_arch[0].awsize   = s_axi_to_tniu[0].awsize  ;
            assign s_axi_to_arch[0].awburst  = s_axi_to_tniu[0].awburst ;
            assign s_axi_to_arch[0].awlock   = s_axi_to_tniu[0].awlock  ;
            assign s_axi_to_arch[0].awprot   = s_axi_to_tniu[0].awprot  ;
            assign s_axi_to_arch[0].awuser   = s_axi_to_tniu[0].awuser  ;
            assign s_axi_to_arch[0].awvalid  = s_axi_to_tniu[0].awvalid ;
            assign s_axi_to_arch[0].awqos    = s_axi_to_tniu[0].awqos   ;
            assign s_axi_to_arch[0].wdata    = s_axi_to_tniu[0].wdata   ;
            assign s_axi_to_arch[0].wstrb    = s_axi_to_tniu[0].wstrb   ;
            assign s_axi_to_arch[0].wlast    = s_axi_to_tniu[0].wlast   ;
            assign s_axi_to_arch[0].wvalid   = s_axi_to_tniu[0].wvalid  ;
            assign s_axi_to_arch[0].wuser    = s_axi_to_tniu[0].wuser   ;
            assign s_axi_to_arch[0].bready   = s_axi_to_tniu[0].bready  ;
            assign s_axi_to_arch[0].arid     = s_axi_to_tniu[0].arid    ;
            assign s_axi_to_arch[0].araddr   = s_axi_to_tniu[0].araddr  ;
            assign s_axi_to_arch[0].arlen    = s_axi_to_tniu[0].arlen   ;
            assign s_axi_to_arch[0].arsize   = s_axi_to_tniu[0].arsize  ;
            assign s_axi_to_arch[0].arburst  = s_axi_to_tniu[0].arburst ;
            assign s_axi_to_arch[0].arlock   = s_axi_to_tniu[0].arlock  ;
            assign s_axi_to_arch[0].arprot   = s_axi_to_tniu[0].arprot  ;
            assign s_axi_to_arch[0].aruser   = s_axi_to_tniu[0].aruser  ;
            assign s_axi_to_arch[0].arvalid  = s_axi_to_tniu[0].arvalid ;
            assign s_axi_to_arch[0].arqos    = s_axi_to_tniu[0].arqos   ;
            assign s_axi_to_arch[0].rready   = s_axi_to_tniu[0].rready  ;

            assign s0_axi4_arready  = '0;
            assign s0_axi4_awready  = '0;
            assign s0_axi4_bid      = '0;
            assign s0_axi4_bresp    = '0;
            assign s0_axi4_bvalid   = '0;
            assign s0_axi4_rdata    = '0;
            assign s0_axi4_rid      = '0;
            assign s0_axi4_rlast    = '0;
            assign s0_axi4_rresp    = '0;
            assign s0_axi4_ruser    = '0;
            assign s0_axi4_rvalid   = '0;
            assign s0_axi4_wready   = '0;

            // }}}
            
            // s1   {{{
            assign s_axi_to_tniu[1].arready  = s_axi_to_arch[1].arready ;
            assign s_axi_to_tniu[1].awready  = s_axi_to_arch[1].awready ;
            assign s_axi_to_tniu[1].bid      = s_axi_to_arch[1].bid     ;
            assign s_axi_to_tniu[1].bresp    = s_axi_to_arch[1].bresp   ;
            assign s_axi_to_tniu[1].bvalid   = s_axi_to_arch[1].bvalid  ;
            assign s_axi_to_tniu[1].rdata    = s_axi_to_arch[1].rdata   ;
            assign s_axi_to_tniu[1].rid      = s_axi_to_arch[1].rid     ;
            assign s_axi_to_tniu[1].rlast    = s_axi_to_arch[1].rlast   ;
            assign s_axi_to_tniu[1].rresp    = s_axi_to_arch[1].rresp   ;
            assign s_axi_to_tniu[1].ruser    = s_axi_to_arch[1].ruser   ;
            assign s_axi_to_tniu[1].rvalid   = s_axi_to_arch[1].rvalid  ;
            assign s_axi_to_tniu[1].wready   = s_axi_to_arch[1].wready  ;

            assign s_axi_to_arch[1].awid     = s_axi_to_tniu[1].awid    ;
            assign s_axi_to_arch[1].awaddr   = s_axi_to_tniu[1].awaddr  ;
            assign s_axi_to_arch[1].awlen    = s_axi_to_tniu[1].awlen   ;
            assign s_axi_to_arch[1].awsize   = s_axi_to_tniu[1].awsize  ;
            assign s_axi_to_arch[1].awburst  = s_axi_to_tniu[1].awburst ;
            assign s_axi_to_arch[1].awlock   = s_axi_to_tniu[1].awlock  ;
            assign s_axi_to_arch[1].awprot   = s_axi_to_tniu[1].awprot  ;
            assign s_axi_to_arch[1].awuser   = s_axi_to_tniu[1].awuser  ;
            assign s_axi_to_arch[1].awvalid  = s_axi_to_tniu[1].awvalid ;
            assign s_axi_to_arch[1].awqos    = s_axi_to_tniu[1].awqos   ;
            assign s_axi_to_arch[1].wdata    = s_axi_to_tniu[1].wdata   ;
            assign s_axi_to_arch[1].wstrb    = s_axi_to_tniu[1].wstrb   ;
            assign s_axi_to_arch[1].wlast    = s_axi_to_tniu[1].wlast   ;
            assign s_axi_to_arch[1].wvalid   = s_axi_to_tniu[1].wvalid  ;
            assign s_axi_to_arch[1].wuser    = s_axi_to_tniu[1].wuser   ;
            assign s_axi_to_arch[1].bready   = s_axi_to_tniu[1].bready  ;
            assign s_axi_to_arch[1].arid     = s_axi_to_tniu[1].arid    ;
            assign s_axi_to_arch[1].araddr   = s_axi_to_tniu[1].araddr  ;
            assign s_axi_to_arch[1].arlen    = s_axi_to_tniu[1].arlen   ;
            assign s_axi_to_arch[1].arsize   = s_axi_to_tniu[1].arsize  ;
            assign s_axi_to_arch[1].arburst  = s_axi_to_tniu[1].arburst ;
            assign s_axi_to_arch[1].arlock   = s_axi_to_tniu[1].arlock  ;
            assign s_axi_to_arch[1].arprot   = s_axi_to_tniu[1].arprot  ;
            assign s_axi_to_arch[1].aruser   = s_axi_to_tniu[1].aruser  ;
            assign s_axi_to_arch[1].arvalid  = s_axi_to_tniu[1].arvalid ;
            assign s_axi_to_arch[1].arqos    = s_axi_to_tniu[1].arqos   ;
            assign s_axi_to_arch[1].rready   = s_axi_to_tniu[1].rready  ;

            assign s1_axi4_arready  = '0;
            assign s1_axi4_awready  = '0;
            assign s1_axi4_bid      = '0;
            assign s1_axi4_bresp    = '0;
            assign s1_axi4_bvalid   = '0;
            assign s1_axi4_rdata    = '0;
            assign s1_axi4_rid      = '0;
            assign s1_axi4_rlast    = '0;
            assign s1_axi4_rresp    = '0;
            assign s1_axi4_ruser    = '0;
            assign s1_axi4_rvalid   = '0;
            assign s1_axi4_wready   = '0;

            // }}}
            
            // s2   {{{
            assign s_axi_to_tniu[2].arready  = s_axi_to_arch[2].arready ;
            assign s_axi_to_tniu[2].awready  = s_axi_to_arch[2].awready ;
            assign s_axi_to_tniu[2].bid      = s_axi_to_arch[2].bid     ;
            assign s_axi_to_tniu[2].bresp    = s_axi_to_arch[2].bresp   ;
            assign s_axi_to_tniu[2].bvalid   = s_axi_to_arch[2].bvalid  ;
            assign s_axi_to_tniu[2].rdata    = s_axi_to_arch[2].rdata   ;
            assign s_axi_to_tniu[2].rid      = s_axi_to_arch[2].rid     ;
            assign s_axi_to_tniu[2].rlast    = s_axi_to_arch[2].rlast   ;
            assign s_axi_to_tniu[2].rresp    = s_axi_to_arch[2].rresp   ;
            assign s_axi_to_tniu[2].ruser    = s_axi_to_arch[2].ruser   ;
            assign s_axi_to_tniu[2].rvalid   = s_axi_to_arch[2].rvalid  ;
            assign s_axi_to_tniu[2].wready   = s_axi_to_arch[2].wready  ;

            assign s_axi_to_arch[2].awid     = s_axi_to_tniu[2].awid    ;
            assign s_axi_to_arch[2].awaddr   = s_axi_to_tniu[2].awaddr  ;
            assign s_axi_to_arch[2].awlen    = s_axi_to_tniu[2].awlen   ;
            assign s_axi_to_arch[2].awsize   = s_axi_to_tniu[2].awsize  ;
            assign s_axi_to_arch[2].awburst  = s_axi_to_tniu[2].awburst ;
            assign s_axi_to_arch[2].awlock   = s_axi_to_tniu[2].awlock  ;
            assign s_axi_to_arch[2].awprot   = s_axi_to_tniu[2].awprot  ;
            assign s_axi_to_arch[2].awuser   = s_axi_to_tniu[2].awuser  ;
            assign s_axi_to_arch[2].awvalid  = s_axi_to_tniu[2].awvalid ;
            assign s_axi_to_arch[2].awqos    = s_axi_to_tniu[2].awqos   ;
            assign s_axi_to_arch[2].wdata    = s_axi_to_tniu[2].wdata   ;
            assign s_axi_to_arch[2].wstrb    = s_axi_to_tniu[2].wstrb   ;
            assign s_axi_to_arch[2].wlast    = s_axi_to_tniu[2].wlast   ;
            assign s_axi_to_arch[2].wvalid   = s_axi_to_tniu[2].wvalid  ;
            assign s_axi_to_arch[2].wuser    = s_axi_to_tniu[2].wuser   ;
            assign s_axi_to_arch[2].bready   = s_axi_to_tniu[2].bready  ;
            assign s_axi_to_arch[2].arid     = s_axi_to_tniu[2].arid    ;
            assign s_axi_to_arch[2].araddr   = s_axi_to_tniu[2].araddr  ;
            assign s_axi_to_arch[2].arlen    = s_axi_to_tniu[2].arlen   ;
            assign s_axi_to_arch[2].arsize   = s_axi_to_tniu[2].arsize  ;
            assign s_axi_to_arch[2].arburst  = s_axi_to_tniu[2].arburst ;
            assign s_axi_to_arch[2].arlock   = s_axi_to_tniu[2].arlock  ;
            assign s_axi_to_arch[2].arprot   = s_axi_to_tniu[2].arprot  ;
            assign s_axi_to_arch[2].aruser   = s_axi_to_tniu[2].aruser  ;
            assign s_axi_to_arch[2].arvalid  = s_axi_to_tniu[2].arvalid ;
            assign s_axi_to_arch[2].arqos    = s_axi_to_tniu[2].arqos   ;
            assign s_axi_to_arch[2].rready   = s_axi_to_tniu[2].rready  ;

            assign s2_axi4_arready  = '0;
            assign s2_axi4_awready  = '0;
            assign s2_axi4_bid      = '0;
            assign s2_axi4_bresp    = '0;
            assign s2_axi4_bvalid   = '0;
            assign s2_axi4_rdata    = '0;
            assign s2_axi4_rid      = '0;
            assign s2_axi4_rlast    = '0;
            assign s2_axi4_rresp    = '0;
            assign s2_axi4_ruser    = '0;
            assign s2_axi4_rvalid   = '0;
            assign s2_axi4_wready   = '0;

            // }}}
            
            // s3   {{{
            assign s_axi_to_tniu[3].arready  = s_axi_to_arch[3].arready ;
            assign s_axi_to_tniu[3].awready  = s_axi_to_arch[3].awready ;
            assign s_axi_to_tniu[3].bid      = s_axi_to_arch[3].bid     ;
            assign s_axi_to_tniu[3].bresp    = s_axi_to_arch[3].bresp   ;
            assign s_axi_to_tniu[3].bvalid   = s_axi_to_arch[3].bvalid  ;
            assign s_axi_to_tniu[3].rdata    = s_axi_to_arch[3].rdata   ;
            assign s_axi_to_tniu[3].rid      = s_axi_to_arch[3].rid     ;
            assign s_axi_to_tniu[3].rlast    = s_axi_to_arch[3].rlast   ;
            assign s_axi_to_tniu[3].rresp    = s_axi_to_arch[3].rresp   ;
            assign s_axi_to_tniu[3].ruser    = s_axi_to_arch[3].ruser   ;
            assign s_axi_to_tniu[3].rvalid   = s_axi_to_arch[3].rvalid  ;
            assign s_axi_to_tniu[3].wready   = s_axi_to_arch[3].wready  ;

            assign s_axi_to_arch[3].awid     = s_axi_to_tniu[3].awid    ;
            assign s_axi_to_arch[3].awaddr   = s_axi_to_tniu[3].awaddr  ;
            assign s_axi_to_arch[3].awlen    = s_axi_to_tniu[3].awlen   ;
            assign s_axi_to_arch[3].awsize   = s_axi_to_tniu[3].awsize  ;
            assign s_axi_to_arch[3].awburst  = s_axi_to_tniu[3].awburst ;
            assign s_axi_to_arch[3].awlock   = s_axi_to_tniu[3].awlock  ;
            assign s_axi_to_arch[3].awprot   = s_axi_to_tniu[3].awprot  ;
            assign s_axi_to_arch[3].awuser   = s_axi_to_tniu[3].awuser  ;
            assign s_axi_to_arch[3].awvalid  = s_axi_to_tniu[3].awvalid ;
            assign s_axi_to_arch[3].awqos    = s_axi_to_tniu[3].awqos   ;
            assign s_axi_to_arch[3].wdata    = s_axi_to_tniu[3].wdata   ;
            assign s_axi_to_arch[3].wstrb    = s_axi_to_tniu[3].wstrb   ;
            assign s_axi_to_arch[3].wlast    = s_axi_to_tniu[3].wlast   ;
            assign s_axi_to_arch[3].wvalid   = s_axi_to_tniu[3].wvalid  ;
            assign s_axi_to_arch[3].wuser    = s_axi_to_tniu[3].wuser   ;
            assign s_axi_to_arch[3].bready   = s_axi_to_tniu[3].bready  ;
            assign s_axi_to_arch[3].arid     = s_axi_to_tniu[3].arid    ;
            assign s_axi_to_arch[3].araddr   = s_axi_to_tniu[3].araddr  ;
            assign s_axi_to_arch[3].arlen    = s_axi_to_tniu[3].arlen   ;
            assign s_axi_to_arch[3].arsize   = s_axi_to_tniu[3].arsize  ;
            assign s_axi_to_arch[3].arburst  = s_axi_to_tniu[3].arburst ;
            assign s_axi_to_arch[3].arlock   = s_axi_to_tniu[3].arlock  ;
            assign s_axi_to_arch[3].arprot   = s_axi_to_tniu[3].arprot  ;
            assign s_axi_to_arch[3].aruser   = s_axi_to_tniu[3].aruser  ;
            assign s_axi_to_arch[3].arvalid  = s_axi_to_tniu[3].arvalid ;
            assign s_axi_to_arch[3].arqos    = s_axi_to_tniu[3].arqos   ;
            assign s_axi_to_arch[3].rready   = s_axi_to_tniu[3].rready  ;

            assign s3_axi4_arready  = '0;
            assign s3_axi4_awready  = '0;
            assign s3_axi4_bid      = '0;
            assign s3_axi4_bresp    = '0;
            assign s3_axi4_bvalid   = '0;
            assign s3_axi4_rdata    = '0;
            assign s3_axi4_rid      = '0;
            assign s3_axi4_rlast    = '0;
            assign s3_axi4_rresp    = '0;
            assign s3_axi4_ruser    = '0;
            assign s3_axi4_rvalid   = '0;
            assign s3_axi4_wready   = '0;

            // }}}
         end else begin: export_arch_axis
            // s0   {{{
            assign s0_axi4_arready  = s_axi_to_arch[0].arready ;
            assign s0_axi4_awready  = s_axi_to_arch[0].awready ;
            assign s0_axi4_bid      = s_axi_to_arch[0].bid[(PORT_AXI_S0_AXID_WIDTH-1):0];
            assign s0_axi4_bresp    = s_axi_to_arch[0].bresp   ;
            assign s0_axi4_bvalid   = s_axi_to_arch[0].bvalid  ;
            assign s0_axi4_rdata    = s_axi_to_arch[0].rdata   ;
            assign s0_axi4_rid      = s_axi_to_arch[0].rid[(PORT_AXI_S0_AXID_WIDTH-1):0];
            assign s0_axi4_rlast    = s_axi_to_arch[0].rlast   ;
            assign s0_axi4_rresp    = s_axi_to_arch[0].rresp   ;
            assign s0_axi4_ruser    = s_axi_to_arch[0].ruser[(PORT_AXI_USER_WIDTH-1):0];
            assign s0_axi4_rvalid   = s_axi_to_arch[0].rvalid  ;
            assign s0_axi4_wready   = s_axi_to_arch[0].wready  ;

            assign s_axi_to_arch[0].awid     = `ZERO_PAD_PORT(PORT_AXI_S0_AXID_WIDTH,    7, s0_axi4_awid);
            assign s_axi_to_arch[0].awaddr   = s0_axi4_awaddr  ;
            assign s_axi_to_arch[0].awlen    = s0_axi4_awlen   ;
            assign s_axi_to_arch[0].awsize   = s0_axi4_awsize  ;
            assign s_axi_to_arch[0].awburst  = s0_axi4_awburst ;
            assign s_axi_to_arch[0].awlock   = s0_axi4_awlock  ;
            assign s_axi_to_arch[0].awprot   = s0_axi4_awprot  ;
            assign s_axi_to_arch[0].awuser   = s0_axi4_awuser  ;
            assign s_axi_to_arch[0].awvalid  = s0_axi4_awvalid ;
            assign s_axi_to_arch[0].awqos    = s0_axi4_awqos   ;
            assign s_axi_to_arch[0].wdata    = s0_axi4_wdata   ;
            assign s_axi_to_arch[0].wstrb    = s0_axi4_wstrb   ;
            assign s_axi_to_arch[0].wlast    = s0_axi4_wlast   ;
            assign s_axi_to_arch[0].wvalid   = s0_axi4_wvalid  ;
            assign s_axi_to_arch[0].wuser    = `ZERO_PAD_PORT(PORT_AXI_USER_WIDTH, PORT_AXI_FBR_USER_WIDTH_MAX, s0_axi4_wuser);
            assign s_axi_to_arch[0].bready   = s0_axi4_bready  ;
            assign s_axi_to_arch[0].arid     = `ZERO_PAD_PORT(PORT_AXI_S0_AXID_WIDTH, 7, s0_axi4_arid);
            assign s_axi_to_arch[0].araddr   = s0_axi4_araddr  ;
            assign s_axi_to_arch[0].arlen    = s0_axi4_arlen   ;
            assign s_axi_to_arch[0].arsize   = s0_axi4_arsize  ;
            assign s_axi_to_arch[0].arburst  = s0_axi4_arburst ;
            assign s_axi_to_arch[0].arlock   = s0_axi4_arlock  ;
            assign s_axi_to_arch[0].arprot   = s0_axi4_arprot  ;
            assign s_axi_to_arch[0].aruser   = s0_axi4_aruser  ;
            assign s_axi_to_arch[0].arvalid  = s0_axi4_arvalid ;
            assign s_axi_to_arch[0].arqos    = s0_axi4_arqos   ;
            assign s_axi_to_arch[0].rready   = s0_axi4_rready  ;
            // }}}

            // s1   {{{
            assign s1_axi4_arready  = s_axi_to_arch[1].arready ;
            assign s1_axi4_awready  = s_axi_to_arch[1].awready ;
            assign s1_axi4_bid      = s_axi_to_arch[1].bid[(PORT_AXI_S1_AXID_WIDTH-1):0];
            assign s1_axi4_bresp    = s_axi_to_arch[1].bresp   ;
            assign s1_axi4_bvalid   = s_axi_to_arch[1].bvalid  ;
            assign s1_axi4_rdata    = s_axi_to_arch[1].rdata   ;
            assign s1_axi4_rid      = s_axi_to_arch[1].rid[(PORT_AXI_S1_AXID_WIDTH-1):0];
            assign s1_axi4_rlast    = s_axi_to_arch[1].rlast   ;
            assign s1_axi4_rresp    = s_axi_to_arch[1].rresp   ;
            assign s1_axi4_ruser    = s_axi_to_arch[1].ruser[(PORT_AXI_USER_WIDTH-1):0];
            assign s1_axi4_rvalid   = s_axi_to_arch[1].rvalid  ;
            assign s1_axi4_wready   = s_axi_to_arch[1].wready  ;

            assign s_axi_to_arch[1].awid     = `ZERO_PAD_PORT(PORT_AXI_S1_AXID_WIDTH,    7, s1_axi4_awid);
            assign s_axi_to_arch[1].awaddr   = s1_axi4_awaddr  ;
            assign s_axi_to_arch[1].awlen    = s1_axi4_awlen   ;
            assign s_axi_to_arch[1].awsize   = s1_axi4_awsize  ;
            assign s_axi_to_arch[1].awburst  = s1_axi4_awburst ;
            assign s_axi_to_arch[1].awlock   = s1_axi4_awlock  ;
            assign s_axi_to_arch[1].awprot   = s1_axi4_awprot  ;
            assign s_axi_to_arch[1].awuser   = s1_axi4_awuser  ;
            assign s_axi_to_arch[1].awvalid  = s1_axi4_awvalid ;
            assign s_axi_to_arch[1].awqos    = s1_axi4_awqos   ;
            assign s_axi_to_arch[1].wdata    = s1_axi4_wdata   ;
            assign s_axi_to_arch[1].wstrb    = s1_axi4_wstrb   ;
            assign s_axi_to_arch[1].wlast    = s1_axi4_wlast   ;
            assign s_axi_to_arch[1].wvalid   = s1_axi4_wvalid  ;
            assign s_axi_to_arch[1].wuser    = `ZERO_PAD_PORT(PORT_AXI_USER_WIDTH, PORT_AXI_FBR_USER_WIDTH_MAX, s1_axi4_wuser);
            assign s_axi_to_arch[1].bready   = s1_axi4_bready  ;
            assign s_axi_to_arch[1].arid     = `ZERO_PAD_PORT(PORT_AXI_S1_AXID_WIDTH, 7, s1_axi4_arid);
            assign s_axi_to_arch[1].araddr   = s1_axi4_araddr  ;
            assign s_axi_to_arch[1].arlen    = s1_axi4_arlen   ;
            assign s_axi_to_arch[1].arsize   = s1_axi4_arsize  ;
            assign s_axi_to_arch[1].arburst  = s1_axi4_arburst ;
            assign s_axi_to_arch[1].arlock   = s1_axi4_arlock  ;
            assign s_axi_to_arch[1].arprot   = s1_axi4_arprot  ;
            assign s_axi_to_arch[1].aruser   = s1_axi4_aruser  ;
            assign s_axi_to_arch[1].arvalid  = s1_axi4_arvalid ;
            assign s_axi_to_arch[1].arqos    = s1_axi4_arqos   ;
            assign s_axi_to_arch[1].rready   = s1_axi4_rready  ;
            // }}}

            // s2   {{{
            assign s2_axi4_arready  = s_axi_to_arch[2].arready ;
            assign s2_axi4_awready  = s_axi_to_arch[2].awready ;
            assign s2_axi4_bid      = s_axi_to_arch[2].bid[(PORT_AXI_S2_AXID_WIDTH-1):0];
            assign s2_axi4_bresp    = s_axi_to_arch[2].bresp   ;
            assign s2_axi4_bvalid   = s_axi_to_arch[2].bvalid  ;
            assign s2_axi4_rdata    = s_axi_to_arch[2].rdata   ;
            assign s2_axi4_rid      = s_axi_to_arch[2].rid[(PORT_AXI_S2_AXID_WIDTH-1):0];
            assign s2_axi4_rlast    = s_axi_to_arch[2].rlast   ;
            assign s2_axi4_rresp    = s_axi_to_arch[2].rresp   ;
            assign s2_axi4_ruser    = s_axi_to_arch[2].ruser[(PORT_AXI_USER_WIDTH-1):0];
            assign s2_axi4_rvalid   = s_axi_to_arch[2].rvalid  ;
            assign s2_axi4_wready   = s_axi_to_arch[2].wready  ;

            assign s_axi_to_arch[2].awid     = `ZERO_PAD_PORT(PORT_AXI_S2_AXID_WIDTH,    7, s2_axi4_awid);
            assign s_axi_to_arch[2].awaddr   = s2_axi4_awaddr  ;
            assign s_axi_to_arch[2].awlen    = s2_axi4_awlen   ;
            assign s_axi_to_arch[2].awsize   = s2_axi4_awsize  ;
            assign s_axi_to_arch[2].awburst  = s2_axi4_awburst ;
            assign s_axi_to_arch[2].awlock   = s2_axi4_awlock  ;
            assign s_axi_to_arch[2].awprot   = s2_axi4_awprot  ;
            assign s_axi_to_arch[2].awuser   = s2_axi4_awuser  ;
            assign s_axi_to_arch[2].awvalid  = s2_axi4_awvalid ;
            assign s_axi_to_arch[2].awqos    = s2_axi4_awqos   ;
            assign s_axi_to_arch[2].wdata    = s2_axi4_wdata   ;
            assign s_axi_to_arch[2].wstrb    = s2_axi4_wstrb   ;
            assign s_axi_to_arch[2].wlast    = s2_axi4_wlast   ;
            assign s_axi_to_arch[2].wvalid   = s2_axi4_wvalid  ;
            assign s_axi_to_arch[2].wuser    = `ZERO_PAD_PORT(PORT_AXI_USER_WIDTH, PORT_AXI_FBR_USER_WIDTH_MAX, s2_axi4_wuser);
            assign s_axi_to_arch[2].bready   = s2_axi4_bready  ;
            assign s_axi_to_arch[2].arid     = `ZERO_PAD_PORT(PORT_AXI_S2_AXID_WIDTH, 7, s2_axi4_arid);
            assign s_axi_to_arch[2].araddr   = s2_axi4_araddr  ;
            assign s_axi_to_arch[2].arlen    = s2_axi4_arlen   ;
            assign s_axi_to_arch[2].arsize   = s2_axi4_arsize  ;
            assign s_axi_to_arch[2].arburst  = s2_axi4_arburst ;
            assign s_axi_to_arch[2].arlock   = s2_axi4_arlock  ;
            assign s_axi_to_arch[2].arprot   = s2_axi4_arprot  ;
            assign s_axi_to_arch[2].aruser   = s2_axi4_aruser  ;
            assign s_axi_to_arch[2].arvalid  = s2_axi4_arvalid ;
            assign s_axi_to_arch[2].arqos    = s2_axi4_arqos   ;
            assign s_axi_to_arch[2].rready   = s2_axi4_rready  ;
            // }}}

            // s3   {{{
            assign s3_axi4_arready  = s_axi_to_arch[3].arready ;
            assign s3_axi4_awready  = s_axi_to_arch[3].awready ;
            assign s3_axi4_bid      = s_axi_to_arch[3].bid[(PORT_AXI_S3_AXID_WIDTH-1):0];
            assign s3_axi4_bresp    = s_axi_to_arch[3].bresp   ;
            assign s3_axi4_bvalid   = s_axi_to_arch[3].bvalid  ;
            assign s3_axi4_rdata    = s_axi_to_arch[3].rdata   ;
            assign s3_axi4_rid      = s_axi_to_arch[3].rid[(PORT_AXI_S3_AXID_WIDTH-1):0];
            assign s3_axi4_rlast    = s_axi_to_arch[3].rlast   ;
            assign s3_axi4_rresp    = s_axi_to_arch[3].rresp   ;
            assign s3_axi4_ruser    = s_axi_to_arch[3].ruser[(PORT_AXI_USER_WIDTH-1):0];
            assign s3_axi4_rvalid   = s_axi_to_arch[3].rvalid  ;
            assign s3_axi4_wready   = s_axi_to_arch[3].wready  ;

            assign s_axi_to_arch[3].awid     = `ZERO_PAD_PORT(PORT_AXI_S3_AXID_WIDTH,    7, s3_axi4_awid);
            assign s_axi_to_arch[3].awaddr   = s3_axi4_awaddr  ;
            assign s_axi_to_arch[3].awlen    = s3_axi4_awlen   ;
            assign s_axi_to_arch[3].awsize   = s3_axi4_awsize  ;
            assign s_axi_to_arch[3].awburst  = s3_axi4_awburst ;
            assign s_axi_to_arch[3].awlock   = s3_axi4_awlock  ;
            assign s_axi_to_arch[3].awprot   = s3_axi4_awprot  ;
            assign s_axi_to_arch[3].awuser   = s3_axi4_awuser  ;
            assign s_axi_to_arch[3].awvalid  = s3_axi4_awvalid ;
            assign s_axi_to_arch[3].awqos    = s3_axi4_awqos   ;
            assign s_axi_to_arch[3].wdata    = s3_axi4_wdata   ;
            assign s_axi_to_arch[3].wstrb    = s3_axi4_wstrb   ;
            assign s_axi_to_arch[3].wlast    = s3_axi4_wlast   ;
            assign s_axi_to_arch[3].wvalid   = s3_axi4_wvalid  ;
            assign s_axi_to_arch[3].wuser    = `ZERO_PAD_PORT(PORT_AXI_USER_WIDTH, PORT_AXI_FBR_USER_WIDTH_MAX, s3_axi4_wuser);
            assign s_axi_to_arch[3].bready   = s3_axi4_bready  ;
            assign s_axi_to_arch[3].arid     = `ZERO_PAD_PORT(PORT_AXI_S3_AXID_WIDTH, 7, s3_axi4_arid);
            assign s_axi_to_arch[3].araddr   = s3_axi4_araddr  ;
            assign s_axi_to_arch[3].arlen    = s3_axi4_arlen   ;
            assign s_axi_to_arch[3].arsize   = s3_axi4_arsize  ;
            assign s_axi_to_arch[3].arburst  = s3_axi4_arburst ;
            assign s_axi_to_arch[3].arlock   = s3_axi4_arlock  ;
            assign s_axi_to_arch[3].arprot   = s3_axi4_arprot  ;
            assign s_axi_to_arch[3].aruser   = s3_axi4_aruser  ;
            assign s_axi_to_arch[3].arvalid  = s3_axi4_arvalid ;
            assign s_axi_to_arch[3].arqos    = s3_axi4_arqos   ;
            assign s_axi_to_arch[3].rready   = s3_axi4_rready  ;
            // }}}
         end

         // ######## SIDEBAND ############
            // {{{ cal0's s0_axi4lite is exported directly from emif hier (as s0_axi4lite*)
            assign s0_axilite__cal0.clk     = s0_axi4lite_clock;
            assign s0_axilite__cal0.rst_n   = s0_axi4lite_reset_n;
            assign s0_axilite__cal0.awaddr  = s0_axi4lite_awaddr;
            assign s0_axilite__cal0.awvalid = s0_axi4lite_awvalid;
            assign s0_axi4lite_awready      = s0_axilite__cal0.awready;
            assign s0_axilite__cal0.araddr  = s0_axi4lite_araddr;
            assign s0_axilite__cal0.arvalid = s0_axi4lite_arvalid;
            assign s0_axi4lite_arready      = s0_axilite__cal0.arready;
            assign s0_axilite__cal0.wdata   = s0_axi4lite_wdata;
            assign s0_axilite__cal0.wstrb   = s0_axi4lite_wstrb;
            assign s0_axilite__cal0.wvalid  = s0_axi4lite_wvalid;
            assign s0_axi4lite_wready       = s0_axilite__cal0.wready;
            assign s0_axi4lite_rresp        = s0_axilite__cal0.rresp;
            assign s0_axi4lite_rdata        = s0_axilite__cal0.rdata;
            assign s0_axi4lite_rvalid       = s0_axilite__cal0.rvalid;
            assign s0_axilite__cal0.rready  = s0_axi4lite_rready;
            assign s0_axi4lite_bresp        = s0_axilite__cal0.bresp;
            assign s0_axi4lite_bvalid       = s0_axilite__cal0.bvalid;
            assign s0_axilite__cal0.bready  = s0_axi4lite_bready;
            // }}} 
            // {{{ cal0's m0_axi4lite is tied off
            assign m0_axilite__cal0.awready      =  1'b0;                                         
            assign m0_axilite__cal0.wready       =  1'b0;                                         
            assign m0_axilite__cal0.bresp        =  2'b00;                                        
            assign m0_axilite__cal0.bvalid       =  1'b0;                                         
            assign m0_axilite__cal0.arready      =  1'b0;                                         
            assign m0_axilite__cal0.rdata        =  32'b00000000000000000000000000000000;         
            assign m0_axilite__cal0.rresp        =  2'b00;                                        
            assign m0_axilite__cal0.rvalid       =  1'b0;                                         
            // }}} 
            // {{{ cal1's s0_axi4lite is exported directly from emif hier (as s1_axi4lite*)
            assign s0_axilite__cal1.clk     = s1_axi4lite_clock;
            assign s0_axilite__cal1.rst_n   = s1_axi4lite_reset_n;
            assign s0_axilite__cal1.awaddr  = s1_axi4lite_awaddr;
            assign s0_axilite__cal1.awvalid = s1_axi4lite_awvalid;
            assign s1_axi4lite_awready      = s0_axilite__cal1.awready;
            assign s0_axilite__cal1.araddr  = s1_axi4lite_araddr;
            assign s0_axilite__cal1.arvalid = s1_axi4lite_arvalid;
            assign s1_axi4lite_arready      = s0_axilite__cal1.arready;
            assign s0_axilite__cal1.wdata   = s1_axi4lite_wdata;
            assign s0_axilite__cal1.wstrb   = s1_axi4lite_wstrb;
            assign s0_axilite__cal1.wvalid  = s1_axi4lite_wvalid;
            assign s1_axi4lite_wready       = s0_axilite__cal1.wready;
            assign s1_axi4lite_rresp        = s0_axilite__cal1.rresp;
            assign s1_axi4lite_rdata        = s0_axilite__cal1.rdata;
            assign s1_axi4lite_rvalid       = s0_axilite__cal1.rvalid;
            assign s0_axilite__cal1.rready  = s1_axi4lite_rready;
            assign s1_axi4lite_bresp        = s0_axilite__cal1.bresp;
            assign s1_axi4lite_bvalid       = s0_axilite__cal1.bvalid;
            assign s0_axilite__cal1.bready  = s1_axi4lite_bready;
            // }}} 
         //  --- leave disconnected: cal*__ls_*_cal, ls_usr_clk_0, ls_usr_rst_n_0 

      end else begin: lockstep
         //  ==== DDR4 DIMM Lockstep -- soft logic ====
         assign ls_io0_usr_clk = s0_axi4_clock_out;
         assign ls_io0_usr_rst_n = s0_axi4_reset_n;
         assign s0_axilite__cal1.clk     = s0_axilite__cal0.clk  ;
         assign s0_axilite__cal1.rst_n   = s0_axilite__cal0.rst_n;

         // ######## MAINBAND ############
         //  --- {{{ axi_reshaper_inst 
         wire [6:0]  s0_axi4_bid_full_width;
         wire [6:0]  s0_axi4_rid_full_width;
         wire [63:0] s0_axi4_ruser_full_width;
         assign s0_axi4_bid   = s0_axi4_bid_full_width[(PORT_AXI_S0_AXID_WIDTH-1):0];
         assign s0_axi4_rid   = s0_axi4_rid_full_width[(PORT_AXI_S0_AXID_WIDTH-1):0];
         assign s0_axi4_ruser = s0_axi4_ruser_full_width[(PORT_AXI_USER_WIDTH-1):0];
         wire [63:0] s0_axi4_wuser_full_width;
         wire [6:0]  s0_axi4_arid_full_width;
         wire [6:0]  s0_axi4_awid_full_width;
         assign s0_axi4_wuser_full_width = `ZERO_PAD_PORT(PORT_AXI_USER_WIDTH, 64, s0_axi4_wuser);
         assign s0_axi4_arid_full_width  = `ZERO_PAD_PORT(PORT_AXI_S0_AXID_WIDTH,    7, s0_axi4_arid);
         assign s0_axi4_awid_full_width  = `ZERO_PAD_PORT(PORT_AXI_S0_AXID_WIDTH,    7, s0_axi4_awid);
         localparam IS_SECONDARY_IO_DQ_WIDTH_40 = IO1_LS_MEM_DQ_WIDTH == 40 ? 1 : 0;
         lockstep_axi4_reshaper #(
            .AXI4_RESHAPER_EN        (1),
            .AXI4_ADDR_WIDTH         (PORT_AXI_AXADDR_WIDTH),
            .AXI4_DATA_WIDTH         (PORT_AXI_DATA_WIDTH),
            .AXI4_ARCH_X40           (IS_SECONDARY_IO_DQ_WIDTH_40),
            .AXI4_ECC_EN             (LS_ECC_EN),
            .AXI4_ECC_AUTOCORRECT_EN (LS_ECC_AUTOCORRECT_EN),
            .AXI4_IF_NUM             (2) 
         ) ls_mainband_reshaper (
            // s0_axi4_clock_out --> axi_clk //s1_axi4_clock_out --> s_axi_clk
            .axi_clk (s0_axi4_clock_out),        
            .s_axi_clk (s1_axi4_clock_out),      
            // s0_axi4_reset_n --> axi_rst_n //s1_axi4_reset_n --> s_axi_rst_n
            .s_axi_rst_n (s1_axi4_reset_n),
            .axi_rst_n (s0_axi4_reset_n),
      
            // s0_axi4 --> mainband interface presented by EMIF
            .s0_axi4_araddr  (s0_axi4_araddr),
            .s0_axi4_arburst (s0_axi4_arburst),
            .s0_axi4_arid    (s0_axi4_arid_full_width),
            .s0_axi4_arlen   (s0_axi4_arlen),
            .s0_axi4_arlock  (s0_axi4_arlock),
            .s0_axi4_arqos   (s0_axi4_arqos),
            .s0_axi4_arsize  (s0_axi4_arsize),
            .s0_axi4_arvalid (s0_axi4_arvalid),
            .s0_axi4_aruser  (s0_axi4_aruser),
            .s0_axi4_arprot  (s0_axi4_arprot),
            .s0_axi4_awaddr  (s0_axi4_awaddr),
            .s0_axi4_awburst (s0_axi4_awburst),
            .s0_axi4_awid    (s0_axi4_awid_full_width),
            .s0_axi4_awlen   (s0_axi4_awlen),
            .s0_axi4_awlock  (s0_axi4_awlock),
            .s0_axi4_awqos   (s0_axi4_awqos),
            .s0_axi4_awsize  (s0_axi4_awsize),
            .s0_axi4_awvalid (s0_axi4_awvalid),
            .s0_axi4_awuser  (s0_axi4_awuser),
            .s0_axi4_awprot  (s0_axi4_awprot),
            .s0_axi4_bready  (s0_axi4_bready),
            .s0_axi4_rready  (s0_axi4_rready),
            .s0_axi4_wdata   (s0_axi4_wdata),
            .s0_axi4_wstrb   (s0_axi4_wstrb),
            .s0_axi4_wlast   (s0_axi4_wlast),
            .s0_axi4_wvalid  (s0_axi4_wvalid),
            .s0_axi4_wuser   (s0_axi4_wuser_full_width),
            .s0_axi4_ruser   (s0_axi4_ruser_full_width),
            .s0_axi4_arready (s0_axi4_arready),
            .s0_axi4_awready (s0_axi4_awready),
            .s0_axi4_bid     (s0_axi4_bid_full_width),
            .s0_axi4_bresp   (s0_axi4_bresp),
            .s0_axi4_bvalid  (s0_axi4_bvalid),
            .s0_axi4_rdata   (s0_axi4_rdata),
            .s0_axi4_rid     (s0_axi4_rid_full_width),
            .s0_axi4_rlast   (s0_axi4_rlast),
            .s0_axi4_rresp   (s0_axi4_rresp),
            .s0_axi4_rvalid  (s0_axi4_rvalid),
            .s0_axi4_wready  (s0_axi4_wready),

            // p_m_axi4 --> io_0.s0_axi4
            .p_m_axi4_araddr  (s_axi_to_arch[0].araddr),
            .p_m_axi4_arburst (s_axi_to_arch[0].arburst),
            .p_m_axi4_arid    (s_axi_to_arch[0].arid),
            .p_m_axi4_arlen   (s_axi_to_arch[0].arlen),
            .p_m_axi4_arlock  (s_axi_to_arch[0].arlock),
            .p_m_axi4_arqos   (s_axi_to_arch[0].arqos),
            .p_m_axi4_arsize  (s_axi_to_arch[0].arsize),
            .p_m_axi4_arvalid (s_axi_to_arch[0].arvalid),
            .p_m_axi4_aruser  (s_axi_to_arch[0].aruser),
            .p_m_axi4_arprot  (s_axi_to_arch[0].arprot),
            .p_m_axi4_awaddr  (s_axi_to_arch[0].awaddr),
            .p_m_axi4_awburst (s_axi_to_arch[0].awburst),
            .p_m_axi4_awid    (s_axi_to_arch[0].awid),
            .p_m_axi4_awlen   (s_axi_to_arch[0].awlen),
            .p_m_axi4_awlock  (s_axi_to_arch[0].awlock),
            .p_m_axi4_awqos   (s_axi_to_arch[0].awqos),
            .p_m_axi4_awsize  (s_axi_to_arch[0].awsize),
            .p_m_axi4_awvalid (s_axi_to_arch[0].awvalid),
            .p_m_axi4_awuser  (s_axi_to_arch[0].awuser),
            .p_m_axi4_awprot  (s_axi_to_arch[0].awprot),
            .p_m_axi4_bready  (s_axi_to_arch[0].bready),
            .p_m_axi4_rready  (s_axi_to_arch[0].rready),
            .p_m_axi4_wdata   (s_axi_to_arch[0].wdata),
            .p_m_axi4_wstrb   (s_axi_to_arch[0].wstrb),
            .p_m_axi4_wlast   (s_axi_to_arch[0].wlast),
            .p_m_axi4_wvalid  (s_axi_to_arch[0].wvalid),
            .p_m_axi4_wuser   (s_axi_to_arch[0].wuser),
            .p_m_axi4_ruser   (s_axi_to_arch[0].ruser),
            .p_m_axi4_arready (s_axi_to_arch[0].arready),
            .p_m_axi4_awready (s_axi_to_arch[0].awready),
            .p_m_axi4_bid     (s_axi_to_arch[0].bid),
            .p_m_axi4_bresp   (s_axi_to_arch[0].bresp),
            .p_m_axi4_bvalid  (s_axi_to_arch[0].bvalid),
            .p_m_axi4_rdata   (s_axi_to_arch[0].rdata),
            .p_m_axi4_rid     (s_axi_to_arch[0].rid),
            .p_m_axi4_rlast   (s_axi_to_arch[0].rlast),
            .p_m_axi4_rresp   (s_axi_to_arch[0].rresp),
            .p_m_axi4_rvalid  (s_axi_to_arch[0].rvalid),
            .p_m_axi4_wready  (s_axi_to_arch[0].wready),

            // s_m_axi4 --> io_1.s0_axi4   
            .s_m_axi4_araddr  (s_axi_to_arch[1].araddr),
            .s_m_axi4_arburst (s_axi_to_arch[1].arburst),
            .s_m_axi4_arid    (s_axi_to_arch[1].arid),
            .s_m_axi4_arlen   (s_axi_to_arch[1].arlen),
            .s_m_axi4_arlock  (s_axi_to_arch[1].arlock),
            .s_m_axi4_arqos   (s_axi_to_arch[1].arqos),
            .s_m_axi4_arsize  (s_axi_to_arch[1].arsize),
            .s_m_axi4_arvalid (s_axi_to_arch[1].arvalid),
            .s_m_axi4_aruser  (s_axi_to_arch[1].aruser),
            .s_m_axi4_arprot  (s_axi_to_arch[1].arprot),
            .s_m_axi4_awaddr  (s_axi_to_arch[1].awaddr),
            .s_m_axi4_awburst (s_axi_to_arch[1].awburst),
            .s_m_axi4_awid    (s_axi_to_arch[1].awid),
            .s_m_axi4_awlen   (s_axi_to_arch[1].awlen),
            .s_m_axi4_awlock  (s_axi_to_arch[1].awlock),
            .s_m_axi4_awqos   (s_axi_to_arch[1].awqos),
            .s_m_axi4_awsize  (s_axi_to_arch[1].awsize),
            .s_m_axi4_awvalid (s_axi_to_arch[1].awvalid),
            .s_m_axi4_awuser  (s_axi_to_arch[1].awuser),
            .s_m_axi4_awprot  (s_axi_to_arch[1].awprot),
            .s_m_axi4_bready  (s_axi_to_arch[1].bready),
            .s_m_axi4_rready  (s_axi_to_arch[1].rready),
            .s_m_axi4_wdata   (s_axi_to_arch[1].wdata),
            .s_m_axi4_wstrb   (s_axi_to_arch[1].wstrb),
            .s_m_axi4_wlast   (s_axi_to_arch[1].wlast),
            .s_m_axi4_wvalid  (s_axi_to_arch[1].wvalid),
            .s_m_axi4_wuser   (s_axi_to_arch[1].wuser),
            .s_m_axi4_ruser   (s_axi_to_arch[1].ruser),
            .s_m_axi4_arready (s_axi_to_arch[1].arready),
            .s_m_axi4_awready (s_axi_to_arch[1].awready),
            .s_m_axi4_bid     (s_axi_to_arch[1].bid),
            .s_m_axi4_bresp   (s_axi_to_arch[1].bresp),
            .s_m_axi4_bvalid  (s_axi_to_arch[1].bvalid),
            .s_m_axi4_rdata   (s_axi_to_arch[1].rdata),
            .s_m_axi4_rid     (s_axi_to_arch[1].rid),
            .s_m_axi4_rlast   (s_axi_to_arch[1].rlast),
            .s_m_axi4_rresp   (s_axi_to_arch[1].rresp),
            .s_m_axi4_rvalid  (s_axi_to_arch[1].rvalid),
            .s_m_axi4_wready  (s_axi_to_arch[1].wready)
         );
         //  --- }}}

         // ######## SIDEBAND ############
         //  --- {{{ axil_adaptor_inst
         localparam AXIL_ADDR_WIDTH_M = DEBUG_TOOLS_EN ? 32 : 27;
         wire [AXIL_ADDR_WIDTH_M-1:0] m0_axil_awaddr_full_width;
         wire [AXIL_ADDR_WIDTH_M-1:0] m0_axil_araddr_full_width;
         wire [AXIL_ADDR_WIDTH_M-1:0] m0_int_axil_awaddr_full_width;
         wire [AXIL_ADDR_WIDTH_M-1:0] m0_int_axil_araddr_full_width;
         assign s0_axilite__cal0.awaddr = m0_axil_awaddr_full_width[PORT_AXIL_ADDRESS_WIDTH-1:0];
         assign s0_axilite__cal0.araddr = m0_axil_araddr_full_width[PORT_AXIL_ADDRESS_WIDTH-1:0];
         assign s0_axilite__cal1.awaddr = m0_int_axil_awaddr_full_width[PORT_AXIL_ADDRESS_WIDTH-1:0];
         assign s0_axilite__cal1.araddr = m0_int_axil_araddr_full_width[PORT_AXIL_ADDRESS_WIDTH-1:0];
         lockstep_axil_adaptor #(
            .AXIL_ADAPTOR_EN    (1),
            .AXIL_ADDR_WIDTH_M  (AXIL_ADDR_WIDTH_M),
            .AXIL_ADDR_WIDTH    (27),
            .AXIL_ADDR_TRANS_EN (1)
         ) ls_sideband_adaptor (
            .fr_clk (ref_clk),
            .core_init_n (core_init_n),
            .axi_clk (s0_axi4_clock_out),
            .axi_rst_n (s0_axi4_reset_n),
            .s_axi_clk (s1_axi4_clock_out),
            
            //   appears as s0_axil on EMIF boundary
            .s0_axi4lite_clk      (s0_axi4lite_clock   ),
            .s0_axi4lite_rst_n    (s0_axi4lite_reset_n ),
            .s0_axi4lite_awaddr   (s0_axi4lite_awaddr  ),
            .s0_axi4lite_awvalid  (s0_axi4lite_awvalid ),
            .s0_axi4lite_awready  (s0_axi4lite_awready ),
            .s0_axi4lite_araddr   (s0_axi4lite_araddr  ),
            .s0_axi4lite_arvalid  (s0_axi4lite_arvalid ),
            .s0_axi4lite_arready  (s0_axi4lite_arready ),
            .s0_axi4lite_wdata    (s0_axi4lite_wdata   ),
            .s0_axi4lite_wvalid   (s0_axi4lite_wvalid  ),
            .s0_axi4lite_wready   (s0_axi4lite_wready  ),
            .s0_axi4lite_rresp    (s0_axi4lite_rresp   ),
            .s0_axi4lite_rdata    (s0_axi4lite_rdata   ),
            .s0_axi4lite_rvalid   (s0_axi4lite_rvalid  ),
            .s0_axi4lite_rready   (s0_axi4lite_rready  ),
            .s0_axi4lite_bresp    (s0_axi4lite_bresp   ),
            .s0_axi4lite_bvalid   (s0_axi4lite_bvalid  ),
            .s0_axi4lite_bready   (s0_axi4lite_bready  ),
            .s0_axi4lite_awprot   (s0_axi4lite_awprot  ),
            .s0_axi4lite_arprot   (s0_axi4lite_arprot  ),
            .s0_axi4lite_wstrb    (s0_axi4lite_wstrb   ),
            
            //   m0_axil --> cal_0.s0_axil
            .m0_axil_clk          (s0_axilite__cal0.clk),
            .m0_axil_rst_n        (s0_axilite__cal0.rst_n),
            .m0_axil_awaddr       (m0_axil_awaddr_full_width),
            .m0_axil_awvalid      (s0_axilite__cal0.awvalid),
            .m0_axil_awready      (s0_axilite__cal0.awready),
            .m0_axil_araddr       (m0_axil_araddr_full_width),
            .m0_axil_arvalid      (s0_axilite__cal0.arvalid),
            .m0_axil_arready      (s0_axilite__cal0.arready),
            .m0_axil_wdata        (s0_axilite__cal0.wdata),
            .m0_axil_wstrb        (s0_axilite__cal0.wstrb),
            .m0_axil_wvalid       (s0_axilite__cal0.wvalid),
            .m0_axil_wready       (s0_axilite__cal0.wready),
            .m0_axil_rresp        (s0_axilite__cal0.rresp),
            .m0_axil_rdata        (s0_axilite__cal0.rdata),
            .m0_axil_rvalid       (s0_axilite__cal0.rvalid),
            .m0_axil_rready       (s0_axilite__cal0.rready),
            .m0_axil_bresp        (s0_axilite__cal0.bresp),
            .m0_axil_bvalid       (s0_axilite__cal0.bvalid),
            .m0_axil_bready       (s0_axilite__cal0.bready),
            
            
            //   cal_0.m0_axil --> s0_int
            .s0_int_axil_awaddr        (m0_axilite__cal0.awaddr  ),
            .s0_int_axil_awvalid       (m0_axilite__cal0.awvalid ),                                             
            .s0_int_axil_awready       (m0_axilite__cal0.awready ),                                         
            .s0_int_axil_wdata         (m0_axilite__cal0.wdata   ),                                             
            .s0_int_axil_wstrb         (m0_axilite__cal0.wstrb   ),                                             
            .s0_int_axil_wvalid        (m0_axilite__cal0.wvalid  ),                                             
            .s0_int_axil_wready        (m0_axilite__cal0.wready  ),                                         
            .s0_int_axil_bresp         (m0_axilite__cal0.bresp   ),                                        
            .s0_int_axil_bvalid        (m0_axilite__cal0.bvalid  ),                                         
            .s0_int_axil_bready        (m0_axilite__cal0.bready  ),                                             
            .s0_int_axil_araddr        (m0_axilite__cal0.araddr  ),                                             
            .s0_int_axil_arvalid       (m0_axilite__cal0.arvalid ),                                             
            .s0_int_axil_arready       (m0_axilite__cal0.arready ),                                         
            .s0_int_axil_rdata         (m0_axilite__cal0.rdata   ),         
            .s0_int_axil_rresp         (m0_axilite__cal0.rresp   ),                                        
            .s0_int_axil_rvalid        (m0_axilite__cal0.rvalid  ),                                         
            .s0_int_axil_rready        (m0_axilite__cal0.rready  ),                                             
            .s0_int_axil_awprot        (m0_axilite__cal0.awprot  ),                                             
            .s0_int_axil_arprot        (m0_axilite__cal0.arprot  ),                                             


            //   m0_int --> cal_1.s0_axil
            .m0_int_axil_awaddr       (m0_int_axil_awaddr_full_width),
            .m0_int_axil_awvalid      (s0_axilite__cal1.awvalid),
            .m0_int_axil_awready      (s0_axilite__cal1.awready),
            .m0_int_axil_araddr       (m0_int_axil_araddr_full_width),
            .m0_int_axil_arvalid      (s0_axilite__cal1.arvalid),
            .m0_int_axil_arready      (s0_axilite__cal1.arready),
            .m0_int_axil_wdata        (s0_axilite__cal1.wdata),
            .m0_int_axil_wstrb        (s0_axilite__cal1.wstrb),
            .m0_int_axil_wvalid       (s0_axilite__cal1.wvalid),
            .m0_int_axil_wready       (s0_axilite__cal1.wready),
            .m0_int_axil_rresp        (s0_axilite__cal1.rresp),
            .m0_int_axil_rdata        (s0_axilite__cal1.rdata),
            .m0_int_axil_rvalid       (s0_axilite__cal1.rvalid),
            .m0_int_axil_rready       (s0_axilite__cal1.rready),
            .m0_int_axil_bresp        (s0_axilite__cal1.bresp),
            .m0_int_axil_bvalid       (s0_axilite__cal1.bvalid),
            .m0_int_axil_bready       (s0_axilite__cal1.bready),

            //   p_lockstep_ctrl    --> cal_0.lockstep_ctrl
            .p_ls_to_cal   (cal0__ls_to_cal),
            .p_ls_from_cal (cal0__ls_from_cal),

            //   s_lockstep_ctrl    --> cal_1.lockstep_ctrl    
            .s_ls_to_cal   (cal1__ls_to_cal),
            .s_ls_from_cal (cal1__ls_from_cal)
         );
         //  --- }}}

      end
   endgenerate

   //  --- {{{ Tie off any nets unused by this configuration
   generate
      genvar _ch;
      begin: unused_nets_tieoffs

         if (MEM_NUM_IO96 != 2) begin: second_cal_tieoffs
            assign s0_axilite__cal1.awready = '0;
            assign s0_axilite__cal1.arready = '0;
            assign s0_axilite__cal1.wready  = '0;
            assign s0_axilite__cal1.rresp   = '0;
            assign s0_axilite__cal1.rdata   = '0;
            assign s0_axilite__cal1.rvalid  = '0;
            assign s0_axilite__cal1.bresp   = '0;
            assign s0_axilite__cal1.bvalid  = '0;
         end

         if (!ADD_DDR4_DIMM_ADAPTORS) begin: non_lockstep_tieoffs
            assign cal0__ls_to_cal  = '0;
            assign cal1__ls_to_cal  = '0;
            assign ls_io0_usr_clk   = '0;
            assign ls_io0_usr_rst_n = '0;
         end

         for (_ch = 0; _ch < 3; ++_ch) begin: int_cache_tieoffs 
            assign s_axi_to_tniu[_ch].awcache  = '0;
            assign s_axi_to_tniu[_ch].arcache  = '0;
            assign s_axi_to_arch[_ch].awcache  = '0;
            assign s_axi_to_arch[_ch].arcache  = '0;
         end

         if (!MAINBAND_USE_NOC_TNIU) begin: fabric_mainband
            for (_ch = 0; _ch < 3; ++_ch) begin: int_noc_tieoffs 
               assign s_axi_to_tniu[_ch].awid    = '0;
               assign s_axi_to_tniu[_ch].awaddr  = '0;
               assign s_axi_to_tniu[_ch].awlen   = '0;
               assign s_axi_to_tniu[_ch].awsize  = '0;
               assign s_axi_to_tniu[_ch].awburst = '0;
               assign s_axi_to_tniu[_ch].awlock  = '0;
               assign s_axi_to_tniu[_ch].awprot  = '0;
               assign s_axi_to_tniu[_ch].awuser  = '0;
               assign s_axi_to_tniu[_ch].awvalid = '0;
               assign s_axi_to_tniu[_ch].awready = '0;
               assign s_axi_to_tniu[_ch].awqos   = '0;
               assign s_axi_to_tniu[_ch].wdata   = '0;
               assign s_axi_to_tniu[_ch].wstrb   = '0;
               assign s_axi_to_tniu[_ch].wlast   = '0;
               assign s_axi_to_tniu[_ch].wvalid  = '0;
               assign s_axi_to_tniu[_ch].wready  = '0;
               assign s_axi_to_tniu[_ch].wuser   = '0;
               assign s_axi_to_tniu[_ch].bid     = '0;  
               assign s_axi_to_tniu[_ch].bresp   = '0;
               assign s_axi_to_tniu[_ch].bvalid  = '0;
               assign s_axi_to_tniu[_ch].bready  = '0;
               assign s_axi_to_tniu[_ch].arid    = '0; 
               assign s_axi_to_tniu[_ch].araddr  = '0;
               assign s_axi_to_tniu[_ch].arlen   = '0;
               assign s_axi_to_tniu[_ch].arsize  = '0;
               assign s_axi_to_tniu[_ch].arburst = '0;
               assign s_axi_to_tniu[_ch].arlock  = '0;
               assign s_axi_to_tniu[_ch].arprot  = '0;
               assign s_axi_to_tniu[_ch].aruser  = '0;
               assign s_axi_to_tniu[_ch].arvalid = '0;
               assign s_axi_to_tniu[_ch].arready = '0;
               assign s_axi_to_tniu[_ch].arqos   = '0;
               assign s_axi_to_tniu[_ch].rid     = '0;  
               assign s_axi_to_tniu[_ch].rdata   = '0;
               assign s_axi_to_tniu[_ch].rresp   = '0;
               assign s_axi_to_tniu[_ch].rlast   = '0;
               assign s_axi_to_tniu[_ch].rvalid  = '0;
               assign s_axi_to_tniu[_ch].rready  = '0;
               assign s_axi_to_tniu[_ch].ruser   = '0;
            end
         end

         if (MEM_NUM_CHANNELS_PER_IO96 == 1) begin: one_ch_per_io96
            for (_ch = 2; _ch <= 3; ++_ch) begin: one_ch_per_io96__int_axi_tieoffs
               assign s_axi_to_arch[_ch].arready  = '0;
               assign s_axi_to_arch[_ch].awready  = '0;
               assign s_axi_to_arch[_ch].bid      = '0;
               assign s_axi_to_arch[_ch].bresp    = '0;
               assign s_axi_to_arch[_ch].bvalid   = '0;
               assign s_axi_to_arch[_ch].rdata    = '0;
               assign s_axi_to_arch[_ch].rid      = '0;
               assign s_axi_to_arch[_ch].rlast    = '0;
               assign s_axi_to_arch[_ch].rresp    = '0;
               assign s_axi_to_arch[_ch].ruser    = '0;
               assign s_axi_to_arch[_ch].rvalid   = '0;
               assign s_axi_to_arch[_ch].wready   = '0;
            end
            if (MEM_NUM_IO96 != 2) begin: one_ch_per_io96__io96_two_tieoffs
               assign s_axi_to_arch[1].arready  = '0;
               assign s_axi_to_arch[1].awready  = '0;
               assign s_axi_to_arch[1].bid      = '0;
               assign s_axi_to_arch[1].bresp    = '0;
               assign s_axi_to_arch[1].bvalid   = '0;
               assign s_axi_to_arch[1].rdata    = '0;
               assign s_axi_to_arch[1].rid      = '0;
               assign s_axi_to_arch[1].rlast    = '0;
               assign s_axi_to_arch[1].rresp    = '0;
               assign s_axi_to_arch[1].ruser    = '0;
               assign s_axi_to_arch[1].rvalid   = '0;
               assign s_axi_to_arch[1].wready   = '0;
            end
         end else begin: two_ch_per_io96
            if (MEM_NUM_IO96 != 2) begin: two_ch_per_io96__one_io96
               for (_ch = 2; _ch <= 3; ++_ch) begin: two_ch_per_io96__one_io96__int_axi_tieoffs
                  assign s_axi_to_arch[_ch].arready  = '0;
                  assign s_axi_to_arch[_ch].awready  = '0;
                  assign s_axi_to_arch[_ch].bid      = '0;
                  assign s_axi_to_arch[_ch].bresp    = '0;
                  assign s_axi_to_arch[_ch].bvalid   = '0;
                  assign s_axi_to_arch[_ch].rdata    = '0;
                  assign s_axi_to_arch[_ch].rid      = '0;
                  assign s_axi_to_arch[_ch].rlast    = '0;
                  assign s_axi_to_arch[_ch].rresp    = '0;
                  assign s_axi_to_arch[_ch].ruser    = '0;
                  assign s_axi_to_arch[_ch].rvalid   = '0;
                  assign s_axi_to_arch[_ch].wready   = '0;
               end
            end
         end

      end
   endgenerate
   //  --- }}}

endmodule

`ifdef ZERO_PAD_PORT
`undef ZERO_PAD_PORT
`endif


