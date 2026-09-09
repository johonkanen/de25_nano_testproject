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

module ed_synth_dut_altera_merlin_burst_adapter_1931_hbsisni 
#(
    parameter 
    ADAPTER_VERSION             = "13.1",

    COMPRESSED_READ_SUPPORT     = 1,

    PKT_BEGIN_BURST             = 81,
    PKT_ADDR_H                  = 79,
    PKT_ADDR_L                  = 48,
    PKT_BYTE_CNT_H              = 5,
    PKT_BYTE_CNT_L              = 0,
    PKT_BURSTWRAP_H             = 11,
    PKT_BURSTWRAP_L             = 6,
    PKT_TRANS_COMPRESSED_READ   = 14,
    PKT_TRANS_WRITE             = 13,
    PKT_TRANS_READ              = 12,
    PKT_BYTEEN_H                = 83,
    PKT_BYTEEN_L                = 80,
    PKT_BURST_TYPE_H            = 88,
    PKT_BURST_TYPE_L            = 87,
    PKT_BURST_SIZE_H            = 86,
    PKT_BURST_SIZE_L            = 84,
    PKT_SAI_H                   = 89,
    PKT_SAI_L                   = 89,
    PKT_EOP_OOO                 = 90,
    PKT_SOP_OOO                 = 91,    
    ST_DATA_W                   = 92,
    ST_CHANNEL_W                = 8,
    ROLE_BASED_USER             = 0,
    ENABLE_OOO                  = 0,

    IN_NARROW_SIZE              = 0,
    NO_WRAP_SUPPORT             = 0,
    INCOMPLETE_WRAP_SUPPORT     = 1,
    BURSTWRAP_CONST_MASK        = 0,
    BURSTWRAP_CONST_VALUE       = 2147483647, 

    OUT_NARROW_SIZE             = 0,
    OUT_FIXED                   = 0,
    OUT_COMPLETE_WRAP           = 0,
    BYTEENABLE_SYNTHESIS        = 0,
    PIPE_INPUTS                 = 0,

    OUT_BYTE_CNT_H              = 5,
    OUT_BURSTWRAP_H             = 11,
    SYNC_RESET                  = 0
)
(
    input                            clk,
    input                            reset,

    input                            sink0_valid,
    input [ST_DATA_W-1 : 0]          sink0_data,
    input [ST_CHANNEL_W-1 : 0]       sink0_channel,
    input                            sink0_startofpacket,
    input                            sink0_endofpacket,
    output reg                       sink0_ready,

    output wire                      source0_valid,
    output wire [ST_DATA_W-1 : 0]    source0_data,
    output wire [ST_CHANNEL_W-1 : 0] source0_channel,
    output wire                      source0_startofpacket,
    output wire                      source0_endofpacket,
    input                            source0_ready
);

    localparam PKT_BURSTWRAP_W = PKT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1;

    generate if (COMPRESSED_READ_SUPPORT == 0) begin : altera_merlin_burst_adapter_uncompressed_only

        altera_merlin_burst_adapter_uncompressed_only #(
            .PKT_BYTE_CNT_H            (PKT_BYTE_CNT_H),
            .PKT_BYTE_CNT_L            (PKT_BYTE_CNT_L),
            .PKT_BYTEEN_H              (PKT_BYTEEN_H),
            .PKT_BYTEEN_L              (PKT_BYTEEN_L),
            .ST_DATA_W                 (ST_DATA_W),
            .ST_CHANNEL_W              (ST_CHANNEL_W)
        ) burst_adapter (
            .clk                   (clk),
            .reset                 (reset),
            .sink0_valid           (sink0_valid),
            .sink0_data            (sink0_data),
            .sink0_channel         (sink0_channel),
            .sink0_startofpacket   (sink0_startofpacket),
            .sink0_endofpacket     (sink0_endofpacket),
            .sink0_ready           (sink0_ready),
            .source0_valid         (source0_valid),
            .source0_data          (source0_data),
            .source0_channel       (source0_channel),
            .source0_startofpacket (source0_startofpacket),
            .source0_endofpacket   (source0_endofpacket),
            .source0_ready         (source0_ready)
        );

    end
    else if (ADAPTER_VERSION == "13.1") begin : altera_merlin_burst_adapter_13_1

        altera_merlin_burst_adapter_13_1 #(
            .PKT_BEGIN_BURST           (PKT_BEGIN_BURST),
            .PKT_ADDR_H                (PKT_ADDR_H ),
            .PKT_ADDR_L                (PKT_ADDR_L),
            .PKT_BYTE_CNT_H            (PKT_BYTE_CNT_H),
            .PKT_BYTE_CNT_L            (PKT_BYTE_CNT_L ),
            .PKT_BURSTWRAP_H           (PKT_BURSTWRAP_H),
            .PKT_BURSTWRAP_L           (PKT_BURSTWRAP_L),
            .PKT_TRANS_COMPRESSED_READ (PKT_TRANS_COMPRESSED_READ),
            .PKT_TRANS_WRITE           (PKT_TRANS_WRITE),
            .PKT_TRANS_READ            (PKT_TRANS_READ),
            .PKT_BYTEEN_H              (PKT_BYTEEN_H),
            .PKT_BYTEEN_L              (PKT_BYTEEN_L),
            .PKT_BURST_TYPE_H          (PKT_BURST_TYPE_H),
            .PKT_BURST_TYPE_L          (PKT_BURST_TYPE_L),
            .PKT_BURST_SIZE_H          (PKT_BURST_SIZE_H),
            .PKT_BURST_SIZE_L          (PKT_BURST_SIZE_L),
            .PKT_SAI_H                 (PKT_SAI_H),
            .PKT_SAI_L                 (PKT_SAI_L),
            .PKT_EOP_OOO               (PKT_EOP_OOO),
            .PKT_SOP_OOO               (PKT_SOP_OOO),
            .ENABLE_OOO                (ENABLE_OOO),            
            .IN_NARROW_SIZE            (IN_NARROW_SIZE),
            .BYTEENABLE_SYNTHESIS      (BYTEENABLE_SYNTHESIS),
            .OUT_NARROW_SIZE           (OUT_NARROW_SIZE),
            .OUT_FIXED                 (OUT_FIXED),
            .OUT_COMPLETE_WRAP         (OUT_COMPLETE_WRAP),
            .ST_DATA_W                 (ST_DATA_W),
            .ST_CHANNEL_W              (ST_CHANNEL_W),
            .ROLE_BASED_USER           (ROLE_BASED_USER),
            .BURSTWRAP_CONST_MASK      (BURSTWRAP_CONST_MASK),
            .BURSTWRAP_CONST_VALUE     (BURSTWRAP_CONST_VALUE),
            .PIPE_INPUTS               (PIPE_INPUTS),
            .NO_WRAP_SUPPORT           (NO_WRAP_SUPPORT),
            .OUT_BYTE_CNT_H            (OUT_BYTE_CNT_H),
            .OUT_BURSTWRAP_H           (OUT_BURSTWRAP_H),
            .SYNC_RESET                (SYNC_RESET)
        ) burst_adapter (
            .clk                   (clk),
            .reset                 (reset),
            .sink0_valid           (sink0_valid),
            .sink0_data            (sink0_data),
            .sink0_channel         (sink0_channel),
            .sink0_startofpacket   (sink0_startofpacket),
            .sink0_endofpacket     (sink0_endofpacket),
            .sink0_ready           (sink0_ready),
            .source0_valid         (source0_valid),
            .source0_data          (source0_data),
            .source0_channel       (source0_channel),
            .source0_startofpacket (source0_startofpacket),
            .source0_endofpacket   (source0_endofpacket),
            .source0_ready         (source0_ready)
        );

    end
    else begin : altera_merlin_burst_adapter_new

        wire                         sink0_pipe_valid;
        wire [ST_DATA_W    - 1 : 0]  sink0_pipe_data;
        wire [ST_CHANNEL_W - 1 : 0]  sink0_pipe_channel;
        wire                         sink0_pipe_sop;
        wire                         sink0_pipe_eop;
        wire                         sink0_pipe_ready;

        altera_merlin_burst_adapter_new #(
            .PKT_BEGIN_BURST           (PKT_BEGIN_BURST),
            .PKT_ADDR_H                (PKT_ADDR_H ),
            .PKT_ADDR_L                (PKT_ADDR_L),
            .PKT_BYTE_CNT_H            (PKT_BYTE_CNT_H),
            .PKT_BYTE_CNT_L            (PKT_BYTE_CNT_L ),
            .PKT_BURSTWRAP_H           (PKT_BURSTWRAP_H),
            .PKT_BURSTWRAP_L           (PKT_BURSTWRAP_L),
            .PKT_TRANS_COMPRESSED_READ (PKT_TRANS_COMPRESSED_READ),
            .PKT_TRANS_WRITE           (PKT_TRANS_WRITE),
            .PKT_TRANS_READ            (PKT_TRANS_READ),
            .PKT_BYTEEN_H              (PKT_BYTEEN_H),
            .PKT_BYTEEN_L              (PKT_BYTEEN_L),
            .PKT_BURST_TYPE_H          (PKT_BURST_TYPE_H),
            .PKT_BURST_TYPE_L          (PKT_BURST_TYPE_L),
            .PKT_BURST_SIZE_H          (PKT_BURST_SIZE_H),
            .PKT_BURST_SIZE_L          (PKT_BURST_SIZE_L),
            .PKT_SAI_H                 (PKT_SAI_H),
            .PKT_SAI_L                 (PKT_SAI_L),
            .PKT_EOP_OOO               (PKT_EOP_OOO),
            .PKT_SOP_OOO               (PKT_SOP_OOO),
            .ENABLE_OOO                (ENABLE_OOO),            
            .IN_NARROW_SIZE            (IN_NARROW_SIZE),
            .BYTEENABLE_SYNTHESIS      (BYTEENABLE_SYNTHESIS),
            .OUT_NARROW_SIZE           (OUT_NARROW_SIZE),
            .OUT_FIXED                 (OUT_FIXED),
            .OUT_COMPLETE_WRAP         (OUT_COMPLETE_WRAP),
            .ST_DATA_W                 (ST_DATA_W),
            .ROLE_BASED_USER           (ROLE_BASED_USER),
            .ST_CHANNEL_W              (ST_CHANNEL_W),
            .BURSTWRAP_CONST_MASK      (BURSTWRAP_CONST_MASK),
            .BURSTWRAP_CONST_VALUE     (BURSTWRAP_CONST_VALUE),
            .PIPE_INPUTS               (PIPE_INPUTS),
            .NO_WRAP_SUPPORT           (NO_WRAP_SUPPORT),
            .INCOMPLETE_WRAP_SUPPORT   (INCOMPLETE_WRAP_SUPPORT),
            .OUT_BYTE_CNT_H            (OUT_BYTE_CNT_H),
            .OUT_BURSTWRAP_H           (OUT_BURSTWRAP_H),
            .SYNC_RESET                (SYNC_RESET)
        ) burst_adapter (
            .clk                   (clk),
            .reset                 (reset),
            .sink0_valid           (sink0_pipe_valid),
            .sink0_data            (sink0_pipe_data),
            .sink0_channel         (sink0_pipe_channel),
            .sink0_startofpacket   (sink0_pipe_sop),
            .sink0_endofpacket     (sink0_pipe_eop),
            .sink0_ready           (sink0_pipe_ready),
            .source0_valid         (source0_valid),
            .source0_data          (source0_data),
            .source0_channel       (source0_channel),
            .source0_startofpacket (source0_startofpacket),
            .source0_endofpacket   (source0_endofpacket),
            .source0_ready         (source0_ready)
        );


        if(PIPE_INPUTS == 1) begin: pipe_inputs
            ed_synth_dut_altera_merlin_burst_adapter_altera_avalon_st_pipeline_stage_1931_glj62si # (
                .SYMBOLS_PER_BEAT (1),
                .BITS_PER_SYMBOL  (ST_DATA_W),
                .USE_PACKETS      (1),
                .USE_EMPTY        (0),
                .EMPTY_WIDTH      (0),
                .CHANNEL_WIDTH    (ST_CHANNEL_W),
                .PACKET_WIDTH     (2),
                .ERROR_WIDTH      (0),
                .PIPELINE_READY   (1),
                .SYNC_RESET       (SYNC_RESET)
            ) pipe_stage (
                 .clk               (clk),
                 .reset             (reset),

                 .in_ready          (sink0_ready),
                 .in_valid          (sink0_valid),
                 .in_startofpacket  (sink0_startofpacket),
                 .in_endofpacket    (sink0_endofpacket),
                 .in_data           (sink0_data),
                 .in_channel        (sink0_channel),

                 .out_ready         (sink0_pipe_ready),
                 .out_valid         (sink0_pipe_valid),
                 .out_startofpacket (sink0_pipe_sop),
                 .out_endofpacket   (sink0_pipe_eop),
                 .out_data          (sink0_pipe_data),
                 .out_channel       (sink0_pipe_channel)
            );

         end
         else begin : no_input_pipeline

             assign sink0_pipe_valid   = sink0_valid;
             assign sink0_pipe_data    = sink0_data;
             assign sink0_pipe_channel = sink0_channel;
             assign sink0_pipe_sop     = sink0_startofpacket;
             assign sink0_pipe_eop     = sink0_endofpacket;
             assign sink0_ready        = sink0_pipe_ready;

         end 

    end 
    endgenerate

   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate
    
    // synthesis translate_off
     
    generate
    if (SYNC_RESET == 0) begin : async_rst0
      always @(posedge clk or posedge reset) begin
          if (reset) begin
          end
          else if (sink0_valid &&
            BURSTWRAP_CONST_MASK[PKT_BURSTWRAP_W - 1:0] &
            (BURSTWRAP_CONST_VALUE[PKT_BURSTWRAP_W - 1:0] ^ sink0_data[PKT_BURSTWRAP_H : PKT_BURSTWRAP_L])
          ) begin
              $display("%t: %m: Error: burstwrap value %X is inconsistent with BURSTWRAP_CONST_MASK value %X", $time(), sink0_data[PKT_BURSTWRAP_H : PKT_BURSTWRAP_L], BURSTWRAP_CONST_MASK[PKT_BURSTWRAP_W - 1:0]);
          end
      end
    end : async_rst0
  
    else begin : sync_rst0
      always @(posedge clk ) begin
          if ((internal_sclr == 1'b0) && sink0_valid &&
            BURSTWRAP_CONST_MASK[PKT_BURSTWRAP_W - 1:0] &
            (BURSTWRAP_CONST_VALUE[PKT_BURSTWRAP_W - 1:0] ^ sink0_data[PKT_BURSTWRAP_H : PKT_BURSTWRAP_L])
          ) begin
              $display("%t: %m: Error: burstwrap value %X is inconsistent with BURSTWRAP_CONST_MASK value %X", $time(), sink0_data[PKT_BURSTWRAP_H : PKT_BURSTWRAP_L], BURSTWRAP_CONST_MASK[PKT_BURSTWRAP_W - 1:0]);
          end
      end
   end : sync_rst0
  endgenerate
    //  synthesis translate_on
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX4YcW+Y66UIiSssp99aMyb+sMlTl9IoAj2EHQqYoeB532WKEabxnjalz/2CbVTSCfywCNN0QRjZnoF9GQJu+lbgvr+l2UI0ih6TxZPeCLBbtfojJXSzmQFaFHpCExHAGkJigS7wwToDWczS+A2i0hwZE2MrWW3pGI62kWA+1YqQ4H9Vvm50/uMJG7u6eozTWHVJmgyVWKsbxFbQ/kHwyA19sDTBKZS4jGJRMReQI02dOgUVOHcGIA1+mW2zvVfVjIOSJNYPVEPOHUTQ7y9IJvZuRyLZXLYdDn4oY/fn8TPWcq3HNjMxvK9eiUHIQhmhwoaLDwoieJqY9VgwsNOyUN0p1ivShbw79YlO4vMip3swub5AHp5JnSRbrAFiPjeS7+YgfOhV6SNmcAZKg6Dlf5wIClOxiUr0lqUC+hzOlIybL6MPVz+kFkIGCny0/jiX1YRSZ+lRPbiMApXnqqeB1JCnIzbKva6NGx/6odvmI4XQtikrZT2j7JX3Ut3dU+Px6SHeRQCdkvMHyIokaIjbqZMZHDKNd4D+7+nlF2wOFgsGuj4Y4mvlPdJwkXVJaWd9u7hwdH3hAe/vDw4+GGEUm8YVgz4HCMHqoQBFeF5MfBwjebaAs939mt4/KWMr1tt7a2hM3Ypwj48QrLMh0Mh0Zv1k78Bps7blEjTkf2QhkDm4xhO+Qh7tOVybSGM38mjXyEPKBPjQTZ3X9FHeyjnwKdcpJVW/xZ0j6/MS8Ika///q4+EhovVEma6lz5Fcg5neuPcDY6H8FPF9GlGlpQPM+vM3"
`endif