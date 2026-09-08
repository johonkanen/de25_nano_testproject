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


module ed_synth_dut_altera_merlin_router_1921_nxsnrbi_default_decode
  #(
     parameter DEFAULT_CHANNEL = 0,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 0 
   )
  (output [404 - 404 : 0] default_destination_id,
   output [2-1 : 0] default_wr_channel,
   output [2-1 : 0] default_rd_channel,
   output [2-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[404 - 404 : 0];

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


module ed_synth_dut_altera_merlin_router_1921_nxsnrbi
(
    input clk,
    input reset,

    input                       sink_valid,
    input  [440-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    output                          src_valid,
    output reg [440-1    : 0] src_data,
    output reg [2-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    localparam PKT_ADDR_H = 319;
    localparam PKT_ADDR_L = 288;
    localparam PKT_DEST_ID_H = 404;
    localparam PKT_DEST_ID_L = 404;
    localparam PKT_PROTECTION_H = 414;
    localparam PKT_PROTECTION_L = 412;
    localparam ST_DATA_W = 440;
    localparam ST_CHANNEL_W = 2;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 322;
    localparam PKT_TRANS_READ  = 323;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    localparam ADDR_RANGE = 64'h8000000;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;


    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [2-1 : 0] default_src_channel;




    wire write_transaction;
    assign write_transaction = sink_data[PKT_TRANS_WRITE];


    ed_synth_dut_altera_merlin_router_1921_nxsnrbi_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

           
         if (write_transaction) begin
          src_channel = 2'b1;
          src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc8jyNwyk2AojvQKlb1sw6+fWasC5CWdKVN3tq5JUwF0fHctyy9QdWlEwfNRvRpFPUZeb82nPGcmCknXHieRcnHm7GQOPl1hcX/y1jTXg7zaacFD+70qRRgyNCxrsEwvu0HxVek3iW729dSPiOw6TYc6M2PRyibBINxLjYj1uz0O2RBljlByLUYNYlxfnQr5oH94A5cwBM61WgvXvoQtXtW8iHgP+O2/HUVVE92357hX3Sxx6qNZqgXybojlVWaeP87ZH0rCHjeKex1ksoQtaoNtTUr8ligNS8VPhHHPZ+uM2lT9v3FxEGHffRJxOseRi0hiM5xxWMkgUiqyBVwmnchXioYAmIOYSVutWr+ScPkFT3JW4tFAWJTiK+HtHwBTO02Z3yCShClkhjF8AxKWhnMeJp+l7WBYbjvArwvw5B0mbYhRjFZlAN/p5IyWgwlT/iF9mqm7+b3rskofg3KUIStm9+k/rsRFlNm3p6yGgyP41yC66BjtgNQ2BMed7g2cGcdWUfC2zGG8XmjuazfynI7XUGEnrn6GIJiZGA1TjZg9Ca5WjfIh6Nm9l1c+UwK+9BAERLEZmWMjA5IP+GRHJxC2qseETbJywrlgGsk2kOkrpK3DtIfZ/U/XdfSVRNpspQlcjH8jJIR1dNal+BlvDIDocerNv+o72JLvUdi/BMGJv4Ynn811Ut/AA8wIQH/g+VuD2C4jGHhNnr5nc1Mhn1nv3YerSD2srG8MbLboMLPwF9TLugmWm2Jsx9wjLCPT/oBiFn/0pKC5gE3zH2FOFW+z"
`endif