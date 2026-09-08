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





`timescale 1 ns / 1 ns

module altera_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R101" */,

    input   clk,
    output  reset_out
);

    (*preserve*) reg [DEPTH-1:0] altera_reset_synchronizer_int_chain;
    reg altera_reset_synchronizer_int_chain_out;

    generate if (ASYNC_RESET) begin

        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_reset_synchronizer_int_chain <= {DEPTH{1'b1}};
                altera_reset_synchronizer_int_chain_out <= 1'b1;
            end
            else begin
                altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
                altera_reset_synchronizer_int_chain[DEPTH-1] <= 0;
                altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
            end
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
     
    end else begin

        always @(posedge clk) begin
            altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
            altera_reset_synchronizer_int_chain[DEPTH-1] <= reset_in;
            altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
 
    end
    endgenerate

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1Fht4277Y+91VJnUrh/5hrFqOADwKRqiLsdt/cqGLEzhQQcrWmg51Yy5mXnSiw6FfImIkgD8Ck/ZT4cliEkfBJ8MvlFHiucF4gjdNZhvvfZU3j81OpYa3tPH5H2W4J0+SkdP2DPeAapjXi9YkQVQjsI0v4dbWpeIG8fZzNZQb9r7IdLCqtnNFCmiFw1vqqzdGnE27id82+iufRydCYAVk76+AWQbaZyosgkUXLqY4VRCSoh4OJxErbAAjmhklcR3qbZtNBCdqCF9bqryWupZkMpklXsfe5G7KRiw8bMAjFvuAkGQdFiOzIojPkWtODBv1c3i4gjsuZE3PgHhRr39wn7obP7Zbf3zLQj/+o5QqVZOBuvsEIcRop+a6TucmMyF05/Unhp5C8/X3pneoq2+xZlVNyoTAWvXxsJsJerJ6mVoXwgs0Z3s450Mwxyi5f58hSPcUlD0U5YH1oljVxcbGyTA/kGzhItzAQlqjUK8Y6PiM7sgNM8c2LCi+syVlvevi00Di4+5Yflxzgid71tikJyvSLR2JIWvDyEwfW1F979kr7GG6qPKwZe6wFqkahaYAqD1kRkCW5dk+TcXzoc1iadVqlx0CgQIAleg7RoO0x/ejjgjSGMJ+kMMBQjDfpp8ulvK+sQlLhAx4dAtyXhMd1yE2XZo2y0Cet2gTSahyRCLfrD8ATSo+QfCgxeAyrOgC1PLuBivxvInziHwS9gnXV4igXcvshPg1Ix27cLQaYhmSMa44reiY9GfUxWuPfMvegh30ope1L7aenwCK7bSPmwX"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc/5PJSo8DpGzONbGXw06KOOJeXx0rtSi+pZ+YjYrtPEe+XIJQcDqqtlWzxg9z3BVgyItoC7gBmv6m14y5UN59zUVhEJXrlMlnJytLXvG4KamX/u/j3GC09c4lyFyMwKJhT6Nnp/zqR9BdvpBLmHhkjkjtee5msl8Sl8qBRET8aoi5DGCSNbpyFqCKRQnHlow/sbgPezscukFkf5igyPC1KRcRq7IJ3AMrFa2dc25qTOucf27bmprzcxeus7tMrlXl+ahKUJVNVwvjmcMViw69fnyTF1gW47a6MnSn1XSxauBSdxzVwwrPK5byRpcou5LlD44VWZCOcf1qTlIvjZ/1R94LEO7K5cE02LIC65Ipjwpq8RL56CISxK5HhcVZ2qWgHznVqAQ6IVKNCTvf54v3vfNlzmU2INgUc4hIVoP8k/M6wUOQi1H6bIFbBhdcUfa/6HJ2uv0PjjAu66fpQFJErWAcd5x0/SH/jtbKtmojjNK7Mt+H7OX+3dNZ1Q3irw6jh8OBsrJnM76PnQpuYvEqg/9sYsP4ocjIhUBgwyESFgTH3/uzhdbCgW4Vy4+XCYWHWajIu8c3Mp2Tepi9qzxEuVXd/9iBxTFspzm7W6j7YIslXv667OqVZYen4r014HQI25UaJl9R7AvqNXAsw2eFTxIXqNC7MphEaTJMo11icuOdPIcy29Ahms/Je746xjmv2Kh0gfyCD25eDTkoL2aOSvJsCSoTdH9kXbmVKoHVseAH4X6t34q/8haMVtq8oTD+bbiyz8KvPTQivCpf9Q0+VC"
`endif