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


module rd_pri_mux_cwyib4q (
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
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1oEvAVIgbyFjRTTJfPd1bMeQf5WpMRRHelZ62SknexiqWwyzYHkyYeLzqzwPu6CkJX1skF+dwc94RQ+WK7sI1vi89fPXoRfCmi1VfEn2RZX5FmHNDDg2vGbtwQbd7vrHSe2prLAj3CwKqT26H/Z7qOPF+5VIvLKjlnVSlKTdG+bQMhogPpDVtjNuniun3MSEu+3/2pwPhLfR+Tr62vo9BjcC9neQJelCkKzPSDKnGQNCttACBmVwWw5INuZa4ijWkNFoLPzLXx4KvVGxEJharzMcz27WV3Kja2veHV6eo7Bk/px5HaI9QSIM27m4ttpizqqkOnPysW6dmU3W4P5B09RbBcadLV3ez4APAj4sHJsRz3TwjD2XoL3nMuZuKChnnY7rMtzegaynjg4uW/ERSCp04UHaYwsDoQopM5xBxq8EO1CsZc+BUxmqLaV0KJrUGLapeNmf81HA/DSpCDsZ9MQZo22nUY6cKh9B0PNs/qQrTXLV3GbVGb/qLwjh9wBYJIP9qKcAjqkTSP60Le30O3fUDDUgK0WPgkd4bkTxfcXjyeDkPxMzTyFeop5vk0mvlNGdJDs0I3KjdvBzRI/A4Cj2KS+7alHHAf6cZ6/kbe3KLKflQUuDVYqfx9nhu6VJOEH2a7ZDjki9VrfWztzSgLACoxKV0jJn/aW1sr83oLwPC/d90wpci51/SpwQbkgIVVQzUBBLWuy0PwrDdsJd04tAgtNCU6fSrG5FCZrXnysXTRd5MdD+T5TlWdYBUnxtQYniC6yqdUIchPi5zCMLlX9"
`endif