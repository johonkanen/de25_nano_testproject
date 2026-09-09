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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW6WQmELu0VHHq5kBgCmOYpZ2hbpUexduxQj22OCzhmOWpMLphcfjznmhUCnVbirKR8fb27SjdVTRU9/IYSzxnVylg7HuglBrRGxAmwrNIe+rC9Pg+BHoxxk2uHdfJUBmLfN3kROlpkXrazQuy64qMtAzjM40HuV+/MwK8CK40jrfYNAAe/xrGjmUKNxdsMBNromb0PmzMqV1kpwrlkxNiOR1BiRIRm7dOrgF9KhX1kbpFeRryf3wu1D7q9KNq3VRkYpZnVJOYqFwdHU4KpP3rLD7KaR9WMjrtRcuvcgjs1rtsahrhJQprWdda3kqwX1oC21UgwKO4sN59k99Wa7bLy7ZpPrxfOp5tvKhJe6e1qNcgu6B0ZfIuu/JGu39DSX1EOMJjAc2GEq5e+EBckI7n1MpzULUUQtYEseBT/M9zgJOKi0dw5cnSdL0qVExrc+EPTJ/beJUuFdaVbZB2SnWmm+PP1GneJUBB/0mHZVM+hmmwCn9+Zf+G6wBTs9jOHloOZvDPWablW8vHqba5dnVacMG90uXhYCBjqb73fF23TFsyn1J113tWqvPvCsUp3ugI45cvKf4wF43ipcoR4Nhz6idMyzLE84Rqz6IRaJd+oknVt7+QSlRwOijza1EaWUjZjNh1C9ivTRhUgud1g1otbcMdSp1av9GoHOb9Ot5j0C7RLxMyRJF032AH4qYZxz5mXT/vSM5phVOqrFWWpz4m2iIqzMpfjkf3gFwOq/gybI+hc/athkoJDyrT8/4EIr6Q/qfpztgMcBdvfO3ttkCJ2T"
`endif