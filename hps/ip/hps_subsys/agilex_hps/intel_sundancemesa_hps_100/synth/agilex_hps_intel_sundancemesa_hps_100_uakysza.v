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



module agilex_hps_intel_sundancemesa_hps_100_uakysza(
  output wire [0 : 0 ] h2f_reset
 ,input wire [0 : 0 ] lwhps2fpga_clk
 ,input wire [0 : 0 ] lwhps2fpga_rst
 ,output wire [3 : 0 ] lwhps2fpga_awid
 ,output wire [28 : 0 ] lwhps2fpga_awaddr
 ,output wire [7 : 0 ] lwhps2fpga_awlen
 ,output wire [2 : 0 ] lwhps2fpga_awsize
 ,output wire [1 : 0 ] lwhps2fpga_awburst
 ,output wire [0 : 0 ] lwhps2fpga_awlock
 ,output wire [3 : 0 ] lwhps2fpga_awcache
 ,output wire [2 : 0 ] lwhps2fpga_awprot
 ,output wire [0 : 0 ] lwhps2fpga_awvalid
 ,input wire [0 : 0 ] lwhps2fpga_awready
 ,output wire [31 : 0 ] lwhps2fpga_wdata
 ,output wire [3 : 0 ] lwhps2fpga_wstrb
 ,output wire [0 : 0 ] lwhps2fpga_wlast
 ,output wire [0 : 0 ] lwhps2fpga_wvalid
 ,input wire [0 : 0 ] lwhps2fpga_wready
 ,input wire [3 : 0 ] lwhps2fpga_bid
 ,input wire [1 : 0 ] lwhps2fpga_bresp
 ,input wire [0 : 0 ] lwhps2fpga_bvalid
 ,output wire [0 : 0 ] lwhps2fpga_bready
 ,output wire [3 : 0 ] lwhps2fpga_arid
 ,output wire [28 : 0 ] lwhps2fpga_araddr
 ,output wire [7 : 0 ] lwhps2fpga_arlen
 ,output wire [2 : 0 ] lwhps2fpga_arsize
 ,output wire [1 : 0 ] lwhps2fpga_arburst
 ,output wire [0 : 0 ] lwhps2fpga_arlock
 ,output wire [3 : 0 ] lwhps2fpga_arcache
 ,output wire [2 : 0 ] lwhps2fpga_arprot
 ,output wire [0 : 0 ] lwhps2fpga_arvalid
 ,input wire [0 : 0 ] lwhps2fpga_arready
 ,input wire [3 : 0 ] lwhps2fpga_rid
 ,input wire [31 : 0 ] lwhps2fpga_rdata
 ,input wire [1 : 0 ] lwhps2fpga_rresp
 ,input wire [0 : 0 ] lwhps2fpga_rlast
 ,input wire [0 : 0 ] lwhps2fpga_rvalid
 ,output wire [0 : 0 ] lwhps2fpga_rready
 ,output wire [0 : 0 ] emac0_rst_clk_app_n_o
 ,input wire [0 : 0 ] uart0_cts_n
 ,input wire [0 : 0 ] uart0_dcd_n
 ,input wire [0 : 0 ] uart0_dsr_n
 ,output wire [0 : 0 ] uart0_dtr_n
 ,output wire [0 : 0 ] uart0_out1_n
 ,output wire [0 : 0 ] uart0_out2_n
 ,input wire [0 : 0 ] uart0_ri_n
 ,output wire [0 : 0 ] uart0_rts_n
 ,input wire [0 : 0 ] uart0_rx
 ,output wire [0 : 0 ] uart0_tx
 ,input wire [0 : 0 ] hps_osc_clk
 ,inout wire [0 : 0 ] sdmmc_data0
 ,inout wire [0 : 0 ] sdmmc_data1
 ,output wire [0 : 0 ] sdmmc_cclk
 ,inout wire [0 : 0 ] sdmmc_data2
 ,inout wire [0 : 0 ] sdmmc_data3
 ,inout wire [0 : 0 ] sdmmc_cmd
 ,output wire [0 : 0 ] emac0_tx_clk
 ,output wire [0 : 0 ] emac0_tx_ctl
 ,input wire [0 : 0 ] emac0_rx_clk
 ,input wire [0 : 0 ] emac0_rx_ctl
 ,output wire [0 : 0 ] emac0_txd0
 ,output wire [0 : 0 ] emac0_txd1
 ,input wire [0 : 0 ] emac0_rxd0
 ,input wire [0 : 0 ] emac0_rxd1
 ,output wire [0 : 0 ] emac0_txd2
 ,output wire [0 : 0 ] emac0_txd3
 ,input wire [0 : 0 ] emac0_rxd2
 ,input wire [0 : 0 ] emac0_rxd3
 ,inout wire [0 : 0 ] mdio0_mdio
 ,output wire [0 : 0 ] mdio0_mdc
 ,output wire [0 : 0 ] uart1_io_tx
 ,input wire [0 : 0 ] uart1_io_rx
 ,inout wire [0 : 0 ] gpio40
 ,inout wire [0 : 0 ] gpio41
 ,output wire [0 : 0 ] hps2mpfe_ccu_clk
 ,output wire [0 : 0 ] hps2mpfe_ccu_rst
 ,output wire [43 : 0 ] hps2mpfe_dmi0_araddr
 ,output wire [1 : 0 ] hps2mpfe_dmi0_arburst
 ,output wire [3 : 0 ] hps2mpfe_dmi0_arcache
 ,output wire [9 : 0 ] hps2mpfe_dmi0_arid
 ,output wire [7 : 0 ] hps2mpfe_dmi0_arlen
 ,output wire [0 : 0 ] hps2mpfe_dmi0_arlock
 ,output wire [2 : 0 ] hps2mpfe_dmi0_arprot
 ,output wire [3 : 0 ] hps2mpfe_dmi0_arqos
 ,input wire [0 : 0 ] hps2mpfe_dmi0_arready
 ,output wire [2 : 0 ] hps2mpfe_dmi0_arsize
 ,output wire [7 : 0 ] hps2mpfe_dmi0_aruser
 ,output wire [0 : 0 ] hps2mpfe_dmi0_arvalid
 ,output wire [43 : 0 ] hps2mpfe_dmi0_awaddr
 ,output wire [1 : 0 ] hps2mpfe_dmi0_awburst
 ,output wire [3 : 0 ] hps2mpfe_dmi0_awcache
 ,output wire [9 : 0 ] hps2mpfe_dmi0_awid
 ,output wire [7 : 0 ] hps2mpfe_dmi0_awlen
 ,output wire [0 : 0 ] hps2mpfe_dmi0_awlock
 ,output wire [2 : 0 ] hps2mpfe_dmi0_awprot
 ,output wire [3 : 0 ] hps2mpfe_dmi0_awqos
 ,input wire [0 : 0 ] hps2mpfe_dmi0_awready
 ,output wire [2 : 0 ] hps2mpfe_dmi0_awsize
 ,output wire [7 : 0 ] hps2mpfe_dmi0_awuser
 ,output wire [0 : 0 ] hps2mpfe_dmi0_awvalid
 ,input wire [9 : 0 ] hps2mpfe_dmi0_bid
 ,output wire [0 : 0 ] hps2mpfe_dmi0_bready
 ,input wire [1 : 0 ] hps2mpfe_dmi0_bresp
 ,input wire [0 : 0 ] hps2mpfe_dmi0_bvalid
 ,input wire [255 : 0 ] hps2mpfe_dmi0_rdata
 ,input wire [9 : 0 ] hps2mpfe_dmi0_rid
 ,input wire [0 : 0 ] hps2mpfe_dmi0_rlast
 ,output wire [0 : 0 ] hps2mpfe_dmi0_rready
 ,input wire [1 : 0 ] hps2mpfe_dmi0_rresp
 ,input wire [0 : 0 ] hps2mpfe_dmi0_rvalid
 ,output wire [255 : 0 ] hps2mpfe_dmi0_wdata
 ,output wire [0 : 0 ] hps2mpfe_dmi0_wlast
 ,input wire [0 : 0 ] hps2mpfe_dmi0_wready
 ,output wire [31 : 0 ] hps2mpfe_dmi0_wstrb
 ,output wire [0 : 0 ] hps2mpfe_dmi0_wvalid
 ,output wire [43 : 0 ] hps2mpfe_dmi1_araddr
 ,output wire [1 : 0 ] hps2mpfe_dmi1_arburst
 ,output wire [3 : 0 ] hps2mpfe_dmi1_arcache
 ,output wire [9 : 0 ] hps2mpfe_dmi1_arid
 ,output wire [7 : 0 ] hps2mpfe_dmi1_arlen
 ,output wire [0 : 0 ] hps2mpfe_dmi1_arlock
 ,output wire [2 : 0 ] hps2mpfe_dmi1_arprot
 ,output wire [3 : 0 ] hps2mpfe_dmi1_arqos
 ,input wire [0 : 0 ] hps2mpfe_dmi1_arready
 ,output wire [2 : 0 ] hps2mpfe_dmi1_arsize
 ,output wire [7 : 0 ] hps2mpfe_dmi1_aruser
 ,output wire [0 : 0 ] hps2mpfe_dmi1_arvalid
 ,output wire [43 : 0 ] hps2mpfe_dmi1_awaddr
 ,output wire [1 : 0 ] hps2mpfe_dmi1_awburst
 ,output wire [3 : 0 ] hps2mpfe_dmi1_awcache
 ,output wire [9 : 0 ] hps2mpfe_dmi1_awid
 ,output wire [7 : 0 ] hps2mpfe_dmi1_awlen
 ,output wire [0 : 0 ] hps2mpfe_dmi1_awlock
 ,output wire [2 : 0 ] hps2mpfe_dmi1_awprot
 ,output wire [3 : 0 ] hps2mpfe_dmi1_awqos
 ,input wire [0 : 0 ] hps2mpfe_dmi1_awready
 ,output wire [2 : 0 ] hps2mpfe_dmi1_awsize
 ,output wire [7 : 0 ] hps2mpfe_dmi1_awuser
 ,output wire [0 : 0 ] hps2mpfe_dmi1_awvalid
 ,input wire [9 : 0 ] hps2mpfe_dmi1_bid
 ,output wire [0 : 0 ] hps2mpfe_dmi1_bready
 ,input wire [1 : 0 ] hps2mpfe_dmi1_bresp
 ,input wire [0 : 0 ] hps2mpfe_dmi1_bvalid
 ,input wire [255 : 0 ] hps2mpfe_dmi1_rdata
 ,input wire [9 : 0 ] hps2mpfe_dmi1_rid
 ,input wire [0 : 0 ] hps2mpfe_dmi1_rlast
 ,output wire [0 : 0 ] hps2mpfe_dmi1_rready
 ,input wire [1 : 0 ] hps2mpfe_dmi1_rresp
 ,input wire [0 : 0 ] hps2mpfe_dmi1_rvalid
 ,output wire [255 : 0 ] hps2mpfe_dmi1_wdata
 ,output wire [0 : 0 ] hps2mpfe_dmi1_wlast
 ,input wire [0 : 0 ] hps2mpfe_dmi1_wready
 ,output wire [31 : 0 ] hps2mpfe_dmi1_wstrb
 ,output wire [0 : 0 ] hps2mpfe_dmi1_wvalid
 ,output wire [43 : 0 ] hps2mpfe_csr_araddr
 ,output wire [1 : 0 ] hps2mpfe_csr_arburst
 ,output wire [3 : 0 ] hps2mpfe_csr_arcache
 ,output wire [9 : 0 ] hps2mpfe_csr_arid
 ,output wire [7 : 0 ] hps2mpfe_csr_arlen
 ,output wire [0 : 0 ] hps2mpfe_csr_arlock
 ,output wire [2 : 0 ] hps2mpfe_csr_arprot
 ,input wire [0 : 0 ] hps2mpfe_csr_arready
 ,output wire [2 : 0 ] hps2mpfe_csr_arsize
 ,output wire [7 : 0 ] hps2mpfe_csr_aruser
 ,output wire [0 : 0 ] hps2mpfe_csr_arvalid
 ,output wire [43 : 0 ] hps2mpfe_csr_awaddr
 ,output wire [1 : 0 ] hps2mpfe_csr_awburst
 ,output wire [3 : 0 ] hps2mpfe_csr_awcache
 ,output wire [9 : 0 ] hps2mpfe_csr_awid
 ,output wire [7 : 0 ] hps2mpfe_csr_awlen
 ,output wire [0 : 0 ] hps2mpfe_csr_awlock
 ,output wire [2 : 0 ] hps2mpfe_csr_awprot
 ,input wire [0 : 0 ] hps2mpfe_csr_awready
 ,output wire [2 : 0 ] hps2mpfe_csr_awsize
 ,output wire [7 : 0 ] hps2mpfe_csr_awuser
 ,output wire [0 : 0 ] hps2mpfe_csr_awvalid
 ,input wire [9 : 0 ] hps2mpfe_csr_bid
 ,output wire [0 : 0 ] hps2mpfe_csr_bready
 ,input wire [1 : 0 ] hps2mpfe_csr_bresp
 ,input wire [0 : 0 ] hps2mpfe_csr_bvalid
 ,input wire [63 : 0 ] hps2mpfe_csr_rdata
 ,input wire [9 : 0 ] hps2mpfe_csr_rid
 ,input wire [0 : 0 ] hps2mpfe_csr_rlast
 ,output wire [0 : 0 ] hps2mpfe_csr_rready
 ,input wire [1 : 0 ] hps2mpfe_csr_rresp
 ,input wire [0 : 0 ] hps2mpfe_csr_rvalid
 ,output wire [63 : 0 ] hps2mpfe_csr_wdata
 ,output wire [0 : 0 ] hps2mpfe_csr_wlast
 ,input wire [0 : 0 ] hps2mpfe_csr_wready
 ,output wire [7 : 0 ] hps2mpfe_csr_wstrb
 ,output wire [0 : 0 ] hps2mpfe_csr_wvalid
 ,input wire [31 : 0 ] f2h_fpga_irq64
 ,input wire [31 : 0 ] f2h_fpga_irq32
 ,output wire [0 : 0 ] h2emif_interconnect_axi_rst
);

