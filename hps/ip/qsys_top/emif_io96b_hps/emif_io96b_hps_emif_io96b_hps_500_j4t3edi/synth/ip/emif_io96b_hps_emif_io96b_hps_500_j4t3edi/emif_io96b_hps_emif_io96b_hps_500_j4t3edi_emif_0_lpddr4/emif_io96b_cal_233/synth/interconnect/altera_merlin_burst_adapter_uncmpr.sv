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

module altera_merlin_burst_adapter_uncompressed_only
#(
    parameter 
    PKT_BYTE_CNT_H  = 5,
    PKT_BYTE_CNT_L  = 0,
    PKT_BYTEEN_H    = 83,
    PKT_BYTEEN_L    = 80,
    ST_DATA_W       = 84,
    ST_CHANNEL_W    = 8
)
(
    input clk,
    input reset,

    input                           sink0_valid,
    input  [ST_DATA_W-1 : 0]        sink0_data,
    input  [ST_CHANNEL_W-1 : 0]     sink0_channel,
    input                           sink0_startofpacket,
    input                           sink0_endofpacket,
    output reg                      sink0_ready,

    output reg                      source0_valid,
    output reg [ST_DATA_W-1    : 0] source0_data,
    output reg [ST_CHANNEL_W-1 : 0] source0_channel,
    output reg                      source0_startofpacket,
    output reg                      source0_endofpacket,
    input                           source0_ready
);
    localparam
        PKT_BYTE_CNT_W = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
        NUM_SYMBOLS    = PKT_BYTEEN_H - PKT_BYTEEN_L + 1;

    wire [PKT_BYTE_CNT_W - 1 : 0] num_symbols_sig = NUM_SYMBOLS[PKT_BYTE_CNT_W - 1 : 0];

    always_comb begin : source0_data_assignments
        source0_valid         = sink0_valid;
        source0_channel       = sink0_channel;
        source0_startofpacket = sink0_startofpacket;
        source0_endofpacket   = sink0_endofpacket;

        source0_data          = sink0_data;
        source0_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L] = num_symbols_sig;

        sink0_ready = source0_ready;
    end

endmodule



`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FjJp8tUNyGN5irle4fz/y2QTsWcrhIYoCIt4ca9rsOt8zTmSoCaF6Wk3PYpIpjZzy7szRzA3jVL7YTrarTQyEw2yEKVpCgrU1L/kJ3XmV59srSbkqwzq3BaqRV8wZkfhwddnynQcLwl1NcqL5ICISVrd51J88zo3Hy0u+e8VX7fW7I6WsSxQsBTAEOHRgrqJ3+N+/pd7aO+MnpV+Q/CSjEF3iwQBIzR0Z5QmjaGhjd+YJkRWU/UCJu+snoqsjxoEA+9YmZoFpd4mpVYF7dz1MZddOkfQKYo6G5NExQbHbjiJLVj31g6B0hx0ru7mvVibMW6002OvpBXd4aqhE7xJAsaQhiQukgPjMVQTHPBFipmhHO9f1Se33puTWOJMPTtqUN9uGR/5/gal69Lqgjx+5HASBGL2N6wHzdoa8Bvl2xInNRabImbano0omE9Uqa/WGMzVVyye/a+V3A/5kWBigsAoGO95uNY65M9f+cw4VPEYfvXoTV+Kkm51HXs9q7XvGJyGDeTE70mu9STNU8/0WXzBlFgm6x97JsPtT4+LD4mynyDfDRyzs/ZtYHFVnpY7O4LRKhy0RmC+zJmZjX/f+ZPz9+PaCX0sJ/EpuXbjUIiny3DAkWaQVU3yRA0HHSDU9Wj859Vlq6H4xP+VqBAzkGedXDsanEV6B1mf3YslCunHLRob0WFQAyVJ5RtytcLFSCrZ4PEI6hxt6MnGRlVHj5hGQAU4nPC6jlp9x9nJUKqLUBWTGTN6hAKw1zgf8zkp345V6YPRqEl+pENIzggxEig"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX6kIwIjBQ56jACMCLfnVRgVRM9pgoG/Uu4h0TREG7qd5ySfFuC0aABoUcejEgwwLijgNbBQ4VeYtV4d5MQAqz4E02yl7yKoRQsaGc2mfaXqwrOEwm+cd28HdmSpi6OlSHI7rAcU+ZizX3NdzTlr+aeyu9TuRObD48H03Ufuag0PfPua4UWiFrRezfz02TczUQ1NDIE9TwOv9aAUstrGXu0b9hdp2f2fIpRL7d+rGwQWKI2BGVbunT0xW4bLEWf0s1JDulcyzy2n5re+Jr578stkmsxm6w88LoU3zCm7YhejVBbPJWkdsUQHPtDtf3E4ag/m5+INHXwhyFtHHhppHfWDAOidBNmrtgmVhmNYDRXZaQ0Bi4IEdAP7CwG7+AsXDUkio+TzY0rEYqfbhH4ZmPcQYjgKv2r08KqlPbyHLquucB2LG+4fh4uXK626tgduHjdnzma1BuQHiGi8uEVtlYGrF3oDDe265BoIDUvvUEZnMqzf7N1/sN3Wd7KFgC/UlDKVahk/svqMC7znjlZMG3FQnh1qd3jvOp+InOC88xkPysIoC0D4KKx+vtUD5rftQsRKByv8mccnJpuJDwrv+vNcxvG5He+loCB4S+ck+FTU0pbLM/BZFIcVejCGkSqSHCuPhfq+gpaDXaAXs8IGRdLavURbai+DSta/4FRlfr7meT0d0swo/yGVtA+rJXkSZyXMDMISNQzh2EC+PYjjFd3rTi2PSqGpFKQad6rmaGdh1y+P9jo+Sbb84qMWpN/RAx6zq9UWgxkLn+i3+PnRidIS"
`endif