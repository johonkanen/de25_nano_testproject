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

// altera message_off 13469
module ed_synth_dut_altera_merlin_axi_translator_1931_d46vvwa
#( 
    parameter S0_ID_WIDTH           = 4,
              M0_ID_WIDTH           = 8,
              M0_ADDR_WIDTH         = 32,
              S0_ADDR_WIDTH         = 32,
              DATA_WIDTH            = 32,
              M0_SAI_WIDTH          = 4, 
              S0_SAI_WIDTH          = 4,
              M0_USER_ADDRCHK_WIDTH = 4, 
              S0_USER_ADDRCHK_WIDTH = 4,
              S0_WRITE_ADDR_USER_WIDTH  = 64,
              S0_READ_ADDR_USER_WIDTH   = 64,
              M0_WRITE_ADDR_USER_WIDTH  = 64,
              M0_READ_ADDR_USER_WIDTH   = 64,
              M0_WRITE_DATA_USER_WIDTH            = 64,
              M0_WRITE_RESPONSE_DATA_USER_WIDTH   = 64,
              M0_READ_DATA_USER_WIDTH             = 64,
              S0_WRITE_DATA_USER_WIDTH            = 64,
              S0_WRITE_RESPONSE_DATA_USER_WIDTH   = 64,
              S0_READ_DATA_USER_WIDTH             = 64,
              M0_AXI_VERSION        = "AXI3",
              S0_AXI_VERSION        = "AXI3",
              USE_S0_AWUSER        = 0,
              USE_S0_ARUSER        = 0,
              USE_S0_WUSER         = 0,
              USE_S0_RUSER         = 0,
              USE_S0_BUSER         = 0,
              USE_S0_AWID          = 0,
              USE_S0_AWREGION      = 0,
              USE_S0_AWSIZE        = 0,
              USE_S0_AWBURST       = 0,
              USE_S0_AWLEN         = 0,
              USE_S0_AWLOCK        = 0,
              USE_S0_AWCACHE       = 0,
              USE_S0_AWQOS         = 0,

              USE_S0_WSTRB         = 0,
   
              USE_S0_BID           = 0,
              USE_S0_BRESP         = 0,
              USE_S0_ARID          = 0,
              USE_S0_ARREGION      = 0,
              USE_S0_ARSIZE        = 0,
              USE_S0_ARBURST       = 0,
              USE_S0_ARLEN         = 0,
              USE_S0_ARLOCK        = 0,
              USE_S0_ARCACHE       = 0,
              USE_S0_ARQOS         = 0,
   
              USE_S0_RID           = 0,
              USE_S0_RRESP         = 0,
              USE_S0_RLAST         = 0,
              S0_BURST_LENGTH_WIDTH = 8,
              S0_LOCK_WIDTH         = 1,
              
              USE_S0_AWUSER_ADDRCHK = 0,
              USE_S0_AWUSER_SAI     = 0,
              USE_S0_ARUSER_SAI     = 0,
              USE_S0_ARUSER_ADDRCHK = 0,
              USE_S0_WUSER_DATACHK  = 0,
              USE_S0_WUSER_POISON   = 0,
              USE_S0_RUSER_DATACHK  = 0,
              USE_S0_RUSER_POISON   = 0,
              
              ROLE_BASED_USER          = 0,                      
              USE_M0_AWREGION      = 1,
              USE_M0_AWLOCK        = 1,
              USE_M0_AWPROT        = 1,
              USE_M0_AWCACHE       = 1,
              USE_M0_AWQOS         = 1,

              USE_M0_WLAST         = 1,
              USE_M0_BRESP         = 1,

              USE_M0_ARREGION      = 1,
              USE_M0_ARLOCK        = 1,
              USE_M0_ARPROT        = 1,
              USE_M0_ARCACHE       = 1,
              USE_M0_ARQOS         = 1,

              USE_M0_RRESP         = 1,
              USE_M0_AWUSER        = 0,
              USE_M0_ARUSER        = 0,
              USE_M0_WUSER         = 0,
              USE_M0_RUSER         = 0,
              USE_M0_BUSER         = 0,
              
              USE_M0_AWUSER_ADDRCHK = 0,
              USE_M0_AWUSER_SAI     = 0,
              USE_M0_ARUSER_SAI     = 0,              
              USE_M0_ARUSER_ADDRCHK = 0,
              USE_M0_WUSER_DATACHK  = 0,
              USE_M0_WUSER_POISON   = 0,
              USE_M0_RUSER_DATACHK  = 0,
              USE_M0_RUSER_POISON   = 0,
              
              M0_BURST_LENGTH_WIDTH= 8,
              M0_LOCK_WIDTH        = 2,

              ACE_LITE_SUPPORT  = 0,
    

              /* |----------+-------------+-------------| */
              /* | Signal   | input       | output      | */
              /* |----------+-------------+-------------| */
              /* | wuser_datachk | s0_wuser_datachk | m0_wuser_datachk | */
              /* | ruser_datachk | m0_ruser_datachk | s0_ruser_datachk | */
              /* |----------+-------------+-------------| */
              CALCULATE_WUSER_DATACHK =  USE_S0_WUSER_DATACHK==0 && USE_M0_WUSER_DATACHK ==1, 
              CALCULATE_RUSER_DATACHK =  USE_S0_RUSER_DATACHK==1 && USE_M0_RUSER_DATACHK ==0,
              
              CALCULATE_AWUSER_ADDRCHK =  USE_S0_AWUSER_ADDRCHK==0 && USE_M0_AWUSER_ADDRCHK ==1, 
              CALCULATE_ARUSER_ADDRCHK =  USE_S0_ARUSER_ADDRCHK==0 && USE_M0_ARUSER_ADDRCHK ==1,              
              
              SKIP_USER_ADDRCHK_CAL =  ((M0_ADDR_WIDTH/8) - M0_USER_ADDRCHK_WIDTH > 1)  , 
              
              S0_PADDING_ZERO      = (S0_USER_ADDRCHK_WIDTH*8) - S0_ADDR_WIDTH,
              M0_PADDING_ZERO      = (M0_USER_ADDRCHK_WIDTH*8) - M0_ADDR_WIDTH,
              
              M0_PARITY_ADDR_WIDTH = M0_ADDR_WIDTH + M0_PADDING_ZERO,

              DATACHK_WIDTH     = DATA_WIDTH / 8,
              POISON_WIDTH      = (DATA_WIDTH + 64 -1) / 64, 
              
              STROBE_WIDTH      = DATA_WIDTH / 8,
              BURST_SIZE        = $clog2(STROBE_WIDTH)
)
(
    input                                          aclk,
    input                                          aresetn,
                         
    input [S0_ID_WIDTH-1:0]                        s0_awid,
    input [S0_ADDR_WIDTH-1:0]                      s0_awaddr,
    input [S0_BURST_LENGTH_WIDTH-1:0]              s0_awlen, 
    input [2:0]                                    s0_awsize,
    input [1:0]                                    s0_awburst,
    input [S0_LOCK_WIDTH-1:0]                      s0_awlock,
    input [3:0]                                    s0_awcache,
    input [2:0]                                    s0_awprot,
    input [S0_WRITE_ADDR_USER_WIDTH-1:0]           s0_awuser,
    input [3:0]                                    s0_awqos,
    input [3:0]                                    s0_awregion, 
    input                                          s0_awvalid,
    output                                         s0_awready,

    input [S0_ID_WIDTH-1:0]                        s0_wid,
    input [DATA_WIDTH-1:0]                         s0_wdata,
    input [STROBE_WIDTH-1:0]                       s0_wstrb,
    input                                          s0_wlast,
    input [S0_WRITE_DATA_USER_WIDTH-1:0]           s0_wuser,
    input                                          s0_wvalid,
    output                                         s0_wready,

    output reg [S0_ID_WIDTH-1:0]                   s0_bid,
    output reg [1:0]                               s0_bresp,
    output [S0_WRITE_RESPONSE_DATA_USER_WIDTH-1:0] s0_buser, 
    output                                         s0_bvalid,
    input                                          s0_bready, 

    input [S0_ID_WIDTH-1:0]                        s0_arid,
    input [S0_ADDR_WIDTH-1:0]                      s0_araddr,
    input [S0_BURST_LENGTH_WIDTH-1:0]              s0_arlen,
    input [2:0]                                    s0_arsize,
    input [1:0]                                    s0_arburst,
    input [S0_LOCK_WIDTH-1:0]                      s0_arlock,
    input [3:0]                                    s0_arcache,
    input [2:0]                                    s0_arprot,
    input [3:0]                                    s0_arqos,
    input [3:0]                                    s0_arregion,
    input [S0_READ_ADDR_USER_WIDTH-1:0]            s0_aruser,
    input                                          s0_arvalid,
    output                                         s0_arready,

    output reg [S0_ID_WIDTH-1:0]                   s0_rid,
    output [DATA_WIDTH-1:0]                        s0_rdata,
    output reg [1:0]                               s0_rresp,
    output reg                                     s0_rlast,
    output [S0_READ_DATA_USER_WIDTH-1:0]           s0_ruser,
    output                                         s0_rvalid,
    input                                          s0_rready,

    input [1:0]                                    s0_ardomain, 
    input [3:0]                                    s0_arsnoop,  
    input [1:0]                                    s0_arbar,   
 
    input [1:0]                                    s0_awdomain, 
    input [2:0]                                    s0_awsnoop,  
    input [1:0]                                    s0_awbar,    
    input                                          s0_awunique,
    
    input [S0_USER_ADDRCHK_WIDTH-1:0]              s0_awuser_addrchk,
    input [S0_SAI_WIDTH-1:0]                       s0_awuser_sai,
    input [S0_SAI_WIDTH-1:0]                       s0_aruser_sai,
    input [S0_USER_ADDRCHK_WIDTH-1:0]              s0_aruser_addrchk,
    input [DATACHK_WIDTH-1:0]                      s0_wuser_datachk,
    input [POISON_WIDTH-1:0]                       s0_wuser_poison,
    output [DATACHK_WIDTH-1:0]                     s0_ruser_datachk,
    output [POISON_WIDTH-1:0]                      s0_ruser_poison,

    output reg [M0_ID_WIDTH-1:0]                   m0_awid,
    output [M0_ADDR_WIDTH-1:0]                     m0_awaddr,
    output reg [M0_BURST_LENGTH_WIDTH-1:0]         m0_awlen, 
    output reg [2:0]                               m0_awsize,
    output reg [1:0]                               m0_awburst,
    output reg [M0_LOCK_WIDTH-1:0]                 m0_awlock,
    output reg [3:0]                               m0_awcache,
    output reg [2:0]                               m0_awprot,
    output reg [3:0]                               m0_awqos,
    output reg [3:0]                               m0_awregion,
    output                                         m0_awvalid,
    output [M0_WRITE_ADDR_USER_WIDTH-1:0]          m0_awuser,
    input                                          m0_awready,

    output reg [M0_ID_WIDTH-1:0]                   m0_wid,
    output [DATA_WIDTH-1:0]                        m0_wdata,
    output reg [STROBE_WIDTH-1:0]                  m0_wstrb,
    output reg                                     m0_wlast,
    output                                         m0_wvalid,
    output [M0_WRITE_DATA_USER_WIDTH-1:0]          m0_wuser, 
    input                                          m0_wready,

    input [M0_ID_WIDTH-1:0]                        m0_bid,
    input [1:0]                                    m0_bresp,
    input [M0_WRITE_RESPONSE_DATA_USER_WIDTH-1:0]  m0_buser, 
    input                                          m0_bvalid,
    output                                         m0_bready,

    output reg [M0_ID_WIDTH-1:0]                   m0_arid,
    output [M0_ADDR_WIDTH-1:0]                     m0_araddr,
    output reg [M0_BURST_LENGTH_WIDTH-1:0]         m0_arlen,
    output reg [2:0]                               m0_arsize,
    output reg [1:0]                               m0_arburst,
    output reg [M0_LOCK_WIDTH-1:0]                 m0_arlock,
    output reg [3:0]                               m0_arcache,
    output reg [3:0]                               m0_arqos,
    output reg [3:0]                               m0_arregion,
    output reg [2:0]                               m0_arprot,
    output                                         m0_arvalid,
    output [M0_READ_ADDR_USER_WIDTH-1:0]           m0_aruser,
    input                                          m0_arready,

    input [M0_ID_WIDTH-1:0]                        m0_rid,
    input [DATA_WIDTH-1:0]                         m0_rdata,
    input [1:0]                                    m0_rresp,
    input [M0_READ_DATA_USER_WIDTH-1:0]            m0_ruser,
    input                                          m0_rlast,
    input                                          m0_rvalid,
    output                                         m0_rready,

    output [1:0]                                   m0_ardomain, 
    output [3:0]                                   m0_arsnoop,  
    output [1:0]                                   m0_arbar,   
 
    output [1:0]                                   m0_awdomain, 
    output [2:0]                                   m0_awsnoop,  
    output [1:0]                                   m0_awbar,    
    output                                         m0_awunique,
    
    output [M0_USER_ADDRCHK_WIDTH-1:0]             m0_awuser_addrchk,
    output [M0_SAI_WIDTH-1:0]                      m0_awuser_sai,
    output [M0_SAI_WIDTH-1:0]                      m0_aruser_sai,    
    output [M0_USER_ADDRCHK_WIDTH-1:0]             m0_aruser_addrchk,
    output [DATACHK_WIDTH-1:0]                     m0_wuser_datachk,
    output [POISON_WIDTH-1:0]                      m0_wuser_poison,
    input  [DATACHK_WIDTH-1:0]                     m0_ruser_datachk,
    input  [POISON_WIDTH-1:0]                      m0_ruser_poison    


);

    
    
