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

module rd_sipo_plus_cwyib4q #(
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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW4ZcXPcdnX2EcfEs74TXIyeOxzPN6s62v0iyaw0igx35kcEM68rk4QCVV6fpWdQjjov8WDfSOvn05YKCmMnP1UH7lDyx17pj7rIQILxzJeuM5uhk3wASlKMvoNtvuXeNPh2NesQGvHcPXH/tDUPKyC+69dQKRoZ2lngd+/pJFiyd9lA/10cQzqtr56ZtnpvCLQosYkjt9QVFV0wVACWjduNfKiNyu4X5zHNwteV7GwBtUUJ/iQ+mkV41bz8wBNrnOmZ9R+U+JKRevguh6UfdMMvWRssPDxHKaoDZgQ5/1QZL0iLW6SyAL+3Z8VDsu60UhSsA4PHJFExuYO0kukh07J1IVmZ6EEK6tDMHk4wdm+WHxVxS8a5jDKJ/1S6EW+GoR/teb/dGaFT01PPG507XgVjcNiBAHjpadVfScN/TtPr0+km+abpGxWa4F16Ic6OxMS2WxE/d8kykSO+e/924WAJLHf1wPGsfO7ecud20Vop3c42Gc+1AV6wRvqKUgNq8m7fMobG4rKHb6UjCH2ts68tvKiwCyl1q1i4z4rJ5mUoCq4dmY0OKcneWzH3s9DBtCQFLjCy/lFqW38l05oWVzl/8Zh/afmd0cQB+P03fqwOdNkEDRRfoB9mftHGkb6Bfb3SG0596+sqCi+FQQSwZ8lpLOq6DPsbWC7h4nk5JxWpfw/fGDHFtBmBNVRD0i0CcCPNxuog0pqQ+yK9eniriMQ/lBIDWlAfktBECVmRDVANj35km8/ENb7FeeIcC5DW12XGZhrxmdzUz4HffXytEpo9"
`endif