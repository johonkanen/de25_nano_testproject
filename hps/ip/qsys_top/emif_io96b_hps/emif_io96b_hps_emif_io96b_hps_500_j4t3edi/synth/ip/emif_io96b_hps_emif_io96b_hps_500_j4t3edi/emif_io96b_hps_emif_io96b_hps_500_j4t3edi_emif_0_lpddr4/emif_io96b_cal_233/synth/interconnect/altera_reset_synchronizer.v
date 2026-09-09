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
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX7UU5GMEXWYX1hrYnv/h/CvZFZ4EwooXxWXgddwGKpOBvlbwHh6onsQC25g8iwH3by5Pd+FZgc00URqSPAoO2feHm+9SeJHJBkAMfWFZNGHHsg6lB/ezovM56C3tOCWbfNIrHchQEBDejxoGCo5PJ7VKR+sF0FlCpj1Z8IguUNlhfK+OPpvFsVFPQ2ksDX6bNxFHLNQOXVyMcNgLVj4g9d7KDwcGdAzBLiinqBNzxuJg4rQl5FCBF7MUq+7pRZ210mdrN5245X7tWIugInzvHNh6RRl8Ll7hESlfEvPSqH1OYB0hPLUi2iAc4kCtAOVmeKpQc1B043eyeJbLQsOyq41mQR8SeNCcMMoSRhEt9BbDPEqxP3Qs0EY5B9r38KRE8sIi3Lk3dCG/QarJA0y97koLEWWCsna1DzRZLCaGsTJONZ3NziSW9wixf3J6Nrp9/DOApc0PVCVS8zBy9F+EpHh+UX4rOjLdaXdOefkbIjVvDTldL2AYJODHzDJCjqO3PJKS3+tyzua7zZhDnFYqXfbMAkMHQvuilW7XH1cTXStK9tYHDUlJtfQ4SB5FdLeM3Uqz4eOJypHjTS8vNhZB5bOScI5gQnm/+Y/JUvzBBzto9kKlcwhk7F0AN2SHypwmkBfjG3IIbpnXRIj7QlWhlA5YOxXOEyS/U0zdT2839MPnpEHl64YELAUKDy5DLHflsqW0uEE/tggdkbs8YIirzCE4AVbw6BrtYEq+992Z0tQAbMhNlkL7prbNv56cCmXKRA+Juz2p+382hRSnhchZ8WN"
`endif