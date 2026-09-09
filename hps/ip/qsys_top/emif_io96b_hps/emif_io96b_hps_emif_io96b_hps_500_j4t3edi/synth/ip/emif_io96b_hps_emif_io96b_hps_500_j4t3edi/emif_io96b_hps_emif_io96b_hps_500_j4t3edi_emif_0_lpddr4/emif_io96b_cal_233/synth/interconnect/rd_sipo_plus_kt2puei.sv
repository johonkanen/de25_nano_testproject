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

module rd_sipo_plus_kt2puei #(
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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW72NUU7aYrLe22c+IT4abYF4MSqhw+/am1M8Wm5DPJEu6t76ONVeTLcFrYrsXPdvB0y6W5vFYv0i0Opc0L+KN7QCRpXHI90od7jmRS8hr8zfJ5+GVoV73BRnnyQzYGjwJxgm5FeMC02O4sHvoaIeoEMNjT0Rz4EcqsnOVx4423R+YWiXtWDi8+VDBG3Zbab7FUG5ly4piwDK/J4AX32+P1ATsZ0VSfDBpyUYhi+h+YEQiSyy+6mvqprNyT3WolKWA4toOCj3W/CmWNCqR1MXwsBW+hEaCLxj1hph6zgxk1TC5npEm9SlcM7pPWv/qq5uJu3+7Mrrahws/pkGwCK+cnDyjd0w9V/giWscacsbkBwZYBs/FGagtefk1gz6818GgrhO1mx2CFd5hpELQmQCUagSqRcAEdl9ncGDj8pXGLAm5Vp/J/AI0UGG9eu0NsXRa4UFyWw3PwlRweslyHPfR6nTKYs44pED4bs4+fMiwWPfjwRMj7ni6j+D4EpEobYC0pG62DGS69c33QeFiasUu6OLLMst+2xLLWkB6RX/dU0jy+sUMTlLWU8yRrOcf1AE1gmL85qULSdh2SqBuJ74hsdYqALGzQuSVuQw+sUT8qq6R5+3merrZt6T0gUP6YNQ424r1hBSbw2LuDkkddfEomXGJ7Sfia9C3Bwc+RULa3SriS6IEMxfodZ2pGdw/y2mijXmLTh0UNH6j5MYRZ4Gt4I+nuKRv0Jh3PL6TwgouhDTRWA5qtQMQq+e6t9n8eHsOnQQ2L5AVs/avEsh1FmC9JO"
`endif