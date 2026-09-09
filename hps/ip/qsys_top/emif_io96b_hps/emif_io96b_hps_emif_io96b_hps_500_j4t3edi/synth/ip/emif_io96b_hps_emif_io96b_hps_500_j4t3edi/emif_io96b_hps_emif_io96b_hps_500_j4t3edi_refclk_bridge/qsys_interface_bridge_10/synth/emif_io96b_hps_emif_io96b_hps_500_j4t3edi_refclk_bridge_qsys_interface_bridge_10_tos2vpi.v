`timescale 1 ps / 1 ps 
module emif_io96b_hps_emif_io96b_hps_500_j4t3edi_refclk_bridge_qsys_interface_bridge_10_tos2vpi (
    input wire  refclk_in, 
    output wire  refclk_out, 
    output wire  refclk_in_gpio, 
    input wire  refclk_out_gpio
);
    assign refclk_in_gpio = refclk_in; 
    assign refclk_out = refclk_out_gpio; 
endmodule