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




`timescale 1ns / 1ns


// altera message_off 13469
module ed_synth_dut_altera_merlin_axi_slave_ni_1971_cwyib4q
#(


    parameter PKT_ORI_BURST_SIZE_H        = 120,
    parameter PKT_ORI_BURST_SIZE_L        = 118,
    parameter PKT_QOS_H                   = 117,
    parameter PKT_QOS_L                   = 114,
    parameter PKT_THREAD_ID_H             = 113,
    parameter PKT_THREAD_ID_L             = 112,
    parameter PKT_RESPONSE_STATUS_H       = 111, 
    parameter PKT_RESPONSE_STATUS_L       = 110,
    parameter PKT_BEGIN_BURST             = 109,
    parameter PKT_CACHE_H                 = 108,
    parameter PKT_CACHE_L                 = 105,
    parameter PKT_DATA_SIDEBAND_H         = 104,
    parameter PKT_DATA_SIDEBAND_L         = 97,
    parameter PKT_ADDR_SIDEBAND_H         = 96, 
    parameter PKT_ADDR_SIDEBAND_L         = 92,
    parameter PKT_BURST_TYPE_H            = 91,
    parameter PKT_BURST_TYPE_L            = 90,
    parameter PKT_PROTECTION_H            = 89, 
    parameter PKT_PROTECTION_L            = 87,
    parameter PKT_BURST_SIZE_H            = 86,
    parameter PKT_BURST_SIZE_L            = 84,
    parameter PKT_BURSTWRAP_H             = 83,
    parameter PKT_BURSTWRAP_L             = 81,
    parameter PKT_BYTE_CNT_H              = 80,
    parameter PKT_BYTE_CNT_L              = 78,
    parameter PKT_ADDR_H                  = 77,
    parameter PKT_ADDR_L                  = 46,
    parameter PKT_TRANS_EXCLUSIVE         = 45,
    parameter PKT_TRANS_LOCK              = 44,
    parameter PKT_TRANS_COMPRESSED_READ   = 43,
    parameter PKT_TRANS_POSTED            = 42,
    parameter PKT_TRANS_WRITE             = 41,
    parameter PKT_TRANS_READ              = 40,
    parameter PKT_DATA_H                  = 39,
    parameter PKT_DATA_L                  = 8,
    parameter PKT_BYTEEN_H                = 7,
    parameter PKT_BYTEEN_L                = 4,
    parameter PKT_SRC_ID_H                = 3,
    parameter PKT_SRC_ID_L                = 2,
    parameter PKT_DEST_ID_H               = 1,
    parameter PKT_DEST_ID_L               = 0,

    parameter PKT_DOMAIN_L                = 121,
    parameter PKT_DOMAIN_H                = 122, 
    parameter PKT_SNOOP_L                 = 123, 
    parameter PKT_SNOOP_H                 = 126,
    parameter PKT_BARRIER_L               = 127, 
    parameter PKT_BARRIER_H               = 128,
    parameter PKT_WUNIQUE                 = 129,
    parameter PKT_EOP_OOO                 = 130,
    parameter PKT_SOP_OOO                 = 131,

    parameter PKT_POISON_L                = 131,
    parameter PKT_POISON_H                = 131,
    parameter PKT_DATACHK_L               = 132,
    parameter PKT_DATACHK_H               = 132,
    parameter PKT_ADDRCHK_L               = 133,
    parameter PKT_ADDRCHK_H               = 133,
    parameter PKT_SAI_L                   = 134,
    parameter PKT_SAI_H                   = 134,    

    parameter USE_MEMORY_BLOCKS           = 0,
    parameter EMPTY_LATENCY               = 1,
    parameter ST_DATA_W                   = 130,
    parameter ADDR_WIDTH                  = 32,
    parameter RDATA_WIDTH                 = 32,
    parameter WDATA_WIDTH                 = 32,
    parameter SAI_WIDTH                   = 4,
    parameter ADDRCHK_WIDTH               = 4,
    parameter ST_CHANNEL_W                = 1,
    parameter AXI_SLAVE_ID_W              = 4,  
    parameter ADDR_USER_WIDTH             = 5, 
    parameter WRITE_ACCEPTANCE_CAPABILITY = 16,
    parameter READ_ACCEPTANCE_CAPABILITY  = 16,
    parameter PASS_ID_TO_SLAVE            = 0,
    parameter AXI_VERSION                 = "AXI3",
    parameter ENABLE_OOO                  = 0,
    parameter REORDER_BUFFER              = 0,
    parameter ROLE_BASED_USER             = 0,        

    parameter ACE_LITE_SUPPORT            = 0,
    parameter SYNC_RESET                  = 0,
    parameter USE_PKT_DATACHK             = 1,    
    parameter USE_PKT_ADDRCHK             = 1,    
    parameter RESPONSE_W                  = PKT_RESPONSE_STATUS_H - PKT_RESPONSE_STATUS_L + 1,
    parameter AXI_WSTRB_W                 = PKT_BYTEEN_H - PKT_BYTEEN_L + 1,
    parameter PKT_DATA_W                  = PKT_DATA_H - PKT_DATA_L + 1,
    parameter NUMSYMBOLS                  = PKT_DATA_W / 8,

    parameter DATA_USER_WIDTH             = 8,
    parameter AXI_LOCK_WIDTH              = (AXI_VERSION == "AXI4") ? 1:2,
    parameter AXI_BURST_LENGTH_WIDTH      = (AXI_VERSION == "AXI4") ? 8:4,
    parameter  PKT_POISON_W               =  PKT_POISON_H - PKT_POISON_L + 1,   
    parameter  DATACHK_WIDTH              = PKT_DATA_W / 8,
    parameter  POISON_WIDTH               = (PKT_DATA_W + 64 -1) / 64, 
    parameter  PADDING_ZERO               = (ADDRCHK_WIDTH*8) - ADDR_WIDTH,
    parameter  PKT_SAI_W                  = PKT_SAI_H - PKT_SAI_L + 1,
    parameter  PARITY_ADDR_WIDTH          =  PADDING_ZERO + ADDR_WIDTH,
    parameter  SKIP_USER_ADDRCHK_CAL        =  (ADDRCHK_WIDTH == 1 && ADDR_WIDTH > 8)

)
(
    input aclk,
    input aresetn,

    output reg         [AXI_SLAVE_ID_W-1:0]     awid,
    output             [ADDR_WIDTH-1:0]         awaddr,
    output reg         [AXI_BURST_LENGTH_WIDTH-1:0] awlen, 
    output             [2:0]                    awsize,
    output             [1:0]                    awburst,
    output             [AXI_LOCK_WIDTH-1:0]     awlock,
    output             [3:0]                    awcache,
    output             [2:0]                    awprot,
    output             [3:0]                    awqos,
    output             [3:0]                    awregion,
    output                                      awvalid,
    output             [ADDR_USER_WIDTH-1:0]    awuser,
    input                                       awready,

    output reg         [AXI_SLAVE_ID_W-1:0]     wid,
    output             [PKT_DATA_W-1:0]         wdata,
    output             [AXI_WSTRB_W-1:0]        wstrb,
    output             [DATA_USER_WIDTH-1:0]    wuser,
    output                                      wlast,
    output                                      wvalid,
    input                                       wready,

    input             [AXI_SLAVE_ID_W-1:0]      bid,
    input             [1:0]                     bresp,
    input             [DATA_USER_WIDTH-1:0]     buser,
    input                                       bvalid,
    output                                      bready,

    output reg         [AXI_SLAVE_ID_W-1:0]     arid,
    output             [ADDR_WIDTH-1:0]         araddr,
    output             [AXI_BURST_LENGTH_WIDTH-1:0] arlen,
    output             [2:0]                    arsize,
    output             [1:0]                    arburst,
    output             [AXI_LOCK_WIDTH-1:0]     arlock,
    output             [3:0]                    arcache,
    output             [2:0]                    arprot,
    output             [3:0]                    arqos,
    output             [3:0]                    arregion,       
    output                                      arvalid,
    output             [ADDR_USER_WIDTH-1:0]    aruser,
    input                                       arready,

    input             [AXI_SLAVE_ID_W-1:0]      rid,
    input             [PKT_DATA_W-1:0]          rdata,
    input             [RESPONSE_W-1:0]          rresp,
    input             [DATA_USER_WIDTH-1:0]     ruser,
    input                                       rlast,
    input                                       rvalid,
    output                                      rready, 
    
    output [ADDRCHK_WIDTH-1:0]                  awuser_addrchk,
    output [SAI_WIDTH-1:0]                      awuser_sai,
    output [SAI_WIDTH-1:0]                      aruser_sai,
    output [ADDRCHK_WIDTH-1:0]                  aruser_addrchk,
    output [DATACHK_WIDTH-1:0]                  wuser_datachk,
    output [POISON_WIDTH-1:0]                   wuser_poison,
    input  [DATACHK_WIDTH-1:0]                  ruser_datachk,
    input  [POISON_WIDTH-1:0]                   ruser_poison,

    output [1:0]                                ardomain, 
    output [3:0]                                arsnoop, 
    output [1:0]                                arbar,
 
    output [1:0]                                awdomain, 
    output [2:0]                                awsnoop, 
    output [1:0]                                awbar, 
    output                                      awunique, 

    output                                      read_cp_ready,
    input                                       read_cp_valid,
    input             [ST_DATA_W-1:0]           read_cp_data,
    input             [ST_CHANNEL_W-1:0]        read_cp_channel,
    input                                       read_cp_startofpacket,
    input                                       read_cp_endofpacket,

    input                                       read_rp_ready,
    output                                      read_rp_valid,
    output reg         [ST_DATA_W-1:0]          read_rp_data,
    output                                      read_rp_startofpacket,
    output                                      read_rp_endofpacket,

    output reg                                  write_cp_ready,
    input                                       write_cp_valid,
    input             [ST_DATA_W-1:0]           write_cp_data,
    input             [ST_CHANNEL_W-1:0]        write_cp_channel,
    input                                       write_cp_startofpacket,
    input                                       write_cp_endofpacket,

    input                                       write_rp_ready,
    output                                      write_rp_valid,
    output reg         [ST_DATA_W-1:0]          write_rp_data,
    output reg                                  write_rp_startofpacket,
    output reg                                  write_rp_endofpacket
);

    
    localparam  MASTER_ID_W         = PKT_SRC_ID_H - PKT_SRC_ID_L + 1;
    localparam  SLAVE_ID_W          = PKT_DEST_ID_H - PKT_DEST_ID_L + 1;
    localparam  THREAD_ID_W         = PKT_THREAD_ID_H - PKT_THREAD_ID_L + 1;
    localparam  BURST_SIZE_W        = PKT_BURST_SIZE_H - PKT_BURST_SIZE_L + 1;
    localparam  BURST_TYPE_W        = 2;
    localparam  BYTECOUNT_W         = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1;
    localparam  BURSTWRAP_W         = PKT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1;
    localparam  PROTECTION_W        = PKT_PROTECTION_H - PKT_PROTECTION_L + 1;
    localparam  CACHE_W             = PKT_CACHE_H - PKT_CACHE_L + 1;
    localparam  BYTEEN_W            = PKT_BYTEEN_H - PKT_BYTEEN_L + 1;
    localparam  USER_W              = PKT_ADDR_SIDEBAND_H - PKT_ADDR_SIDEBAND_L + 1;
    localparam  DOMAIN_VALUE        = 3;    
    localparam  BARRIER_VALUE       = 2;    
    localparam  SNOOP_VALUE         = 0;    
    localparam  WUNIQUE_VALUE       = 0;   
    localparam  MATCH_ID_W          = (((PKT_DEST_ID_H - PKT_DEST_ID_L + 1) + (PKT_THREAD_ID_H - PKT_THREAD_ID_L + 1)) - AXI_SLAVE_ID_W );
    localparam  INTERNAL_ID_W       = ((MASTER_ID_W + THREAD_ID_W) > AXI_SLAVE_ID_W ? (MASTER_ID_W + THREAD_ID_W ): AXI_SLAVE_ID_W );
    localparam  PKT_DATACHK_W       = (USE_PKT_DATACHK)? PKT_DATACHK_H - PKT_DATACHK_L + 1: 1;
    localparam META_DATA_W          = ST_DATA_W - AXI_SLAVE_ID_W ;
    localparam ST_PIPELINE_DATA_W   = DATA_USER_WIDTH + AXI_SLAVE_ID_W + RESPONSE_W + PKT_DATA_W + 1;

    function integer log2ceil;
        input reg[63:0] val;
        reg [63:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
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
    wire [PKT_DATA_W-1:0]     write_cmd_data;
    wire [AXI_WSTRB_W-1:0]    write_cmd_byteen;
    reg  [ADDR_WIDTH-1:0]     write_cmd_addr;
    reg  [BYTECOUNT_W-1:0]    write_cmd_bytecount;
    wire [MASTER_ID_W-1:0]    write_cmd_mid;
    wire [THREAD_ID_W-1:0]    write_cmd_threadid;
    wire [1:0]                write_cmd_lock;
    reg  [BURST_TYPE_W-1:0]   write_cmd_bursttype;
    wire [BURST_SIZE_W-1:0]   write_cmd_size;
    wire [PROTECTION_W-1:0]   write_cmd_protection;
    wire [CACHE_W-1:0]        write_cmd_cache;
    wire [USER_W-1:0]         write_cmd_user;
    wire [ADDRCHK_WIDTH-1:0]  write_cmd_awuser_addrchk;
    wire [DATACHK_WIDTH-1:0]  write_cmd_wuser_datachk;
    wire [POISON_WIDTH-1:0]   write_cmd_wuser_poison;
    wire [SAI_WIDTH-1:0]      write_cmd_awuser_sai;

  
    reg                       internal_write_cp_endofburst;
    reg                       internal_read_cp_startofburst;
    reg                       internal_read_cp_endofburst;  
  
    wire [ADDR_WIDTH-1:0]     read_cmd_addr;
    wire [ADDR_WIDTH-1:0]     read_cmd_addr_aligned;
    wire [BURST_SIZE_W-1:0]   read_cmd_size;
    reg  [BYTECOUNT_W-1:0]    read_cmd_bytecount;
    wire [MASTER_ID_W-1:0]    read_cmd_mid;
    wire [THREAD_ID_W-1:0]    read_cmd_threadid;
    wire [1:0]                read_cmd_lock;
    wire [PROTECTION_W-1:0]   read_cmd_protection;
    wire [CACHE_W-1:0]        read_cmd_cache;
    reg  [BURST_TYPE_W-1:0]   read_cmd_bursttype;
    wire [USER_W-1:0]         read_cmd_user;
    wire                      read_cmd_compressed;
    wire [ADDRCHK_WIDTH-1:0]  read_cmd_aruser_addrchk;
    wire [SAI_WIDTH-1:0]      read_cmd_aruser_sai;        

    wire [3:0]                read_cmd_snoop;
    wire [1:0]                read_cmd_domain;
    wire [1:0]                read_cmd_bar;

    wire [2:0]                write_cmd_snoop;
    wire [1:0]                write_cmd_domain;
    wire [1:0]                write_cmd_bar;
    wire                      write_cmd_unique;
  
    wire                      awvalid_suppress; 
    wire                      wvalid_suppress;
  
    wire [ST_DATA_W:0]        write_rsp_fifo_indata; 
    wire [ST_DATA_W:0]        write_rsp_fifo_outdata;
    wire                      write_rsp_fifo_invalid;
    wire                      write_rsp_fifo_inready;
    wire                      write_rsp_fifo_outvalid;
    wire                      write_rsp_fifo_outready;
    wire [ST_DATA_W:0]        read_rsp_fifo_indata;  
    wire [ST_DATA_W:0]        read_rsp_fifo_outdata;
    wire                      read_rsp_fifo_invalid;
    wire                      read_rsp_fifo_inready;
    wire                      read_rsp_fifo_outvalid;
    wire                      read_rsp_fifo_outready;  
    wire                      write_rsp_fifo_posted;
  
  
    wire areset = ~aresetn;  
  
    reg                       read_sop_enable;
    reg                       address_taken;
    reg                       data_taken;
    reg  [BYTECOUNT_W-1:0]    minimum_bytecount;
    wire [31:0]               awlen_wire;  
    wire [31:0]               arlen_wire;  
    reg                       write_rsp_fifo_sop; 
    wire                      write_rsp_fifo_eop;
    reg [RESPONSE_W-1:0]      bresp_merged;  
    reg [RESPONSE_W-1:0]      previous_response_in;
    reg                       reset_merged_output; 
    wire                      rvalid_uncompressor;
 
    reg [INTERNAL_ID_W -1 :0 ] awid_internal;  
    reg [INTERNAL_ID_W -1 :0 ] wid_internal ;  
    reg [INTERNAL_ID_W -1 :0 ] arid_internal;  
 
    wire [(SLAVE_ID_W + THREAD_ID_W -1):0] write_rp_data_bid_internal; 
    wire [(SLAVE_ID_W + THREAD_ID_W -1):0] read_rp_data_rid_internal ;
 
    wire [META_DATA_W -1 :0] meta_read_data_resp_mem_in;
    wire [ST_DATA_W : 0]     read_rsp_mem_indata;
    wire [META_DATA_W -1 :0] meta_write_data_resp_mem_in;
    wire [ST_DATA_W : 0]     write_rsp_mem_indata;
    
    wire [ST_PIPELINE_DATA_W-1:0]p1_data_in;
    wire p1_valid_in,p1_bvalid_in;
    wire p1_ready_in,p1_bready_in;
    wire [ST_PIPELINE_DATA_W-1:0]p1_data_out;
    wire p1_valid_out,p1_bvalid_out;
    wire p1_ready_out,p1_bready_out;
    wire [DATA_USER_WIDTH + AXI_SLAVE_ID_W + 1 : 0] p1_bdata_in,p1_bdata_out;
    
    wire [PKT_DATA_W-1:0]p1_rdata;
    wire [RESPONSE_W-1:0] p1_rresp,p1_bresp;
    wire [DATA_USER_WIDTH-1:0]p1_ruser,p1_buser;
    wire [AXI_SLAVE_ID_W-1:0]p1_rid,p1_bid;
    wire [AXI_SLAVE_ID_W-1:0]rid_resp_mem,bid_resp_mem;    
    wire p1_rlast;
    wire rvalid_resp_mem,bvalid_resp_mem;

    wire read_rp_ready_temp,write_rp_ready_temp;
    wire read_rp_valid_temp,write_rp_valid_temp;
    reg [ST_DATA_W-1:0] read_rp_data_temp,write_rp_data_temp;
    wire read_rp_startofpacket_temp,write_rp_startofpacket_temp;
    wire read_rp_endofpacket_temp,write_rp_endofpacket_temp;

    typedef enum bit [1:0] 
    {
      FIXED       = 2'b00,
      INCR        = 2'b01,
      WRAP        = 2'b10,
      RESERVED    = 2'b11
    } AxiBurstType;


   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge aclk) begin
         internal_sclr <= areset;
      end
   end
   endgenerate
   


    assign write_cmd_data        = write_cp_data[PKT_DATA_H : PKT_DATA_L];
    assign write_cmd_byteen      = write_cp_data[PKT_BYTEEN_H : PKT_BYTEEN_L];
    assign write_cmd_mid         = write_cp_data[PKT_SRC_ID_H : PKT_SRC_ID_L];
    assign write_cmd_size        = write_cp_data[PKT_BURST_SIZE_H : PKT_BURST_SIZE_L];
    assign write_cmd_lock        = { 1'b0, write_cp_data[PKT_TRANS_EXCLUSIVE] };
    assign write_cmd_addr        = write_cp_data[PKT_ADDR_H : PKT_ADDR_L];
    assign write_cmd_bytecount   = write_cp_data[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L]; 
    assign write_cmd_threadid    = write_cp_data[PKT_THREAD_ID_H : PKT_THREAD_ID_L];
    assign write_cmd_protection  = write_cp_data[PKT_PROTECTION_H : PKT_PROTECTION_L];
    assign write_cmd_bursttype   = write_cp_data[PKT_BURST_TYPE_H : PKT_BURST_TYPE_L];
    assign write_cmd_user        = write_cp_data[PKT_ADDR_SIDEBAND_H : PKT_ADDR_SIDEBAND_L];
    assign awlen_wire            = (write_cmd_bytecount >> log2ceil(PKT_DATA_W / 8)) - 1;
    generate 
    if (ROLE_BASED_USER) begin
        if(POISON_WIDTH == PKT_POISON_W)
            assign write_cmd_wuser_poison          = write_cp_data[PKT_POISON_H : PKT_POISON_L ];
        else
            assign write_cmd_wuser_poison          = {{(POISON_WIDTH - PKT_POISON_W){1'b0}} , write_cp_data[PKT_POISON_H : PKT_POISON_L ]};
            
        if(SAI_WIDTH == PKT_SAI_W)
            assign write_cmd_awuser_sai           = write_cp_data [PKT_SAI_H : PKT_SAI_L];
        else
            assign write_cmd_awuser_sai           = {{(SAI_WIDTH - PKT_SAI_W){1'b0}}, write_cp_data[PKT_SAI_H:PKT_SAI_L ]};
            
        if(USE_PKT_ADDRCHK)
            assign write_cmd_awuser_addrchk = write_cp_data[PKT_ADDRCHK_H:PKT_ADDRCHK_L];
        else begin
            if(SKIP_USER_ADDRCHK_CAL) begin
                 assign write_cmd_awuser_addrchk = 1'b0;
            end 
            else begin
                 assign write_cmd_awuser_addrchk = addrcalcParity({{PADDING_ZERO{1'b0}},write_cmd_addr});
            end
        end
        
        if(USE_PKT_DATACHK)
            assign write_cmd_wuser_datachk = write_cp_data[PKT_DATACHK_H : PKT_DATACHK_L]; 
        else
            assign write_cmd_wuser_datachk = calcParity(write_cmd_data);
        
        
    end
    endgenerate

       assign write_cmd_domain         = write_cp_data[PKT_DOMAIN_H : PKT_DOMAIN_L];
       assign write_cmd_snoop          = write_cp_data[PKT_SNOOP_H-1 : PKT_SNOOP_L];   
       assign write_cmd_bar            = write_cp_data[PKT_BARRIER_H : PKT_BARRIER_L];
       assign write_cmd_unique         = write_cp_data[PKT_WUNIQUE];
       assign write_cmd_cache          = write_cp_data[PKT_CACHE_H : PKT_CACHE_L];
    

    always @* begin
        awid_internal       = {INTERNAL_ID_W{1'b0}};
        awid_internal       = PASS_ID_TO_SLAVE ? {write_cmd_mid, write_cmd_threadid} : {INTERNAL_ID_W{1'b0}} ;
    end
    assign awaddr        = write_cmd_addr;
    assign awlen         = awlen_wire[AXI_BURST_LENGTH_WIDTH-1:0];
    assign awsize        = write_cmd_size[2:0];
    assign awcache       = write_cmd_cache;
    assign awprot        = write_cmd_protection;
    assign awlock        = write_cmd_lock[AXI_LOCK_WIDTH-1:0];
    assign awuser        = write_cmd_user;
    assign awburst       = write_cmd_bursttype;
    generate 
      if (ENABLE_OOO == 0) begin
         assign awid          = awid_internal[AXI_SLAVE_ID_W -1 :0];
      end
    endgenerate      
    
    generate 
      if (ROLE_BASED_USER) begin
         assign awuser_addrchk = write_cmd_awuser_addrchk;
         assign awuser_sai     = write_cmd_awuser_sai;
      end
    endgenerate

    always @* begin
        wid_internal        = {INTERNAL_ID_W{1'b0}};
        wid_internal        = PASS_ID_TO_SLAVE ? {write_cmd_mid, write_cmd_threadid} : {INTERNAL_ID_W{1'b0}};
    end   
    assign wdata         = write_cmd_data;
    assign wstrb         = write_cmd_byteen;
    assign wlast         = internal_write_cp_endofburst;
    assign wid           = wid_internal[AXI_SLAVE_ID_W -1 :0];
    generate 
      if (ROLE_BASED_USER) begin
        assign wuser_datachk = write_cmd_wuser_datachk;
        assign wuser_poison  = write_cmd_wuser_poison;
      end
    endgenerate

    generate
        if (AXI_VERSION == "AXI4") begin
            wire [DATA_USER_WIDTH-1:0] write_cmd_wuser;
            wire [3:0]                 write_cmd_qos;
            assign write_cmd_wuser       = write_cp_data[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L];
            assign write_cmd_qos         = write_cp_data[PKT_QOS_H : PKT_QOS_L];
            assign wuser         = write_cmd_wuser;
            assign awqos         = write_cmd_qos;
            assign awregion      = 4'b0;
        end else begin
            assign wuser         = '0;
            assign awqos         = '0;
            assign awregion      = '0;   
        end
    endgenerate

    reg [RESPONSE_W-1:0]  previous_response;


    function reg [1:0] merged_response;
        input [3:0] previous_and_current_responses;
 
        begin
            case (previous_and_current_responses)
   
                4'b1101: merged_response = 2'b11;
                4'b1100: merged_response = 2'b11;
                4'b1111: merged_response = 2'b11;
                4'b1110: merged_response = 2'b11;

                4'b1001: merged_response = 2'b10;
                4'b1000: merged_response = 2'b10;
                4'b1011: merged_response = 2'b11;
                4'b1010: merged_response = 2'b10; 
   
                4'b0001: merged_response = 2'b00;
                4'b0000: merged_response = 2'b00;
                4'b0011: merged_response = 2'b11;
                4'b0010: merged_response = 2'b10;
   
                4'b0101: merged_response = 2'b01;
                4'b0100: merged_response = 2'b00;
                4'b0111: merged_response = 2'b11;
                4'b0110: merged_response = 2'b10;
   
                default: merged_response = 2'b01;
            endcase
        end
    endfunction   

    generate
    if (SYNC_RESET == 0) begin : async_rst0
       always_ff @(posedge aclk, negedge aresetn) begin
           if (!aresetn) begin
               write_rsp_fifo_sop  <= 1'b1;
           end 
           else begin
               if (write_rsp_fifo_outready) begin
                   write_rsp_fifo_sop <= 1'b0;
                   if (write_rsp_fifo_eop)
                       write_rsp_fifo_sop <= 1'b1;
               end
           end
       end
    end 

    else begin : sync_rst0
       always_ff @(posedge aclk) begin
           if (internal_sclr) begin
               write_rsp_fifo_sop  <= 1'b1;
           end 
           else begin
               if (write_rsp_fifo_outready) begin
                   write_rsp_fifo_sop <= 1'b0;
                   if (write_rsp_fifo_eop)
                       write_rsp_fifo_sop <= 1'b1;
               end
           end
       end
    end 
    endgenerate

    always_comb begin
        reset_merged_output = write_rsp_fifo_sop && bvalid_resp_mem;
        previous_response_in = reset_merged_output ? p1_bresp : previous_response;
        bresp_merged = merged_response( {previous_response_in, p1_bresp} );
    end

    generate
    if (SYNC_RESET == 0) begin : async_rst1 
       always_ff @(posedge aclk or negedge aresetn) begin
           if (!aresetn) begin 
               previous_response <= 2'b01;
           end
           else begin
               if (bvalid) begin
                   previous_response <= bresp_merged;
               end
           end
       end
    end 
   
    else begin : sync_rst1
       always_ff @(posedge aclk ) begin
           if (internal_sclr) begin 
               previous_response <= 2'b01;
           end
           else begin
               if (bvalid) begin
                   previous_response <= bresp_merged;
               end
           end
       end
    end 
    endgenerate
    generate
      if(ENABLE_OOO == 0)begin
        assign write_rsp_fifo_indata = {write_cp_endofpacket, write_cp_data};
      end
    endgenerate  
        generate
           if (( SLAVE_ID_W + THREAD_ID_W ) > AXI_SLAVE_ID_W ) begin    
                  assign write_rp_data_bid_internal  = {{MATCH_ID_W{1'b0}}, p1_bid};
           end else begin
                  assign write_rp_data_bid_internal  = p1_bid;
           end
   endgenerate 

    always_comb
    begin
        write_rp_data_temp = write_rsp_fifo_outdata[ST_DATA_W-1:0];
        write_rp_data_temp[PKT_DEST_ID_H:PKT_DEST_ID_L]                         = write_rsp_fifo_outdata[PKT_SRC_ID_H:PKT_SRC_ID_L];
        write_rp_data_temp[PKT_SRC_ID_H:PKT_SRC_ID_L]                           = write_rsp_fifo_outdata[PKT_DEST_ID_H:PKT_DEST_ID_L];
        write_rp_data_temp[PKT_ORI_BURST_SIZE_H:PKT_ORI_BURST_SIZE_L]           = write_rsp_fifo_outdata[PKT_ORI_BURST_SIZE_H:PKT_ORI_BURST_SIZE_L];
       if (PASS_ID_TO_SLAVE) begin
            { write_rp_data_temp[PKT_DEST_ID_H:PKT_DEST_ID_L], write_rp_data_temp[PKT_THREAD_ID_H:PKT_THREAD_ID_L] }  = write_rp_data_bid_internal;
        end
 
        if (AXI_VERSION == "AXI4") begin
            write_rp_data_temp[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L]           = p1_buser;
        end
        else begin
            write_rp_data_temp[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L]           = '0;
        end   
        write_rp_data_temp[PKT_RESPONSE_STATUS_H:PKT_RESPONSE_STATUS_L] = bresp_merged;
    end


    assign write_rsp_fifo_eop     = write_rsp_fifo_outdata[ST_DATA_W];
    assign write_rp_startofpacket_temp = 1'b1;
    assign write_rp_endofpacket_temp   = 1'b1;
    



    wire [31:0] minimum_bytecount_wire = PKT_DATA_W / 8; 
    assign minimum_bytecount = minimum_bytecount_wire[BYTECOUNT_W-1:0];

    assign internal_write_cp_endofburst = (write_cmd_bytecount == minimum_bytecount);

    assign  write_cp_ready = (awready && wready && write_rsp_fifo_inready) || (address_taken && wready) || (data_taken && awready);
    
    assign  awvalid = write_cp_valid && !address_taken && write_rsp_fifo_inready;  
    assign  wvalid  = write_cp_valid && !data_taken && write_rsp_fifo_inready;     

    generate
    if (SYNC_RESET == 0) begin : async_rst2

       always_ff @(posedge aclk or negedge aresetn) begin
           if (!aresetn) begin
               address_taken   <= '0;
           end
           else begin
               if (awvalid && awready)
                   address_taken   <= '1;
               if (write_cp_valid && write_cp_ready && internal_write_cp_endofburst) 
                   address_taken   <= '0;
           end        
       end
    end 

    else begin : sync_rst2

       always_ff @(posedge aclk ) begin
           if (internal_sclr) begin
               address_taken   <= '0;
           end
           else begin
               if (awvalid && awready)
                   address_taken   <= '1;
               if (write_cp_valid && write_cp_ready && internal_write_cp_endofburst) 
                   address_taken   <= '0;
           end        
       end
    end 
    endgenerate

    generate
    if (SYNC_RESET == 0) begin : async_rst3
       always_ff @(posedge aclk or negedge aresetn) begin
           if  (!aresetn) begin
               data_taken  <= '0;
           end
           else begin
               if (wvalid && wready)
                   data_taken  <= '1;
               if (write_cp_valid && write_cp_ready)
                   data_taken  <= '0;
           end
       end
    end 

    else begin : sync_rst3

       always_ff @(posedge aclk ) begin
           if  (internal_sclr) begin
               data_taken  <= '0;
           end
           else begin
               if (wvalid && wready)
                   data_taken  <= '1;
               if (write_cp_valid && write_cp_ready)
                   data_taken  <= '0;
           end
       end
    end 
    endgenerate
    assign write_rsp_fifo_posted  = write_rsp_fifo_outdata[PKT_TRANS_POSTED];
   generate
      if (USE_MEMORY_BLOCKS) begin : Using_M20k_with_2_clk_latency
          assign p1_bready_out                 = (write_rp_ready_temp && write_rsp_fifo_outvalid) || (bvalid_resp_mem && write_rsp_fifo_posted && write_rsp_fifo_outvalid) ||  bvalid_resp_mem && write_rsp_fifo_outvalid && !write_rsp_fifo_posted && !write_rsp_fifo_eop;  
      end else begin : Using_ALM_memory_with_1_clk_latency
          assign p1_bready_out                 = write_rp_ready_temp || (bvalid_resp_mem && write_rsp_fifo_posted) ||  bvalid_resp_mem && write_rsp_fifo_outvalid && !write_rsp_fifo_posted && !write_rsp_fifo_eop;  
      end
   endgenerate

    assign write_rp_valid_temp         = bvalid_resp_mem && write_rsp_fifo_outvalid && !write_rsp_fifo_posted && write_rsp_fifo_eop;

    assign write_rsp_fifo_invalid  = write_cp_ready && write_cp_valid && internal_write_cp_endofburst;

    assign write_rsp_fifo_outready = bvalid_resp_mem && p1_bready_out;

    

    assign read_cmd_addr            = read_cp_data[PKT_ADDR_H : PKT_ADDR_L ];
    assign read_cmd_mid             = read_cp_data[PKT_SRC_ID_H :PKT_SRC_ID_L];
    assign read_cmd_bytecount       = read_cp_data[PKT_BYTE_CNT_H :PKT_BYTE_CNT_L];    
    assign read_cmd_size            = read_cp_data[PKT_BURST_SIZE_H:PKT_BURST_SIZE_L];
    assign read_cmd_threadid        = read_cp_data[PKT_THREAD_ID_H:PKT_THREAD_ID_L];
    assign read_cmd_protection      = read_cp_data[PKT_PROTECTION_H:PKT_PROTECTION_L];
    assign read_cmd_bursttype       = read_cp_data[PKT_BURST_TYPE_H:PKT_BURST_TYPE_L];
    assign read_cmd_user            = read_cp_data[PKT_ADDR_SIDEBAND_H : PKT_ADDR_SIDEBAND_L];
    assign read_cmd_compressed      = read_cp_data[PKT_TRANS_COMPRESSED_READ];
    assign read_cmd_lock            = { 1'b0, read_cp_data[PKT_TRANS_EXCLUSIVE] };
    assign arlen_wire               = read_cmd_compressed ? (read_cmd_bytecount >> log2ceil(PKT_DATA_W / 8)) - 1 : '0;

    generate
      if(ROLE_BASED_USER) begin
        if(USE_PKT_ADDRCHK)
            assign read_cmd_aruser_addrchk = read_cp_data[PKT_ADDRCHK_H : PKT_ADDRCHK_L];
        else begin
            if(SKIP_USER_ADDRCHK_CAL) begin
                assign read_cmd_aruser_addrchk = 1'b0;    
            end
            else begin
                assign read_cmd_aruser_addrchk = addrcalcParity({{PADDING_ZERO{1'b0}},read_cmd_addr});    
            end
        end
        if(SAI_WIDTH == PKT_SAI_W)
            assign read_cmd_aruser_sai           = read_cp_data [PKT_SAI_H : PKT_SAI_L];
        else
            assign read_cmd_aruser_sai           = {{(SAI_WIDTH - PKT_SAI_W){1'b0}}, read_cp_data[PKT_SAI_H:PKT_SAI_L ]};
      end else begin
            assign read_cmd_aruser_addrchk       = '0;
            assign read_cmd_aruser_sai           = '0;
      end
    endgenerate
       assign read_cmd_domain          = read_cp_data[PKT_DOMAIN_H : PKT_DOMAIN_L];    
       assign read_cmd_snoop           = read_cp_data[PKT_SNOOP_H : PKT_SNOOP_L];      
       assign read_cmd_bar             = read_cp_data[PKT_BARRIER_H : PKT_BARRIER_L];
       assign read_cmd_cache           = read_cp_data[PKT_CACHE_H:PKT_CACHE_L];

    always @* begin
        arid_internal        = {INTERNAL_ID_W{1'b0}};
        arid_internal        = PASS_ID_TO_SLAVE ? {read_cmd_mid, read_cmd_threadid} : {INTERNAL_ID_W{1'b0}};
    end   
    assign araddr       = read_cmd_addr;
    assign arlen        = arlen_wire[AXI_BURST_LENGTH_WIDTH-1:0];         
    assign arsize       = read_cmd_size[2:0];
    assign arlock       = read_cmd_lock[AXI_LOCK_WIDTH-1:0];
    assign arcache      = read_cmd_cache;
    assign arprot       = read_cmd_protection;
    assign aruser       = read_cmd_user;
    assign arburst      = read_cmd_bursttype;
    assign aruser_addrchk = read_cmd_aruser_addrchk;
    assign aruser_sai   = read_cmd_aruser_sai;

    assign ardomain     = read_cmd_domain;
    assign arsnoop      = read_cmd_snoop;
    assign arbar        = read_cmd_bar;

    assign awdomain     = write_cmd_domain;
    assign awsnoop      = write_cmd_snoop;
    assign awbar        = write_cmd_bar;
    assign awunique     = write_cmd_unique;
    generate
      if (ENABLE_OOO == 0) begin
          assign arid         = arid_internal[AXI_SLAVE_ID_W -1:0];
      end
    endgenerate

    generate
        if (AXI_VERSION == "AXI4") begin
            wire [3:0]  read_cmd_qos;
            assign read_cmd_qos = read_cp_data[PKT_QOS_H : PKT_QOS_L];
            assign arqos        = read_cmd_qos;
            assign arregion     = 4'b0;
        end
        else begin
            assign arqos        = '0;
            assign arregion     = '0;
        end
    endgenerate
    reg [ADDR_WIDTH + (BURSTWRAP_W-1) + BURST_SIZE_W + BURST_TYPE_W - 1:0]     address_for_alignment;
    reg [ADDR_WIDTH + log2ceil(NUMSYMBOLS)-1:0] address_after_aligned;

    assign address_for_alignment    = {read_cmd_addr, read_cmd_size};
    assign read_cmd_addr_aligned    = address_after_aligned[ADDR_WIDTH-1:0];
    
    altera_merlin_address_alignment
        #(
          .ADDR_W            (ADDR_WIDTH),
          .BURSTWRAP_W       (BURSTWRAP_W),
          .INCREMENT_ADDRESS (0),
          .NUMSYMBOLS        (NUMSYMBOLS),
          .SIZE_W            (BURST_SIZE_W),
          .SYNC_RESET        (SYNC_RESET)
          ) check_and_align_address_to_size
            (
             .clk(aclk),
             .reset(aresetn),
             .in_data(address_for_alignment),
             .out_data(address_after_aligned),
             .in_valid(),
             .in_sop(),
             .in_eop(),
             .out_ready()
             );
    reg [ST_DATA_W-1:0]           read_cp_data_for_fifo;
    always_comb
        begin
            read_cp_data_for_fifo                           = read_cp_data;
            read_cp_data_for_fifo[PKT_ADDR_H : PKT_ADDR_L ] = read_cmd_addr_aligned;
        end
    generate
      if (ENABLE_OOO == 0) begin
          assign read_rsp_fifo_indata = {read_cp_endofpacket, read_cp_data_for_fifo}; 
      end
    endgenerate
  

    wire                        uncompressor_outvalid;
    wire                        uncompressor_inready;
    wire                        read_rsp_fifo_outdata_eop;
    wire                        read_rsp_fifo_outdata_is_comp;
    reg                         read_rsp_fifo_outdata_sop;
    wire [BURSTWRAP_W-1 : 0]    read_rsp_fifo_outdata_burstwrap;
    wire [ADDR_WIDTH-1 : 0]     read_rsp_fifo_outdata_addr;
    wire [BYTECOUNT_W-1: 0]     read_rsp_fifo_outdata_bytecount;
    wire [BURST_SIZE_W-1 : 0]   read_rsp_fifo_outdata_burstsize;
    wire                        uncompressor_is_comp;
    wire [BURSTWRAP_W-1 : 0]    uncompressor_burstwrap;
    wire [ADDR_WIDTH-1 : 0]     uncompressor_addr;
    wire [BYTECOUNT_W-1: 0]     uncompressor_bytecount;   
    wire [BURST_SIZE_W-1:0]     uncompressor_burstsize;

    generate
        if (( SLAVE_ID_W + THREAD_ID_W ) > AXI_SLAVE_ID_W ) begin
              assign read_rp_data_rid_internal = {{MATCH_ID_W{1'b0}},p1_rid};
        end else begin
              assign read_rp_data_rid_internal       = p1_rid;
        end
    endgenerate

    always_comb
        begin
            read_rp_data_temp = read_rsp_fifo_outdata[ST_DATA_W-1:0];
            read_rp_data_temp[PKT_DATA_H : PKT_DATA_L]           = p1_rdata;
            read_rp_data_temp[PKT_ADDR_H : PKT_ADDR_L]           = uncompressor_addr;
            read_rp_data_temp[PKT_BYTE_CNT_H : PKT_BYTE_CNT_L]   = uncompressor_bytecount;
            read_rp_data_temp[PKT_TRANS_COMPRESSED_READ]         = uncompressor_is_comp;
            read_rp_data_temp[PKT_BURSTWRAP_H:PKT_BURSTWRAP_L]   = uncompressor_burstwrap;
            read_rp_data_temp[PKT_BURST_SIZE_H:PKT_BURST_SIZE_L] = uncompressor_burstsize;
            read_rp_data_temp[PKT_DEST_ID_H:PKT_DEST_ID_L]       = read_rsp_fifo_outdata[PKT_SRC_ID_H:PKT_SRC_ID_L];
            read_rp_data_temp[PKT_SRC_ID_H:PKT_SRC_ID_L]         = read_rsp_fifo_outdata[PKT_DEST_ID_H:PKT_DEST_ID_L];
            read_rp_data_temp[PKT_ORI_BURST_SIZE_H:PKT_ORI_BURST_SIZE_L] = read_rsp_fifo_outdata[PKT_ORI_BURST_SIZE_H:PKT_ORI_BURST_SIZE_L];
            read_rp_data_temp[PKT_RESPONSE_STATUS_H:PKT_RESPONSE_STATUS_L] = p1_rresp;

            if (PASS_ID_TO_SLAVE) begin
                { read_rp_data_temp[PKT_DEST_ID_H:PKT_DEST_ID_L], read_rp_data_temp[PKT_THREAD_ID_H:PKT_THREAD_ID_L] } = read_rp_data_rid_internal;
            end

            if (AXI_VERSION == "AXI4") begin
                read_rp_data_temp[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L]           = p1_ruser;
            end
            else begin
                read_rp_data_temp[PKT_DATA_SIDEBAND_H : PKT_DATA_SIDEBAND_L]           = '0;
            end
            
            if (ROLE_BASED_USER) begin
               read_rp_data_temp[PKT_POISON_H:PKT_POISON_L]                    = ruser_poison; 
               if(USE_PKT_DATACHK)
                   read_rp_data_temp[PKT_DATACHK_H:PKT_DATACHK_L]              = ruser_datachk;
               else             
                   read_rp_data_temp[PKT_DATACHK_H:PKT_DATACHK_L]              = '0;
            end
        end      


    generate 
    if (USE_MEMORY_BLOCKS) begin : Using_M20k_change1
    if (SYNC_RESET == 0) begin : async_rst4_m20k
       always_ff @ (posedge aclk or negedge aresetn)
       if  (!aresetn)
           read_rsp_fifo_outdata_sop <= 1'b1;
       else
       begin
           if (read_rp_ready_temp & rvalid_resp_mem & (!read_rp_endofpacket))
               read_rsp_fifo_outdata_sop <= 1'b0;
           if (read_rp_ready_temp & rvalid_resp_mem & read_rp_endofpacket)
               read_rsp_fifo_outdata_sop <= 1'b1;
       end   
    end 

    else begin : sync_rst4_m20k_ch
       always_ff @ (posedge aclk )
       if  (internal_sclr)
           read_rsp_fifo_outdata_sop <= 1'b1;
       else
       begin
           if (read_rp_ready_temp & rvalid_resp_mem & (!read_rp_endofpacket))
               read_rsp_fifo_outdata_sop <= 1'b0;
           if (read_rp_ready_temp & rvalid_resp_mem & read_rp_endofpacket)
               read_rsp_fifo_outdata_sop <= 1'b1;
       end 
    end 
    end else begin : Using_ALM_memory_change1
        if (SYNC_RESET == 0) begin : async_rst4
       always_ff @ (posedge aclk or negedge aresetn)
       if  (!aresetn)
           read_rsp_fifo_outdata_sop <= 1'b1;
       else
       begin
           if (read_rp_ready_temp & rvalid_resp_mem)
               read_rsp_fifo_outdata_sop <= 1'b0;
           if (read_rp_ready_temp & rvalid_resp_mem & read_rp_endofpacket)
               read_rsp_fifo_outdata_sop <= 1'b1;
       end   
    end 

    else begin : sync_rst4
       always_ff @ (posedge aclk )
       if  (internal_sclr)
           read_rsp_fifo_outdata_sop <= 1'b1;
       else
       begin
           if (read_rp_ready_temp & rvalid_resp_mem)
               read_rsp_fifo_outdata_sop <= 1'b0;
           if (read_rp_ready_temp & rvalid_resp_mem & read_rp_endofpacket)
               read_rsp_fifo_outdata_sop <= 1'b1;
       end 
    end 
    end
    endgenerate


    assign read_cp_ready    = arready && read_rsp_fifo_inready; 
   generate
      assign arvalid = read_cp_valid && read_rsp_fifo_inready; 
      if (USE_MEMORY_BLOCKS) begin : Using_M20k_change2
          assign p1_ready_out           = read_rp_ready_temp && read_rsp_fifo_outvalid;
      end else begin : Using_ALM_memory_chnage2
          assign p1_ready_out           = read_rp_ready_temp;
      end
       assign read_rp_valid_temp    = rvalid_resp_mem && uncompressor_outvalid;
   endgenerate     
    assign read_rsp_fifo_invalid    = read_cp_ready && read_cp_valid;    
    assign read_rsp_fifo_outready   = uncompressor_inready;  


    assign read_rsp_fifo_outdata_eop        = read_rsp_fifo_outdata[ST_DATA_W];
    assign read_rsp_fifo_outdata_burstwrap  = read_rsp_fifo_outdata[PKT_BURSTWRAP_H:PKT_BURSTWRAP_L];
    assign read_rsp_fifo_outdata_addr       = read_rsp_fifo_outdata[PKT_ADDR_H:PKT_ADDR_L];         
    assign read_rsp_fifo_outdata_bytecount  = read_rsp_fifo_outdata[PKT_BYTE_CNT_H:PKT_BYTE_CNT_L]; 
    assign read_rsp_fifo_outdata_is_comp    = read_rsp_fifo_outdata[PKT_TRANS_COMPRESSED_READ];
    assign read_rsp_fifo_outdata_burstsize  = read_rsp_fifo_outdata[PKT_BURST_SIZE_H:PKT_BURST_SIZE_L];


   generate
       if (USE_MEMORY_BLOCKS) begin : Using_M20k_rvalid
           assign rvalid_uncompressor = (rvalid_resp_mem && read_rsp_fifo_outvalid);
       end else begin : Using_ALM_memory_rvalid
           assign rvalid_uncompressor = rvalid_resp_mem;
       end    
   endgenerate

    altera_merlin_burst_uncompressor #(
        .ADDR_W         (ADDR_WIDTH),
        .BURSTWRAP_W    (BURSTWRAP_W),
        .BYTE_CNT_W     (BYTECOUNT_W),
        .PKT_SYMBOLS    (NUMSYMBOLS),
        .BURST_SIZE_W   (BURST_SIZE_W),
        .SYNC_RESET     (SYNC_RESET)
    ) read_burst_uncompressor (
        .clk                    (aclk),
        .reset                  (areset),
        .sink_startofpacket     (read_rsp_fifo_outdata_sop),
        .sink_endofpacket       (read_rsp_fifo_outdata_eop),
        .sink_valid             (rvalid_uncompressor),
        .sink_ready             (uncompressor_inready),
        .sink_addr              (read_rsp_fifo_outdata_addr),
        .sink_burstwrap         (read_rsp_fifo_outdata_burstwrap),
        .sink_byte_cnt          (read_rsp_fifo_outdata_bytecount),
        .sink_is_compressed     (read_rsp_fifo_outdata_is_comp),
        .sink_burstsize         (read_rsp_fifo_outdata_burstsize),

        .source_startofpacket   (read_rp_startofpacket_temp),
        .source_endofpacket     (read_rp_endofpacket_temp),
        .source_valid           (uncompressor_outvalid),
        .source_ready           (read_rp_ready_temp),
        .source_addr            (uncompressor_addr),
        .source_burstwrap       (uncompressor_burstwrap),
        .source_byte_cnt        (uncompressor_bytecount),
        .source_is_compressed   (uncompressor_is_comp),
        .source_burstsize       (uncompressor_burstsize)
    );

 generate 
   if (ENABLE_OOO == 0) begin

    ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_sc_fifo_1971_ysgnmwa #(
        .SYMBOLS_PER_BEAT    (1),
        .BITS_PER_SYMBOL     (ST_DATA_W + 1),
        .FIFO_DEPTH          (WRITE_ACCEPTANCE_CAPABILITY),
        .CHANNEL_WIDTH       (0),
        .ERROR_WIDTH         (0),
        .USE_PACKETS         (0),
        .USE_FILL_LEVEL      (0),
        .EMPTY_LATENCY       (EMPTY_LATENCY),
        .USE_MEMORY_BLOCKS   (USE_MEMORY_BLOCKS), 
        .USE_STORE_FORWARD   (0),
        .USE_ALMOST_FULL_IF  (0),
        .USE_ALMOST_EMPTY_IF (0),
        .SYNC_RESET          (SYNC_RESET)
    ) write_rsp_fifo (
        .clk               (aclk),                                 
        .reset             (areset),                               
        .in_data           (write_rsp_fifo_indata),                
        .in_valid          (write_rsp_fifo_invalid),               
        .in_ready          (write_rsp_fifo_inready),               
        .out_data          (write_rsp_fifo_outdata),               
        .out_valid         (write_rsp_fifo_outvalid),              
        .out_ready         (write_rsp_fifo_outready)               
    );         

    ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_sc_fifo_1971_ysgnmwa #(
        .SYMBOLS_PER_BEAT    (1),
        .BITS_PER_SYMBOL     (ST_DATA_W + 1),  
        .FIFO_DEPTH          (READ_ACCEPTANCE_CAPABILITY),
        .CHANNEL_WIDTH       (0),
        .ERROR_WIDTH         (0),
        .USE_PACKETS         (0),
        .USE_FILL_LEVEL      (0),
        .EMPTY_LATENCY       (EMPTY_LATENCY),
        .USE_MEMORY_BLOCKS   (USE_MEMORY_BLOCKS),
        .USE_STORE_FORWARD   (0),
        .USE_ALMOST_FULL_IF  (0),
        .USE_ALMOST_EMPTY_IF (0),
        .SYNC_RESET          (SYNC_RESET)
    ) read_rsp_fifo (
        .clk               (aclk),                                 
        .reset             (areset),                               
        .in_data           (read_rsp_fifo_indata),                 
        .in_valid          (read_rsp_fifo_invalid),                
        .in_ready          (read_rsp_fifo_inready),                
        .out_data          (read_rsp_fifo_outdata),                
        .out_valid         (read_rsp_fifo_outvalid),               
        .out_ready         (read_rsp_fifo_outready)                
    );      
   end
   else begin   
      assign meta_write_data_resp_mem_in  =  write_cp_data[ST_DATA_W-1: AXI_SLAVE_ID_W];                               
      assign write_rsp_mem_indata         = {write_cp_endofpacket,meta_write_data_resp_mem_in , awid_internal[AXI_SLAVE_ID_W -1:0]}; 
     
      wr_response_mem_cwyib4q #(
       .ST_DATA_W    (META_DATA_W + AXI_SLAVE_ID_W +1), 
       .ID_W         (AXI_SLAVE_ID_W),
       .PIPELINE_OUT (1),
       .PIPELINE_CMP (0)
      ) write_response_memory (
          .clk              (aclk),                                 
          .rst              (areset),                               
          .in_data          (write_rsp_mem_indata),                 
          .in_valid         (write_rsp_fifo_invalid),                
          .in_ready         (write_rsp_fifo_inready),                
          .out_data         (write_rsp_fifo_outdata),                
          .out_valid        (write_rsp_fifo_outvalid),               
          .out_ready        (p1_bready_out), 
     
          .cmd_id           (awid),
          .cmd_ready        ('1),
          
          .rsp_valid        (bvalid_resp_mem),
          .rsp_id           (bid_resp_mem)
      ); 
     
                                       
      assign meta_read_data_resp_mem_in  =   read_cp_data_for_fifo [ST_DATA_W-1: AXI_SLAVE_ID_W];                               
      assign read_rsp_mem_indata         =  {read_cp_endofpacket, meta_read_data_resp_mem_in , arid_internal[AXI_SLAVE_ID_W -1:0]}; 
     
      rd_response_mem_cwyib4q #(
       .ST_DATA_W    (META_DATA_W + AXI_SLAVE_ID_W +1), 
       .ID_W         (AXI_SLAVE_ID_W),
       .PIPELINE_OUT (1),
       .PIPELINE_CMP (0)
      ) read_response_memory (
          .clk              (aclk),                                 
          .rst              (areset),                               
          .in_data          (read_rsp_mem_indata),                 
          .in_valid         (read_rsp_fifo_invalid),                
          .in_ready         (read_rsp_fifo_inready),                
          .out_data         (read_rsp_fifo_outdata),                
          .out_valid        (read_rsp_fifo_outvalid),               
          .out_ready        (p1_rlast && p1_ready_out),
     
          .cmd_id           (arid),
          .cmd_ready        (arready),
          
          .rsp_valid        (rvalid_resp_mem),
          .rsp_id           (rid_resp_mem)
      ); 
   end
endgenerate  

generate 
   if (ENABLE_OOO == 1) begin
   
     assign p1_data_in  = {rlast,ruser,rresp,rid,rdata};
     assign p1_valid_in = rvalid;
     assign rready      = p1_ready_in;
     assign p1_rdata    = p1_data_out[0 +: PKT_DATA_W];
     assign p1_rid      = p1_data_out[PKT_DATA_W +: AXI_SLAVE_ID_W];
     assign p1_rresp    = p1_data_out[PKT_DATA_W+AXI_SLAVE_ID_W +: RESPONSE_W];
     assign p1_ruser    = p1_data_out[PKT_DATA_W+AXI_SLAVE_ID_W+RESPONSE_W +: DATA_USER_WIDTH];
     assign p1_rlast    = p1_data_out[ST_PIPELINE_DATA_W-1];

    
    ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_alj3kza #(
      .SYMBOLS_PER_BEAT (1),
      .BITS_PER_SYMBOL  (ST_PIPELINE_DATA_W),
      .USE_PACKETS      (0),
      .USE_EMPTY        (0),
      .PIPELINE_READY   (0),
      .SYNC_RESET       (SYNC_RESET),
      .CHANNEL_WIDTH    (0),
      .ERROR_WIDTH      (0)
    ) altera_avalon_st_pipeline_stage_rd (
        .clk               (aclk),                                 
        .reset             (areset),                               
        .in_data           (p1_data_in),                
        .in_valid          (p1_valid_in),               
        .in_ready          (p1_ready_in),               
        .out_data          (p1_data_out),               
        .out_valid         (p1_valid_out),              
        .out_ready         (p1_ready_out)               
    );

     assign p1_bdata_in  = {buser,bresp,bid};
     assign p1_bvalid_in = bvalid;
     assign bready      = p1_bready_in;
     assign p1_bid      = p1_bdata_out[0 +: AXI_SLAVE_ID_W];
     assign p1_bresp    = p1_bdata_out[AXI_SLAVE_ID_W +: 2];
     assign p1_buser    = p1_bdata_out[AXI_SLAVE_ID_W+2 +: DATA_USER_WIDTH];

    ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_h6wexfa #(
      .SYMBOLS_PER_BEAT (1),
      .BITS_PER_SYMBOL  (DATA_USER_WIDTH + AXI_SLAVE_ID_W + 2),
      .USE_PACKETS      (0),
      .USE_EMPTY        (0),
      .PIPELINE_READY   (0),
      .SYNC_RESET       (SYNC_RESET),
      .CHANNEL_WIDTH    (0),
      .ERROR_WIDTH      (0)
    ) altera_avalon_st_pipeline_stage_wr (
        .clk               (aclk),                                 
        .reset             (areset),                               
        .in_data           (p1_bdata_in),                
        .in_valid          (p1_bvalid_in),               
        .in_ready          (p1_bready_in),               
        .out_data          (p1_bdata_out),               
        .out_valid         (p1_bvalid_out),              
        .out_ready         (p1_bready_out)               
    );

  end
  else begin
    assign p1_rdata = rdata;  
    assign p1_rid   = rid;  
    assign p1_rresp = rresp;  
    assign p1_ruser = ruser;  
    assign p1_rlast = rlast;
    assign rready   = p1_ready_out;

    assign p1_bid   = bid;  
    assign p1_bresp = bresp;  
    assign p1_buser = buser;  
    assign bready   = p1_bready_out;


  end      
endgenerate

generate
  if (ENABLE_OOO ==1)begin
    assign rid_resp_mem     = (p1_ready_in == 1) ? rid : p1_rid;
    assign rvalid_resp_mem  = p1_valid_out;
    assign bid_resp_mem     = (p1_bready_in == 1) ? bid : p1_bid;
    assign bvalid_resp_mem  = p1_bvalid_out;
  end
  else begin
   assign rvalid_resp_mem = rvalid;   
   assign bvalid_resp_mem = bvalid;   
 end
endgenerate

reg sop_enable;
generate
     if(ENABLE_OOO ==1 && REORDER_BUFFER == 1)begin
           if(SYNC_RESET == 0) begin : async_rst1
               always_ff @(posedge aclk, negedge aresetn)
               begin
                   if (!aresetn)
                       begin
                           sop_enable <= 1'b1;
                       end
                   else
                       begin
                           if(p1_rlast && read_rp_valid_temp && read_rp_ready_temp)
                              sop_enable <= 1;
                           else if(read_rp_valid_temp && read_rp_ready_temp)
                              sop_enable <= 0;               
                       end
               end
           end : async_rst1
           
           else begin : sync_rst1   
             always_ff @(posedge aclk)
             begin
                 if (internal_sclr)
                     begin
                         sop_enable <= 1'b1;
                     end
                 else
                    begin
                        if(p1_rlast && read_rp_valid_temp && read_rp_ready_temp)
                           sop_enable <= 1;
                        else if (read_rp_valid_temp && read_rp_ready_temp)
                           sop_enable <= 0;               
                    end
             end
           end : sync_rst1
     end     
     else begin
          always @* begin
              sop_enable = read_rp_startofpacket_temp;
          end
     end
     
   if(ENABLE_OOO ==1 && REORDER_BUFFER == 0)begin

       ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_cgpn6xq #(
             .SYMBOLS_PER_BEAT (1),
             .BITS_PER_SYMBOL  (ST_DATA_W),
             .USE_PACKETS      (1),
             .USE_EMPTY        (0),
             .PIPELINE_READY   (1),
             .SYNC_RESET       (SYNC_RESET),
             .CHANNEL_WIDTH    (0),
             .ERROR_WIDTH      (0),
             .PACKET_WIDTH     (2)
           ) altera_avalon_st_pipeline_stage_rd_rp (
               .clk               (aclk),                                 
               .reset             (areset),                               
               .in_data           (read_rp_data_temp),                
               .in_valid          (read_rp_valid_temp),               
               .in_ready          (read_rp_ready_temp),   
               .in_startofpacket  (sop_enable),  
               .in_endofpacket    (read_rp_endofpacket_temp),            
               .out_data          (read_rp_data),               
               .out_valid         (read_rp_valid),              
               .out_ready         (read_rp_ready),
               .out_startofpacket  (read_rp_startofpacket),  
               .out_endofpacket    (read_rp_endofpacket)               
           );
       
       ed_synth_dut_altera_merlin_axi_slave_ni_altera_avalon_st_pipeline_stage_1971_cgpn6xq #(
             .SYMBOLS_PER_BEAT (1),
             .BITS_PER_SYMBOL  (ST_DATA_W),
             .USE_PACKETS      (1),
             .USE_EMPTY        (0),
             .PIPELINE_READY   (1),
             .SYNC_RESET       (SYNC_RESET),
             .CHANNEL_WIDTH    (0),
             .ERROR_WIDTH      (0),
             .PACKET_WIDTH     (2)
           ) altera_avalon_st_pipeline_stage_wr_rp (
               .clk               (aclk),                                 
               .reset             (areset),                               
               .in_data           (write_rp_data_temp),                
               .in_valid          (write_rp_valid_temp),               
               .in_ready          (write_rp_ready_temp),  
               .in_startofpacket  (write_rp_startofpacket_temp),  
               .in_endofpacket    (write_rp_endofpacket_temp),              
               .out_data          (write_rp_data),               
               .out_valid         (write_rp_valid),              
               .out_ready         (write_rp_ready),
               .out_startofpacket  (write_rp_startofpacket),  
               .out_endofpacket    (write_rp_endofpacket)               
           );
       
   end 
   else begin
     
        assign read_rp_data = read_rp_data_temp ;
        assign read_rp_valid = read_rp_valid_temp  ;
        assign read_rp_startofpacket = sop_enable  ;
        assign read_rp_endofpacket = read_rp_endofpacket_temp  ;
        assign read_rp_ready_temp = read_rp_ready;
        
        assign write_rp_data = write_rp_data_temp ;
        assign write_rp_valid = write_rp_valid_temp  ;
        assign write_rp_startofpacket = write_rp_startofpacket_temp  ;
        assign write_rp_endofpacket = write_rp_endofpacket_temp  ;
        assign write_rp_ready_temp = write_rp_ready;
     
   end
endgenerate
     
// synthesis translate_off  
generate
  if (ENABLE_OOO == 0) begin    
    ERROR_write_transaction_occurs_when_write_rsp_fifo_is_full:
        assert property ( @(posedge aclk)
            disable iff (areset) (!write_rsp_fifo_inready |-> !write_rsp_fifo_invalid)
        );
    
    ERROR_read_transaction_occurs_when_read_rsp_fifo_is_full:
        assert property ( @(posedge aclk)
            disable iff (areset) (!read_rsp_fifo_inready |-> !read_rsp_fifo_invalid)
        );    
   end
endgenerate
   
   generate
     if(ENABLE_OOO == 0)begin
        if (USE_MEMORY_BLOCKS) begin : Using_M20k_change4
            ERROR_write_response_occurs_when_write_rsp_fifo_is_empty:
                assert property ( @(posedge aclk)
                   disable iff (areset) (!write_rsp_fifo_outvalid |-> !(bvalid && write_rsp_fifo_outvalid))
            );  
        end else begin : Using_ALM_memory_change4
            ERROR_write_response_occurs_when_write_rsp_fifo_is_empty:
                assert property ( @(posedge aclk)
                    disable iff (areset) (!write_rsp_fifo_outvalid |-> !bvalid)
                ); 
        end
     end   
   endgenerate

   generate
     if(ENABLE_OOO == 0)begin
        if (USE_MEMORY_BLOCKS) begin : Using_M20k_change5
             ERROR_readdata_receive_but_read_ID_fifo_is_empty:
                 assert property ( @(posedge aclk)
                     disable iff (areset) (!read_rsp_fifo_outvalid |-> !(rvalid_resp_mem && read_rsp_fifo_outvalid))
                 );
        end else begin : Using_ALM_memory_change5
             ERROR_readdata_receive_but_read_ID_fifo_is_empty:
                 assert property ( @(posedge aclk)
                     disable iff (areset) (!read_rsp_fifo_outvalid |-> !rvalid_resp_mem)
                 );
        end
     end  
   endgenerate
 

ERROR_pkt_trans_write_not_asserted_when_write_cp_valid_is_asserted:
    assert property ( @(posedge aclk)
        disable iff (areset) (write_cp_valid |-> write_cp_data[PKT_TRANS_WRITE])
    );

//  synthesis translate_on


endmodule



`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9Pui0uJwZqf9aADiO/Xn1pqtSmduImHPl7WC7S33sCUH9zIFvzzUhgE0abA0xsaQn3r92AcwXvQ4V3oI5NUKuIewSJ4TdAg483QaEZ0Myuxx+hdFXpYv0UyF0ed1lNJyNOSb+eiTfAiimk+WTbM8vsOsgp+BOCCVrxdd92t0ztsDSSFsTjXyvSw0hcAQVPc1qED5cQWO/j3Cgr9Kt1SRz06f3WC7ll5AMS/S0actWqRbxwqAGnkF5+OLTzopg+uE0Bibt12mFrP9DNW4+nJb+sJmZvZnPfVjm1sMXRv8c5LMGUrb/OSaW0Dv79HtLiSzAnOlL22WLgxqfDWKKIA/IG2KO695jCCP7Zw0Rmz+bbi8vGR73y0wLHOUzH3diAnXZF0mwnq2nl0v1mFLLehowyoCIDgDac8WM5vawtom77plOMjI1WS8Ga96SVyDHO+PjyOshUORc2DTQFtZVy3ooLKGoPXDqxmToPd68udi/vZ7mfMDrIajD1Ed99kVHWNn0K/7wJThbEzLRMPNsVEbdG/R4pGuW4hskQMDiag8vMH3vVDwWJiejsB/Ar/6jx6Hd7DqZLe+2E190FA2yNpe5FkVSyThJLLami0OJxdJlxjyORq88NXG3q8nvK5ZOKi6GKaft3t0AIlu3U2MX3Wd53zrrYzgrnPwiCI0GxJQg3GMaUADMEcPHP1CWgqn9ByxA4iP85cuWPk3rvgHBYFxnfhwurA4+7cAd9INwTJ9ogt4oDlw8758Mpcq6Jk0vnoO4mm2av0PQlRx45ISUu/haz"
`endif