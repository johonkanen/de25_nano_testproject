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


module ed_synth_dut_altera_merlin_router_1921_irryw4q_default_decode
  #(
     parameter DEFAULT_CHANNEL = 0,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 0 
   )
  (output [152 - 152 : 0] default_destination_id,
   output [2-1 : 0] default_wr_channel,
   output [2-1 : 0] default_rd_channel,
   output [2-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[152 - 152 : 0];

  generate
    if (DEFAULT_CHANNEL == -1) begin : no_default_channel_assignment
      assign default_src_channel = '0;
    end
    else begin : default_channel_assignment
      assign default_src_channel = 2'b1 << DEFAULT_CHANNEL;
    end
  endgenerate

  generate
    if (DEFAULT_RD_CHANNEL == -1) begin : no_default_rw_channel_assignment
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin : default_rw_channel_assignment
      assign default_wr_channel = 2'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 2'b1 << DEFAULT_RD_CHANNEL;
    end
  endgenerate

endmodule


module ed_synth_dut_altera_merlin_router_1921_irryw4q
(
    input clk,
    input reset,

    input                       sink_valid,
    input  [188-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    output                          src_valid,
    output reg [188-1    : 0] src_data,
    output reg [2-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    localparam PKT_ADDR_H = 67;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 152;
    localparam PKT_DEST_ID_L = 152;
    localparam PKT_PROTECTION_H = 162;
    localparam PKT_PROTECTION_L = 160;
    localparam ST_DATA_W = 188;
    localparam ST_CHANNEL_W = 2;
    localparam DECODER_TYPE = 1;

    localparam PKT_TRANS_WRITE = 70;
    localparam PKT_TRANS_READ  = 71;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    localparam ADDR_RANGE = 64'h0;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

    reg [PKT_DEST_ID_W-1 : 0] destid;

    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [2-1 : 0] default_src_channel;




    wire write_transaction;
    assign write_transaction = sink_data[PKT_TRANS_WRITE];


    ed_synth_dut_altera_merlin_router_1921_irryw4q_default_decode the_default_decode(
      .default_destination_id (),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;

        destid      = sink_data[PKT_DEST_ID_H : PKT_DEST_ID_L];



        if (destid == 0  && write_transaction) begin
            src_channel = 2'b1;
        end

    end


    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc/aXw2KGt15i8Ontqzzc5iJbHtbyuK+0Q5jwVTA9X29v7NxaDqn+QuOu+lqdiNYQIi9IFPnRoc/V4MMa0IgcC22NqFuIFEff0rW8NQZC82G4z6LAjHZOhYKf47+eoPUy9wHSCTv6/aZDL5MLD9YA8uQHR6pIl4uphV0dyXpU05/N4DcS1Htjce2XXOr78CYbtffZstACjxW0uM03OmmZzsn+VJlEP8sz90WlapTvY3RHOInZYsV33+D7tnLRjhI0zB2WbiCCrGJQJ+vDdjMvwAqRcU8ylsj40NsFMhaMGTaz+HRae1fSlVvTwtU1gp+91trGHFBLyp07VXar5DbjYOE/Ck9cvc0Z+PSfFQcHGfqtAa3OPzPwOeiqvV6jZD+CapVRzr2QnHkwTfhCBULAewLkUPhNhXfiutlYCURSCcZlQBOK+JDhMgvBtmci4sr7UtBoeSaArK1q4wumcO9n3B17tWjo0mTukDaWDSvLBtylXTgSYtUEAoHx9c/cxhq2jJ7QNNL9mLHut+qm00NEPaYwKmJduSXbvf5JIisyfHkacSPyKWVs4gUk2UbAlNyr6iiBtp4sB9gsbr3cYEKN8Jh+gSr91GTCvlDcsq3+n5oGcqDe9LH90vhR/qdp/KzUOZ3piP18bfP54yUeSV8D3iHOWYxRJX0ovnH0wjWRJy5f2pf5daLKnNax6Ueqsc01QUuRjFL8Impn1CHCcRYAHFn38/dNtsM1EI/X04ZEME+B5Nvop1TXQU/8ME7D/0sV4vRximIE963miYxJMbJVZPs"
`endif