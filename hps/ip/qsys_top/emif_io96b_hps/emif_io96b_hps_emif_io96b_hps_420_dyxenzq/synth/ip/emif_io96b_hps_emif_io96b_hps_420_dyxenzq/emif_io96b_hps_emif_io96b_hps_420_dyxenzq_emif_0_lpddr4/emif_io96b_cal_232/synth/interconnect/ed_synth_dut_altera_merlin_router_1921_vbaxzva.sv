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


module ed_synth_dut_altera_merlin_router_1921_vbaxzva_default_decode
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


module ed_synth_dut_altera_merlin_router_1921_vbaxzva
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




    wire read_transaction;
    assign read_transaction  = sink_data[PKT_TRANS_READ];


    ed_synth_dut_altera_merlin_router_1921_vbaxzva_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

           
         if (read_transaction) begin
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
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc+Kgt+SuqlEJ/YzdS7HIklwKnCDjyKjnwejruoSDE7tWaBXTVjCskIvFug2508xm1rsEJHS6g7XOXswBNHXx/LdoaI98AbCVaregp3yxCFge6Lb4nLZazkM3FlEZAfsKRnQnQBu8mb9GA9R7zbkKmHih8SfKurT3Dnk9Wr2ao/Ybx/rLp0VM7SaanMoVbo1Fu8ae6DrxmZX7VqvUfmor0DmE/li9tnq/1gZd9GtL1hXCyeVNZS1n95emIWYQcUK3bkVRoy5f1VUdRa2sNK712/2eqidkGeifBobAlllzxDUaK3o2STUcASbO/1CzN6kM6s71YhZBVeExTBWnIJNWIjo1SWPf32riKMlbw5RwqZalxn/4dCLdycELkzrRmU0XCW03yWjvtX6mhzNN6FU5lFWETzY8eCnxGlA5WTWgPuWp1sVCCOy9Wp7z8JIcVWDyAtYOT78I1wfC3SBbxkOzyDG/azfK6kL0xmIBQxnh+fk0oprz/UvE/RGxcYZWbWVCvHvZpsF91LnKdyt5wmzUE3VCHm/gtnlZHGJuwlfeeJcqpBZyTEI9NA6n4B91QxjonWH9BShJQkPy9JE6yb8e82OkUBR0Ox9IZiBFRYVF8XVB4B7ulJXnZSS/N6eSLCRwtyMqLdZE241iEgHbQuUSoVMjQ1KxlQRKOLdIwmbfJhPCzBIMzgUPxRjIDbBrFTG7oQl6AbXk8zOEVA1xbXFMB1DkBWWXtb7LU8e7blkSfbWvEJ8cl+z0U6Ixt3pyi8Qwscq3InccB7qRFI+S1lezWXj"
`endif