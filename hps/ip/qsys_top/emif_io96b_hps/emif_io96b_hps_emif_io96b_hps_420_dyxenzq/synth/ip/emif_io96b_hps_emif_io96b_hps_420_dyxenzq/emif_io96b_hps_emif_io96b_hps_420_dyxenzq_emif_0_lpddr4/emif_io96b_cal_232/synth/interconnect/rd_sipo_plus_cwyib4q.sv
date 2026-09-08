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
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1ol3tXEbzq4qd9aRu2yUt4omqhnJvTYjj5uaq+JAFS6QUyIwKTDzG30IXwXQTu5dZvwrewxjFO6EHJxIRTXVfeIa5rxmp3FjF0cE2TAKc04zUpjWDIf/8vnASX5zeuHyLfAjVVIz6ZZC/kah1QeQMxMJbPlFqszWg4HuRNca2O0/HHiS4HKC8OALPSdqYaDXTvTrG8CqAPvsIGR1qIvaa/kzS4M9L3wx9pV4rzTpkgB7Uku+WtK2jrmongqY8evadTcmEVn9nwDFw0yw9vyvMVzXTpcaUgAS8GC8uZOlcA8MeaZvoOiC2rRtD/65K91bwKijFGADh548QwxSRwsn2ynD5Aj1hm/84dZxZBBkrGuF8mxJcYfbK5Tms/uDtvfjEVu1QJvHYC3PmH6FWt/Uv7d4hhgdcvjOIiFuqx4a5d8tw88Z8u7lIFk0Mnr4gGuIc6LK6YZkptkWLImC9OerBLCoG1pl4Vkc8Q/PgJZF1EMPiNbnE7/hi3Q1S2m9iTOkCeoTRnyFjxBtoM91gmycuS9Wal2UOxl0cNn0aUsQknlLs+8zqOj7m6+aEYd+AbTkey8Ovi7qfrQh8QFoavyh8auQ3iaux7zBIZB7eTgyBjKEhmFFyZVIiqWJJWg1+ofojWqJgyLjEwtv1rGqyWl14uAgd+x9K3CWfE7ALadNIu2Nw4tnSHTeVqWTv8ftzJOMqsJaSboLzRftmUptz+FYioRm+zxAwqCEwp85PC5b0U6npye5e85bHskmKufzAL1MEWWxO6acm4EhecDVQWSrUXI"
`endif