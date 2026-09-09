module agilex_hps (
		output wire         h2f_reset_reset,                //               h2f_reset.reset,            Active high reset from the HPS Reset Manager.
		input  wire         lwhps2fpga_axi_clock_clk,       //    lwhps2fpga_axi_clock.clk,              clock from a single source in the FPGA.
		input  wire         lwhps2fpga_axi_reset_reset,     //    lwhps2fpga_axi_reset.reset,            Async reset to the Bridge logic. This signal is active-HIGH.
		output wire [3:0]   lwhps2fpga_awid,                //              lwhps2fpga.awid,             Identification tag for a write transaction.
		output wire [28:0]  lwhps2fpga_awaddr,              //                        .awaddr,           The address of the first transfer in a write transaction.
		output wire [7:0]   lwhps2fpga_awlen,               //                        .awlen,            The exact number of data transfers in a write transaction.
		output wire [2:0]   lwhps2fpga_awsize,              //                        .awsize,           The number of bytes in each data transfer in a write transaction.
		output wire [1:0]   lwhps2fpga_awburst,             //                        .awburst,          Indicates how address changes between each transfer in a write transaction.
		output wire         lwhps2fpga_awlock,              //                        .awlock,           Provides information about the atomic characteristics of a write transaction.
		output wire [3:0]   lwhps2fpga_awcache,             //                        .awcache,          Indicates how a write transaction is required to progress through a system.
		output wire [2:0]   lwhps2fpga_awprot,              //                        .awprot,           Protection attributes of a write transaction: privilege, security level, and access type.
		output wire         lwhps2fpga_awvalid,             //                        .awvalid,          Indicates that the write address channel signals are valid.
		input  wire         lwhps2fpga_awready,             //                        .awready,          Indicates that a transfer on the write address channel can be accepted.
		output wire [31:0]  lwhps2fpga_wdata,               //                        .wdata,            Write data.
		output wire [3:0]   lwhps2fpga_wstrb,               //                        .wstrb,            Write strobes, indicate which byte lanes hold valid data.
		output wire         lwhps2fpga_wlast,               //                        .wlast,            User-defined extension for the write data channel.
		output wire         lwhps2fpga_wvalid,              //                        .wvalid,           Indicates that the write data channel signals are valid.
		input  wire         lwhps2fpga_wready,              //                        .wready,           Indicates that a transfer on the write data channel can be accepted.
		input  wire [3:0]   lwhps2fpga_bid,                 //                        .bid,              Transaction identifier for the write response.
		input  wire [1:0]   lwhps2fpga_bresp,               //                        .bresp,            Write response, indicates the status of a write transaction.
		input  wire         lwhps2fpga_bvalid,              //                        .bvalid,           Indicates that the write response channel signals are valid.
		output wire         lwhps2fpga_bready,              //                        .bready,           Indicates that a transfer on the write response channel can be accepted.
		output wire [3:0]   lwhps2fpga_arid,                //                        .arid,             Transaction identifier for the read transaction.
		output wire [28:0]  lwhps2fpga_araddr,              //                        .araddr,           The address of the first transfer in a read transaction.
		output wire [7:0]   lwhps2fpga_arlen,               //                        .arlen,            The exact number of data transfers in a read transaction.
		output wire [2:0]   lwhps2fpga_arsize,              //                        .arsize,           The number of bytes in each data transfer in a read transaction.
		output wire [1:0]   lwhps2fpga_arburst,             //                        .arburst,          Indicates how address changes between each transfer in a read transaction.
		output wire         lwhps2fpga_arlock,              //                        .arlock,           Provides information about the atomic characteristics of a read transaction.
		output wire [3:0]   lwhps2fpga_arcache,             //                        .arcache,          Indicates how a read transaction is required to progress through a system.
		output wire [2:0]   lwhps2fpga_arprot,              //                        .arprot,           Protection attributes of a read transaction: privilege, security level, and access type.
		output wire         lwhps2fpga_arvalid,             //                        .arvalid,          Indicates that the read address channel signals are valid.
		input  wire         lwhps2fpga_arready,             //                        .arready,          Indicates that a transfer on the read address channel can be accepted.
		input  wire [3:0]   lwhps2fpga_rid,                 //                        .rid,              Identification tag for read data and response.
		input  wire [31:0]  lwhps2fpga_rdata,               //                        .rdata,            Read data.
		input  wire [1:0]   lwhps2fpga_rresp,               //                        .rresp,            Read response, indicates the status of a read transfer.
		input  wire         lwhps2fpga_rlast,               //                        .rlast,            Indicates whether this is the last data transfer in a read transaction.
		input  wire         lwhps2fpga_rvalid,              //                        .rvalid,           Indicates that the read data channel signals are valid.
		output wire         lwhps2fpga_rready,              //                        .rready,           Indicates that a transfer on the read data channel can be accepted.
		output wire         emac0_app_rst_reset_n,          //           emac0_app_rst.reset_n,          EMAC0 application clock reset output.
		input  wire         uart0_cts_n,                    //                   uart0.cts_n,            Clear to send. Necessary for auto flow control feature.
		input  wire         uart0_dcd_n,                    //                        .dcd_n,            Data carrier detect.
		input  wire         uart0_dsr_n,                    //                        .dsr_n,            Data set ready.
		output wire         uart0_dtr_n,                    //                        .dtr_n,            Data terminal ready.
		output wire         uart0_out1_n,                   //                        .out1_n,           User defined output 1.
		output wire         uart0_out2_n,                   //                        .out2_n,           User defined output 2.
		input  wire         uart0_ri_n,                     //                        .ri_n,             Ring indicator.
		output wire         uart0_rts_n,                    //                        .rts_n,            Request to send. Necessary for auto flow control feature.
		input  wire         uart0_rx,                       //                        .rx,               Receive data.
		output wire         uart0_tx,                       //                        .tx,               Transmit data.
		output wire         h2f_user0_clk_clk,              //           h2f_user0_clk.clk,              User clock generated by HPS Clock Manager.
		input  wire         hps_io_hps_osc_clk,             //                  hps_io.hps_osc_clk,      HPS input clock pin for EOSC reference clock.
		inout  wire         hps_io_sdmmc_data0,             //                        .sdmmc_data0,      SDMMC data[0].
		inout  wire         hps_io_sdmmc_data1,             //                        .sdmmc_data1,      SDMMC data[1].
		output wire         hps_io_sdmmc_cclk,              //                        .sdmmc_cclk,       SDMMC output clock.
		inout  wire         hps_io_sdmmc_data2,             //                        .sdmmc_data2,      SDMMC data[2].
		inout  wire         hps_io_sdmmc_data3,             //                        .sdmmc_data3,      SDMMC data[3].
		inout  wire         hps_io_sdmmc_cmd,               //                        .sdmmc_cmd,        SDMMC command.
		output wire         hps_io_emac0_tx_clk,            //                        .emac0_tx_clk,     EMAC0 transmit clock.
		output wire         hps_io_emac0_tx_ctl,            //                        .emac0_tx_ctl,     EMAC0 transmit data enable.
		input  wire         hps_io_emac0_rx_clk,            //                        .emac0_rx_clk,     EMAC0 receive clock.
		input  wire         hps_io_emac0_rx_ctl,            //                        .emac0_rx_ctl,     EMAC0 receive data enable.
		output wire         hps_io_emac0_txd0,              //                        .emac0_txd0,       EMAC0 transmit data[0].
		output wire         hps_io_emac0_txd1,              //                        .emac0_txd1,       EMAC0 transmit data[1].
		input  wire         hps_io_emac0_rxd0,              //                        .emac0_rxd0,       EMAC0 receive data[0].
		input  wire         hps_io_emac0_rxd1,              //                        .emac0_rxd1,       EMAC0 receive data[1].
		output wire         hps_io_emac0_txd2,              //                        .emac0_txd2,       EMAC0 transmit data[2].
		output wire         hps_io_emac0_txd3,              //                        .emac0_txd3,       EMAC0 transmit data[3].
		input  wire         hps_io_emac0_rxd2,              //                        .emac0_rxd2,       EMAC0 receive data[2].
		input  wire         hps_io_emac0_rxd3,              //                        .emac0_rxd3,       EMAC0 receive data[3].
		inout  wire         hps_io_mdio0_mdio,              //                        .mdio0_mdio,       EMAC0 MDIO data.
		output wire         hps_io_mdio0_mdc,               //                        .mdio0_mdc,        EMAC0 MDIO clock.
		output wire         hps_io_uart1_tx,                //                        .uart1_tx,         UART1 transmit data.
		input  wire         hps_io_uart1_rx,                //                        .uart1_rx,         UART1 receive data.
		inout  wire         hps_io_gpio40,                  //                        .gpio40,           GPIO1 IO16
		inout  wire         hps_io_gpio41,                  //                        .gpio41,           GPIO1 IO17
		input  wire [31:0]  fpga2hps_interrupt_irq1_irq,    // fpga2hps_interrupt_irq1.irq,              FPGA-to-HPS interrupts (higher 32 bits).
		input  wire [31:0]  fpga2hps_interrupt_irq0_irq,    // fpga2hps_interrupt_irq0.irq,              FPGA-to-HPS interrupts (lower 32 bits).
		input  wire         io96b0_to_hps_ch0_axil_clk,     //           io96b0_to_hps.ch0_axil_clk,     Clock source signal. Synchronous signals are sampled on the rising edge of this clock.
		input  wire         io96b0_to_hps_ch0_axil_reset_n, //                        .ch0_axil_reset_n, Required placeholder reset. The actual bridge reset is driven by HPS Reset Manager.
		input  wire         io96b0_to_hps_ch0_axil_arready, //                        .ch0_axil_arready, Indicates a transfer on the read address channel can be accepted.
		input  wire         io96b0_to_hps_ch0_axil_awready, //                        .ch0_axil_awready, Indicates a transfer on the write address channel can be accepted.
		input  wire [1:0]   io96b0_to_hps_ch0_axil_bresp,   //                        .ch0_axil_bresp,   Indicates status of write transaction.
		input  wire         io96b0_to_hps_ch0_axil_bvalid,  //                        .ch0_axil_bvalid,  Indicates write response channel signals are valid.
		input  wire [31:0]  io96b0_to_hps_ch0_axil_rdata,   //                        .ch0_axil_rdata,   Read data.
		input  wire [1:0]   io96b0_to_hps_ch0_axil_rresp,   //                        .ch0_axil_rresp,   Indicates status of read transaction.
		input  wire         io96b0_to_hps_ch0_axil_rvalid,  //                        .ch0_axil_rvalid,  Indicates read data channel signals are valid.
		input  wire         io96b0_to_hps_ch0_axil_wready,  //                        .ch0_axil_wready,  Indicates a transfer on the write data channel can be accepted.
		output wire [26:0]  io96b0_to_hps_ch0_axil_araddr,  //                        .ch0_axil_araddr,  The address of the first transfer in a read transaction.
		output wire         io96b0_to_hps_ch0_axil_arvalid, //                        .ch0_axil_arvalid, Indicates read address channel signals are valid.
		output wire [26:0]  io96b0_to_hps_ch0_axil_awaddr,  //                        .ch0_axil_awaddr,  The address of the first transfer in a write transaction.
		output wire         io96b0_to_hps_ch0_axil_awvalid, //                        .ch0_axil_awvalid, Indicates write address channel signals are valid.
		output wire         io96b0_to_hps_ch0_axil_bready,  //                        .ch0_axil_bready,  Indicates a transfer on the write response channel can be accepted.
		output wire         io96b0_to_hps_ch0_axil_rready,  //                        .ch0_axil_rready,  Indicates a transfer on the read data channel can be accepted.
		output wire [31:0]  io96b0_to_hps_ch0_axil_wdata,   //                        .ch0_axil_wdata,   Write data.
		output wire [3:0]   io96b0_to_hps_ch0_axil_wstrb,   //                        .ch0_axil_wstrb,   Write strobes indicating which bye lanes hold valid data.
		output wire         io96b0_to_hps_ch0_axil_wvalid,  //                        .ch0_axil_wvalid,  Indicates write data channel signals are valid.
		output wire [2:0]   io96b0_to_hps_ch0_axil_arprot,  //                        .ch0_axil_arprot,  Placeholder ARPROT. Protection attributes not supported for this bridge.
		output wire [2:0]   io96b0_to_hps_ch0_axil_awprot,  //                        .ch0_axil_awprot,  Placegolder AWPROT. Protection attributes not supported for this bridge.
		input  wire         io96b0_to_hps_axi4_ch0_clk,     //                        .axi4_ch0_clk,     Clock source signal. Synchronous signals are sampled on the rising edge of this clock.
		input  wire         io96b0_to_hps_axi4_ch0_reset_n, //                        .axi4_ch0_reset_n, Required placeholder reset. The actual bridge reset is driven by HPS Reset Manager.
		input  wire         io96b0_to_hps_axi4_ch0_arready, //                        .axi4_ch0_arready, Indicates a transfer on the read address channel can be accepted.
		input  wire         io96b0_to_hps_axi4_ch0_awready, //                        .axi4_ch0_awready, Indicates a transfer on the write address channel can be accepted.
		input  wire [6:0]   io96b0_to_hps_axi4_ch0_bid,     //                        .axi4_ch0_bid,     Identification tag for a write response.
		input  wire [1:0]   io96b0_to_hps_axi4_ch0_bresp,   //                        .axi4_ch0_bresp,   Indicates the status of a write transaction.
		input  wire         io96b0_to_hps_axi4_ch0_bvalid,  //                        .axi4_ch0_bvalid,  Indicates write response channel signals are valid.
		input  wire [255:0] io96b0_to_hps_axi4_ch0_rdata,   //                        .axi4_ch0_rdata,   Read data.
		input  wire [6:0]   io96b0_to_hps_axi4_ch0_rid,     //                        .axi4_ch0_rid,     Identification tag for read data and response.
		input  wire         io96b0_to_hps_axi4_ch0_rlast,   //                        .axi4_ch0_rlast,   Indicates the last data transfer in a read transaction.
		input  wire [1:0]   io96b0_to_hps_axi4_ch0_rresp,   //                        .axi4_ch0_rresp,   Indicates the status of a read transfer.
		input  wire [31:0]  io96b0_to_hps_axi4_ch0_ruser,   //                        .axi4_ch0_ruser,   Extension of read data channel.
		input  wire         io96b0_to_hps_axi4_ch0_rvalid,  //                        .axi4_ch0_rvalid,  Indicates read data channel signals are valid.
		input  wire         io96b0_to_hps_axi4_ch0_wready,  //                        .axi4_ch0_wready,  Indicates a transfer on the write data channel can be accepted.
		output wire [39:0]  io96b0_to_hps_axi4_ch0_araddr,  //                        .axi4_ch0_araddr,  The address of the first transfer in a read transaction.
		output wire [1:0]   io96b0_to_hps_axi4_ch0_arburst, //                        .axi4_ch0_arburst, Burst type indicating how address changes between each transfer in a read transaction.
		output wire [6:0]   io96b0_to_hps_axi4_ch0_arid,    //                        .axi4_ch0_arid,    Identification tag for a read transaction.
		output wire [7:0]   io96b0_to_hps_axi4_ch0_arlen,   //                        .axi4_ch0_arlen,   Exact number of data transfers in a read transaction.
		output wire         io96b0_to_hps_axi4_ch0_arlock,  //                        .axi4_ch0_arlock,  Provides info on atomic characteristics of a read transaction.
		output wire [3:0]   io96b0_to_hps_axi4_ch0_arqos,   //                        .axi4_ch0_arqos,   Quality of service identifier for a read transaction.
		output wire [2:0]   io96b0_to_hps_axi4_ch0_arsize,  //                        .axi4_ch0_arsize,  The number of bytes in each data transfer in a read transaction.
		output wire [13:0]  io96b0_to_hps_axi4_ch0_aruser,  //                        .axi4_ch0_aruser,  Extension of read address channel.
		output wire         io96b0_to_hps_axi4_ch0_arvalid, //                        .axi4_ch0_arvalid, Indicates read address channel signals are valid.
		output wire [39:0]  io96b0_to_hps_axi4_ch0_awaddr,  //                        .axi4_ch0_awaddr,  The address of the first transfer in a write transaction.
		output wire [1:0]   io96b0_to_hps_axi4_ch0_awburst, //                        .axi4_ch0_awburst, Burst type indicating how address changes between each transfer in a write transaction.
		output wire [6:0]   io96b0_to_hps_axi4_ch0_awid,    //                        .axi4_ch0_awid,    Identification tag for a write transaction.
		output wire [7:0]   io96b0_to_hps_axi4_ch0_awlen,   //                        .axi4_ch0_awlen,   Exact number of data transfers in a write transaction.
		output wire         io96b0_to_hps_axi4_ch0_awlock,  //                        .axi4_ch0_awlock,  Provides info on atomic characteristics of a write transaction.
		output wire [3:0]   io96b0_to_hps_axi4_ch0_awqos,   //                        .axi4_ch0_awqos,   Quality of service identifier for a write transaction.
		output wire [2:0]   io96b0_to_hps_axi4_ch0_awsize,  //                        .axi4_ch0_awsize,  Number of bytes in each data transfer in a write transaction.
		output wire [13:0]  io96b0_to_hps_axi4_ch0_awuser,  //                        .axi4_ch0_awuser,  Extension of write address channel.
		output wire         io96b0_to_hps_axi4_ch0_awvalid, //                        .axi4_ch0_awvalid, Indicates write address channel signals are valid.
		output wire         io96b0_to_hps_axi4_ch0_bready,  //                        .axi4_ch0_bready,  Indicates a transfer on write response channel can be accepted.
		output wire         io96b0_to_hps_axi4_ch0_rready,  //                        .axi4_ch0_rready,  Indicates a transfer on read data channel can be accepted.
		output wire [255:0] io96b0_to_hps_axi4_ch0_wdata,   //                        .axi4_ch0_wdata,   Write data.
		output wire         io96b0_to_hps_axi4_ch0_wlast,   //                        .axi4_ch0_wlast,   Indicates the last data transfer in a write transaction.
		output wire [31:0]  io96b0_to_hps_axi4_ch0_wstrb,   //                        .axi4_ch0_wstrb,   Write strobes indicating which byte lanes hold valid data.
		output wire [31:0]  io96b0_to_hps_axi4_ch0_wuser,   //                        .axi4_ch0_wuser,   Extension of the write data channel.
		output wire         io96b0_to_hps_axi4_ch0_wvalid,  //                        .axi4_ch0_wvalid,  Indicates write data channel signals are valid.
		output wire [2:0]   io96b0_to_hps_axi4_ch0_arprot,  //                        .axi4_ch0_arprot,  Placeholder ARPROT. Protection attributes not supported for this bridge.
		output wire [2:0]   io96b0_to_hps_axi4_ch0_awprot   //                        .axi4_ch0_awprot,  Placeholder AWPROT. Protection attributes not supported for this bridge.
	);
endmodule

