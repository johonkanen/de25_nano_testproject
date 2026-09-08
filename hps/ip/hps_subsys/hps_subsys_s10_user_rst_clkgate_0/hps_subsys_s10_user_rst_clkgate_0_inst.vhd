	component hps_subsys_s10_user_rst_clkgate_0 is
		port (
			ninit_done : out std_logic   -- reset
		);
	end component hps_subsys_s10_user_rst_clkgate_0;

	u0 : component hps_subsys_s10_user_rst_clkgate_0
		port map (
			ninit_done => CONNECTED_TO_ninit_done  -- ninit_done.reset
		);

