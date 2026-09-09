	component emif_io96b_hps_emif_io96b_hps_500_j4t3edi_refclk_bridge is
		port (
			refclk_in       : in  std_logic := 'X'; -- clk
			refclk_out      : out std_logic;        -- clk
			refclk_in_gpio  : out std_logic;        -- export
			refclk_out_gpio : in  std_logic := 'X'  -- export
		);
	end component emif_io96b_hps_emif_io96b_hps_500_j4t3edi_refclk_bridge;

	u0 : component emif_io96b_hps_emif_io96b_hps_500_j4t3edi_refclk_bridge
		port map (
			refclk_in       => CONNECTED_TO_refclk_in,       --       refclk_in.clk
			refclk_out      => CONNECTED_TO_refclk_out,      --      refclk_out.clk
			refclk_in_gpio  => CONNECTED_TO_refclk_in_gpio,  --  refclk_in_gpio.export
			refclk_out_gpio => CONNECTED_TO_refclk_out_gpio  -- refclk_out_gpio.export
		);

