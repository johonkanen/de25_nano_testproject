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




`timescale 1ps/1ps


module rd_pri_mux_kt2puei (
input in0,
input [1-1:0] clr, 
input [1-1:0] shift_index_out, 
output logic sel,
output logic [1-1:0] sel_index
);

always @ * begin
    if (in0 && !clr[0]) begin
        sel = in0;
        sel_index=0;
    end
end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1obv3w6pvqnRfMIiqoffMaFyeWWoRohwprKDqycmbxxPa9P6wlE1/LCP+juSCN2LeMw3+wTR1cPtrVuu6Wb0vtcore4AdaO17PCLIAv0QenzIc1Z5VTeNnXTXhQf9wLgpS9V3/ZEKAWmD23c+vVJeUwdLfAqLVILvJJWGk2k8nJQOgbMh9tt5Niv2UP0zsFD93ZbR9KT/EMDKVRHE+cDPIluNGGCh6leDXqxN5xgftlGJLgwiZ6qiQWOHFgPAYoxaHZzsU61C6E2mpM3bjrkwTPtG8rdfdPmip3/+10RhPM0HrEhfC3zysczG1z8O8OQVeJWfDJJfmBAW62d0GryiBrXTqVYy9cwsBBLS7mwzBSVkOLNCJxi6y8EWqmSG9o1707NMFiDClrGuPE8HQzf4xZjDNs+tl+S2GupJJR4aM4NB3+5ebm+5Vkyn0bfgmZkiM0RW1SGtm7UQoHrVbyWKhLMcybWF/98c7ucqENCrpxCmZf4TEi7MPWCS64aSYFwNF2OI1yAe3z8S2T3xq38ITCRr95PxUnLtuvn9bN6B7hZY3ihUyo01lXEdqCvGtcfw201+kPmNcGNfSA8K/L9JvUC97zaKRTFyi3gHM0pmU9/t4rCaXNlgXjlG4HRftF3hcdbKnI7yFQ3T2kZtGOiP2CViC9AZC6bh+8KG7gv9UVcW6bdN1U45qEGc71x60bpamLyOQxoXEtytUp0WAPrN0CDqO0GwZB3+6ksvg5iWk9z57D6TKUqiyeXKI1zrNauTstM1K+y7PoSNhTEQFJiKe4"
`endif