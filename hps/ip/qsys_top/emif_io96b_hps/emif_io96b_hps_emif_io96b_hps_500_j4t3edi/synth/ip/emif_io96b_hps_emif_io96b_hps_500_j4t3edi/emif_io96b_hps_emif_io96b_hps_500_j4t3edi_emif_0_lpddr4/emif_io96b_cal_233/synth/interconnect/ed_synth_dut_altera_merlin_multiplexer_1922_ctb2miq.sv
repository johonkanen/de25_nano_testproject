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








// altera message_off 13448

`timescale 1 ns / 1 ns



module ed_synth_dut_altera_merlin_multiplexer_1922_ctb2miq
(
    input                       sink0_valid,
    input [124-1   : 0]  sink0_data,
    input [2-1: 0]  sink0_channel,
    input                       sink0_startofpacket,
    input                       sink0_endofpacket,
    output                      sink0_ready,

    input                       sink1_valid,
    input [124-1   : 0]  sink1_data,
    input [2-1: 0]  sink1_channel,
    input                       sink1_startofpacket,
    input                       sink1_endofpacket,
    output                      sink1_ready,


    output reg                  src_valid,
    output [124-1    : 0] src_data,
    output [2-1 : 0] src_channel,
    output                      src_startofpacket,
    output                      src_endofpacket,
    input                       src_ready,

    input clk,
    input reset
);
    localparam PAYLOAD_W        = 124 + 2 + 2;
    localparam NUM_INPUTS       = 2;
    localparam SHARE_COUNTER_W  = 1;
    localparam PIPELINE_ARB     = 0;
    localparam ST_DATA_W        = 124;
    localparam ST_CHANNEL_W     = 2;
    localparam PKT_TRANS_LOCK   = 72;
    localparam SYNC_RESET       = 0;

    wire [NUM_INPUTS - 1 : 0]      request;
    wire [NUM_INPUTS - 1 : 0]      valid;
    wire [NUM_INPUTS - 1 : 0]      grant;
    wire [NUM_INPUTS - 1 : 0]      next_grant;
    reg [NUM_INPUTS - 1 : 0]       saved_grant;
    reg [PAYLOAD_W - 1 : 0]        src_payload;
    wire                           last_cycle;
    reg                            packet_in_progress;
    reg                            update_grant;

    wire [PAYLOAD_W - 1 : 0] sink0_payload;
    wire [PAYLOAD_W - 1 : 0] sink1_payload;

    assign valid[0] = sink0_valid;
    assign valid[1] = sink1_valid;


    reg [NUM_INPUTS - 1 : 0] lock;
    always @* begin
      lock[0] = sink0_data[72];
      lock[1] = sink1_data[72];
    end

    assign last_cycle = src_valid & src_ready & src_endofpacket & ~(|(lock & grant));
     always @(posedge clk or posedge reset) begin
        if (reset) begin
          packet_in_progress <= 1'b0;
        end
        else begin
          if (last_cycle)
            packet_in_progress <= 1'b0; 
          else if (src_valid)
            packet_in_progress <= 1'b1;
        end
     end
     wire [SHARE_COUNTER_W - 1 : 0] share_0 = 1'd0;
     wire [SHARE_COUNTER_W - 1 : 0] share_1 = 1'd0;

    reg [SHARE_COUNTER_W - 1 : 0] next_grant_share;
    always @* begin
      next_grant_share =
    share_0 & { SHARE_COUNTER_W {next_grant[0]} } |
    share_1 & { SHARE_COUNTER_W {next_grant[1]} };
    end

    wire grant_changed = ~packet_in_progress && ~(|(saved_grant & valid));
    reg first_packet_r;
    wire first_packet = grant_changed | first_packet_r;
    always @(posedge clk or posedge reset) begin
      if (reset) begin
        first_packet_r <= 1'b0;
      end
      else begin 
        if (update_grant)
          first_packet_r <= 1'b1;
        else if (last_cycle)
          first_packet_r <= 1'b0;
        else if (grant_changed)
          first_packet_r <= 1'b1;
      end
    end


    reg [SHARE_COUNTER_W - 1 : 0] p1_share_count;
    reg [SHARE_COUNTER_W - 1 : 0] share_count;
    reg share_count_zero_flag;

    always @* begin
      if (first_packet) begin
        p1_share_count = next_grant_share;
      end
      else begin
        p1_share_count = share_count_zero_flag ? '0 : share_count - 1'b1;
      end
     end

    always @(posedge clk or posedge reset) begin
      if (reset) begin
        share_count <= '0;
        share_count_zero_flag <= 1'b1;
      end
      else begin
        if (last_cycle) begin
          share_count <= p1_share_count;
          share_count_zero_flag <= (p1_share_count == '0);
        end
      end
    end 




    wire final_packet_0 = 1'b1;

    wire final_packet_1 = 1'b1;


    wire [NUM_INPUTS - 1 : 0] final_packet = {
    final_packet_1,
    final_packet_0
    };

    wire p1_done = |(final_packet & grant);

    reg first_cycle;

    always @(posedge clk, posedge reset) begin
      if (reset)
        first_cycle <= 0;
      else
        first_cycle <= last_cycle && ~p1_done;
    end


    always @* begin
      update_grant = 0;

  update_grant = (last_cycle && p1_done) || (first_cycle && ~(|valid));
  update_grant = last_cycle;
    end

    wire save_grant;
    assign save_grant = 1;
    assign grant = next_grant;

    always @(posedge clk) begin
      if (save_grant)
        saved_grant <= next_grant;
    end


    assign request = valid;

    wire [NUM_INPUTS - 1 : 0] next_grant_from_arb;
                               
    altera_merlin_arbitrator
    #(
    .NUM_REQUESTERS(NUM_INPUTS),
    .SCHEME ("no-arb"),
    .PIPELINE (0),
    .SYNC_RESET (0)
    ) arb (
    .clk (clk),
    .reset (reset),
    .request (request),
    .grant (next_grant_from_arb),
    .save_top_priority (src_valid),
    .increment_top_priority (update_grant)
    );

   assign next_grant = next_grant_from_arb;
                         

    assign sink0_ready = src_ready && grant[0];
    assign sink1_ready = src_ready && grant[1];

    always @ (*) begin
       case(1) 
           grant[0] : begin
               src_valid = valid[0];
               src_payload = sink0_payload;
           end

           grant[1] : begin
               src_valid = valid[1];
               src_payload = sink1_payload;
           end


           default : begin
                src_valid = 1'b0;
                src_payload = {PAYLOAD_W{1'b0}};
           end
       endcase

    end


    assign sink0_payload = {sink0_channel,sink0_data,
    sink0_startofpacket,sink0_endofpacket};
    assign sink1_payload = {sink1_channel,sink1_data,
    sink1_startofpacket,sink1_endofpacket};

    assign {src_channel,src_data,src_startofpacket,src_endofpacket} = src_payload;
endmodule


`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW7DGHiUlCUOiTrNkHqyE0Zvb2+er7EsmWgga1boWZhNeC9hGjyiQ7DipWjkwNogctK/eaeuT+a9AI9OUbwEvqDqPTvQi3k/ErB7KRhhTraNYkexHxW1hNPoilTayFFpHfsP3tIaNyubUYbHqE9navG30FlzgvnM+eCJAdwtK+vhJqMvov0GB4iYH5ALD0QrJSAtchQbI2XWoJucdxwwSMrIYmIcYC0Wn5v4kG487klQVZEGx7t4nJxDpomYn5/CPLx4t4JCOVTCGLoxXWI/q3OprOvPrhrWS3vQYNZtRrmvBlpinPcfjaYPtiSddMA/cLgTyqrPCIkoFv2PeB7GTxnaDdD0i8nEHlRDpfxuAfekH/3qrYXBHjMSh3JH7zRqjs52Ea7k4lBGv9QoExZ+NoCJmt6KJgx2PYI35TS9FZxqO3hWiHXVEopAonPduNlJxWQtAfT0/o7pqTtgTpqFNBw5yfJN3QwwvXOpcCvagGbJ0rAbcpjy6YrdUOIst2hv0GZ02LcKkWKs3OolymP2HaWhkbfLyQxdPqKYdhY/drRXd+CGYQfl7KLOOd1KHETWZfAa8TxHhEHNtcxkV7I18GMmfcn5OFioDrc1eDOS+lZUd0ph/xTE9iRrHRxp9E9mRO9X++PCLhlWaA278MKaRkDYbAv66grc7zHDz6OrLTuf8ql2HGEK+98qTxQXPQJzFq7hQU7Z3dvfNT2n4J+141PWE60bso4UBIdKdrIttt9T9v/KWJnT0GX5G10bnqvJsBEQXiN8RyOcIvectpVMhl+D"
`endif