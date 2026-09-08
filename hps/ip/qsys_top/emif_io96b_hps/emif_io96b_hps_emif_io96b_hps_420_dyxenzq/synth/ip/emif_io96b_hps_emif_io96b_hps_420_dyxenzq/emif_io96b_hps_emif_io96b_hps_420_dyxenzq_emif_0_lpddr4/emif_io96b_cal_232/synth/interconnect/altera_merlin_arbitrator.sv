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







/* -----------------------------------------------------------------------
Round-robin/fixed arbitration implementation.

Q: how do you find the least-significant set-bit in an n-bit binary number, X?

A: M = X & (~X + 1)

Example: X = 101000100
 101000100 & 
 010111011 + 1 =

 101000100 &
 010111100 =
 -----------
 000000100

The method can be generalized to find the first set-bit
at a bit index no lower than bit-index N, simply by adding
2**N rather than 1.


Q: how does this relate to round-robin arbitration?
A:
Let X be the concatenation of all request signals.
Let the number to be added to X (hereafter called the
top_priority) initialize to 1, and be assigned from the
concatenation of the previous saved-grant, left-rotated
by one position, each time arbitration occurs.  The
concatenation of grants is then M.

Problem: consider this case:

top_priority            = 010000
request                 = 001001
~request + top_priority = 000110
next_grant              = 000000 <- no one is granted!

There was no "set bit at a bit index no lower than bit-index 4", so 
the result was 0.

We need to propagate the carry out from (~request + top_priority) to the LSB, so
that the sum becomes 000111, and next_grant is 000001.  This operation could be
called a "circular add". 

A bit of experimentation on the circular add reveals a significant amount of 
delay in exiting and re-entering the carry chain - this will vary with device
family.  Quartus also reports a combinational loop warning.  Finally, 
Modelsim 6.3g has trouble with the expression, evaluating it to 'X'.  But 
Modelsim _doesn't_ report a combinational loop!)

An alternate solution: concatenate the request vector with itself, and OR
corresponding bits from the top and bottom halves to determine next_grant.

Example:

top_priority                        =        010000
{request, request}                  = 001001 001001
{~request, ~request} + top_priority = 110111 000110
result of & operation               = 000001 000000
next_grant                          =        000001

Notice that if request = 0, the sum operation will overflow, but we can ignore
this; the next_grant result is 0 (no one granted), as you might expect.
In the implementation, the last-granted value must be maintained as
a non-zero value - best probably simply not to update it when no requests
occur.

----------------------------------------------------------------------- */ 

