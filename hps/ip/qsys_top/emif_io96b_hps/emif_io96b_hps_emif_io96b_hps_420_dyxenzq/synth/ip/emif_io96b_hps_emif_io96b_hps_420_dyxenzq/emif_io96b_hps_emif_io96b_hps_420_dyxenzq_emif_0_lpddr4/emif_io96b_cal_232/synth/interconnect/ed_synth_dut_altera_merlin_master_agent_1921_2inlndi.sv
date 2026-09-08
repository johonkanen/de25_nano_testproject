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

module ed_synth_dut_altera_merlin_master_agent_1921_2inlndi
#(
   parameter 
   PKT_QOS_H                  = 109,
   PKT_QOS_L                  = 106,
   PKT_DATA_SIDEBAND_H        = 105,
   PKT_DATA_SIDEBAND_L        = 98,
   PKT_ADDR_SIDEBAND_H        = 97, 
   PKT_ADDR_SIDEBAND_L        = 93,
   PKT_CACHE_H                = 92,
   PKT_CACHE_L                = 89,
   PKT_THREAD_ID_H            = 88,
   PKT_THREAD_ID_L            = 87,
   PKT_BEGIN_BURST            = 81,
   PKT_PROTECTION_H           = 80,
   PKT_PROTECTION_L           = 80,
   PKT_BURSTWRAP_H            = 79,
   PKT_BURSTWRAP_L            = 77,
   PKT_BYTE_CNT_H             = 76,
   PKT_BYTE_CNT_L             = 74,
   PKT_ADDR_H                 = 73,
   PKT_ADDR_L                 = 42,
   PKT_BURST_SIZE_H           = 86,
   PKT_BURST_SIZE_L           = 84,
   PKT_BURST_TYPE_H           = 94,
   PKT_BURST_TYPE_L           = 93,
   PKT_TRANS_EXCLUSIVE        = 83,
   PKT_TRANS_LOCK             = 82,
   PKT_TRANS_COMPRESSED_READ  = 41,
   PKT_TRANS_POSTED           = 40,
   PKT_TRANS_WRITE            = 39,
   PKT_TRANS_READ             = 38,
   PKT_DATA_H                 = 37,
   PKT_DATA_L                 = 6,
   PKT_BYTEEN_H               = 5,
   PKT_BYTEEN_L               = 2,
   PKT_SRC_ID_H               = 1,
   PKT_SRC_ID_L               = 1,
   PKT_DEST_ID_H              = 0,
   PKT_DEST_ID_L              = 0,
   PKT_RESPONSE_STATUS_L      = 110,
   PKT_RESPONSE_STATUS_H      = 111,
   PKT_ORI_BURST_SIZE_L       = 112,
   PKT_ORI_BURST_SIZE_H       = 114,
   PKT_DOMAIN_L               = 115,
   PKT_DOMAIN_H               = 116,
   PKT_SNOOP_L                = 117,
   PKT_SNOOP_H                = 120,
   PKT_BARRIER_L              = 121,
   PKT_BARRIER_H              = 122,
   PKT_WUNIQUE                = 123,
   PKT_POISON_L               = 126,
   PKT_POISON_H               = 126,
   PKT_DATACHK_L              = 127,
   PKT_DATACHK_H              = 127,
   PKT_ADDRCHK_L              = 128,
   PKT_ADDRCHK_H              = 128,
   PKT_SAI_L                  = 129,
   PKT_SAI_H                  = 129,
   ST_DATA_W                  = 130,
   ST_CHANNEL_W               = 1,
   SYNC_RESET                 = 0,
   ROLE_BASED_USER            = 0,
   AV_BURSTCOUNT_W       = 3,
   ID                    = 1,
   SUPPRESS_0_BYTEEN_RSP = 1,
   BURSTWRAP_VALUE       = 4,
   CACHE_VALUE           = 0,
   SECURE_ACCESS_BIT     = 1,
   USE_READRESPONSE      = 0,
   USE_WRITERESPONSE     = 0,
   DOMAIN_VALUE          = 3,    
   BARRIER_VALUE         = 2,    
   SNOOP_VALUE           = 0,    
   WUNIQUE_VALUE         = 0,   
   USE_PKT_DATACHK       = 1,    
   USE_PKT_ADDRCHK       = 0,       
  
   PKT_BURSTWRAP_W   = PKT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1,
   PKT_BYTE_CNT_W    = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1,
   PKT_PROTECTION_W  = PKT_PROTECTION_H - PKT_PROTECTION_L + 1,
   PKT_ADDR_W        = PKT_ADDR_H - PKT_ADDR_L + 1,
   PKT_DATA_W        = PKT_DATA_H - PKT_DATA_L + 1,
   PKT_BYTEEN_W      = PKT_BYTEEN_H - PKT_BYTEEN_L + 1,
   PKT_SRC_ID_W      = PKT_SRC_ID_H - PKT_SRC_ID_L + 1,
   PKT_DEST_ID_W     = PKT_DEST_ID_H - PKT_DEST_ID_L + 1,
   PKT_BURST_SIZE_W  = PKT_BURST_SIZE_H - PKT_BURST_SIZE_L + 1,
   ADDRCHK_WIDTH     = (USE_PKT_ADDRCHK)? PKT_ADDRCHK_H - PKT_ADDRCHK_L + 1: 1,
   PADDING_ZERO      = (USE_PKT_ADDRCHK)? ((ADDRCHK_WIDTH*8) - PKT_ADDR_W) : 1,
   PARITY_ADDR_WIDTH =  PADDING_ZERO + PKT_ADDR_W,
   PKT_DATACHK_W     = (USE_PKT_DATACHK)? PKT_DATACHK_H - PKT_DATACHK_L + 1: 1  
) (
   input                         clk,
   input                         reset,

   input [PKT_ADDR_W-1 : 0]      av_address,
   input                         av_write,
   input                         av_read,
   input [PKT_DATA_W-1 : 0]      av_writedata,
   output reg [PKT_DATA_W-1 : 0] av_readdata,
   output wire                   av_waitrequest,
   output reg                    av_readdatavalid,
   input [PKT_BYTEEN_W-1 : 0]    av_byteenable,
   input [AV_BURSTCOUNT_W-1 : 0] av_burstcount,
   input                         av_debugaccess,
   input                         av_lock,
   output reg [1 : 0]            av_response,
   output reg                    av_writeresponsevalid,

   output reg                    cp_valid,
   output reg [ST_DATA_W-1 : 0]  cp_data,
   output wire                   cp_startofpacket,
   output wire                   cp_endofpacket,
   input                         cp_ready,

   input                         rp_valid,
   input [ST_DATA_W-1 : 0]       rp_data,
   input [ST_CHANNEL_W-1 : 0]    rp_channel,
   input                         rp_startofpacket,
   input                         rp_endofpacket,
   output reg                    rp_ready
);
   function integer clogb2;
      input [31 : 0] value;
      begin
         for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
            value = value >> 1;
         clogb2 = clogb2 - 1;
      end
   endfunction 

   function reg [PKT_DATACHK_W-1:0] calcParity (
       input [PKT_DATA_W-1:0] data
    );
       for (int i=0; i<PKT_DATACHK_W; i++)
           calcParity[i] = ~(^ data[i*8 +:8]);
   endfunction
   
    function reg [ADDRCHK_WIDTH-1:0] addrcalcParity (
        input [PARITY_ADDR_WIDTH-1:0] addr
     );
        for (int i=0; i<ADDRCHK_WIDTH; i++)
            addrcalcParity[i] = ~(^ addr[i*8 +:8]);
    endfunction  

   localparam MAX_BURST    = 1 << (AV_BURSTCOUNT_W - 1);
   localparam NUMSYMBOLS   = PKT_BYTEEN_W; 
   localparam BURSTING     = (MAX_BURST > NUMSYMBOLS);
   localparam BITS_TO_ZERO = clogb2(NUMSYMBOLS);
   localparam BURST_SIZE   = clogb2(NUMSYMBOLS);

   typedef enum bit  [1 : 0]
   {
      FIXED       = 2'b00,
      INCR        = 2'b01,
      WRAP        = 2'b10,
      OTHER_WRAP  = 2'b11
   } MerlinBurstType;

   wire is_burst;
   assign is_burst = (BURSTING) & (av_burstcount > NUMSYMBOLS);

   wire [31 : 0] burstwrap_value_int = BURSTWRAP_VALUE;
   wire [31 : 0] id_int              = ID; 
   wire [PKT_BURST_SIZE_W-1 : 0] burstsize_sig = BURST_SIZE[PKT_BURST_SIZE_W-1 : 0];
   wire [1 : 0] bursttype_value = burstwrap_value_int[PKT_BURSTWRAP_W-1] ? INCR : WRAP;

   wire [PKT_ADDR_W-1 : 0] av_address_aligned;
   generate 
      if (NUMSYMBOLS > 1) begin
         assign av_address_aligned = 
         {av_address[PKT_ADDR_W-1 : BITS_TO_ZERO], {BITS_TO_ZERO {1'b0}}};
      end
      else begin
         assign av_address_aligned = av_address;
      end 
   endgenerate

   wire [PKT_DATACHK_W-1:0] datachk_wire;
   generate
   if (USE_PKT_DATACHK) begin
      assign   datachk_wire = calcParity(av_writedata);
   end
   else begin
      assign   datachk_wire = '0;
   end
   endgenerate
   
   wire [ADDRCHK_WIDTH-1:0] addrchk_wire;
   generate
   if (USE_PKT_ADDRCHK) begin
      assign   addrchk_wire = addrcalcParity(av_address);
   end
   else begin
      assign   addrchk_wire = '0;
   end
   endgenerate   

   always_comb begin
      cp_data                                              = '0;

      cp_data[PKT_PROTECTION_L]                            = av_debugaccess;    
      cp_data[PKT_PROTECTION_L+1]                          = SECURE_ACCESS_BIT[0];  
      cp_data[PKT_PROTECTION_L+2]                          = 1'b0;                  
      cp_data[PKT_BURSTWRAP_H : PKT_BURSTWRAP_L]           = burstwrap_value_int[PKT_BURSTWRAP_W-1 : 0];
      cp_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L]             = av_burstcount;
      cp_data[PKT_ADDR_H : PKT_ADDR_L]                     = av_address_aligned;
      cp_data[PKT_TRANS_EXCLUSIVE]                         = 1'b0;
      cp_data[PKT_TRANS_LOCK]                              = av_lock;
      cp_data[PKT_TRANS_COMPRESSED_READ]                   = av_read & is_burst;
      cp_data[PKT_TRANS_READ]                              = av_read;
      cp_data[PKT_TRANS_WRITE]                             = av_write;
      cp_data[PKT_TRANS_POSTED]                            = av_write & !USE_WRITERESPONSE;
      cp_data[PKT_DATA_H : PKT_DATA_L]                     = av_writedata;
      cp_data[PKT_BYTEEN_H : PKT_BYTEEN_L]                 = av_byteenable;
      cp_data[PKT_BURST_SIZE_H : PKT_BURST_SIZE_L]         = burstsize_sig;
      cp_data[PKT_ORI_BURST_SIZE_H : PKT_ORI_BURST_SIZE_L] = burstsize_sig;
      cp_data[PKT_BURST_TYPE_H : PKT_BURST_TYPE_L]         = bursttype_value;
      cp_data[PKT_SRC_ID_H : PKT_SRC_ID_L]                 = id_int[PKT_SRC_ID_W-1 : 0];
      cp_data[PKT_THREAD_ID_H : PKT_THREAD_ID_L]           = '0;
      cp_data[PKT_CACHE_H : PKT_CACHE_L]                   = CACHE_VALUE[3 : 0];
      cp_data[PKT_QOS_H : PKT_QOS_L]                       = '0;        
      cp_data[PKT_ADDR_SIDEBAND_H : PKT_ADDR_SIDEBAND_L]   = '0;
      cp_data[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L]   = '0;
      cp_data[PKT_DOMAIN_H : PKT_DOMAIN_L]                 = DOMAIN_VALUE[1:0];
      cp_data[PKT_BARRIER_H : PKT_BARRIER_L]               = BARRIER_VALUE[1:0];
      cp_data[PKT_SNOOP_H : PKT_SNOOP_L]                   = SNOOP_VALUE[3:0];
      cp_data[PKT_WUNIQUE]                                 = WUNIQUE_VALUE[0];

      if( ROLE_BASED_USER) begin
      cp_data[PKT_POISON_H:PKT_POISON_L]                   = '0;
      cp_data[PKT_DATACHK_H:PKT_DATACHK_L]                 = datachk_wire;
      cp_data[PKT_ADDRCHK_H:PKT_ADDRCHK_L]                 = addrchk_wire;
      cp_data[PKT_SAI_H : PKT_SAI_L]                       = '0;
      end

      av_readdata                                          = rp_data[PKT_DATA_H : PKT_DATA_L];
      if (USE_WRITERESPONSE || USE_READRESPONSE)
         av_response = rp_data[PKT_RESPONSE_STATUS_H : PKT_RESPONSE_STATUS_L];
      else
         av_response = '0;
      end

   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate

   reg hold_waitrequest;

   generate
   if (SYNC_RESET == 0) begin: async_reg0
      always @ (posedge clk, posedge reset) begin
         if (reset)
            hold_waitrequest <= 1'b1;
         else
            hold_waitrequest <= 1'b0;
      end 
   end 

   else begin 
      always @ (posedge clk) begin
         if (internal_sclr)
            hold_waitrequest <= 1'b1;
         else
            hold_waitrequest <= 1'b0;
      end 
   end  
   endgenerate
 
   always_comb begin
      cp_valid = 0;
         if ((av_write || av_read) && ~hold_waitrequest)
            cp_valid = 1;
   end

   generate if (BURSTING) begin
      reg sop_enable;

      if (SYNC_RESET == 0) begin :async_reg1
         always @(posedge clk, posedge reset) begin
            if (reset) begin
               sop_enable <= 1'b1;
            end
            else begin
               if (cp_valid && cp_ready) begin
                  sop_enable <= 1'b0;
                  if (cp_endofpacket)
                     sop_enable <= 1'b1;
               end
            end
         end
      end 

      else begin 
         always @(posedge clk) begin
            if (internal_sclr) begin
               sop_enable <= 1'b1;
            end
            else begin
               if (cp_valid && cp_ready) begin
                  sop_enable <= 1'b0;
                  if (cp_endofpacket)
                     sop_enable <= 1'b1;
               end
            end
         end
      end 

      assign cp_startofpacket = sop_enable;
      assign cp_endofpacket   = (av_read) | (av_burstcount == NUMSYMBOLS);

   end 
   else begin

      assign cp_startofpacket = 1'b1;
      assign cp_endofpacket   = 1'b1;

   end
   endgenerate

   generate 
      if(SYNC_RESET == 0) begin
         assign av_waitrequest = (hold_waitrequest) | !cp_ready;
      end
      else begin
         assign av_waitrequest = internal_sclr | !cp_ready;
      end
   endgenerate
   always_comb begin
      rp_ready              = 1;
      av_readdatavalid      = 0;
      av_writeresponsevalid = 0;

      if (USE_WRITERESPONSE && (rp_data[PKT_TRANS_WRITE] == 1))
         av_writeresponsevalid = rp_valid;
      else
         av_readdatavalid      = rp_valid;

      if (SUPPRESS_0_BYTEEN_RSP) begin
         if (rp_data[PKT_BYTEEN_H : PKT_BYTEEN_L] == 0)
            av_readdatavalid = 0;
      end
   end

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9sn/lWDLNpD8oylX2jE7Zkco9/pztyvwVKxLu4MEu01OmRTU7lV2AIHakxijYOzMjE78gsWneeIj/0EXgJdeaJdCDBKI8dqBwwBUAiyb/DdZsUStKVPcD4Bca2CV2yTqbqxPeADIx4CmCquVcHAUDqYj+pBTG40ocP524wEXrnVXW8m68NFhxNGBW0XZF4MF2LmDSBrocbAQHPoy28on8HIYptg0pMpjRwgyzp1DENx0ht62K9uzK2nRDhp4FGTat5kA729pduNA/Qh31pq66Xr8QVzm9GW3aQr1Vxp6KkoUCVJGuSeC22Pe++e2kGGJ/Q7vzcmMlhRRxiI8mat5RY0SJ155xZY9+NZUW7UxMUEVJCCr7Ei+tTEoQzcJM43TlNazbaEB4N7kp6IjStSAwWstJMHdPV5LMgIuodL3t3Jvqa7eEPdzdj4h3AD1znRKP5xV2qiPKPbDC3hAetNOvBrGKOR6lfcavjA5RHIaGNr+58CI486ypWwtrFQ/TcXjlHVwxIPSS4yZGprmgDsJ/YCPxYWTpvl2OXt6tg5YN6aJTGVJVHXvGy5Ec9aU537xRkNyBHYRut9u1EovygInSJmf3T8QgVC7owM8BEE3FyEqm4OwOR0r22kbJfEhxZ7l0K9I5OMIt8+SvczmouKGg4Vw3W3+Z/fbUb3jpIXczO0QbupJu54816iKACnSteU+GSIculrt8fpaDPXu+v0Ih0mBYh29ACOBDPCruDkGuCi4HGtQub+KIUP5CgHGk1PXQL0DGwWGykUXgnE/2G7e0Q"
`endif