always_comb
    begin
        if (S0_AXI_VERSION == "AXI3") begin
            if (M0_AXI_VERSION == "AXI3") begin
                m0_awlen    = s0_awlen;
                m0_awsize   = s0_awsize;
                m0_awburst  = s0_awburst;
                m0_awlock   = s0_awlock;
                m0_awcache  = s0_awcache;
                m0_awprot   = s0_awprot;

                m0_wid      = s0_wid;
                m0_wstrb    = s0_wstrb;
                m0_wlast    = s0_wlast;
                
                m0_arlen    = s0_arlen;
                m0_arsize   = s0_arsize;
                m0_arburst  = s0_arburst;
                m0_arcache  = s0_arcache;
                m0_arprot   = s0_arprot;
                m0_arlock   = s0_arlock;
                
                s0_bresp    = m0_bresp;
                s0_rresp    = m0_rresp;
                s0_rlast    = m0_rlast;
                m0_awregion = '0;
                m0_awqos    = '0;
                m0_arregion = '0;
                m0_arqos    = '0;
                                
                m0_awid     =     s0_awid;
                m0_arid     =     s0_arid;
                m0_wid      =     s0_wid;
                s0_bid      =     m0_bid[S0_ID_WIDTH - 1 : 0];
                s0_rid      =     m0_rid[S0_ID_WIDTH - 1 : 0];
            end
            else begin
                m0_awregion    = '0;
                m0_awqos       = '0;
                m0_arregion    = '0;
                m0_arqos       = '0;
                
                m0_awlock  = s0_awlock[0];
                m0_arlock  = s0_arlock[0];

                m0_awprot    = s0_awprot;
                m0_arprot    = s0_arprot;
                m0_wlast     = s0_wlast;
                m0_awcache   = s0_awcache;
                m0_arcache   = s0_arcache;
                
                s0_bid      = m0_bid[S0_ID_WIDTH-1:0];
                s0_rid      = m0_rid[S0_ID_WIDTH-1:0];
                s0_rlast    = m0_rlast;
                m0_awlen    = s0_awlen;
                m0_awid     = s0_awid;
                m0_arid     = s0_arid;
                m0_awburst  = s0_awburst;
                m0_arburst  = s0_arburst;
                m0_wstrb    = s0_wstrb;
                m0_awsize   = s0_awsize;
                m0_arsize   = s0_arsize;
                m0_arlen    = s0_arlen;
                m0_awqos    = '0;
                m0_arqos    = '0;
                
                m0_wid      = s0_wid;
            
                if (USE_M0_BRESP)
                    s0_bresp     = m0_bresp;
                else
                    s0_bresp     = 2'b00; 
                if (USE_M0_RRESP)
                    s0_rresp     = m0_rresp;
                else
                    s0_rresp     = 2'b00; 
            end 
        end 
        
        else begin
                        
            if ((USE_M0_AWREGION) && (!USE_S0_AWREGION))
                m0_awregion    = '0; 
            else
                m0_awregion    = s0_awregion;
                        
            if ((USE_M0_AWLOCK) && (!USE_S0_AWLOCK))
                m0_awlock      = '0;
            else 
                m0_awlock      = s0_awlock;

            if ((USE_M0_AWCACHE) && (!USE_S0_AWCACHE))
                m0_awcache     = '0;
            else
                m0_awcache     = s0_awcache;
            
            if ((USE_M0_AWQOS) && (!USE_S0_AWQOS)) 
                m0_awqos       = '0;
            else
                m0_awqos       = s0_awqos;
        
            if ((USE_S0_BRESP) && (!USE_M0_BRESP))
                s0_bresp       = 2'b00; 
            else
                s0_bresp       = m0_bresp;
            
            if ((USE_M0_ARREGION) && (!USE_S0_ARREGION))
                m0_arregion    = '0; 
            else
                m0_arregion    = s0_arregion;
                        
            if ((USE_M0_ARLOCK) && (!USE_S0_ARLOCK))
                m0_arlock      = '0;
            else 
                m0_arlock      = s0_arlock;

            if ((USE_M0_ARCACHE) && (!USE_S0_ARCACHE))
                m0_arcache     = '0;
            else
                m0_arcache     = s0_arcache;
            
            if ((USE_M0_ARQOS) && (!USE_S0_ARQOS)) 
                m0_arqos       = '0;
            else
                m0_arqos       = s0_arqos;
        
            if ((USE_S0_RRESP) && (!USE_M0_RRESP))
                s0_rresp       = 2'b00; 
            else
                s0_rresp       = m0_rresp;
        
        
            if (USE_S0_AWID)
                m0_awid    = s0_awid;
            else
                m0_awid    = '0;
            if (USE_S0_AWLEN)
                m0_awlen    = s0_awlen;
            else
                m0_awlen    = '0;
            if (USE_S0_AWSIZE)
                m0_awsize   = s0_awsize;
            else
                m0_awsize   = BURST_SIZE[2:0]; 
            if (USE_S0_AWBURST)
                m0_awburst  = s0_awburst;
            else
                m0_awburst  = 2'b01; 
            if (USE_S0_WSTRB)
                m0_wstrb    = s0_wstrb;
            else
                m0_wstrb    =  {STROBE_WIDTH{1'b1}};

            if (USE_S0_ARID)
                m0_arid    = s0_arid;
            else
                m0_arid    = '0;
            if (USE_S0_ARLEN)
                m0_arlen    = s0_arlen;
            else
                m0_arlen    = '0;
            if (USE_S0_ARSIZE)
                m0_arsize   = s0_arsize;
            else
                m0_arsize   = BURST_SIZE[2:0]; 
            if (USE_S0_ARBURST)
                m0_arburst  = s0_arburst;
            else
                m0_arburst  = 2'b01; 

            s0_bid          = m0_bid[S0_ID_WIDTH-1:0];
            s0_rid          = m0_rid[S0_ID_WIDTH-1:0];
            s0_rlast        = m0_rlast;
            m0_wid          = '0;
                        
            m0_awprot       = s0_awprot;
            m0_wlast        = s0_wlast;
            m0_arprot       = s0_arprot;
            
            end 
        
        if (S0_AXI_VERSION == "AXI4Lite") begin
            m0_awid      = '0;
            m0_awlen     = '0; 
            m0_awburst   = 2'b01; 
            m0_awsize    = BURST_SIZE[2:0];
            m0_awlock    = '0;
            m0_awcache   = '0;
            m0_awprot    = s0_awprot;
            m0_awqos     = '0;
            m0_awregion  = '0;

            m0_wid       = '0;
            m0_wlast     = 1'b1; 

            s0_bid       = m0_bid;

            m0_arid      = '0;
            m0_arlen     = '0;
            m0_arsize    = BURST_SIZE[2:0];
            m0_arburst   = 2'b01;
            m0_arlock    = '0;
            m0_arcache   = '0;
            m0_arprot    = s0_arprot;
            m0_arqos     = '0;
            m0_arregion  = '0;

            s0_rid       = m0_rid;
            s0_rlast     = 1'b1;
        end 
        else begin

            s0_bid  = m0_bid [S0_ID_WIDTH-1:0];
            s0_rid  = m0_rid [S0_ID_WIDTH-1:0];
            end 
    end 
    

    assign m0_awvalid      =     s0_awvalid;
    assign s0_awready      =     m0_awready;
    
    assign m0_wdata        =     s0_wdata;
    assign m0_wvalid       =     s0_wvalid;
    assign s0_wready       =     m0_wready;

    assign m0_arvalid      =     s0_arvalid;
    assign s0_arready      =     m0_arready;

    assign s0_bvalid       =     m0_bvalid;
    assign m0_bready       =     s0_bready;

    assign s0_rdata        =     m0_rdata;
    assign s0_rvalid       =     m0_rvalid;
    assign m0_rready       =     s0_rready;
    assign m0_awaddr       =     s0_awaddr[M0_ADDR_WIDTH-1 :0];
    assign m0_araddr       =     s0_araddr[M0_ADDR_WIDTH-1 :0];
    assign m0_awuser       =     USE_S0_AWUSER ? s0_awuser : '0;
    assign m0_aruser       =     USE_S0_ARUSER ? s0_aruser : '0;
    assign m0_wuser        =     USE_S0_WUSER ? s0_wuser : '0;
    assign s0_buser        =     USE_M0_BUSER ? m0_buser : '0;
    assign s0_ruser        =     USE_M0_RUSER ? m0_ruser : '0;

    assign m0_wuser_poison   =   (USE_S0_WUSER_POISON && ROLE_BASED_USER) ? s0_wuser_poison: 1'b0;
    assign s0_ruser_poison   =   (USE_M0_RUSER_POISON && ROLE_BASED_USER)  ? m0_ruser_poison: 1'b0;

    assign m0_awuser_sai     =   (USE_S0_AWUSER_SAI   && ROLE_BASED_USER) ? s0_awuser_sai: 'b0;
    assign m0_aruser_sai     =   (USE_S0_ARUSER_SAI   && ROLE_BASED_USER) ? s0_aruser_sai: 'b0;

    assign m0_ardomain  =  s0_ardomain;
    assign m0_arsnoop   =  s0_arsnoop;
    assign m0_arbar     =  s0_arbar;

    assign m0_awdomain  =  s0_awdomain;
    assign m0_awsnoop   =  s0_awsnoop;
    assign m0_awbar     =  s0_awbar;
    assign m0_awunique  =  s0_awunique;
    
generate
    if (CALCULATE_WUSER_DATACHK && ROLE_BASED_USER) begin
        assign m0_wuser_datachk = calcParity(s0_wdata);
    end
    else if(ROLE_BASED_USER) begin
        assign m0_wuser_datachk = s0_wuser_datachk;
    end else begin
        assign m0_wuser_datachk = '0;
    end
    
    if (CALCULATE_RUSER_DATACHK && ROLE_BASED_USER) begin
        assign s0_ruser_datachk = calcParity(m0_rdata);
    end else if(ROLE_BASED_USER) begin
        assign s0_ruser_datachk = m0_ruser_datachk;
    end else begin
        assign s0_ruser_datachk = '0;
    end

    if (CALCULATE_AWUSER_ADDRCHK && ROLE_BASED_USER) begin
        if(SKIP_USER_ADDRCHK_CAL) begin
            assign m0_awuser_addrchk = '0;
        end
        else begin
            assign m0_awuser_addrchk = addrcalcParity({{M0_PADDING_ZERO{1'b0}},m0_awaddr});
        end
    end else if(ROLE_BASED_USER) begin
        assign m0_awuser_addrchk = s0_awuser_addrchk;
    end else begin
        assign m0_awuser_addrchk = '0;
    end

    if (CALCULATE_ARUSER_ADDRCHK && ROLE_BASED_USER) begin
        if(SKIP_USER_ADDRCHK_CAL) begin
            assign m0_awuser_addrchk = '0;
        end
        else begin
            assign m0_aruser_addrchk = addrcalcParity({{M0_PADDING_ZERO{1'b0}},m0_araddr});
        end
    end else if(ROLE_BASED_USER) begin
        assign m0_aruser_addrchk = s0_aruser_addrchk;
    end else begin
        assign m0_aruser_addrchk = '0; 
    end
endgenerate;     
    

    function reg [DATACHK_WIDTH-1:0] calcParity (
        input [DATA_WIDTH-1:0] data
    );
        for (int i=0; i<DATACHK_WIDTH; i++)
            calcParity[i] = ~(^ data[i*8 +:8]);
    endfunction

    function reg [M0_USER_ADDRCHK_WIDTH-1:0] addrcalcParity (
        input [M0_PARITY_ADDR_WIDTH-1:0] addr
    );
        for (int i=0; i<M0_USER_ADDRCHK_WIDTH; i++)
            addrcalcParity[i] = ~(^ addr[i*8 +:8]);
    endfunction

    

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc8rvsobUulwCjlnl/YMCJFnwrhEr5KxJ6tJqMkWCgMTyBY5dwUiSTx0LnKID0um5o1wSqaVHPLHocluA4t8k0jaWNhRtJWEKjAtjoQI1ft5vV9Mon3QzldGuU9noNSUtl7m8DmyH1xZe+I52AADL6Uf8s9aajyWNCQdMwghVeUIkVO7tiaLb/fM7O/7Pcj5p9ti1GYC7h7d0iK/8/E51lInGMQnNAXwTw4Nhg2PYW4HQfDB6WMnAzEaInzV13rk50jXJgMrhgxuvwFj/xHYp47VMih95AKt19OobgZXS85pc0jGcMxFJujW0eFigspMFSRXjk8xh0fV8a3NzhQ3YwoW73ZZPGaZRAbMn75HwcDZnsx01jz/Fulu9ddu+2wD5UP6DdDs1rgOKysDNb66N3r887F8kjM3JNYq08vA1Lq/fVKgT8OgxeRgu+ssuQX6/7R0ox5tZUaiGVdbh/FFNETMLo8oj54QDCh09/TAgR5IXmrqrwu49ibX3NnbhT9X9tjR1hpOlyaP6nCGu7IQ6U2P2vAcJqjHWYdCxMs6Fexr3qFyHQhTRP9pk9yucCmby+f5nPic3tMXHslwcAPa9bGS0iGES9CMVSmtBpw9Kf12dIFtWaU6V1q55qCB1cBaPDo8XAF5R9xuqROhAC32lDw2v4dP7T5Qlhq/QtrT8bQwmJeKp5EfsCUN4euwtGYHnpUfpw4cyeAVjRYTmkJWrneimqH4TvxghNMIVwFvw+5HKq/QI1CXUptaCBP2j6wfHbmaaur6RcrmVvBulETKJg94"
`endif