	component emif_io96b_hps_emif_io96b_hps_420_dyxenzq_refclk_gpio is
		port (
			dout   : out std_logic_vector(0 downto 0);                    -- export
			pad_in : in  std_logic_vector(0 downto 0) := (others => 'X')  -- export
		);
	end component emif_io96b_hps_emif_io96b_hps_420_dyxenzq_refclk_gpio;

	u0 : component emif_io96b_hps_emif_io96b_hps_420_dyxenzq_refclk_gpio
		port map (
			dout   => CONNECTED_TO_dout,   --   dout.export
			pad_in => CONNECTED_TO_pad_in  -- pad_in.export
		);

