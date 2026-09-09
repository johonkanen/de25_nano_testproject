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


module ed_synth_dut_altera_merlin_router_1921_wqohhgi_default_decode
  #(
     parameter DEFAULT_CHANNEL = -1,
               DEFAULT_WR_CHANNEL = 0,
               DEFAULT_RD_CHANNEL = 1,
               DEFAULT_DESTID = 0 
   )
  (output [88 - 88 : 0] default_destination_id,
   output [2-1 : 0] default_wr_channel,
   output [2-1 : 0] default_rd_channel,
   output [2-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[88 - 88 : 0];

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


module ed_synth_dut_altera_merlin_router_1921_wqohhgi
(
    input clk,
    input reset,

    input                       sink_valid,
    input  [124-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    output                          src_valid,
    output reg [124-1    : 0] src_data,
    output reg [2-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    localparam PKT_ADDR_H = 67;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 88;
    localparam PKT_DEST_ID_L = 88;
    localparam PKT_PROTECTION_H = 92;
    localparam PKT_PROTECTION_L = 90;
    localparam ST_DATA_W = 124;
    localparam ST_CHANNEL_W = 2;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 70;
    localparam PKT_TRANS_READ  = 71;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    localparam ADDR_RANGE = 64'h100000000;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

      reg [PKT_ADDR_W-1 : 0] address;
      always @* begin
        address = {PKT_ADDR_W{1'b0}};
        address [REAL_ADDRESS_RANGE:0] = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];
      end   

    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [2-1 : 0] default_rd_channel;
    wire [2-1 : 0] default_wr_channel;




    wire write_transaction;
    assign write_transaction = sink_data[PKT_TRANS_WRITE];
    wire read_transaction;
    assign read_transaction  = sink_data[PKT_TRANS_READ];


    ed_synth_dut_altera_merlin_router_1921_wqohhgi_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (default_wr_channel),
      .default_rd_channel   (default_rd_channel),
      .default_src_channel  ()
    );

    always @* begin
        src_data    = sink_data;
        src_channel = write_transaction ? default_wr_channel : default_rd_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

           
         if (write_transaction) begin
          src_channel = 2'b01;
          src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
	     end
        
           
         if (read_transaction) begin
          src_channel = 2'b10;
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
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW5jj1jOdIGve80ik0eVV9yeEyTW0ZWZ/UyjqUJIWslfB8MWPyfC3SlBLZjyk3q0344Mc3fnXiuUWz1Jc7+CXHLyYzAXY7w/bnTlNYqguWuWtg6SCNIf56vgmUd0IM+4L+E5w7g9MqCi+kdeIWHd0pEX0ekCy/wfBF88F0obULOfyXhKj4NZ9UDr49crDkTuvocqey64BdOMG5AbXLJPfXPnBVx4mqTHR0Xfrf9bwxFAY/mH1Eb2HWfmQKH7sOy1GSXV7ZLDGQEytSIv4vYwDuH3UlBs23Kdc+AOn0UPTGFJc4cY75i+SLpFNNH0vsbIj6QsF/qcQBaElTmcHIavqugthbufMu1gqtWzvspwdjYXsf1/s0cCZyS6ALyi2I+TNem6o7V7x3O71LcDAF56PHmJb6FWKAYREeETkLLdxi7WRKr2RhqLI7VkBkWd6vk2IXuNw67kS/xfVODmuMlDJ+jCJ2V/xa73GtkDDqriFt5CgUXoE4i4LuzUyKqFw+Cdp9cA5/3BbrFRDyUet0794Khnw3RN8KL3OBAseEleFfsL6AO9FuiIp8zFjWBHCYc8gcZ1WkdEXyokVqSaZKQReO8qBme6D2pUPH9i46gva5nc7B1UApU9HHUCBjn/vWRFIvSXjipN4WWIeEyqfDiaaDvNf1iByyazK17Nhf2sCnY0nCoOwfFuK2TvNfBlh9XxxtdPfW0IMFshpiWrkIX0QkO5exTYqlXKrDhlJm4T9FBGzyzDErkVyCvIoDdK3BNnEPdv8UcR0y9KuIFn5q2gTHwD"
`endif