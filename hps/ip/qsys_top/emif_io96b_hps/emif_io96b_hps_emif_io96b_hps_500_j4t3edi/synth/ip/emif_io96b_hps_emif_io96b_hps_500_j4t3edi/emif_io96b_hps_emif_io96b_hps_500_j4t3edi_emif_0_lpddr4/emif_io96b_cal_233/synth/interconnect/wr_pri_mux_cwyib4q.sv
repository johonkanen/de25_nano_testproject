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


module wr_pri_mux_cwyib4q (
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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW4WU7DqZnvIHF89gdTbvHMKpcbhXywqMCkaU/2EffqZo1J3GobKfSR6d9oNtzmuWLwswMp7I0kJX/YFVEqJxWcaLRRz//HNtWb97UYcEf0Rd30MAfGcniUF+UV/0qeqTuHVOMeZMI46Q+sRJj4OgJdkr9Fku/wzF5yoPqQLE0hiDc1hdb/u81AfORVa2Qz5sAirRFZablbOKRZwkOKYczgHdcpL1Vb9ed07ywIRBDcyEvh8c0wLDp9VMc8Vg3Jpw2ixyFGsoQf1cac/RQFu22DRrpj5ddMH93QVWfv+uTpAZK2lUm7a+Vu0oy6SZ/JYvHvHFfbuIcWslW52/cOvgDRLHUXq8j/gXFP3wo8qbljJ7bNB6yQmiQlRdQAYoDu/uHVYuTHZ5A5rNJ88nksAt/0QureDbH5TdXFduYDsx63q8LD5R4iJE5TjESYKISLC7+s1K62rdP7CdScdJdKbatGfEl85vzqBYC28bCZev3Wg/trA5rPT3mNjbwwuTo3ZFP6EhUntW+3Hl3kYvIzZ/RDgZRweHf8Fs1Kn5HwrmCyqFv8N7WfcdCoSl+MSlaIyc+mUsERbPXEw9wT900wE88LvoRIOb0jIWbLW8J0YeMIpDk2z8BwsMoTS/SLKMLyobS4oUpFL1TNWdku6ZD1s0i5uGwDGAeTgMLzuXj3Iwun9pL2oKWsNrMTTC5ooQ5a63hvKQDFKCx3aU27J2mLq/nlcQ4qSisxDAdCXdJd5BiLPAHbY4dsphz1wfOTe05McVYudA2I4lrIo2JLKFrUt93ne"
`endif