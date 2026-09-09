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

module wr_sipo_plus_kt2puei #(
    parameter DEPTH = 1, 
    parameter TOTAL_W = 35,
    parameter ID_W    =10
) (
    input clk,
    input rst,
    input in_valid,
    input [TOTAL_W-2:0] in_data, 
    output in_ready,
    input [DEPTH-1:0] clr, 
    output [DEPTH-1:0] shift_occurred, 
    output [TOTAL_W-1:0] dout0

);

logic [TOTAL_W-1:0] mem[DEPTH-1:0];




logic shift_in;



assign shift_in  = in_ready & in_valid;




always @ (posedge clk) begin
    if (shift_in)
        mem[1-1][TOTAL_W-2:0] <= in_data[TOTAL_W-2:0];

end

always @ (posedge clk) begin

    if (rst)
        mem[0][TOTAL_W-1] <= 0;
    else if (shift_in)
        mem[0][TOTAL_W-1] <= 1 & (! clr[0]);
    else if (clr[0])
        mem[0][TOTAL_W-1] <= 0;

end

assign in_ready = !(  mem[0][TOTAL_W-1]  );

assign dout0 = mem[0];

endmodule
    


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW5P9CaxzggHV+F9Dta308fgntzAJmxhPWzCYhDV6YrzfsyD8XcR/jRlc/y1V3yJiNwoMVlIfQP9flU+qi5XYO1B2WoARoLKK73h4apiy3HC6mmoTB0bf0YISEFaxd92b2TpZLFnbXgishbsMisyPAEXbp8r9uJ7MBtc7abeRjdiSQqRaWrVMKkxkOLd8ehoUmS6L2aPPCfUnSMtLBpvzMbixlhmufpV1D6P2jxplewMn4mxkSbFTY8L2ethkicIi2Z8G7UyYKrcK2h2FPJcga6Ikg3FZAy12HTRZGzSd31k5dRo1KY2Cn2DvXc8vWzO+qqqp8Ig1pFmqV5UsSw3GN3B7lP+nQwgKkAldXbwuF/KBSHkowNdLEzuw/Uv9SIyGM14vCY7zBj3vwUULeitCHBY0AbMdd7R/NgRGCyFjQDI30YzVFn9YhjN8cfg1agL1tEUJutjmCP2Wyxg8l/DZ4hchNODKfrVS7vg69VUUJ6ktsjm61moidUiMO+13jViJ/JvDiws/dAJQjgruIJ+fDkZSBSiLRxsRVRmHzBty+GTSTsva7KgddVvVZxa+BVl0xuSd93ROiCo37RpB3O/ch39BMLOWGUEg9dCgkJjgtbOCX1tm8+DTptevAlCZ8X4TZdGvB//eE2PoDqIwC0RQp/HglGEAkB0/mT8jJ+Fs2sbsELO/OXGH88CjjXRxaWmVbbB+YMNhoomcfmfsDCcorZ+R7+WZ4pajVl+VnJVdBPuDI9MgA1NNHn+0O/aWaFua1l5PFIp8HW0olLljVS/Rh+s"
`endif