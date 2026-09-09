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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW6tUMUbzIe72BZNfuO1jqls1lWWiqFhvs6VRqQA1Lu+wSZWpG7b5MVEaQqAEZBBLO3xE6wDcvNyhch750TCDMFS4wLjRIozpznKAjGXufqVCsqGBi/jUi2MVi7ZnEa1RD/8GYxwUEvpevcuH2RWmc1cWlIdQ/8TrnIIKeUK9ZZHIPBquNnrDwmh4kW9JaTdwluhNkcCS4CfiJb0/K3P6SlWlOnI5wSXbZj1U/ZgWfvZGJqohH85Mcmex+YSmxs7zolXU3k2zHGVqVVaIO2kDxf8EOYKcjqxHkbMIOvn6XE1hrpjt5U1VpVDBb4V8vhBEO0/oIw9WEqnONVOILdFTqYn1a1nNdxonuhk9e7MgmAb7P52dWPDXOIN4i3rBGWxWiElL6TYaHsFSGBMyCq02meGYdSNI7ketJicaqe7HCTdBWR/XoCUE1Yp1ISY8j+3Cx4Up40S9vFqZ47wFGdUJw2f2fp5tRbnbOXwLVuuSSXVTC2QUxtBFODuq5MoK1oCvH0qUSSX835SMBaRvKpQ42j7WAwmo7y564NwdAM7r3vkcHfdz63GQvPnYM+eU5K4LLCcjzh/X5cp5ByPf8C8LoKswDkB9PsNtUnQLiBT9Mh3UjgDqh/QsV35YLzBw3f5h52nK1Vm0mPA2OukxuRQGAYcQrJDCps0QbFFY6Z0SkGx0w1Z3GPlJXH/TY1UovJZGJep7jOz/w0Ug1phm3rC+VW6Ned6cPPsODKOKfD0RxrXgYouW2IIuKSccLyGzT8Mqq3ClEkvRVZQAExi3X69Xcnr"
`endif