// assignments for top ports
assign hps2mpfe_ccu_rst = 1'd0;

wire [ 0:0] lwhps2fpga_rst_intr;
wire [ 3:0] lwhps2fpga_awid_intr;
wire [ 28:0] lwhps2fpga_awaddr_intr;
wire [ 7:0] lwhps2fpga_awlen_intr;
wire [ 2:0] lwhps2fpga_awsize_intr;
wire [ 1:0] lwhps2fpga_awburst_intr;
wire [ 0:0] lwhps2fpga_awlock_intr;
wire [ 3:0] lwhps2fpga_awcache_intr;
wire [ 2:0] lwhps2fpga_awprot_intr;
wire [ 0:0] lwhps2fpga_awvalid_intr;
wire [ 0:0] lwhps2fpga_awready_intr;
wire [ 31:0] lwhps2fpga_wdata_intr;
wire [ 3:0] lwhps2fpga_wstrb_intr;
wire [ 0:0] lwhps2fpga_wlast_intr;
wire [ 0:0] lwhps2fpga_wvalid_intr;
wire [ 0:0] lwhps2fpga_wready_intr;
wire [ 3:0] lwhps2fpga_bid_intr;
wire [ 1:0] lwhps2fpga_bresp_intr;
wire [ 0:0] lwhps2fpga_bvalid_intr;
wire [ 0:0] lwhps2fpga_bready_intr;
wire [ 3:0] lwhps2fpga_arid_intr;
wire [ 28:0] lwhps2fpga_araddr_intr;
wire [ 7:0] lwhps2fpga_arlen_intr;
wire [ 2:0] lwhps2fpga_arsize_intr;
wire [ 1:0] lwhps2fpga_arburst_intr;
wire [ 0:0] lwhps2fpga_arlock_intr;
wire [ 3:0] lwhps2fpga_arcache_intr;
wire [ 2:0] lwhps2fpga_arprot_intr;
wire [ 0:0] lwhps2fpga_arvalid_intr;
wire [ 0:0] lwhps2fpga_arready_intr;
wire [ 3:0] lwhps2fpga_rid_intr;
wire [ 31:0] lwhps2fpga_rdata_intr;
wire [ 1:0] lwhps2fpga_rresp_intr;
wire [ 0:0] lwhps2fpga_rlast_intr;
wire [ 0:0] lwhps2fpga_rvalid_intr;
wire [ 0:0] lwhps2fpga_rready_intr;


