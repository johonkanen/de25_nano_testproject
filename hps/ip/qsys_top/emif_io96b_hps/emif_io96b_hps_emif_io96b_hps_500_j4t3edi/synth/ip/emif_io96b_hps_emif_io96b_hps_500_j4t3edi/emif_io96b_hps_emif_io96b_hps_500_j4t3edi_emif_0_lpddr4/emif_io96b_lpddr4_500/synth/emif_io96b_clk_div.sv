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


// a generic clock divider to be used in simulation
module clk_div #(
  parameter RATIO = 2
) (
  input wire clk_input,
  output wire clk_output
);
  localparam WIDTH = $clog2(RATIO);
  logic [WIDTH-1:0] r_reg;

  initial r_reg = 0;

  always @(posedge clk_input)
    r_reg <= r_reg + 1;

  assign clk_output = r_reg[WIDTH-1];
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3r7eKJk6TD83snHqVsGnBetQtyQnjTXUB3wChRnntnKY3wPaGneubuMI5Tg1TMIMLhc3T1m6G+WdFMml9yrkgUaNFNiUcAd5rqdu3pjyxRZ4j0V+IGe1npmr2i5Fr9lggnfHPYeZMNx4BSgSl8MnT37WUmbDjSpHcAzGYHdHNWud3y5EZUTRfg4Ek6GoUZlZMkovDfCJFBpHFC5c+zTZGsMOMTeQvB6piGwKHIfMr18x3AK3ys3TWmxPWvJjt70GxVh/R/rlGLgzwOFoaiIYmWTY+usUSjp63OkFNvXBPqaYOyEO10anDdmbFj/Oz6zhVpf3IyZn3jArOH8WRFgwDLka4Kun3aXJqs8E01z+rKJ5AUps/l2tdnXXHx0ThqdMNdgy+sSnVFEjTHQEGF+RqBj5E41Uo3WvFL5O7u7tWThOj/+eoHn/aHv9fmoPKnYiJ3JBvJy2XF9iY6r/0XjVdiRBDa/klGxYvOw7ipVrlhz0zbL9asu8XnDNOWut17y6SOIg9PCYbixwm7okdtSNvNrXXpi0l52a+5RQVAhb8sf2KVwFTj9RoKx5QmML0vRYTu7FGIe7gkoN2CdVT4Mbmtl4+62VDuvQi4gQUgNIpsUE37+cdFKgF7Hk3ZCt/hhlQ85ZzKc6r0d+WbLIuEA6mEJHOGze6F0TfuXfLRwBLp+HlaqVsyDobeqOdv/kRiet+eXxJyTQjAgBdKuO22u0F97a8rihhj2yy6FnaSx9zWNHfPTcTz+W1OH3WGA61D2FU/T8y4imJa1v26+6SYI6O+AwhENG7BnOsAxx9ShgwLvztBVn4+4zbVZbyiQi8VDMEElwM+ShmO4Z64OCjAPkPm5oAodGiQnRld2+h3CYvUd+BLS/AOJnp3qxC7qX7dKt//TSFh9MX/7V8c/JqByGbFVSqT7XyXytu5Kn0jrkZflz7K0DKefHPK6d/SM/G1jMpn5vR6nhZKKqkSs0oRxSRZISEeaE1Zbps4O/OEDJK+2BUzU6KnFVuAPHRlYgMvok"
`endif