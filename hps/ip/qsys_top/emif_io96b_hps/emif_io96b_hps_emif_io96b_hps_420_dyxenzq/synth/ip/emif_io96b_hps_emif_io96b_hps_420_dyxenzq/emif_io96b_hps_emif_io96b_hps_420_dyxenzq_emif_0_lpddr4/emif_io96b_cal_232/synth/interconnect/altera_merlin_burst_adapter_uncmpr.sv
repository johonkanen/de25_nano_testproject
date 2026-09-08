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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9WCv23ZsM10w8ViIrJnVQOmIGdVjCt2XNn+JdAhvlIpKL7ugR+gmtIlNL5EdiDj8LdVDuv/aI5kJjBEG1rx6c5M1MIU+R7OoAsDq5aFGzkOVrJjZUF37yBgSjCIXf18rz9kARvE7F3SJ9+wEQPEYYJnCnA11zvGqFm5KLceFz4ObZDcrBApUf5Wi+GgNZBqw5HOkJn2dAta1RJHTvF28TJEKZ0DOPzU1aLPacpYy53ohQ7E9PEPZo/bZzgdrNj6XoXPZTDjeSqzGQJcXrXfm3ehTpHUSmIhehot7997uG881ctA1TzhJWi3QfUheZVE5QlyabjdncCt2AC3YidBk1IBCHgqSAhf7xAi1k289vnirWsHDDklaDCB/PWZSB5xnaiDGFKtituB096oR93usuC87Ji6uVxqvGfGG8gKnlzcJEdEWrv8Nx+A212o1TR2SqR1Qdt+vBHJaKLS3Vvw2PDnw8LYHFsKj9uh382HFeAHGs2TpWXUmNulxhg/NeCDnfRikU/t6RkNVepEyE/ppODu3Vq29kWjCgqJ+juVVCsLPgI0bzm5GKWxBVPC9Nui+P8WonQRMi/zwNa67hEpgr24UrB6rzAQEY6KJTt9+oIqwRJoeWOfvRiWjAGxNQbkenECJ2GhQGSNY9oRdWYwFTJnlK16ZnM3RinqNFqVkfYJ9J0wbsd0TSMGrpdWycVQZqH8UmKYB99hVamicZIiObvoK4qfZo00Ln0BBXy8rD8Sbi2Vr5+/NYBZsi/mRCx9MjhSho8pqeb0e6LRRiaVCLT"
`endif