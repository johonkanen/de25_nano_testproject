module hps_subsys (
		output wire        h2f_reset_reset,                       //                 h2f_reset.reset
		input  wire        lwhps2fpga_axi_clock_clk,              //      lwhps2fpga_axi_clock.clk
		input  wire        lwhps2fpga_axi_reset_reset,            //      lwhps2fpga_axi_reset.reset
		output wire [3:0]  lwhps2fpga_awid,                       //                lwhps2fpga.awid
		output wire [28:0] lwhps2fpga_awaddr,                     //                          .awaddr
		output wire [7:0]  lwhps2fpga_awlen,                      //                          .awlen
		output wire [2:0]  lwhps2fpga_awsize,                     //                          .awsize
		output wire [1:0]  lwhps2fpga_awburst,                    //                          .awburst
		output wire        lwhps2fpga_awlock,                     //                          .awlock
		output wire [3:0]  lwhps2fpga_awcache,                    //                          .awcache
		output wire [2:0]  lwhps2fpga_awprot,                     //                          .awprot
		output wire        lwhps2fpga_awvalid,                    //                          .awvalid
		input  wire        lwhps2fpga_awready,                    //                          .awready
		output wire [31:0] lwhps2fpga_wdata,                      //                          .wdata
		output wire [3:0]  lwhps2fpga_wstrb,                      //                          .wstrb
		output wire        lwhps2fpga_wlast,                      //                          .wlast
		output wire        lwhps2fpga_wvalid,                     //                          .wvalid
		input  wire        lwhps2fpga_wready,                     //                          .wready
		input  wire [3:0]  lwhps2fpga_bid,                        //                          .bid
		input  wire [1:0]  lwhps2fpga_bresp,                      //                          .bresp
		input  wire        lwhps2fpga_bvalid,                     //                          .bvalid
		output wire        lwhps2fpga_bready,                     //                          .bready
		output wire [3:0]  lwhps2fpga_arid,                       //                          .arid
		output wire [28:0] lwhps2fpga_araddr,                     //                          .araddr
		output wire [7:0]  lwhps2fpga_arlen,                      //                          .arlen
		output wire [2:0]  lwhps2fpga_arsize,                     //                          .arsize
		output wire [1:0]  lwhps2fpga_arburst,                    //                          .arburst
		output wire        lwhps2fpga_arlock,                     //                          .arlock
		output wire [3:0]  lwhps2fpga_arcache,                    //                          .arcache
		output wire [2:0]  lwhps2fpga_arprot,                     //                          .arprot
		output wire        lwhps2fpga_arvalid,                    //                          .arvalid
		input  wire        lwhps2fpga_arready,                    //                          .arready
		input  wire [3:0]  lwhps2fpga_rid,                        //                          .rid
		input  wire [31:0] lwhps2fpga_rdata,                      //                          .rdata
		input  wire [1:0]  lwhps2fpga_rresp,                      //                          .rresp
		input  wire        lwhps2fpga_rlast,                      //                          .rlast
		input  wire        lwhps2fpga_rvalid,                     //                          .rvalid
		output wire        lwhps2fpga_rready,                     //                          .rready
		input  wire        hps_uart0_cts_n,                       //                 hps_uart0.cts_n
		input  wire        hps_uart0_dcd_n,                       //                          .dcd_n
		input  wire        hps_uart0_dsr_n,                       //                          .dsr_n
		output wire        hps_uart0_dtr_n,                       //                          .dtr_n
		output wire        hps_uart0_out1_n,                      //                          .out1_n
		output wire        hps_uart0_out2_n,                      //                          .out2_n
		input  wire        hps_uart0_ri_n,                        //                          .ri_n
		output wire        hps_uart0_rts_n,                       //                          .rts_n
		input  wire        hps_uart0_rx,                          //                          .rx
		output wire        hps_uart0_tx,                          //                          .tx
		input  wire        hps_io_hps_osc_clk,                    //                    hps_io.hps_osc_clk
		inout  wire        hps_io_sdmmc_data0,                    //                          .sdmmc_data0
		inout  wire        hps_io_sdmmc_data1,                    //                          .sdmmc_data1
		output wire        hps_io_sdmmc_cclk,                     //                          .sdmmc_cclk
		inout  wire        hps_io_sdmmc_data2,                    //                          .sdmmc_data2
		inout  wire        hps_io_sdmmc_data3,                    //                          .sdmmc_data3
		inout  wire        hps_io_sdmmc_cmd,                      //                          .sdmmc_cmd
		output wire        hps_io_emac0_tx_clk,                   //                          .emac0_tx_clk
		output wire        hps_io_emac0_tx_ctl,                   //                          .emac0_tx_ctl
		input  wire        hps_io_emac0_rx_clk,                   //                          .emac0_rx_clk
		input  wire        hps_io_emac0_rx_ctl,                   //                          .emac0_rx_ctl
		output wire        hps_io_emac0_txd0,                     //                          .emac0_txd0
		output wire        hps_io_emac0_txd1,                     //                          .emac0_txd1
		input  wire        hps_io_emac0_rxd0,                     //                          .emac0_rxd0
		input  wire        hps_io_emac0_rxd1,                     //                          .emac0_rxd1
		output wire        hps_io_emac0_txd2,                     //                          .emac0_txd2
		output wire        hps_io_emac0_txd3,                     //                          .emac0_txd3
		input  wire        hps_io_emac0_rxd2,                     //                          .emac0_rxd2
		input  wire        hps_io_emac0_rxd3,                     //                          .emac0_rxd3
		inout  wire        hps_io_mdio0_mdio,                     //                          .mdio0_mdio
		output wire        hps_io_mdio0_mdc,                      //                          .mdio0_mdc
		output wire        hps_io_uart1_tx,                       //                          .uart1_tx
		input  wire        hps_io_uart1_rx,                       //                          .uart1_rx
		inout  wire        hps_io_gpio40,                         //                          .gpio40
		inout  wire        hps_io_gpio41,                         //                          .gpio41
		input  wire [31:0] f2h_irq1_in_irq,                       //               f2h_irq1_in.irq
		input  wire [31:0] f2h_irq0_in_irq,                       //               f2h_irq0_in.irq
		output wire [0:0]  emif_hps_emif_mem_0_mem_cs,            //       emif_hps_emif_mem_0.mem_cs
		output wire [5:0]  emif_hps_emif_mem_0_mem_ca,            //                          .mem_ca
		output wire [0:0]  emif_hps_emif_mem_0_mem_cke,           //                          .mem_cke
		inout  wire [31:0] emif_hps_emif_mem_0_mem_dq,            //                          .mem_dq
		inout  wire [3:0]  emif_hps_emif_mem_0_mem_dqs_t,         //                          .mem_dqs_t
		inout  wire [3:0]  emif_hps_emif_mem_0_mem_dqs_c,         //                          .mem_dqs_c
		inout  wire [3:0]  emif_hps_emif_mem_0_mem_dmi,           //                          .mem_dmi
		output wire [0:0]  emif_hps_emif_mem_ck_0_mem_ck_t,       //    emif_hps_emif_mem_ck_0.mem_ck_t
		output wire [0:0]  emif_hps_emif_mem_ck_0_mem_ck_c,       //                          .mem_ck_c
		output wire        emif_hps_emif_mem_reset_n_mem_reset_n, // emif_hps_emif_mem_reset_n.mem_reset_n
		input  wire        emif_hps_emif_oct_0_oct_rzqin,         //       emif_hps_emif_oct_0.oct_rzqin
		input  wire        emif_hps_emif_ref_clk_clk,             //     emif_hps_emif_ref_clk.clk
		output wire        ninit_done_reset                       //                ninit_done.reset
	);
endmodule

