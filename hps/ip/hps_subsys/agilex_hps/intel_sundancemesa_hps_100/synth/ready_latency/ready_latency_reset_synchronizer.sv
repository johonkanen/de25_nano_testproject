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


//
// Module : ready_latency_reset_synchronizer
// Description :
//     2-stage reset synchronizer used for ready latency reset. Takes an
//     asynchronous, active high reset input (rst_async) and synchronizes it
//     to the rising edge of the clock (clk). The output (rst_sync) is active
//     high and safe for use in the clk domain. 
//     This module is intended to be used for Agilex 5 HPS ready latency
//     adapters for the fabric-facing bridges. HPS IP generation should
//     automatically instantiate and connect the HPS reset output (h2f_reset)
//     to the synchronizer input and synchronizer output to each bridge ready
//     latency adapter. This ensures HPS reset and the bridge soft-logic
//     resets are synchronized to the bridge clocks.
//
module ready_latency_reset_synchronizer (
    input logic clk,
    input logic rst_async,    // asynchronous active high input reset
    output logic rst_sync     // synchronized active high output reset 
);

    // 2-stage synchronizer register
    logic [1:0] sync_reg;

    // asynchronous assertion, synchronous deassertion of reset
    always_ff @(posedge clk or posedge rst_async) begin
        if (rst_async) begin
            sync_reg <= 2'b11;    // assert reset synchronously
        end else begin
            sync_reg <= {sync_reg[0], 1'b0}; // Shift in '0' to release reset
        end
    end

    // Output is the last stage of the synchronizer
    assign rst_sync = sync_reg[1];

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "xNJlgkakk7uiTmEjO9UCOiW8WFpugeSW63QHtS30B9QJksAJwiQ+9GCGkSbdthDdQaRLBfJoWNG4xd1Le5ZmK7wx83gQgGT5VNieh4JzpDR7c52fcCtIuIUgjxvJ413zJyrPayuh+cwviqihsXTZbiXvFsNV5MnOjxhWWlON/Pbi4Zww3xgB7RzxmTleesxsCL+HFph8ANHKuqt1d55T9R8660IFIV+4x0PSz2jci8mFyCFUrl4XRJ6lealRoI7pX+emfkLgWm8T2Y1ufolT2OybALWdsBpvoZ4Lpt8UBq/1tH8/OSuWLiQn+Rc+bGsmDOvXkCuXH2CJWPvgFs7AnaxV1JcQN6f4fNIGtnyAutiILGCfbmO5c45AYyiVL+izBsI16v2wcYvazk3bDgsgcnBKcNZ4MZ68Rv2zK6F0MZwybtQ2GyaxSI5hRbiqu+yO/DWmYX5pyTnUMe/Ew8BR1emTq1GgrAY5BUB8j2dm1TP6jMzknPRnw/vE3lhU9WEc6o40K9MXSxkRpBNqTtizHU3wmKOJxZ55WNwit9NyHy1TrK5RvjgJNljyQXpII5G2RL5IYJLN0KcYlXRAwfzaYppPu5Cfh+if6aeO9EjeAN7occICet7LYE5EFicA9EGR+/TB1I8cq+/VrnIG9WFpRHKmr0Hig+VxeuDNGk+sjKv+hGs/9g7XPyDstx/oY1THTErp13/IWEEtwgQm9ZdQLuqh1EZOjJYwr97bVUny5wpVnJqcAVM0aKju/pqWTkrlVH8dprWkohVSqcblZOaTLvS4cawIK10sciyUC2heGikrmuxljE4XCqTsIj5CXyWMNQ6yjMiobhUejpgIt8XX1VWL3wVURkkIl/l2b6xzDxoNKnjynHVjyc65GyvUThA3BfEAHkFoelkEYlKmywoU/w0lUfbjON9DhU+E1DhVDvdQ14+BVKI4vdv8Q2PFfwEVcwRnnePlajYIx446kk2kGCzeTI9XULPlHIiIMrxqkHzqNE/Ur5qWzR6Klz5rkGFg"
`endif