wire [0:0] hps_osc_clk_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_hps_osc_clk_ibuf(
    .i(hps_osc_clk),
    .o(hps_osc_clk_ibuf_o)
);



wire [0:0] sdmmc_cclk_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_sdmmc_cclk_obuf(
    .i(sdmmc_cclk_obuf_i),
    .o(sdmmc_cclk),
    .oe(1'b1)
);

wire [0:0] sdmmc_data3_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_sdmmc_data3_ibuf(
    .i(sdmmc_data3),
    .o(sdmmc_data3_ibuf_o)
);

wire [0:0] sdmmc_data3_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_sdmmc_data3_obuf(
    .i(sdmmc_data3_obuf_i),
    .o(sdmmc_data3),
    .oe(1'b1)
);

wire [0:0] emac0_rx_clk_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_emac0_rx_clk_ibuf(
    .i(emac0_rx_clk),
    .o(emac0_rx_clk_ibuf_o)
);


wire [0:0] mdio0_mdio_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_mdio0_mdio_ibuf(
    .i(mdio0_mdio),
    .o(mdio0_mdio_ibuf_o)
);

wire [0:0] mdio0_mdio_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_mdio0_mdio_obuf(
    .i(mdio0_mdio_obuf_i),
    .o(mdio0_mdio),
    .oe(1'b1)
);


wire [0:0] emac0_tx_clk_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_emac0_tx_clk_obuf(
    .i(emac0_tx_clk_obuf_i),
    .o(emac0_tx_clk),
    .oe(1'b1)
);

wire [0:0] gpio40_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_gpio40_ibuf(
    .i(gpio40),
    .o(gpio40_ibuf_o)
);

wire [0:0] gpio40_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_gpio40_obuf(
    .i(gpio40_obuf_i),
    .o(gpio40),
    .oe(1'b1)
);

wire [0:0] emac0_rxd0_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_emac0_rxd0_ibuf(
    .i(emac0_rxd0),
    .o(emac0_rxd0_ibuf_o)
);


wire [0:0] gpio41_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_gpio41_ibuf(
    .i(gpio41),
    .o(gpio41_ibuf_o)
);

wire [0:0] gpio41_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_gpio41_obuf(
    .i(gpio41_obuf_i),
    .o(gpio41),
    .oe(1'b1)
);

wire [0:0] emac0_rxd1_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_emac0_rxd1_ibuf(
    .i(emac0_rxd1),
    .o(emac0_rxd1_ibuf_o)
);



wire [0:0] emac0_txd0_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_emac0_txd0_obuf(
    .i(emac0_txd0_obuf_i),
    .o(emac0_txd0),
    .oe(1'b1)
);

wire [0:0] uart1_io_rx_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_uart1_io_rx_ibuf(
    .i(uart1_io_rx),
    .o(uart1_io_rx_ibuf_o)
);


wire [0:0] emac0_rxd2_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_emac0_rxd2_ibuf(
    .i(emac0_rxd2),
    .o(emac0_rxd2_ibuf_o)
);



wire [0:0] emac0_txd1_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_emac0_txd1_obuf(
    .i(emac0_txd1_obuf_i),
    .o(emac0_txd1),
    .oe(1'b1)
);

wire [0:0] emac0_rxd3_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_emac0_rxd3_ibuf(
    .i(emac0_rxd3),
    .o(emac0_rxd3_ibuf_o)
);



wire [0:0] emac0_txd2_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_emac0_txd2_obuf(
    .i(emac0_txd2_obuf_i),
    .o(emac0_txd2),
    .oe(1'b1)
);


wire [0:0] uart1_io_tx_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_uart1_io_tx_obuf(
    .i(uart1_io_tx_obuf_i),
    .o(uart1_io_tx),
    .oe(1'b1)
);


wire [0:0] emac0_txd3_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_emac0_txd3_obuf(
    .i(emac0_txd3_obuf_i),
    .o(emac0_txd3),
    .oe(1'b1)
);

wire [0:0] emac0_rx_ctl_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_emac0_rx_ctl_ibuf(
    .i(emac0_rx_ctl),
    .o(emac0_rx_ctl_ibuf_o)
);



wire [0:0] emac0_tx_ctl_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_emac0_tx_ctl_obuf(
    .i(emac0_tx_ctl_obuf_i),
    .o(emac0_tx_ctl),
    .oe(1'b1)
);


wire [0:0] mdio0_mdc_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_mdio0_mdc_obuf(
    .i(mdio0_mdc_obuf_i),
    .o(mdio0_mdc),
    .oe(1'b1)
);

wire [0:0] sdmmc_data0_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_sdmmc_data0_ibuf(
    .i(sdmmc_data0),
    .o(sdmmc_data0_ibuf_o)
);

wire [0:0] sdmmc_data0_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_sdmmc_data0_obuf(
    .i(sdmmc_data0_obuf_i),
    .o(sdmmc_data0),
    .oe(1'b1)
);

wire [0:0] sdmmc_data1_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_sdmmc_data1_ibuf(
    .i(sdmmc_data1),
    .o(sdmmc_data1_ibuf_o)
);

wire [0:0] sdmmc_data1_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_sdmmc_data1_obuf(
    .i(sdmmc_data1_obuf_i),
    .o(sdmmc_data1),
    .oe(1'b1)
);

wire [0:0] sdmmc_cmd_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_sdmmc_cmd_ibuf(
    .i(sdmmc_cmd),
    .o(sdmmc_cmd_ibuf_o)
);

wire [0:0] sdmmc_cmd_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_sdmmc_cmd_obuf(
    .i(sdmmc_cmd_obuf_i),
    .o(sdmmc_cmd),
    .oe(1'b1)
);

wire [0:0] sdmmc_data2_ibuf_o;
tennm_ph2_io_ibuf #(
    .buffer_usage("REGULAR"),
    .bus_hold("BUS_HOLD_OFF"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .schmitt_trigger("SCHMITT_TRIGGER_OFF"),
    .termination("TERMINATION_RT_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO"),
    .vref("VREF_OFF"),
    .weak_pull_down("WEAK_PULL_DOWN_OFF"),
    .weak_pull_up("WEAK_PULL_UP_OFF")
) hps_sdmmc_data2_ibuf(
    .i(sdmmc_data2),
    .o(sdmmc_data2_ibuf_o)
);

wire [0:0] sdmmc_data2_obuf_i;
tennm_ph2_io_obuf #(
    .buffer_usage("REGULAR"),
    .dynamic_pull_up_enabled("false"),
    .equalization("EQUALIZATION_OFF"),
    .io_standard("IO_STANDARD_IOSTD_OFF"),
    .open_drain("OPEN_DRAIN_OFF"),
    .rzq_id("RZQ_ID_RZQ0"),
    .slew_rate("SLEW_RATE_SLOW"),
    .termination("TERMINATION_SERIES_OFF"),
    .toggle_speed("TOGGLE_SPEED_SLOW"),
    .usage_mode("USAGE_MODE_GPIO")
) hps_sdmmc_data2_obuf(
    .i(sdmmc_data2_obuf_i),
    .o(sdmmc_data2),
    .oe(1'b1)
);

ready_latency_reset_synchronizer lwhps2fpga_axi4_rl_adp_inst_reset_sync(
 .clk(lwhps2fpga_clk)
,.rst_async(lwhps2fpga_rst)
,.rst_sync(lwhps2fpga_rst_intr)
);

hps_axi4_ready_latency_adp #(
        .NUM_PIPELINES(2)
        ,.LOG_DEPTH(3)
        ,.ID_WIDTH(4)
        ,.ADDR_WIDTH(29)
        ,.DATA_WIDTH(32)
        ,.STRB_WIDTH(4)
        ,.BUFFER_TYPE("MLAB")
        ) lwhps2fpga_axi4_rl_adp_inst(
 .clk(lwhps2fpga_clk)
,.reset(lwhps2fpga_rst_intr)
,.awid(lwhps2fpga_awid_intr)
,.awid_r(lwhps2fpga_awid)
,.awaddr(lwhps2fpga_awaddr_intr)
,.awaddr_r(lwhps2fpga_awaddr)
,.awlen(lwhps2fpga_awlen_intr)
,.awlen_r(lwhps2fpga_awlen)
,.awsize(lwhps2fpga_awsize_intr)
,.awsize_r(lwhps2fpga_awsize)
,.awburst(lwhps2fpga_awburst_intr)
,.awburst_r(lwhps2fpga_awburst)
,.awlock(lwhps2fpga_awlock_intr)
,.awlock_r(lwhps2fpga_awlock)
,.awcache(lwhps2fpga_awcache_intr)
,.awcache_r(lwhps2fpga_awcache)
,.awprot(lwhps2fpga_awprot_intr)
,.awprot_r(lwhps2fpga_awprot)
,.awvalid(lwhps2fpga_awvalid_intr)
,.awvalid_r(lwhps2fpga_awvalid)
,.awready(lwhps2fpga_awready)
,.awready_r(lwhps2fpga_awready_intr)
,.wdata(lwhps2fpga_wdata_intr)
,.wdata_r(lwhps2fpga_wdata)
,.wstrb(lwhps2fpga_wstrb_intr)
,.wstrb_r(lwhps2fpga_wstrb)
,.wlast(lwhps2fpga_wlast_intr)
,.wlast_r(lwhps2fpga_wlast)
,.wvalid(lwhps2fpga_wvalid_intr)
,.wvalid_r(lwhps2fpga_wvalid)
,.wready(lwhps2fpga_wready)
,.wready_r(lwhps2fpga_wready_intr)
,.bid(lwhps2fpga_bid)
,.bid_r(lwhps2fpga_bid_intr)
,.bresp(lwhps2fpga_bresp)
,.bresp_r(lwhps2fpga_bresp_intr)
,.bvalid(lwhps2fpga_bvalid)
,.bvalid_r(lwhps2fpga_bvalid_intr)
,.bready(lwhps2fpga_bready_intr)
,.bready_r(lwhps2fpga_bready)
,.arid(lwhps2fpga_arid_intr)
,.arid_r(lwhps2fpga_arid)
,.araddr(lwhps2fpga_araddr_intr)
,.araddr_r(lwhps2fpga_araddr)
,.arlen(lwhps2fpga_arlen_intr)
,.arlen_r(lwhps2fpga_arlen)
,.arsize(lwhps2fpga_arsize_intr)
,.arsize_r(lwhps2fpga_arsize)
,.arburst(lwhps2fpga_arburst_intr)
,.arburst_r(lwhps2fpga_arburst)
,.arlock(lwhps2fpga_arlock_intr)
,.arlock_r(lwhps2fpga_arlock)
,.arcache(lwhps2fpga_arcache_intr)
,.arcache_r(lwhps2fpga_arcache)
,.arprot(lwhps2fpga_arprot_intr)
,.arprot_r(lwhps2fpga_arprot)
,.arvalid(lwhps2fpga_arvalid_intr)
,.arvalid_r(lwhps2fpga_arvalid)
,.arready(lwhps2fpga_arready)
,.arready_r(lwhps2fpga_arready_intr)
,.rid(lwhps2fpga_rid)
,.rid_r(lwhps2fpga_rid_intr)
,.rdata(lwhps2fpga_rdata)
,.rdata_r(lwhps2fpga_rdata_intr)
,.rresp(lwhps2fpga_rresp)
,.rresp_r(lwhps2fpga_rresp_intr)
,.rlast(lwhps2fpga_rlast)
,.rlast_r(lwhps2fpga_rlast_intr)
,.rvalid(lwhps2fpga_rvalid)
,.rvalid_r(lwhps2fpga_rvalid_intr)
,.rready(lwhps2fpga_rready_intr)
,.rready_r(lwhps2fpga_rready)
);

(* preserve *) wire w_tpiu_clkin;

(* preserve *) tennm_lcell_comb #(
    .dont_touch("on"),
    .lut_mask(64'hAAAAAAAAAAAAAAAA) // buffer
  ) tpiu_clkin_lcell (
    .dataa(1'b0)
    ,.combout(w_tpiu_clkin)
);

wire[63:0] unused_bits;
(* preserve *)(* altera_attribute = "-name PRESERVE_FANOUT_FREE_WYSIWYG ON" *) 
tennm_soc_hps #(
.soc_hps_wrapper_powerdown_mode("FALSE")
,.soc_hps_wrapper_hps_a55_core_state("HPS_A55_CORE_STATE_BOTH_ON")
,.soc_hps_wrapper_hps_a76_core_selection("HPS_A76_CORE_SELECTION_OFF")
,.soc_hps_wrapper_hps_l3_memory_size("HPS_L3_MEMORY_SIZE_1_MB")
,.soc_hps_wrapper_powermode_freq_hz(32'b00011111110010011111100001010000)
,.soc_hps_wrapper_h2f_addr_width(32'b00000000000000000000000000100110)
,.soc_hps_wrapper_h2f_data_width(32'b00000000000000000000000000000000)
,.soc_hps_wrapper_lwh2f_addr_width(32'b00000000000000000000000000011101)
,.soc_hps_wrapper_lwh2f_data_width(32'b00000000000000000000000000100000)
 ) sundancemesa_hps_inst (
  .ccu_dmi1_awcache({
     hps2mpfe_dmi1_awcache[3:0]
  })
 ,.mpfe_csr_wlast({
     hps2mpfe_csr_wlast[0:0]
  })
 ,.lwsoc2fpga_b_resp({
     lwhps2fpga_bresp_intr
  })
 ,.hps_iob_8_bidir_in({
     sdmmc_cmd_ibuf_o
  })
 ,.hps_iob_1_bidir_in({
     sdmmc_data0_ibuf_o
  })
 ,.cs_dbg_fpga_apb_prdata({
     32'h0
  })
 ,.lwsoc2fpga_b_id({
     lwhps2fpga_bid_intr
  })
 ,.fpga_atb_atbytes({
     2'h0
  })
 ,.soc2fpga_port_size_config_0({
     1'h1
  })
 ,.soc2fpga_port_size_config_1({
     1'h1
  })
 ,.mpfe_csr_rdata({
     hps2mpfe_csr_rdata[63:0]
  })
 ,.fpga_atb_atdata({
     32'h0
  })
 ,.soc2fpga_b_id({
     4'h0
  })
 ,.i2c_emac0_sda_i({
     1'h0
  })
 ,.ccu_dmi1_awlen({
     hps2mpfe_dmi1_awlen[7:0]
  })
 ,.f2s_fpga_irq({
     f2h_fpga_irq64[31:0]
    ,f2h_fpga_irq32[31:0]
  })
 ,.ccu_dmi0_bvalid({
     hps2mpfe_dmi0_bvalid[0:0]
  })
 ,.lwsoc2fpga_aw_len({
     lwhps2fpga_awlen_intr
  })
 ,.uart0_rx({
     uart0_rx[0:0]
  })
 ,.cs_dbg_fpga_apb_pclken({
     1'h0
  })
 ,.mpfe_csr_awburst({
     hps2mpfe_csr_awburst[1:0]
  })
 ,.ccu_dmi0_awqos({
     hps2mpfe_dmi0_awqos[3:0]
  })
 ,.lwsoc2fpga_ar_id({
     lwhps2fpga_arid_intr
  })
 ,.lwsoc2fpga_ar_ready({
     lwhps2fpga_arready_intr
  })
 ,.mpfe_csr_arvalid({
     hps2mpfe_csr_arvalid[0:0]
  })
 ,.lwsoc2fpga_port_size_config_0({
     1'h1
  })
 ,.ccu_dmi1_rvalid({
     hps2mpfe_dmi1_rvalid[0:0]
  })
 ,.hps_ioa_22_bidir_out({
     emac0_txd3_obuf_i
  })
 ,.fpga0_dma_single({
     1'h0
  })
 ,.ccu_dmi0_awuser({
     hps2mpfe_dmi0_awuser[7:0]
  })
 ,.ccu_dmi0_awlen({
     hps2mpfe_dmi0_awlen[7:0]
  })
 ,.hps_iob_7_bidir_out({
     sdmmc_data3_obuf_i
  })
 ,.mpfe_csr_awprot({
     hps2mpfe_csr_awprot[2:0]
  })
 ,.ccu_dmi0_awlock({
     hps2mpfe_dmi0_awlock[0:0]
  })
 ,.mpfe_csr_rready({
     hps2mpfe_csr_rready[0:0]
  })
 ,.mpfe_csr_wvalid({
     hps2mpfe_csr_wvalid[0:0]
  })
 ,.emac2_phy_txclk_i({
     1'h0
  })
 ,.fpga_eventoack({
     1'h0
  })
 ,.hps_ioa_23_bidir_in({
     emac0_rxd2_ibuf_o
  })
 ,.hps_ioa_15_bidir_in({
     emac0_rx_clk_ibuf_o
  })
 ,.hps_ioa_14_bidir_out({
     emac0_tx_ctl_obuf_i
  })
 ,.uart0_tx({
     uart0_tx[0:0]
  })
 ,.emac2_phy_crs_i({
     1'h0
  })
 ,.lwsoc2fpga_b_valid({
     lwhps2fpga_bvalid_intr
  })
 ,.spis1_ss_in_n({
     1'h0
  })
 ,.ccu_dmi1_awready({
     hps2mpfe_dmi1_awready[0:0]
  })
 ,.hps_iob_24_bidir_out({
     mdio0_mdc_obuf_i
  })
 ,.fpga3_dma_req({
     1'h0
  })
 ,.mpfe_csr_awsize({
     hps2mpfe_csr_awsize[2:0]
  })
 ,.mpfe_csr_bresp({
     hps2mpfe_csr_bresp[1:0]
  })
 ,.uart0_ri_n({
     uart0_ri_n[0:0]
  })
 ,.fpga7_dma_req({
     1'h0
  })
 ,.mpfe_csr_bid({
     hps2mpfe_csr_bid[9:0]
  })
 ,.spis0_mosi_i({
     1'h0
  })
 ,.lwsoc2fpga_ar_prot({
     lwhps2fpga_arprot_intr
  })
 ,.lwsoc2fpga_aw_burst({
     lwhps2fpga_awburst_intr
  })
 ,.soc2fpga_r_resp({
     2'h0
  })
 ,.mpfe_csr_aruser({
     hps2mpfe_csr_aruser[7:0]
  })
 ,.spim0_ss_in_n({
     1'h0
  })
 ,.fpga_ctitrigin({
     8'h0
  })
 ,.mpfe_csr_arlock({
     hps2mpfe_csr_arlock[0:0]
  })
 ,.emac0_gmii_mdi_i({
     1'h0
  })
 ,.lwsoc2fpga_ar_size({
     lwhps2fpga_arsize_intr
  })
 ,.mpfe_csr_wdata({
     hps2mpfe_csr_wdata[63:0]
  })
 ,.lwsoc2fpga_r_valid({
     lwhps2fpga_rvalid_intr
  })
 ,.ccu_dmi0_awid({
     hps2mpfe_dmi0_awid[9:0]
  })
 ,.fpga1_dma_single({
     1'h0
  })
 ,.emac0_phy_rxdv_i({
     1'h0
  })
 ,.i3c_m_scl_in_a({
     1'h0
  })
 ,.lwsoc2fpga_w_ready({
     lwhps2fpga_wready_intr
  })
 ,.mpfe_csr_rresp({
     hps2mpfe_csr_rresp[1:0]
  })
 ,.soc2fpga_ar_ready({
     1'h0
  })
 ,.fpga_atb_atid({
     7'h0
  })
 ,.mpfe_csr_rid({
     hps2mpfe_csr_rid[9:0]
  })
 ,.ccu_dmi0_wready({
     hps2mpfe_dmi0_wready[0:0]
  })
 ,.ccu_dmi1_arburst({
     hps2mpfe_dmi1_arburst[1:0]
  })
 ,.mpfe_csr_arlen({
     hps2mpfe_csr_arlen[7:0]
  })
 ,.spim1_miso_i({
     1'h0
  })
 ,.ccu_dmi0_araddr({
     hps2mpfe_dmi0_araddr[43:0]
  })
 ,.uart0_out2_n({
     uart0_out2_n[0:0]
  })
 ,.ccu_dmi0_bid({
     hps2mpfe_dmi0_bid[9:0]
  })
 ,.emac2_phy_rxclk_i({
     1'h0
  })
 ,.emac0_phy_col_i({
     1'h0
  })
 ,.emac1_phy_txclk_i({
     1'h0
  })
 ,.lwsoc2fpga_r_last({
     lwhps2fpga_rlast_intr
  })
 ,.ccu_dmi1_arprot({
     hps2mpfe_dmi1_arprot[2:0]
  })
 ,.cs_ntrst_fpga({
     1'h0
  })
 ,.mpfe_csr_arcache({
     hps2mpfe_csr_arcache[3:0]
  })
 ,.mpfe_csr_bvalid({
     hps2mpfe_csr_bvalid[0:0]
  })
 ,.ccu_dmi1_arsize({
     hps2mpfe_dmi1_arsize[2:0]
  })
 ,.hps_ioa_19_bidir_in({
     emac0_rxd0_ibuf_o
  })
 ,.hps_ioa_20_bidir_in({
     emac0_rxd1_ibuf_o
  })
 ,.ccu_dmi0_awburst({
     hps2mpfe_dmi0_awburst[1:0]
  })
 ,.ccu_dmi1_arid({
     hps2mpfe_dmi1_arid[9:0]
  })
 ,.emac1_gmii_mdi_i({
     1'h0
  })
 ,.hps_iob_2_bidir_out({
     sdmmc_data1_obuf_i
  })
 ,.ccu_dmi0_arvalid({
     hps2mpfe_dmi0_arvalid[0:0]
  })
 ,.hps_iob_16_bidir_in({
     uart1_io_rx_ibuf_o
  })
 ,.fpga2_dma_single({
     1'h0
  })
 ,.emac1_phy_rxdv_i({
     1'h0
  })
 ,.ccu_dmi0_rid({
     hps2mpfe_dmi0_rid[9:0]
  })
 ,.uart1_cts_n({
     1'h0
  })
 ,.lwsoc2fpga_aw_id({
     lwhps2fpga_awid_intr
  })
 ,.cs_tck_fpga({
     1'h0
  })
 ,.hps_iob_2_bidir_in({
     sdmmc_data1_ibuf_o
  })
 ,.hps_iob_18_bidir_out({
     gpio41_obuf_i
  })
 ,.mpfe_csr_awuser({
     hps2mpfe_csr_awuser[7:0]
  })
 ,.cs_hwevents_fpga({
     44'h0
  })
 ,.mpfe_csr_awlock({
     hps2mpfe_csr_awlock[0:0]
  })
 ,.emac1_phy_rxd_i({
     8'h0
  })
 ,.emac1_phy_rxclk_i({
     1'h0
  })
 ,.uart0_cts_n({
     uart0_cts_n[0:0]
  })
 ,.lwsoc2fpga_ar_lock({
     lwhps2fpga_arlock_intr
  })
 ,.ccu_dmi0_bready({
     hps2mpfe_dmi0_bready[0:0]
  })
 ,.emac0_phy_txclk_i({
     1'h0
  })
 ,.soc2fpga_b_valid({
     1'h0
  })
 ,.emac2_phy_col_i({
     1'h0
  })
 ,.fpga0_dma_req({
     1'h0
  })
 ,.emac2_gmii_mdi_i({
     1'h0
  })
 ,.ccu_dmi0_awaddr({
     hps2mpfe_dmi0_awaddr[43:0]
  })
 ,.mpfe_csr_arready({
     hps2mpfe_csr_arready[0:0]
  })
 ,.mpfe_csr_awvalid({
     hps2mpfe_csr_awvalid[0:0]
  })
 ,.lwsoc2fpga_w_strb({
     lwhps2fpga_wstrb_intr
  })
 ,.f2s_gp({
     32'h0
  })
 ,.ccu_dmi1_awprot({
     hps2mpfe_dmi1_awprot[2:0]
  })
 ,.fpga4_dma_req({
     1'h0
  })
 ,.emac0_rst_clk_app_n_o({
     emac0_rst_clk_app_n_o[0:0]
  })
 ,.fpga3_dma_single({
     1'h0
  })
 ,.emac2_ptp_aux_ts_trig_i({
     1'h0
  })
 ,.emac2_phy_rxdv_i({
     1'h0
  })
 ,.hps_ioa_18_bidir_out({
     emac0_txd1_obuf_i
  })
 ,.ccu_dmi1_rready({
     hps2mpfe_dmi1_rready[0:0]
  })
 ,.ccu_dmi1_wvalid({
     hps2mpfe_dmi1_wvalid[0:0]
  })
 ,.cs_dbg_fpga_apb_pready({
     1'h0
  })
 ,.hps_ioa_24_bidir_in({
     emac0_rxd3_ibuf_o
  })
 ,.ccu_dmi1_awsize({
     hps2mpfe_dmi1_awsize[2:0]
  })
 ,.hps_ioa_16_bidir_in({
     emac0_rx_ctl_ibuf_o
  })
 ,.spim1_ss_in_n({
     1'h0
  })
 ,.mpfe_csr_wready({
     hps2mpfe_csr_wready[0:0]
  })
 ,.lwsoc2fpga_r_data({
     lwhps2fpga_rdata_intr
  })
 ,.dbgapbdisable({
     1'h0
  })
 ,.mpfe_csr_araddr({
     hps2mpfe_csr_araddr[43:0]
  })
 ,.soc2fpga_r_valid({
     1'h0
  })
 ,.lwsoc2fpga_b_ready({
     lwhps2fpga_bready_intr
  })
 ,.ccu_dmi1_aruser({
     hps2mpfe_dmi1_aruser[7:0]
  })
 ,.ccu_dmi1_wstrb({
     hps2mpfe_dmi1_wstrb[31:0]
  })
 ,.soc2fpga_w_ready({
     1'h0
  })
 ,.i2c1_scl_i({
     1'h0
  })
 ,.hps_iob_6_bidir_in({
     sdmmc_data2_ibuf_o
  })
 ,.ccu_dmi1_arlock({
     hps2mpfe_dmi1_arlock[0:0]
  })
 ,.lwsoc2fpga_ar_burst({
     lwhps2fpga_arburst_intr
  })
 ,.cs_dbg_fpga_apb_pclk({
     1'h0
  })
 ,.ccu_dmi0_arcache({
     hps2mpfe_dmi0_arcache[3:0]
  })
 ,.ccu_dmi1_rlast({
     hps2mpfe_dmi1_rlast[0:0]
  })
 ,.lwsoc2fpga_aw_prot({
     lwhps2fpga_awprot_intr
  })
 ,.mpfe_csr_awid({
     hps2mpfe_csr_awid[9:0]
  })
 ,.mpfe_csr_awlen({
     hps2mpfe_csr_awlen[7:0]
  })
 ,.lwsoc2fpga_aw_valid({
     lwhps2fpga_awvalid_intr
  })
 ,.emac0_phy_rxclk_i({
     1'h0
  })
 ,.lwsoc2fpga_aw_size({
     lwhps2fpga_awsize_intr
  })
 ,.fpga4_dma_single({
     1'h0
  })
 ,.lwsoc2fpga_r_ready({
     lwhps2fpga_rready_intr
  })
 ,.mpu_ccu_clk({
     hps2mpfe_ccu_clk[0:0]
  })
 ,.ccu_dmi0_wstrb({
     hps2mpfe_dmi0_wstrb[31:0]
  })
 ,.emac_ptp_ref_clk({
     1'h0
  })
 ,.emif_rst_n({
     h2emif_interconnect_axi_rst[0:0]
  })
 ,.i2c0_scl_i({
     1'h0
  })
 ,.fpga_eventireq({
     1'h0
  })
 ,.ccu_dmi0_rlast({
     hps2mpfe_dmi0_rlast[0:0]
  })
 ,.tpiu_trace_ctl({
     1'h1
  })
 ,.s2f_rst({
     h2f_reset[0:0]
  })
 ,.ccu_dmi1_awburst({
     hps2mpfe_dmi1_awburst[1:0]
  })
 ,.dft_in_core_loopback_en_n({
     1'h1
  })
 ,.hps_ioa_21_bidir_out({
     emac0_txd2_obuf_i
  })
 ,.ccu_dmi1_bvalid({
     hps2mpfe_dmi1_bvalid[0:0]
  })
 ,.ccu_dmi1_arvalid({
     hps2mpfe_dmi1_arvalid[0:0]
  })
 ,.lwsoc2fpga_w_last({
     lwhps2fpga_wlast_intr
  })
 ,.hps_iob_6_bidir_out({
     sdmmc_data2_obuf_i
  })
 ,.mpfe_csr_awcache({
     hps2mpfe_csr_awcache[3:0]
  })
 ,.mpfe_csr_bready({
     hps2mpfe_csr_bready[0:0]
  })
 ,.i2c_emac2_scl_i({
     1'h0
  })
 ,.emac1_phy_crs_i({
     1'h0
  })
 ,.hps_ioa_13_bidir_out({
     emac0_tx_clk_obuf_i
  })
 ,.hps_iob_23_bidir_out({
     mdio0_mdio_obuf_i
  })
 ,.mpfe_csr_awaddr({
     hps2mpfe_csr_awaddr[43:0]
  })
 ,.emac1_ptp_aux_ts_trig_i({
     1'h0
  })
 ,.lwsoc2fpga_r_resp({
     lwhps2fpga_rresp_intr
  })
 ,.hps_iob_17_bidir_in({
     gpio40_ibuf_o
  })
 ,.ccu_dmi0_arready({
     hps2mpfe_dmi0_arready[0:0]
  })
 ,.ccu_dmi0_awvalid({
     hps2mpfe_dmi0_awvalid[0:0]
  })
 ,.ccu_dmi1_awuser({
     hps2mpfe_dmi1_awuser[7:0]
  })
 ,.ccu_dmi1_awlock({
     hps2mpfe_dmi1_awlock[0:0]
  })
 ,.lwsoc2fpga_r_id({
     lwhps2fpga_rid_intr
  })
 ,.fpga5_dma_single({
     1'h0
  })
 ,.i3c_s_sda_in_a({
     1'h0
  })
 ,.ccu_dmi1_wlast({
     hps2mpfe_dmi1_wlast[0:0]
  })
 ,.soc2fpga_b_resp({
     2'h0
  })
 ,.hps_iob_15_bidir_out({
     uart1_io_tx_obuf_i
  })
 ,.soc2fpga_r_id({
     4'h0
  })
 ,.ccu_dmi0_arid({
     hps2mpfe_dmi0_arid[9:0]
  })
 ,.lwsoc2fpga_ar_addr({
     lwhps2fpga_araddr_intr
  })
 ,.ccu_dmi0_rvalid({
     hps2mpfe_dmi0_rvalid[0:0]
  })
 ,.i2c_emac1_scl_i({
     1'h0
  })
 ,.fpga1_dma_req({
     1'h0
  })
 ,.spis1_mosi_i({
     1'h0
  })
 ,.ccu_dmi1_rdata({
     hps2mpfe_dmi1_rdata[255:0]
  })
 ,.lwsoc2fpga_clk({
     lwhps2fpga_clk
  })
 ,.lwsoc2fpga_aw_cache({
     lwhps2fpga_awcache_intr
  })
 ,.fpga5_dma_req({
     1'h0
  })
 ,.f2s_pending_rst_ack({
     1'h0
  })
 ,.ccu_dmi0_wlast({
     hps2mpfe_dmi0_wlast[0:0]
  })
 ,.lwsoc2fpga_aw_lock({
     lwhps2fpga_awlock_intr
  })
 ,.uart0_dtr_n({
     uart0_dtr_n[0:0]
  })
 ,.fpga_atb_atclk({
     1'h0
  })
 ,.mpfe_csr_awready({
     hps2mpfe_csr_awready[0:0]
  })
 ,.hps_iob_8_bidir_out({
     sdmmc_cmd_obuf_i
  })
 ,.i2c_emac0_scl_i({
     1'h0
  })
 ,.fpga6_dma_single({
     1'h0
  })
 ,.ccu_dmi0_rdata({
     hps2mpfe_dmi0_rdata[255:0]
  })
 ,.ccu_dmi1_wready({
     hps2mpfe_dmi1_wready[0:0]
  })
 ,.ccu_dmi1_araddr({
     hps2mpfe_dmi1_araddr[43:0]
  })
 ,.fpga_ctitrigoutack({
     8'h0
  })
 ,.ccu_dmi1_arcache({
     hps2mpfe_dmi1_arcache[3:0]
  })
 ,.hps_iob_1_bidir_out({
     sdmmc_data0_obuf_i
  })
 ,.lwsoc2fpga_w_data({
     lwhps2fpga_wdata_intr
  })
 ,.ccu_dmi1_bresp({
     hps2mpfe_dmi1_bresp[1:0]
  })
 ,.hps_iob_7_bidir_in({
     sdmmc_data3_ibuf_o
  })
 ,.hps_iob_17_bidir_out({
     gpio40_obuf_i
  })
 ,.soc2fpga_clk({
     1'h0
  })
 ,.ccu_dmi0_awcache({
     hps2mpfe_dmi0_awcache[3:0]
  })
 ,.spim0_miso_i({
     1'h0
  })
 ,.mpfe_csr_arburst({
     hps2mpfe_csr_arburst[1:0]
  })
 ,.lwsoc2fpga_ar_valid({
     lwhps2fpga_arvalid_intr
  })
 ,.ccu_dmi1_arqos({
     hps2mpfe_dmi1_arqos[3:0]
  })
 ,.uart1_dsr_n({
     1'h0
  })
 ,.ccu_dmi0_arprot({
     hps2mpfe_dmi0_arprot[2:0]
  })
 ,.lwsoc2fpga_aw_ready({
     lwhps2fpga_awready_intr
  })
 ,.emac0_phy_rxd_i({
     8'h0
  })
 ,.uart1_dcd_n({
     1'h0
  })
 ,.ccu_dmi1_wdata({
     hps2mpfe_dmi1_wdata[255:0]
  })
 ,.emac0_phy_rxer_i({
     1'h0
  })
 ,.ccu_dmi0_bresp({
     hps2mpfe_dmi0_bresp[1:0]
  })
 ,.fpga7_dma_single({
     1'h0
  })
 ,.ccu_dmi1_rresp({
     hps2mpfe_dmi1_rresp[1:0]
  })
 ,.ccu_dmi0_arsize({
     hps2mpfe_dmi0_arsize[2:0]
  })
 ,.uart0_rts_n({
     uart0_rts_n[0:0]
  })
 ,.emac1_phy_col_i({
     1'h0
  })
 ,.uart1_ri_n({
     1'h0
  })
 ,.ccu_dmi1_arlen({
     hps2mpfe_dmi1_arlen[7:0]
  })
 ,.i2c1_sda_i({
     1'h0
  })
 ,.mpfe_csr_rvalid({
     hps2mpfe_csr_rvalid[0:0]
  })
 ,.fpga_atb_atvalid({
     1'h0
  })
 ,.ccu_dmi0_arqos({
     hps2mpfe_dmi0_arqos[3:0]
  })
 ,.uart0_dsr_n({
     uart0_dsr_n[0:0]
  })
 ,.soc2fpga_r_last({
     1'h0
  })
 ,.hps_ioa_17_bidir_out({
     emac0_txd0_obuf_i
  })
 ,.ccu_dmi1_bready({
     hps2mpfe_dmi1_bready[0:0]
  })
 ,.uart0_dcd_n({
     uart0_dcd_n[0:0]
  })
 ,.ccu_dmi1_awvalid({
     hps2mpfe_dmi1_awvalid[0:0]
  })
 ,.ccu_dmi1_arready({
     hps2mpfe_dmi1_arready[0:0]
  })
 ,.ccu_dmi0_wdata({
     hps2mpfe_dmi0_wdata[255:0]
  })
 ,.hps_iob_3_bidir_out({
     sdmmc_cclk_obuf_i
  })
 ,.ccu_dmi1_awaddr({
     hps2mpfe_dmi1_awaddr[43:0]
  })
 ,.ccu_dmi0_rresp({
     hps2mpfe_dmi0_rresp[1:0]
  })
 ,.mpfe_csr_wstrb({
     hps2mpfe_csr_wstrb[7:0]
  })
 ,.ccu_dmi1_awid({
     hps2mpfe_dmi1_awid[9:0]
  })
 ,.fpga_atb_atresetn({
     1'h0
  })
 ,.ccu_dmi1_bid({
     hps2mpfe_dmi1_bid[9:0]
  })
 ,.hps_iob_18_bidir_in({
     gpio41_ibuf_o
  })
 ,.mpfe_csr_rlast({
     hps2mpfe_csr_rlast[0:0]
  })
 ,.ccu_dmi0_arlen({
     hps2mpfe_dmi0_arlen[7:0]
  })
 ,.i2c0_sda_i({
     1'h0
  })
 ,.mpfe_csr_arid({
     hps2mpfe_csr_arid[9:0]
  })
 ,.hps_iob_4_bidir_in({
     hps_osc_clk_ibuf_o
  })
 ,.emac1_phy_rxer_i({
     1'h0
  })
 ,.fpga_atb_afready({
     1'h0
  })
 ,.spis0_ss_in_n({
     1'h0
  })
 ,.ccu_dmi0_awready({
     hps2mpfe_dmi0_awready[0:0]
  })
 ,.fpga2_dma_req({
     1'h0
  })
 ,.i3c_m_sda_in_a({
     1'h0
  })
 ,.fpga6_dma_req({
     1'h0
  })
 ,.lwsoc2fpga_w_valid({
     lwhps2fpga_wvalid_intr
  })
 ,.emac2_phy_rxd_i({
     8'h0
  })
 ,.uart1_rx({
     1'h0
  })
 ,.ccu_dmi0_awprot({
     hps2mpfe_dmi0_awprot[2:0]
  })
 ,.lwsoc2fpga_ar_len({
     lwhps2fpga_arlen_intr
  })
 ,.i3c_s_scl_in_a({
     1'h0
  })
 ,.soc2fpga_aw_ready({
     1'h0
  })
 ,.lwsoc2fpga_aw_addr({
     lwhps2fpga_awaddr_intr
  })
 ,.uart0_out1_n({
     uart0_out1_n[0:0]
  })
 ,.ccu_dmi0_wvalid({
     hps2mpfe_dmi0_wvalid[0:0]
  })
 ,.ccu_dmi0_rready({
     hps2mpfe_dmi0_rready[0:0]
  })
 ,.ccu_dmi1_rid({
     hps2mpfe_dmi1_rid[9:0]
  })
 ,.cs_tdi_fpga({
     1'h0
  })
 ,.i2c_emac2_sda_i({
     1'h0
  })
 ,.lwsoc2fpga_ar_cache({
     lwhps2fpga_arcache_intr
  })
 ,.ccu_dmi0_awsize({
     hps2mpfe_dmi0_awsize[2:0]
  })
 ,.cs_dbg_fpga_apb_pslverr({
     1'h0
  })
 ,.ccu_dmi0_aruser({
     hps2mpfe_dmi0_aruser[7:0]
  })
 ,.mpfe_csr_arprot({
     hps2mpfe_csr_arprot[2:0]
  })
 ,.ccu_dmi0_arburst({
     hps2mpfe_dmi0_arburst[1:0]
  })
 ,.ccu_dmi0_arlock({
     hps2mpfe_dmi0_arlock[0:0]
  })
 ,.emac2_phy_rxer_i({
     1'h0
  })
 ,.i2c_emac1_sda_i({
     1'h0
  })
 ,.mpfe_csr_arsize({
     hps2mpfe_csr_arsize[2:0]
  })
 ,.emac0_phy_crs_i({
     1'h0
  })
 ,.f2s_free_clk({
     1'h0
  })
 ,.cs_tms_fpga({
     1'h0
  })
 ,.ccu_dmi1_awqos({
     hps2mpfe_dmi1_awqos[3:0]
  })
 ,.hps_iob_23_bidir_in({
     mdio0_mdio_ibuf_o
  })
 ,.tpiu_trace_clkin(w_tpiu_clkin)
);

endmodule