`timescale 1 ns / 1 ns

module altera_merlin_arbitrator
#(
    parameter NUM_REQUESTERS = 8,
    parameter SCHEME         = "round-robin",
    parameter PIPELINE       = 0,
    parameter SYNC_RESET     = 0
)
(
    input clk,
    input reset,
   
    input [NUM_REQUESTERS-1:0]  request,
   
    output [NUM_REQUESTERS-1:0] grant,

    input                       increment_top_priority,
    input                       save_top_priority
);

    wire [NUM_REQUESTERS-1:0]   top_priority;
    reg  [NUM_REQUESTERS-1:0]   top_priority_reg;
    reg  [NUM_REQUESTERS-1:0]   last_grant;
    wire [2*NUM_REQUESTERS-1:0] result;

    generate
        if (SCHEME == "round-robin" && NUM_REQUESTERS > 1) begin
            assign top_priority = top_priority_reg;
        end
        else begin
            assign top_priority = 1'b1;
        end
    endgenerate

    altera_merlin_arb_adder
    #(
        .WIDTH (2 * NUM_REQUESTERS)
    ) 
    adder
    (
        .a ({ ~request, ~request }),
        .b ({{NUM_REQUESTERS{1'b0}}, top_priority}),
        .sum (result)
    );

  
    generate if (SCHEME == "no-arb") begin

        assign grant = request;

    end else begin
        wire [2*NUM_REQUESTERS-1:0] grant_double_vector;
        assign grant_double_vector = {request, request} & result;

        assign grant =
            grant_double_vector[NUM_REQUESTERS - 1 : 0] |
            grant_double_vector[2 * NUM_REQUESTERS - 1 : NUM_REQUESTERS];

    end
    endgenerate
    
   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate  

   generate 
   if (SYNC_RESET == 0) begin : async_rst0
       always @(posedge clk or posedge reset) begin
           if (reset) begin
               top_priority_reg <= 1'b1;
           end
           else begin
               if (PIPELINE) begin
                   if (increment_top_priority) begin
                       top_priority_reg <= (|request) ? {grant[NUM_REQUESTERS-2:0],
                           grant[NUM_REQUESTERS-1]} : top_priority_reg;
                   end
               end else begin
                   if (increment_top_priority) begin
                       if (|request)
                           top_priority_reg <= { grant[NUM_REQUESTERS-2:0],
                               grant[NUM_REQUESTERS-1] };
                       else
                           top_priority_reg <= { top_priority_reg[NUM_REQUESTERS-2:0], top_priority_reg[NUM_REQUESTERS-1] };
                   end
                   else if (save_top_priority) begin
                       top_priority_reg <= grant; 
                   end
               end
           end
       end
   end : async_rst0

   else begin : sync_rst0
       always @(posedge clk)  begin
           if (internal_sclr) begin
               top_priority_reg <= 1'b1;
           end
           else begin
               if (PIPELINE) begin
                   if (increment_top_priority) begin
                       top_priority_reg <= (|request) ? {grant[NUM_REQUESTERS-2:0],
                           grant[NUM_REQUESTERS-1]} : top_priority_reg;
                   end
               end else begin
                   if (increment_top_priority) begin
                       if (|request)
                           top_priority_reg <= { grant[NUM_REQUESTERS-2:0],
                               grant[NUM_REQUESTERS-1] };
                       else
                           top_priority_reg <= { top_priority_reg[NUM_REQUESTERS-2:0], top_priority_reg[NUM_REQUESTERS-1] };
                   end
                   else if (save_top_priority) begin
                       top_priority_reg <= grant; 
                   end
               end
           end
       end
   end : sync_rst0
   endgenerate
endmodule

module altera_merlin_arb_adder
#(
    parameter WIDTH = 8
)
(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,

    output [WIDTH-1:0] sum
);

    wire [WIDTH:0] sum_lint;
    genvar i;
    generate if (WIDTH <= 8) begin : full_adder

        wire cout[WIDTH-1:0];

        assign sum[0]  = (a[0] ^ b[0]);
        assign cout[0] = (a[0] & b[0]);

        for (i = 1; i < WIDTH; i = i+1) begin : arb

            assign sum[i] = (a[i] ^ b[i]) ^ cout[i-1];
            assign cout[i] = (a[i] & b[i]) | (cout[i-1] & (a[i] ^ b[i]));

        end

    end else begin : carry_chain

        assign sum_lint = a + b;
        assign sum = sum_lint[WIDTH-1:0];

    end
    endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FjTCeZ6k5epRRQm1jaEO9dtTZPvYIpxyd134ionjya/bVJZC8amlVu7xw6nw3zmLA1YXsGvsrgRxdtnwASNxo8VwrMgUzkqZbNZk98MBRqu4Q7oqcuwSPQV6A+A3vU0+JTGoVwSYdQD3THXjk+vZ9vkzTdX26x1e1R1KlDOj2R0YCIvkYx0QwtnVI6PAo9CqEs68fLS7n6Tf8nhjnL2qfettSmlS5perH5fHR9wfUuouYoOYs7oTjocPspLbltpXaPp3F7D548c8VhK4PlIen5Z+UTXwcX114RMxcacpOFYxDvM6w+vs7YtMb5TiaKX2F79Ml3pG8BvnTUtYxbIrWnpoPKMiUt1LvMDh+iDXHZwAhcvUe9MiijBreEf0b6kyzlwvuwFRWFBgjcM6vx4tMgmpc6SZ8m3QVNsXXV6MkppqsqI4lJog94aEtzSmK3iDUZFhJGA4Vxomo1S2M6e4F9SAamJ0dFTMVksXzPREwd79VFFTR5L4yd7Zo9Z2KxtQcKvjgR5nQmO9ZVC83Mynmro57c0fUFqUVPOAqTxXZI8o0p6hmT6ZIyw6x3M71/OjXsR5c5S0L63qyE3DOqfdWDFiXQcSttGKgRuyIbOFlg4pRL7laywvSxnDIM1mFEJ1q5EQMz9ek8L/0kuWOg7YBa/GT6eYghYtce/STHdiaMY4XsxYlHDPN6wqdKHGKPL20Wcnv9Y/SQUx7mGfijXc5MUV8/F8fsaYOgsswMCoNhJAkjFjQaOR/38ab3jKVt+qwYy2LXO1HwZNgkBPfyeZzXy"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc+nr35Cm6IExALKpLcnO+UJrc0+skjtaPXUa+NG52LD9HT9MnpDgbfPP6uunEv9O8yVoBTSVWt7ZWG98fzRBp7oQAiZPYaNfRZnhKWJ6Yi8nx76EbIJOLk4+Djvvm9GIPpkovw97zRHmKbp6pmMQBuPsatu5gE3MCbCy3seMK08vUzdMji+SJU0waIoXCUTbZY0XK0cq23gqIDpHk9Q1eNj2jaDRc5u8WTInC7QbItIKV7eswJpttGO1INoPa8XXiCHvA0eNu5KBvY4CIXtnkB4p4FWxU0512+77e5GStAiVF1AHjF8Td/Yz7c2vqC2x1sxvbr6T7A+WNK/n/wVGAhqNJ73eSpaNINazsQ0NsV3NEmLYlWFc5Z/cpY3MUx7ZopjTm31NBuT6YRCsHq9vdprpbTxoEQzC7rgJFH+1xOLAyVfd78KN3LMQQJItlVKSSoOLMjg3zZMAvf0xta3sv6NsfkHkw/dJXkOimztc7QNxyCxlt2pQh1Go17/JHhL/gfNLWxenAnpa53ZM5OAKpjafXnJTD6EREPpzvZqoeGHGv29Kt73edtPIld/eUrl8s3cq38K1ZuO2UQnfOwFENgCee8+mcpRYbiw0Tvl+jvJwv0lAUOuDB75Q3RFNrf4twTZ5NLmbpqKuT56QH9ZqcqJR7qX/rfqw7x2UON6iJGhP/UE24qt73JlFn8ia5of6d9cbUN0YguBPTMnIwL1tEmN0eYqslBIcJJz3KscENGWXhbQo7+DEBgh0+BJM9CgYH+Loi+LxCukriAWU0V8i0fE"
`endif