	emif_io96b_hps_emif_io96b_hps_500_j4t3edi_refclk_bridge u0 (
		.refclk_in       (_connected_to_refclk_in_),       //   input,  width = 1,       refclk_in.clk
		.refclk_out      (_connected_to_refclk_out_),      //  output,  width = 1,      refclk_out.clk
		.refclk_in_gpio  (_connected_to_refclk_in_gpio_),  //  output,  width = 1,  refclk_in_gpio.export
		.refclk_out_gpio (_connected_to_refclk_out_gpio_)  //   input,  width = 1, refclk_out_gpio.export
	);

