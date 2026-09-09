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





`default_nettype none

/* intel_axi4lite_injector_ph2

   The AXI4 Lite injector provides a way for AXI4 Lite masters in customer designs to interact with 
   registers in the periphery without needing a dedicated FP NOC INIU. This is acheived by providing
   an AXI4 master interface that can be directly connected to an INIU, and an AXI4 slave interface
   identical to that of an INIU except that the AXI ID signals are one bit narrower than that of an
   INIU. On the INIU interface that bit is used to indicate whether the transaction originates from
   the mainband AXI4 slave, or one of the AXI4 Lite slave interfaces. The corresponding response ID
   bit is used to steer responses back to the originating interface. 

   This module provides four AXI Lite interfaces, of which 1 to 4 can be active. This style of
   configuration with a fixed port list is intended to serve deployment as a Platform Designer IP,
   which would have a TCL generated top level wrapper that hides ports for interfaces not required
   by the customer design. 

   The AXI4 mainband slave interface can also be configured as inactive if desired.

   Arbitration:

   Arbitration works the same way for the AR, AW, and W channels and is therefore handled by the 
   same logic in all cases. 

   There are two steps to arbitration: determining which AXI Lite channel should be considered
   for access to the INIU, and determining whether mainband or AXI-lite traffic should win the
   arbitration. 

   Since the number of in-flight commands or data-writes are tracked per AXI Lite interface, the
   arbitration between AXI Lite interfaces can be based on this information: The interface with
   the fewest in-flight commands/data beats wins. Ties are broken by preferring one of the 
   interfaces that did not win the previous arbitration. 

   To determine whether mainband traffic or the winner of the AXI-Lite arbitration should enter
   the INIU, the logic is configured with an upper bound on AXI-Lite INIU cycle share during
   times of contention with mainband traffic. More accurately, this is the fraction of cycles
   in which mainband traffic automatically takes precedence over AXI-Lite traffic. 

   On a cycle in which AXI-Lite traffic is permitted to contend with mainband traffic, the mainband
   stream is backpressured if AXI-Lite traffic arbitration has a winner (this part of the logic 
   has a big impact on fMax!). On cycles where there is no mainband command/data offered for 
   transfer, the AXI Lite automatically wins and this cycle does not count against the 
   contended traffic limit. 

   Due to the nature of register accesses this traffic should not offer significant contention with
   mainband traffic of real customer designs. Configuration register accesses are rare, and polling 
   traffic is limited by the high latency (> 100ns) of AXI Lite accesses across the FP NOC and onto 
   the low-bandwidth CSR access NOC.  

   Ready latency:

   The AXI Lite interfaces and user-facing mainband interfaces are fully compliant with the AXI4
   specification and therefore have ready latency = 0. In principle the INIU interfaces could have
   a non-zero ready latency, but currently only zero ready latency is supported on that interface.

   Backpressure generation:
   
   Upstream readies are forced low when the response FIFOs are no longer able to absorb any more
   responses in addition to the responses to commands that have already been accepted. 

   Parameters:
       NUM_ACTIVE_AXI4LITE_S_INTERFACES 
           How many of the user-facing AXI4Lite interfaces are actually used in the customer design
           - must be <= 4
       AXI4LITE_QOS
           AXI4 QoS to be used when converting Lite transactions into full mainband transactions. 
           Defaults to zero. The selected QoS is not taken into account during arbitration. 
           Permissible values are 0 to 15.
       NUM_ACTIVE_AXI4_S_INTERFACES
           Number of AXI4 mainband slave interfaces that will be used by the customer design. 
           Can only be 0 or 1 - a value of 0 will save on mainband interface logic, especially FIFOs.
       BUFFER_AXI4_S_READ_RESPONSES
           If an AXI4 mainband slave interface will be exposed by the wrapper for this IP and this
           parameter is non-zero, a 32-deep MLAB FIFO will be implemented on the mainband R channel. 
           This means that R channel backpressure from the user design will not cause INIU backpressure
           (and thus block responses to AXI4 Lite reads) until the buffer is full.  
           The wide read response FIFO comes with an area penalty and may also affect fMax.
       AXI4_S_TRANSFER_MULTIPLE
           When there is contention between the AXI-Lite and AXI4 mainband interfaces, this parameter
           limits the AXI-Lite data transfers to approximately 1 every AXI4_S_TRANSFER_MULTIPLE 
           mainband data transfers. This limit is based on transfer rate on R and W rather than
           command rate, so that its behaviour is not dependent on mainband burst length.  
     
   Read address tracking:

   AXI Lite read commands only request 32 or 64 bits, and are therefore converted to mainband 
   narrow and potentially unaligned transfers (addresses are not divisible by the width of the
   mainband interface, which is 32 bytes). Therefore the 32 or 64 read response bits appear in
   different segments of the 256 bit INIU response, depending on the source address. There are
   at most 8 possible slices from which the response bits must be obtained, and therefore each
   AXI Lite interface has an associated read response slice FIFO - a 32-deep and 4 bit wide 
   MLAB FIFO. The high NOC latency may cause this FIFO to fill up, in which case the user's
   AXI Lite master must be back-pressured.   

   Clocking and resets:

   For compliance with the AXI4 specification, each AXI4 or AXI4 Lite interface has an associated
   clock and reset. To avoid wasting area on wide clock-crossing FIFOs, this IP requires that 
   the mainband interfaces have the same clock, unless the user-facing slave interface is not
   activated. However each active AXI4 Lite interface can have an independent clock. 

   Since a set of clock-crossing FIFOs must be instantiated for each AXI Lite interface, 
   this enables responses to AXI Lite commands to be handled in a way that does not backpressure
   the INIU (which would harm mainband throughput). The AXI4 Lite interface logic will not accept
   read or write commands unless there is sufficient space in the response FIFOs to absorb all
   outstanding responses. 

   The command multiplexing and response demultiplexing logic is driven and reset by the 
   clock and reset associated with the INIU-facing mainband master interface.

   TODO? non-zero ready latency on the INIU interfaces 
   TODO? additional arbitration schemes
   TODO? support unoc based 512b read response path. 
   TODO: check that in all cases the AXI4 reset spec (A3.1.2) is followed
   TODO? support INIU user-data width of zero. 
   TODO? Take AXI Lite QoS into account when chosing between mainband and AXI-Lite transactions. 

   TODO: enable and validate the 64-bit AXI4 Lite option (not yet validated as it is not needed for FP)
*/

module intel_axi4lite_injector_ph2 #(
    parameter  NUM_ACTIVE_AXI4LITE_S_INTERFACES = 4,
    parameter  AXI4LITE_QOS                     = 0,                  
    parameter  NUM_ACTIVE_AXI4_S_INTERFACES     = 1,
    parameter  BUFFER_AXI4_S_READ_RESPONSES     = 0,   
    parameter  AXI4_S_TRANSFER_MULTIPLE         = 9,   
    parameter  INIU_AXI4_ADDR_WIDTH             = 44,  
    localparam AXI4_S_FIFO_DEPTH_LOG2           = 5,   
    localparam INIU_AXI4_ID_WIDTH               = 7,   
    localparam INIU_AXI4_AWUSER_WIDTH           = 11,  
    localparam INIU_AXI4_ARUSER_WIDTH           = 11,  
    localparam INIU_AXI4_DATA_WIDTH             = 256, 
    localparam AXI4LITE_ADDR_WIDTH              = INIU_AXI4_ADDR_WIDTH,
    localparam AXI4LITE_DATA_WIDTH              = 32,
    localparam AXI4LITE_FIFO_DEPTH_LOG2         = 5,   
    localparam NUM_AXI4LITE_S_INTERFACES        = 4    
) (
    input  wire                                 s0_axi4lite_aclk,     
    input  wire                                 s0_axi4lite_aresetn,
    input  wire  [AXI4LITE_ADDR_WIDTH-1:0]      s0_axi4lite_awaddr,   
    input  wire  [2:0]                          s0_axi4lite_awprot,   
    input  wire                                 s0_axi4lite_awvalid,  
    output logic                                s0_axi4lite_awready,
    input  wire  [AXI4LITE_DATA_WIDTH-1:0]      s0_axi4lite_wdata,    
    input  wire  [(AXI4LITE_DATA_WIDTH/8)-1:0]  s0_axi4lite_wstrb,    
    input  wire                                 s0_axi4lite_wvalid,   
    output logic                                s0_axi4lite_wready,
    output logic [1:0]                          s0_axi4lite_bresp,    
    output logic                                s0_axi4lite_bvalid,   
    input  wire                                 s0_axi4lite_bready,
    input  wire  [AXI4LITE_ADDR_WIDTH-1:0]      s0_axi4lite_araddr,   
    input  wire  [2:0]                          s0_axi4lite_arprot,   
    input  wire                                 s0_axi4lite_arvalid,  
    output logic                                s0_axi4lite_arready,
    output logic [AXI4LITE_DATA_WIDTH-1:0]      s0_axi4lite_rdata,    
    output logic [1:0]                          s0_axi4lite_rresp,    
    output logic                                s0_axi4lite_rvalid,   
    input  wire                                 s0_axi4lite_rready,   
    input  wire  [AXI4LITE_ADDR_WIDTH-1:0]      s1_axi4lite_awaddr,   
    input  wire  [2:0]                          s1_axi4lite_awprot,   
    input  wire                                 s1_axi4lite_aclk,     
    input  wire                                 s1_axi4lite_aresetn,
    input  wire                                 s1_axi4lite_awvalid,  
    output logic                                s1_axi4lite_awready,
    input  wire  [AXI4LITE_DATA_WIDTH-1:0]      s1_axi4lite_wdata,    
    input  wire  [(AXI4LITE_DATA_WIDTH/8)-1:0]  s1_axi4lite_wstrb,    
    input  wire                                 s1_axi4lite_wvalid,   
    output logic                                s1_axi4lite_wready,
    output logic [1:0]                          s1_axi4lite_bresp,    
    output logic                                s1_axi4lite_bvalid,   
    input  wire                                 s1_axi4lite_bready,
    input  wire  [AXI4LITE_ADDR_WIDTH-1:0]      s1_axi4lite_araddr,   
    input  wire  [2:0]                          s1_axi4lite_arprot,   
    input  wire                                 s1_axi4lite_arvalid,  
    output logic                                s1_axi4lite_arready,
    output logic [AXI4LITE_DATA_WIDTH-1:0]      s1_axi4lite_rdata,    
    output logic [1:0]                          s1_axi4lite_rresp,    
    output logic                                s1_axi4lite_rvalid,   
    input  wire                                 s1_axi4lite_rready,   
    input  wire  [AXI4LITE_ADDR_WIDTH-1:0]      s2_axi4lite_awaddr,   
    input  wire                                 s2_axi4lite_aclk,     
    input  wire                                 s2_axi4lite_aresetn,
    input  wire  [2:0]                          s2_axi4lite_awprot,   
    input  wire                                 s2_axi4lite_awvalid,  
    output logic                                s2_axi4lite_awready,
    input  wire  [AXI4LITE_DATA_WIDTH-1:0]      s2_axi4lite_wdata,    
    input  wire  [(AXI4LITE_DATA_WIDTH/8)-1:0]  s2_axi4lite_wstrb,    
    input  wire                                 s2_axi4lite_wvalid,   
    output logic                                s2_axi4lite_wready,
    output logic [1:0]                          s2_axi4lite_bresp,    
    output logic                                s2_axi4lite_bvalid,   
    input  wire                                 s2_axi4lite_bready,
    input  wire  [AXI4LITE_ADDR_WIDTH-1:0]      s2_axi4lite_araddr,   
    input  wire  [2:0]                          s2_axi4lite_arprot,   
    input  wire                                 s2_axi4lite_arvalid,  
    output logic                                s2_axi4lite_arready,
    output logic [AXI4LITE_DATA_WIDTH-1:0]      s2_axi4lite_rdata,    
    output logic [1:0]                          s2_axi4lite_rresp,    
    output logic                                s2_axi4lite_rvalid,   
    input  wire                                 s2_axi4lite_rready,   
    input  wire  [AXI4LITE_ADDR_WIDTH-1:0]      s3_axi4lite_awaddr,   
    input  wire                                 s3_axi4lite_aclk,     
    input  wire                                 s3_axi4lite_aresetn,
    input  wire  [2:0]                          s3_axi4lite_awprot,   
    input  wire                                 s3_axi4lite_awvalid,  
    output logic                                s3_axi4lite_awready,
    input  wire  [AXI4LITE_DATA_WIDTH-1:0]      s3_axi4lite_wdata,    
    input  wire  [(AXI4LITE_DATA_WIDTH/8)-1:0]  s3_axi4lite_wstrb,    
    input  wire                                 s3_axi4lite_wvalid,   
    output logic                                s3_axi4lite_wready,
    output logic [1:0]                          s3_axi4lite_bresp,    
    output logic                                s3_axi4lite_bvalid,   
    input  wire                                 s3_axi4lite_bready,
    input  wire  [AXI4LITE_ADDR_WIDTH-1:0]      s3_axi4lite_araddr,   
    input  wire  [2:0]                          s3_axi4lite_arprot,   
    input  wire                                 s3_axi4lite_arvalid,  
    output logic                                s3_axi4lite_arready,
    output logic [AXI4LITE_DATA_WIDTH-1:0]      s3_axi4lite_rdata,    
    output logic [1:0]                          s3_axi4lite_rresp,    
    output logic                                s3_axi4lite_rvalid,   
    input  wire                                 s3_axi4lite_rready, 
    input  wire                                 s_axi4_aclk,
    input  wire                                 s_axi4_aresetn,
    input  wire  [INIU_AXI4_ID_WIDTH-2:0]       s_axi4_awid,   
    input  wire  [INIU_AXI4_ADDR_WIDTH-1:0]     s_axi4_awaddr, 
    input  wire  [7:0]                          s_axi4_awlen,  
    input  wire  [2:0]                          s_axi4_awsize, 
    input  wire  [1:0]                          s_axi4_awburst,
    input  wire                                 s_axi4_awlock, 
    input  wire  [2:0]                          s_axi4_awprot, 
    input  wire  [3:0]                          s_axi4_awqos,  
    input  wire  [INIU_AXI4_AWUSER_WIDTH-1:0]   s_axi4_awuser, 
    input  wire                                 s_axi4_awvalid,
    output logic                                s_axi4_awready,
    input  wire  [INIU_AXI4_DATA_WIDTH-1:0]     s_axi4_wdata,  
    input  wire  [(INIU_AXI4_DATA_WIDTH/8)-1:0] s_axi4_wstrb,  
    input  wire                                 s_axi4_wlast,  
    input  wire  [(INIU_AXI4_DATA_WIDTH/8)-1:0] s_axi4_wuser,  
    input  wire                                 s_axi4_wvalid, 
    output logic                                s_axi4_wready, 
    output logic [INIU_AXI4_ID_WIDTH-2:0]       s_axi4_bid,    
    output logic [1:0]                          s_axi4_bresp,  
    output logic                                s_axi4_bvalid, 
    input  wire                                 s_axi4_bready, 
    input  wire  [INIU_AXI4_ID_WIDTH-2:0]       s_axi4_arid,   
    input  wire  [INIU_AXI4_ADDR_WIDTH-1:0]     s_axi4_araddr, 
    input  wire  [7:0]                          s_axi4_arlen,  
    input  wire  [2:0]                          s_axi4_arsize, 
    input  wire  [1:0]                          s_axi4_arburst,
    input  wire                                 s_axi4_arlock, 
    input  wire  [2:0]                          s_axi4_arprot, 
    input  wire  [3:0]                          s_axi4_arqos,  
    input  wire  [INIU_AXI4_ARUSER_WIDTH-1:0]   s_axi4_aruser, 
    input  wire                                 s_axi4_arvalid,
    output logic                                s_axi4_arready,
    output logic [INIU_AXI4_ID_WIDTH-2:0]       s_axi4_rid,
    output logic [INIU_AXI4_DATA_WIDTH-1:0]     s_axi4_rdata,
    output logic [1:0]                          s_axi4_rresp,
    output logic                                s_axi4_rlast,
    output logic [(INIU_AXI4_DATA_WIDTH/8)-1:0] s_axi4_ruser,
    output logic                                s_axi4_rvalid,
    input  wire                                 s_axi4_rready, 
    input  wire                                 m_axi4_aclk,
    input  wire                                 m_axi4_aresetn,
    output logic [INIU_AXI4_ID_WIDTH-1:0]       m_axi4_awid,   
    output logic [INIU_AXI4_ADDR_WIDTH-1:0]     m_axi4_awaddr, 
    output logic [7:0]                          m_axi4_awlen,  
    output logic [2:0]                          m_axi4_awsize, 
    output logic [1:0]                          m_axi4_awburst,
    output logic                                m_axi4_awlock, 
    output logic [2:0]                          m_axi4_awprot, 
    output logic [3:0]                          m_axi4_awqos,  
    output logic [INIU_AXI4_AWUSER_WIDTH-1:0]   m_axi4_awuser, 
    output logic                                m_axi4_awvalid,
    input  wire                                 m_axi4_awready,
    output logic [INIU_AXI4_DATA_WIDTH-1:0]     m_axi4_wdata,  
    output logic [(INIU_AXI4_DATA_WIDTH/8)-1:0] m_axi4_wstrb,  
    output logic                                m_axi4_wlast,  
    output logic [(INIU_AXI4_DATA_WIDTH/8)-1:0] m_axi4_wuser,  
    output logic                                m_axi4_wvalid, 
    input  wire                                 m_axi4_wready,  
    input  wire  [INIU_AXI4_ID_WIDTH-1:0]       m_axi4_bid,    
    input  wire  [1:0]                          m_axi4_bresp,  
    input  wire                                 m_axi4_bvalid, 
    output logic                                m_axi4_bready,  
    output logic [INIU_AXI4_ID_WIDTH-1:0]       m_axi4_arid,     
    output logic [INIU_AXI4_ADDR_WIDTH-1:0]     m_axi4_araddr,   
    output logic [7:0]                          m_axi4_arlen,    
    output logic [2:0]                          m_axi4_arsize,   
    output logic [1:0]                          m_axi4_arburst,  
    output logic                                m_axi4_arlock,   
    output logic [2:0]                          m_axi4_arprot,   
    output logic [3:0]                          m_axi4_arqos,    
    output logic [INIU_AXI4_ARUSER_WIDTH-1:0]   m_axi4_aruser,   
    output logic                                m_axi4_arvalid,  
    input  wire                                 m_axi4_arready,
    input  wire  [INIU_AXI4_ID_WIDTH-1:0]       m_axi4_rid,
    input  wire  [INIU_AXI4_DATA_WIDTH-1:0]     m_axi4_rdata,
    input  wire  [1:0]                          m_axi4_rresp,
    input  wire                                 m_axi4_rlast,
    input  wire  [(INIU_AXI4_DATA_WIDTH/8)-1:0] m_axi4_ruser,
    input  wire                                 m_axi4_rvalid,
    output logic                                m_axi4_rready 
);

    initial begin
        assert((NUM_ACTIVE_AXI4LITE_S_INTERFACES >= 0) && (NUM_ACTIVE_AXI4LITE_S_INTERFACES <= NUM_AXI4LITE_S_INTERFACES));
        assert((NUM_ACTIVE_AXI4LITE_S_INTERFACES > 0) || (NUM_ACTIVE_AXI4_S_INTERFACES > 0));
        assert((NUM_ACTIVE_AXI4_S_INTERFACES >= 0)    && (NUM_ACTIVE_AXI4_S_INTERFACES <= 1));
        assert((AXI4LITE_DATA_WIDTH == 32) || (AXI4LITE_DATA_WIDTH == 64));
        assert((INIU_AXI4_DATA_WIDTH % AXI4LITE_DATA_WIDTH) == 0);
    end

    generate
    if (NUM_ACTIVE_AXI4LITE_S_INTERFACES > 0) begin: gen_axi4lite_logic

        localparam RWDATA_SLICEID_WIDTH = $clog2(INIU_AXI4_DATA_WIDTH/AXI4LITE_DATA_WIDTH);
    
        logic read_response_demultiplexer_alarm;
        logic write_response_demultiplexer_alarm;
        logic axi4lite_slave_alarm [NUM_AXI4LITE_S_INTERFACES];
    
        wire                               s_axi4lite_aclks    [NUM_AXI4LITE_S_INTERFACES];  
        wire                               s_axi4lite_aresetns [NUM_AXI4LITE_S_INTERFACES];  
        wire [AXI4LITE_ADDR_WIDTH-1:0]     s_axi4lite_awaddrs  [NUM_AXI4LITE_S_INTERFACES];   
        wire [2:0]                         s_axi4lite_awprots  [NUM_AXI4LITE_S_INTERFACES];   
        wire                               s_axi4lite_awvalids [NUM_AXI4LITE_S_INTERFACES];  
        wire                               s_axi4lite_awreadies[NUM_AXI4LITE_S_INTERFACES];
        wire [AXI4LITE_DATA_WIDTH-1:0]     s_axi4lite_wdatas   [NUM_AXI4LITE_S_INTERFACES];    
        wire [(AXI4LITE_DATA_WIDTH/8)-1:0] s_axi4lite_wstrbs   [NUM_AXI4LITE_S_INTERFACES];    
        wire                               s_axi4lite_wvalids  [NUM_AXI4LITE_S_INTERFACES];   
        wire                               s_axi4lite_wreadies [NUM_AXI4LITE_S_INTERFACES];
        wire [1:0]                         s_axi4lite_bresps   [NUM_AXI4LITE_S_INTERFACES];   
        wire                               s_axi4lite_bvalids  [NUM_AXI4LITE_S_INTERFACES];  
        wire                               s_axi4lite_breadies [NUM_AXI4LITE_S_INTERFACES];
        wire [AXI4LITE_ADDR_WIDTH-1:0]     s_axi4lite_araddrs  [NUM_AXI4LITE_S_INTERFACES];   
        wire [2:0]                         s_axi4lite_arprots  [NUM_AXI4LITE_S_INTERFACES];   
        wire                               s_axi4lite_arvalids [NUM_AXI4LITE_S_INTERFACES];  
        wire                               s_axi4lite_arreadies[NUM_AXI4LITE_S_INTERFACES];
        wire [AXI4LITE_DATA_WIDTH-1:0]     s_axi4lite_rdatas   [NUM_AXI4LITE_S_INTERFACES];    
        wire [1:0]                         s_axi4lite_rresps   [NUM_AXI4LITE_S_INTERFACES];    
        wire                               s_axi4lite_rvalids  [NUM_AXI4LITE_S_INTERFACES];   
        wire                               s_axi4lite_rreadies [NUM_AXI4LITE_S_INTERFACES];
    
        wire [AXI4LITE_ADDR_WIDTH-1:0]     internal_axi4lite_awaddrs  [NUM_AXI4LITE_S_INTERFACES];   
        wire [2:0]                         internal_axi4lite_awprots  [NUM_AXI4LITE_S_INTERFACES];   
        wire                               internal_axi4lite_awvalids [NUM_AXI4LITE_S_INTERFACES];  
        wire                               internal_axi4lite_awreadies[NUM_AXI4LITE_S_INTERFACES];
        wire [AXI4LITE_DATA_WIDTH-1:0]     internal_axi4lite_wdatas   [NUM_AXI4LITE_S_INTERFACES];    
        wire [(AXI4LITE_DATA_WIDTH/8)-1:0] internal_axi4lite_wstrbs   [NUM_AXI4LITE_S_INTERFACES];    
        wire                               internal_axi4lite_wvalids  [NUM_AXI4LITE_S_INTERFACES];   
        wire                               internal_axi4lite_wreadies [NUM_AXI4LITE_S_INTERFACES];
        wire [1:0]                         internal_axi4lite_bresps   [NUM_AXI4LITE_S_INTERFACES];   
        wire                               internal_axi4lite_bvalids  [NUM_AXI4LITE_S_INTERFACES];  
        wire                               internal_axi4lite_breadies [NUM_AXI4LITE_S_INTERFACES];
        wire [AXI4LITE_ADDR_WIDTH-1:0]     internal_axi4lite_araddrs  [NUM_AXI4LITE_S_INTERFACES];   
        wire [2:0]                         internal_axi4lite_arprots  [NUM_AXI4LITE_S_INTERFACES];   
        wire                               internal_axi4lite_arvalids [NUM_AXI4LITE_S_INTERFACES];  
        wire                               internal_axi4lite_arreadies[NUM_AXI4LITE_S_INTERFACES];
        wire [AXI4LITE_DATA_WIDTH-1:0]     internal_axi4lite_rdatas   [NUM_AXI4LITE_S_INTERFACES];    
        wire [1:0]                         internal_axi4lite_rresps   [NUM_AXI4LITE_S_INTERFACES];    
        wire                               internal_axi4lite_rvalids  [NUM_AXI4LITE_S_INTERFACES];   
        wire                               internal_axi4lite_rreadies [NUM_AXI4LITE_S_INTERFACES];
    
        wire                               internal_axi4lite_aww_valids [NUM_AXI4LITE_S_INTERFACES];  
    
        wire [RWDATA_SLICEID_WIDTH-1:0]    rdata_slice_selector_sliceids[NUM_AXI4LITE_S_INTERFACES];  
        wire                               rdata_slice_selector_valids  [NUM_AXI4LITE_S_INTERFACES];  
        wire                               rdata_slice_selector_readies [NUM_AXI4LITE_S_INTERFACES];  
     
        wire [RWDATA_SLICEID_WIDTH-1:0]    wdata_slice_selector_sliceid;
    
        wire [AXI4LITE_FIFO_DEPTH_LOG2-1:0]  arbitrated_axi4lite_ar_requests_in_flight[NUM_AXI4LITE_S_INTERFACES];  
        wire [AXI4LITE_FIFO_DEPTH_LOG2-1:0]  arbitrated_axi4lite_aw_requests_in_flight[NUM_AXI4LITE_S_INTERFACES];  
    
        wire                                 internal_s_axi4_aclk;
        wire                                 internal_s_axi4_aresetn;
        wire  [INIU_AXI4_ID_WIDTH-2:0]       internal_s_axi4_awid;   
        wire  [INIU_AXI4_ADDR_WIDTH-1:0]     internal_s_axi4_awaddr; 
        wire  [7:0]                          internal_s_axi4_awlen;  
        wire  [2:0]                          internal_s_axi4_awsize; 
        wire  [1:0]                          internal_s_axi4_awburst;
        wire                                 internal_s_axi4_awlock; 
        wire  [2:0]                          internal_s_axi4_awprot; 
        wire  [3:0]                          internal_s_axi4_awqos;  
        wire  [INIU_AXI4_AWUSER_WIDTH-1:0]   internal_s_axi4_awuser; 
        wire                                 internal_s_axi4_awvalid;
        logic                                internal_s_axi4_awready;
        wire  [INIU_AXI4_DATA_WIDTH-1:0]     internal_s_axi4_wdata;  
        wire  [(INIU_AXI4_DATA_WIDTH/8)-1:0] internal_s_axi4_wstrb;  
        wire                                 internal_s_axi4_wlast;  
        wire  [(INIU_AXI4_DATA_WIDTH/8)-1:0] internal_s_axi4_wuser;  
        wire                                 internal_s_axi4_wvalid; 
        logic                                internal_s_axi4_wready; 
        logic [INIU_AXI4_ID_WIDTH-2:0]       internal_s_axi4_bid;    
        logic [1:0]                          internal_s_axi4_bresp;  
        logic                                internal_s_axi4_bvalid; 
        wire                                 internal_s_axi4_bready; 
        wire  [INIU_AXI4_ID_WIDTH-2:0]       internal_s_axi4_arid;   
        wire  [INIU_AXI4_ADDR_WIDTH-1:0]     internal_s_axi4_araddr; 
        wire  [7:0]                          internal_s_axi4_arlen;  
        wire  [2:0]                          internal_s_axi4_arsize; 
        wire  [1:0]                          internal_s_axi4_arburst;
        wire                                 internal_s_axi4_arlock; 
        wire  [2:0]                          internal_s_axi4_arprot; 
        wire  [3:0]                          internal_s_axi4_arqos;  
        wire  [INIU_AXI4_ARUSER_WIDTH-1:0]   internal_s_axi4_aruser; 
        wire                                 internal_s_axi4_arvalid;
        logic                                internal_s_axi4_arready;
        logic [INIU_AXI4_ID_WIDTH-2:0]       internal_s_axi4_rid;
        logic [INIU_AXI4_DATA_WIDTH-1:0]     internal_s_axi4_rdata;
        logic [1:0]                          internal_s_axi4_rresp;
        logic                                internal_s_axi4_rlast;
        logic [(INIU_AXI4_DATA_WIDTH/8)-1:0] internal_s_axi4_ruser;
        logic                                internal_s_axi4_rvalid;
        wire                                 internal_s_axi4_rready; 
    
        assign s_axi4_awready = internal_s_axi4_awready;
        assign s_axi4_wready  = internal_s_axi4_wready; 
        assign s_axi4_bid     = internal_s_axi4_bid;    
        assign s_axi4_bresp   = internal_s_axi4_bresp;  
        assign s_axi4_bvalid  = internal_s_axi4_bvalid; 
        assign s_axi4_arready = internal_s_axi4_arready;
        assign s_axi4_rid     = internal_s_axi4_rid;
        assign s_axi4_rdata   = internal_s_axi4_rdata;
        assign s_axi4_rresp   = internal_s_axi4_rresp;
        assign s_axi4_rlast   = internal_s_axi4_rlast;
        assign s_axi4_ruser   = internal_s_axi4_ruser;
        assign s_axi4_rvalid  = internal_s_axi4_rvalid;
    
        if (NUM_ACTIVE_AXI4_S_INTERFACES == 0) begin: default_internal_axi4_signals
            assign internal_s_axi4_aclk    = 1'b0;
            assign internal_s_axi4_aresetn = 1'b1;
            assign internal_s_axi4_awid    = {(INIU_AXI4_ID_WIDTH-1) {1'b0}};   
            assign internal_s_axi4_awaddr  = {INIU_AXI4_ADDR_WIDTH {1'b0}};
            assign internal_s_axi4_awlen   = 8'b0;
            assign internal_s_axi4_awsize  = 3'b0; 
            assign internal_s_axi4_awburst = 2'b0;
            assign internal_s_axi4_awlock  = 1'b0; 
            assign internal_s_axi4_awprot  = 3'b0; 
            assign internal_s_axi4_awqos   = 4'b0;  
            assign internal_s_axi4_awuser  = {INIU_AXI4_AWUSER_WIDTH {1'b0}};
            assign internal_s_axi4_awvalid = 1'b0;
            assign internal_s_axi4_wdata   = {INIU_AXI4_DATA_WIDTH {1'b0}};
            assign internal_s_axi4_wstrb   = {(INIU_AXI4_DATA_WIDTH/8){1'b0}};
            assign internal_s_axi4_wlast   = 1'b0;  
            assign internal_s_axi4_wuser   = {(INIU_AXI4_DATA_WIDTH/8){1'b0}};  
            assign internal_s_axi4_wvalid  = 1'b0; 
            assign internal_s_axi4_bready  = 1'b0; 
            assign internal_s_axi4_arid    = {(INIU_AXI4_ID_WIDTH-1) {1'b0}};
            assign internal_s_axi4_araddr  = {INIU_AXI4_ADDR_WIDTH {1'b0}}; 
            assign internal_s_axi4_arlen   = 8'b0;  
            assign internal_s_axi4_arsize  = 3'b0; 
            assign internal_s_axi4_arburst = 2'b0;
            assign internal_s_axi4_arlock  = 1'b0; 
            assign internal_s_axi4_arprot  = 3'b0; 
            assign internal_s_axi4_arqos   = 4'b0;  
            assign internal_s_axi4_aruser  = {INIU_AXI4_ARUSER_WIDTH {1'b0}};
            assign internal_s_axi4_arvalid = 1'b0;
            assign internal_s_axi4_rready  = 1'b0; 
        end else begin: connect_internal_axi4_signals
            assign internal_s_axi4_aclk    = s_axi4_aclk;
            assign internal_s_axi4_aresetn = s_axi4_aresetn;
            assign internal_s_axi4_awid    = s_axi4_awid;   
            assign internal_s_axi4_awaddr  = s_axi4_awaddr; 
            assign internal_s_axi4_awlen   = s_axi4_awlen;  
            assign internal_s_axi4_awsize  = s_axi4_awsize; 
            assign internal_s_axi4_awburst = s_axi4_awburst;
            assign internal_s_axi4_awlock  = s_axi4_awlock; 
            assign internal_s_axi4_awprot  = s_axi4_awprot; 
            assign internal_s_axi4_awqos   = s_axi4_awqos;  
            assign internal_s_axi4_awuser  = s_axi4_awuser; 
            assign internal_s_axi4_awvalid = s_axi4_awvalid;
            assign internal_s_axi4_wdata   = s_axi4_wdata;  
            assign internal_s_axi4_wstrb   = s_axi4_wstrb;  
            assign internal_s_axi4_wlast   = s_axi4_wlast;  
            assign internal_s_axi4_wuser   = s_axi4_wuser;  
            assign internal_s_axi4_wvalid  = s_axi4_wvalid; 
            assign internal_s_axi4_bready  = s_axi4_bready; 
            assign internal_s_axi4_arid    = s_axi4_arid;   
            assign internal_s_axi4_araddr  = s_axi4_araddr; 
            assign internal_s_axi4_arlen   = s_axi4_arlen;  
            assign internal_s_axi4_arsize  = s_axi4_arsize; 
            assign internal_s_axi4_arburst = s_axi4_arburst;
            assign internal_s_axi4_arlock  = s_axi4_arlock; 
            assign internal_s_axi4_arprot  = s_axi4_arprot; 
            assign internal_s_axi4_arqos   = s_axi4_arqos;  
            assign internal_s_axi4_aruser  = s_axi4_aruser; 
            assign internal_s_axi4_arvalid = s_axi4_arvalid;
            assign internal_s_axi4_rready  = s_axi4_rready; 
        end
    
        assign s_axi4lite_aclks     = ('{s0_axi4lite_aclk,   s1_axi4lite_aclk,   s2_axi4lite_aclk,   s3_axi4lite_aclk   });
        assign s_axi4lite_aresetns  = ('{s0_axi4lite_aresetn,s1_axi4lite_aresetn,s2_axi4lite_aresetn,s3_axi4lite_aresetn});
    
        assign s_axi4lite_awaddrs   = ('{s0_axi4lite_awaddr, s1_axi4lite_awaddr, s2_axi4lite_awaddr, s3_axi4lite_awaddr });
        assign s_axi4lite_awprots   = ('{s0_axi4lite_awprot, s1_axi4lite_awprot, s2_axi4lite_awprot, s3_axi4lite_awprot });
        assign s_axi4lite_awvalids  = ('{s0_axi4lite_awvalid,s1_axi4lite_awvalid,s2_axi4lite_awvalid,s3_axi4lite_awvalid});
        assign s_axi4lite_wdatas    = ('{s0_axi4lite_wdata,  s1_axi4lite_wdata,  s2_axi4lite_wdata,  s3_axi4lite_wdata  });
        assign s_axi4lite_wstrbs    = ('{s0_axi4lite_wstrb,  s1_axi4lite_wstrb,  s2_axi4lite_wstrb,  s3_axi4lite_wstrb  });
        assign s_axi4lite_wvalids   = ('{s0_axi4lite_wvalid, s1_axi4lite_wvalid, s2_axi4lite_wvalid, s3_axi4lite_wvalid });
        assign s_axi4lite_araddrs   = ('{s0_axi4lite_araddr, s1_axi4lite_araddr, s2_axi4lite_araddr, s3_axi4lite_araddr });
        assign s_axi4lite_arprots   = ('{s0_axi4lite_arprot, s1_axi4lite_arprot, s2_axi4lite_arprot, s3_axi4lite_arprot });
        assign s_axi4lite_arvalids  = ('{s0_axi4lite_arvalid,s1_axi4lite_arvalid,s2_axi4lite_arvalid,s3_axi4lite_arvalid});
        assign {s0_axi4lite_awready,     s1_axi4lite_awready,     s2_axi4lite_awready,     s3_axi4lite_awready}
             = {s_axi4lite_awreadies[0], s_axi4lite_awreadies[1], s_axi4lite_awreadies[2], s_axi4lite_awreadies[3]};
        assign {s0_axi4lite_wready,      s1_axi4lite_wready,      s2_axi4lite_wready,      s3_axi4lite_wready}
             = {s_axi4lite_wreadies[0],  s_axi4lite_wreadies[1],  s_axi4lite_wreadies[2],  s_axi4lite_wreadies[3]};
        assign {s0_axi4lite_arready,     s1_axi4lite_arready,     s2_axi4lite_arready,     s3_axi4lite_arready}
             = {s_axi4lite_arreadies[0], s_axi4lite_arreadies[1], s_axi4lite_arreadies[2], s_axi4lite_arreadies[3]};
    
        assign s_axi4lite_breadies  = ('{s0_axi4lite_bready, s1_axi4lite_bready, s2_axi4lite_bready, s3_axi4lite_bready });
        assign s_axi4lite_rreadies  = ('{s0_axi4lite_rready, s1_axi4lite_rready, s2_axi4lite_rready, s3_axi4lite_rready });
        assign {s0_axi4lite_bresp,     s1_axi4lite_bresp,     s2_axi4lite_bresp,     s3_axi4lite_bresp}
             = {s_axi4lite_bresps[0],  s_axi4lite_bresps[1],  s_axi4lite_bresps[2],  s_axi4lite_bresps[3]};
        assign {s0_axi4lite_bvalid,    s1_axi4lite_bvalid,    s2_axi4lite_bvalid,    s3_axi4lite_bvalid}
             = {s_axi4lite_bvalids[0], s_axi4lite_bvalids[1], s_axi4lite_bvalids[2], s_axi4lite_bvalids[3]};
        assign {s0_axi4lite_rdata,     s1_axi4lite_rdata,     s2_axi4lite_rdata,     s3_axi4lite_rdata}
             = {s_axi4lite_rdatas[0],  s_axi4lite_rdatas[1],  s_axi4lite_rdatas[2],  s_axi4lite_rdatas[3]};
        assign {s0_axi4lite_rresp,     s1_axi4lite_rresp,     s2_axi4lite_rresp,     s3_axi4lite_rresp}
             = {s_axi4lite_rresps[0],  s_axi4lite_rresps[1],  s_axi4lite_rresps[2],  s_axi4lite_rresps[3]};
        assign {s0_axi4lite_rvalid,    s1_axi4lite_rvalid,    s2_axi4lite_rvalid,    s3_axi4lite_rvalid}
             = {s_axi4lite_rvalids[0], s_axi4lite_rvalids[1], s_axi4lite_rvalids[2], s_axi4lite_rvalids[3]};
    
        for (genvar axi4lite_if = 0; axi4lite_if < NUM_AXI4LITE_S_INTERFACES; axi4lite_if = axi4lite_if + 1)
        begin: gen_axi4lite_interface
            intel_axi4lite_injector_ph2_axi4lite_slave #(
                .ACTIVE              (NUM_ACTIVE_AXI4LITE_S_INTERFACES > axi4lite_if),
                .AXI4LITE_ADDR_WIDTH (AXI4LITE_ADDR_WIDTH),
                .AXI4LITE_DATA_WIDTH (AXI4LITE_DATA_WIDTH),
                .RDATA_SLICEID_WIDTH (RWDATA_SLICEID_WIDTH),
                .FIFO_DEPTH_LOG2     (AXI4LITE_FIFO_DEPTH_LOG2)
            ) axi4lite_slave_inst (
                .s_axi4lite_aclk                 (s_axi4lite_aclks    [axi4lite_if]),   
                .s_axi4lite_aresetn              (s_axi4lite_aresetns [axi4lite_if]), 
                .s_axi4lite_awaddr               (s_axi4lite_awaddrs  [axi4lite_if]), 
                .s_axi4lite_awprot               (s_axi4lite_awprots  [axi4lite_if]), 
                .s_axi4lite_awvalid              (s_axi4lite_awvalids [axi4lite_if]),
                .s_axi4lite_awready              (s_axi4lite_awreadies[axi4lite_if]), 
                .s_axi4lite_wdata                (s_axi4lite_wdatas   [axi4lite_if]),  
                .s_axi4lite_wstrb                (s_axi4lite_wstrbs   [axi4lite_if]),  
                .s_axi4lite_wvalid               (s_axi4lite_wvalids  [axi4lite_if]), 
                .s_axi4lite_wready               (s_axi4lite_wreadies [axi4lite_if]),   
                .s_axi4lite_bresp                (s_axi4lite_bresps   [axi4lite_if]),  
                .s_axi4lite_bvalid               (s_axi4lite_bvalids  [axi4lite_if]), 
                .s_axi4lite_bready               (s_axi4lite_breadies [axi4lite_if]), 
                .s_axi4lite_araddr               (s_axi4lite_araddrs  [axi4lite_if]), 
                .s_axi4lite_arprot               (s_axi4lite_arprots  [axi4lite_if]), 
                .s_axi4lite_arvalid              (s_axi4lite_arvalids [axi4lite_if]),
                .s_axi4lite_arready              (s_axi4lite_arreadies[axi4lite_if]),
                .s_axi4lite_rdata                (s_axi4lite_rdatas   [axi4lite_if]),  
                .s_axi4lite_rresp                (s_axi4lite_rresps   [axi4lite_if]),  
                .s_axi4lite_rvalid               (s_axi4lite_rvalids  [axi4lite_if]), 
                .s_axi4lite_rready               (s_axi4lite_rreadies [axi4lite_if]),    
                .m_axi4lite_aclk                 (m_axi4_aclk),    
                .m_axi4lite_aresetn              (m_axi4_aresetn), 
                .m_axi4lite_awaddr               (internal_axi4lite_awaddrs     [axi4lite_if]), 
                .m_axi4lite_awprot               (internal_axi4lite_awprots     [axi4lite_if]), 
                .m_axi4lite_awvalid              (internal_axi4lite_awvalids    [axi4lite_if]),
                .m_axi4lite_awready              (internal_axi4lite_awreadies   [axi4lite_if]), 
                .m_axi4lite_wdata                (internal_axi4lite_wdatas      [axi4lite_if]),  
                .m_axi4lite_wstrb                (internal_axi4lite_wstrbs      [axi4lite_if]),  
                .m_axi4lite_wvalid               (internal_axi4lite_wvalids     [axi4lite_if]), 
                .m_axi4lite_wready               (internal_axi4lite_wreadies    [axi4lite_if]),   
                .m_axi4lite_bresp                (internal_axi4lite_bresps      [axi4lite_if]),  
                .m_axi4lite_bvalid               (internal_axi4lite_bvalids     [axi4lite_if]), 
                .m_axi4lite_bready               (internal_axi4lite_breadies    [axi4lite_if]), 
                .m_axi4lite_araddr               (internal_axi4lite_araddrs     [axi4lite_if]), 
                .m_axi4lite_arprot               (internal_axi4lite_arprots     [axi4lite_if]), 
                .m_axi4lite_arvalid              (internal_axi4lite_arvalids    [axi4lite_if]),
                .m_axi4lite_arready              (internal_axi4lite_arreadies   [axi4lite_if]),
                .m_axi4lite_rdata                (internal_axi4lite_rdatas      [axi4lite_if]),  
                .m_axi4lite_rresp                (internal_axi4lite_rresps      [axi4lite_if]),  
                .m_axi4lite_rvalid               (internal_axi4lite_rvalids     [axi4lite_if]), 
                .m_axi4lite_rready               (internal_axi4lite_rreadies    [axi4lite_if]),    
                .rdata_slice_selector_sliceid    (rdata_slice_selector_sliceids [axi4lite_if]),  
                .rdata_slice_selector_valid      (rdata_slice_selector_valids   [axi4lite_if]),  
                .rdata_slice_selector_ready      (rdata_slice_selector_readies  [axi4lite_if]),
                .arbitrated_ar_requests_in_flight(arbitrated_axi4lite_ar_requests_in_flight[axi4lite_if]),
                .arbitrated_aw_requests_in_flight(arbitrated_axi4lite_aw_requests_in_flight[axi4lite_if]),
                .alarm                           (axi4lite_slave_alarm          [axi4lite_if])  
            );
            assign internal_axi4lite_aww_valids[axi4lite_if] = internal_axi4lite_awvalids[axi4lite_if] 
                                                             & internal_axi4lite_wvalids [axi4lite_if];
        end
    
    
        localparam CHANNEL_ID_WIDTH = $clog2(NUM_AXI4LITE_S_INTERFACES-1);
    
        wire                        internal_axi4lite_ar_arbitration_has_result;
        wire [CHANNEL_ID_WIDTH-1:0] internal_axi4lite_ar_arbitration_winner_id;
    
        wire                        internal_axi4lite_aww_arbitration_has_result;
        wire [CHANNEL_ID_WIDTH-1:0] internal_axi4lite_aww_arbitration_winner_id;
    
        intel_axi4lite_injector_ph2_axi4lite_channel_arbiter #(
            .NUM_CHANNELS          (NUM_AXI4LITE_S_INTERFACES),
            .NUM_ACTIVE_CHANNELS   (NUM_ACTIVE_AXI4LITE_S_INTERFACES),
            .REQUEST_COUNTER_WIDTH (AXI4LITE_FIFO_DEPTH_LOG2)
        ) axi4lite_ar_arbiter (
            .aclk                   (m_axi4_aclk),
            .aresetn                (m_axi4_aresetn),
            .channel_valids         (internal_axi4lite_arvalids),
            .requests_in_flight     (arbitrated_axi4lite_ar_requests_in_flight),
            .arbitration_has_result (internal_axi4lite_ar_arbitration_has_result),
            .arbitration_winner_id  (internal_axi4lite_ar_arbitration_winner_id)        
        );
    
        intel_axi4lite_injector_ph2_axi4lite_channel_arbiter #(
            .NUM_CHANNELS          (NUM_AXI4LITE_S_INTERFACES),
            .NUM_ACTIVE_CHANNELS   (NUM_ACTIVE_AXI4LITE_S_INTERFACES),
            .REQUEST_COUNTER_WIDTH (AXI4LITE_FIFO_DEPTH_LOG2)
        ) axi4lite_aww_arbiter (
            .aclk                   (m_axi4_aclk),
            .aresetn                (m_axi4_aresetn),
            .channel_valids         (internal_axi4lite_aww_valids),
            .requests_in_flight     (arbitrated_axi4lite_aw_requests_in_flight),
            .arbitration_has_result (internal_axi4lite_aww_arbitration_has_result),
            .arbitration_winner_id  (internal_axi4lite_aww_arbitration_winner_id)        
        );
    
    
        wire ar_merge_ready;
        wire aww_merge_ready;
    
        for (genvar axi4lite_if = 0; axi4lite_if < NUM_AXI4LITE_S_INTERFACES; axi4lite_if = axi4lite_if + 1) 
        begin: gen_internal_axi4lite_backpressure  
            assign internal_axi4lite_arreadies[axi4lite_if] = 
               (internal_axi4lite_ar_arbitration_winner_id == axi4lite_if) & ar_merge_ready;
            assign internal_axi4lite_awreadies[axi4lite_if] = 
               (internal_axi4lite_aww_arbitration_winner_id == axi4lite_if) & aww_merge_ready;
            assign internal_axi4lite_wreadies[axi4lite_if] =
               internal_axi4lite_awreadies[axi4lite_if];
        end
    
        intel_axi4lite_injector_ph2_ax_channel_merge #(
            .NUM_ACTIVE_AXI4_S_INTERFACES (NUM_ACTIVE_AXI4_S_INTERFACES),
            .INIU_AXI4_ID_WIDTH           (INIU_AXI4_ID_WIDTH),
            .INIU_AXI4_ADDR_WIDTH         (INIU_AXI4_ADDR_WIDTH),
            .INIU_AXI4_AXUSER_WIDTH       (INIU_AXI4_ARUSER_WIDTH),
            .AXI4LITE_DATA_WIDTH          (AXI4LITE_DATA_WIDTH),
            .AXI4LITE_QOS                 (AXI4LITE_QOS),
            .TRACK_AXI4_S_W_TRANSFERS     (0),
            .AXI4_S_TRANSFER_MULTIPLE     (AXI4_S_TRANSFER_MULTIPLE),
            .FIFO_DEPTH_LOG2              (AXI4_S_FIFO_DEPTH_LOG2)
        ) axi4_ar_merge (
            .aclk                 (m_axi4_aclk),
            .aresetn              (m_axi4_aresetn),
            .axi4lite_interface_id({{(INIU_AXI4_ID_WIDTH-CHANNEL_ID_WIDTH-1){1'b0}},
                                   internal_axi4lite_ar_arbitration_winner_id}),
            .axi4lite_axaddr      (internal_axi4lite_araddrs [internal_axi4lite_ar_arbitration_winner_id]),   
            .axi4lite_axprot      (internal_axi4lite_arprots [internal_axi4lite_ar_arbitration_winner_id]),  
            .axi4lite_axvalid     (internal_axi4lite_arvalids[internal_axi4lite_ar_arbitration_winner_id]),  
            .axi4lite_axready     (ar_merge_ready),
            .s_axi4_axid          (internal_s_axi4_arid),   
            .s_axi4_axaddr        (internal_s_axi4_araddr), 
            .s_axi4_axlen         (internal_s_axi4_arlen),  
            .s_axi4_axsize        (internal_s_axi4_arsize), 
            .s_axi4_axburst       (internal_s_axi4_arburst),
            .s_axi4_axlock        (internal_s_axi4_arlock), 
            .s_axi4_axprot        (internal_s_axi4_arprot), 
            .s_axi4_axqos         (internal_s_axi4_arqos),  
            .s_axi4_axuser        (internal_s_axi4_aruser), 
            .s_axi4_axvalid       (internal_s_axi4_arvalid),
            .s_axi4_axready       (internal_s_axi4_arready),
            .s_axi4_wlast         (),
            .s_axi4_wvalid        (),
            .s_axi4_wready        (),
            .m_axi4_axid          (m_axi4_arid),   
            .m_axi4_axaddr        (m_axi4_araddr), 
            .m_axi4_axlen         (m_axi4_arlen),  
            .m_axi4_axsize        (m_axi4_arsize), 
            .m_axi4_axburst       (m_axi4_arburst),
            .m_axi4_axlock        (m_axi4_arlock), 
            .m_axi4_axprot        (m_axi4_arprot), 
            .m_axi4_axqos         (m_axi4_arqos),  
            .m_axi4_axuser        (m_axi4_aruser), 
            .m_axi4_axvalid       (m_axi4_arvalid),
            .m_axi4_axready       (m_axi4_arready),
            .m_axi4_wready        ()
        );
    
        intel_axi4lite_injector_ph2_ax_channel_merge #(
            .NUM_ACTIVE_AXI4_S_INTERFACES (NUM_ACTIVE_AXI4_S_INTERFACES),
            .INIU_AXI4_ID_WIDTH           (INIU_AXI4_ID_WIDTH),
            .INIU_AXI4_ADDR_WIDTH         (INIU_AXI4_ADDR_WIDTH),
            .INIU_AXI4_AXUSER_WIDTH       (INIU_AXI4_ARUSER_WIDTH),
            .AXI4LITE_DATA_WIDTH          (AXI4LITE_DATA_WIDTH),
            .AXI4LITE_QOS                 (AXI4LITE_QOS),
            .TRACK_AXI4_S_W_TRANSFERS     (1),
            .AXI4_S_TRANSFER_MULTIPLE     (AXI4_S_TRANSFER_MULTIPLE),
            .FIFO_DEPTH_LOG2              (AXI4_S_FIFO_DEPTH_LOG2)
        ) axi4_aw_merge (
            .aclk                         (m_axi4_aclk),
            .aresetn                      (m_axi4_aresetn),
            .axi4lite_interface_id        ({{(INIU_AXI4_ID_WIDTH-CHANNEL_ID_WIDTH-1){1'b0}},
                                           internal_axi4lite_aww_arbitration_winner_id}),
            .axi4lite_axaddr              (internal_axi4lite_awaddrs [internal_axi4lite_aww_arbitration_winner_id]),   
            .axi4lite_axprot              (internal_axi4lite_awprots [internal_axi4lite_aww_arbitration_winner_id]),  
            .axi4lite_axvalid             (internal_axi4lite_aww_valids[internal_axi4lite_aww_arbitration_winner_id]),  
            .axi4lite_axready             (aww_merge_ready),
            .s_axi4_axid                  (internal_s_axi4_awid),   
            .s_axi4_axaddr                (internal_s_axi4_awaddr), 
            .s_axi4_axlen                 (internal_s_axi4_awlen),  
            .s_axi4_axsize                (internal_s_axi4_awsize), 
            .s_axi4_axburst               (internal_s_axi4_awburst),
            .s_axi4_axlock                (internal_s_axi4_awlock), 
            .s_axi4_axprot                (internal_s_axi4_awprot), 
            .s_axi4_axqos                 (internal_s_axi4_awqos),  
            .s_axi4_axuser                (internal_s_axi4_awuser), 
            .s_axi4_axvalid               (internal_s_axi4_awvalid),
            .s_axi4_axready               (internal_s_axi4_awready),
            .s_axi4_wlast                 (internal_s_axi4_wlast),
            .s_axi4_wvalid                (internal_s_axi4_wvalid),
            .s_axi4_wready                (internal_s_axi4_wready),
            .m_axi4_axid                  (m_axi4_awid),   
            .m_axi4_axaddr                (m_axi4_awaddr), 
            .m_axi4_axlen                 (m_axi4_awlen),  
            .m_axi4_axsize                (m_axi4_awsize), 
            .m_axi4_axburst               (m_axi4_awburst),
            .m_axi4_axlock                (m_axi4_awlock), 
            .m_axi4_axprot                (m_axi4_awprot), 
            .m_axi4_axqos                 (m_axi4_awqos),  
            .m_axi4_axuser                (m_axi4_awuser), 
            .m_axi4_axvalid               (m_axi4_awvalid),
            .m_axi4_axready               (m_axi4_awready),
            .m_axi4_wready                (m_axi4_wready)
        );
    
    
        assign wdata_slice_selector_sliceid 
             = internal_axi4lite_awaddrs[internal_axi4lite_aww_arbitration_winner_id]
                                        [$clog2(AXI4LITE_DATA_WIDTH/8)+:RWDATA_SLICEID_WIDTH];
    
        intel_axi4lite_injector_ph2_w_channel_merge #(
            .NUM_ACTIVE_AXI4_S_INTERFACES (NUM_ACTIVE_AXI4_S_INTERFACES),
            .INIU_AXI4_DATA_WIDTH         (INIU_AXI4_DATA_WIDTH),
            .AXI4LITE_DATA_WIDTH          (AXI4LITE_DATA_WIDTH),
            .WDATA_SLICEID_WIDTH          (RWDATA_SLICEID_WIDTH)
        ) axi4_w_merge (
            .aclk                         (m_axi4_aclk),
            .aresetn                      (m_axi4_aresetn),
            .axi4lite_wdata               (internal_axi4lite_wdatas [internal_axi4lite_aww_arbitration_winner_id]),    
            .axi4lite_wstrb               (internal_axi4lite_wstrbs [internal_axi4lite_aww_arbitration_winner_id]),
            .axi4lite_wvalid              (internal_axi4lite_aww_valids[internal_axi4lite_aww_arbitration_winner_id]),  
            .axi4lite_wready              (aww_merge_ready),
            .wdata_slice_selector_sliceid (wdata_slice_selector_sliceid),
            .s_axi4_wdata                 (internal_s_axi4_wdata),  
            .s_axi4_wstrb                 (internal_s_axi4_wstrb),  
            .s_axi4_wlast                 (internal_s_axi4_wlast),  
            .s_axi4_wuser                 (internal_s_axi4_wuser),  
            .s_axi4_wvalid                (internal_s_axi4_wvalid), 
            .s_axi4_wready                (internal_s_axi4_wready), 
            .m_axi4_wdata                 (m_axi4_wdata),  
            .m_axi4_wstrb                 (m_axi4_wstrb),  
            .m_axi4_wlast                 (m_axi4_wlast),  
            .m_axi4_wuser                 (m_axi4_wuser),  
            .m_axi4_wvalid                (m_axi4_wvalid)
        );
    
    
        intel_axi4lite_injector_ph2_write_response_demultiplexer #(
            .INIU_AXI4_ID_WIDTH               (INIU_AXI4_ID_WIDTH),
            .NUM_AXI4LITE_S_INTERFACES        (NUM_AXI4LITE_S_INTERFACES),
            .NUM_ACTIVE_AXI4LITE_S_INTERFACES (NUM_ACTIVE_AXI4LITE_S_INTERFACES),
            .NUM_ACTIVE_AXI4_S_INTERFACES     (NUM_ACTIVE_AXI4_S_INTERFACES)
        ) write_response_demultiplexer (
            .aclk               (m_axi4_aclk),
            .aresetn            (m_axi4_aresetn),
            .m_axi4_bid         (m_axi4_bid),
            .m_axi4_bresp       (m_axi4_bresp),
            .m_axi4_bvalid      (m_axi4_bvalid),
            .m_axi4_bready      (m_axi4_bready), 
            .s_axi4_bid         (internal_s_axi4_bid),
            .s_axi4_bresp       (internal_s_axi4_bresp),
            .s_axi4_bvalid      (internal_s_axi4_bvalid),
            .s_axi4_bready      (internal_s_axi4_bready), 
            .s_axi4lite_bresps  (internal_axi4lite_bresps),
            .s_axi4lite_bvalids (internal_axi4lite_bvalids),
            .s_axi4lite_breadies(internal_axi4lite_breadies), 
            .alarm              (write_response_demultiplexer_alarm)
        );
    
        intel_axi4lite_injector_ph2_read_response_demultiplexer #(
            .INIU_AXI4_ID_WIDTH               (INIU_AXI4_ID_WIDTH),
            .INIU_AXI4_DATA_WIDTH             (INIU_AXI4_DATA_WIDTH),
            .AXI4LITE_DATA_WIDTH              (AXI4LITE_DATA_WIDTH),
            .RDATA_SLICEID_WIDTH              (RWDATA_SLICEID_WIDTH),
            .NUM_AXI4LITE_S_INTERFACES        (NUM_AXI4LITE_S_INTERFACES),
            .NUM_ACTIVE_AXI4LITE_S_INTERFACES (NUM_ACTIVE_AXI4LITE_S_INTERFACES),
            .NUM_ACTIVE_AXI4_S_INTERFACES     (NUM_ACTIVE_AXI4_S_INTERFACES),
            .BUFFER_AXI4_S_READ_RESPONSES     (BUFFER_AXI4_S_READ_RESPONSES)
        ) read_response_demultiplexer (
            .aclk                         (m_axi4_aclk),
            .aresetn                      (m_axi4_aresetn),
            .s_axi4_rid                   (internal_s_axi4_rid),
            .s_axi4_rdata                 (internal_s_axi4_rdata),
            .s_axi4_rresp                 (internal_s_axi4_rresp),
            .s_axi4_rlast                 (internal_s_axi4_rlast),
            .s_axi4_ruser                 (internal_s_axi4_ruser),
            .s_axi4_rvalid                (internal_s_axi4_rvalid),
            .s_axi4_rready                (internal_s_axi4_rready), 
            .m_axi4_rid                   (m_axi4_rid),
            .m_axi4_rdata                 (m_axi4_rdata),
            .m_axi4_rresp                 (m_axi4_rresp),
            .m_axi4_rlast                 (m_axi4_rlast),
            .m_axi4_ruser                 (m_axi4_ruser),
            .m_axi4_rvalid                (m_axi4_rvalid),
            .m_axi4_rready                (m_axi4_rready), 
            .s_axi4lite_rdatas            (internal_axi4lite_rdatas),
            .s_axi4lite_rresps            (internal_axi4lite_rresps),
            .s_axi4lite_rvalids           (internal_axi4lite_rvalids),
            .s_axi4lite_rreadies          (internal_axi4lite_rreadies), 
            .rdata_slice_selector_sliceids(rdata_slice_selector_sliceids),
            .rdata_slice_selector_valids  (rdata_slice_selector_valids),
            .rdata_slice_selector_readies (rdata_slice_selector_readies),
            .alarm                        (read_response_demultiplexer_alarm)
        );

    end else begin: adjust_axi4_id_widths

        assign s_axi4_awready = m_axi4_awready;
        assign s_axi4_wready  = m_axi4_wready; 
        assign s_axi4_bid     = m_axi4_bid[INIU_AXI4_ID_WIDTH-2:0];   
        assign s_axi4_bresp   = m_axi4_bresp;  
        assign s_axi4_bvalid  = m_axi4_bvalid; 
        assign s_axi4_arready = m_axi4_arready;
        assign s_axi4_rid     = m_axi4_rid[INIU_AXI4_ID_WIDTH-2:0];   
        assign s_axi4_rdata   = m_axi4_rdata;
        assign s_axi4_rresp   = m_axi4_rresp;
        assign s_axi4_rlast   = m_axi4_rlast;
        assign s_axi4_ruser   = m_axi4_ruser;
        assign s_axi4_rvalid  = m_axi4_rvalid;
        assign m_axi4_awid    = {1'b0, s_axi4_awid};   
        assign m_axi4_awaddr  = s_axi4_awaddr; 
        assign m_axi4_awlen   = s_axi4_awlen;  
        assign m_axi4_awsize  = s_axi4_awsize; 
        assign m_axi4_awburst = s_axi4_awburst;
        assign m_axi4_awlock  = s_axi4_awlock; 
        assign m_axi4_awprot  = s_axi4_awprot; 
        assign m_axi4_awqos   = s_axi4_awqos;  
        assign m_axi4_awuser  = s_axi4_awuser; 
        assign m_axi4_awvalid = s_axi4_awvalid;
        assign m_axi4_wdata   = s_axi4_wdata;  
        assign m_axi4_wstrb   = s_axi4_wstrb;  
        assign m_axi4_wlast   = s_axi4_wlast;  
        assign m_axi4_wuser   = s_axi4_wuser;  
        assign m_axi4_wvalid  = s_axi4_wvalid; 
        assign m_axi4_bready  = s_axi4_bready;  
        assign m_axi4_arid    = {1'b0, s_axi4_arid};     
        assign m_axi4_araddr  = s_axi4_araddr;   
        assign m_axi4_arlen   = s_axi4_arlen;    
        assign m_axi4_arsize  = s_axi4_arsize;   
        assign m_axi4_arburst = s_axi4_arburst;  
        assign m_axi4_arlock  = s_axi4_arlock;   
        assign m_axi4_arprot  = s_axi4_arprot;   
        assign m_axi4_arqos   = s_axi4_arqos;    
        assign m_axi4_aruser  = s_axi4_aruser;   
        assign m_axi4_arvalid = s_axi4_arvalid;  
        assign m_axi4_rready  = s_axi4_rready;

    end
    endgenerate

endmodule

/* Per-slave logic.

   This module adapts the user-facing AXI Lite interface (in its own clock domain) to an internal
   interface in the INIU clock domain. The internal interface includes the usual AXI4 Lite AR, 
   AW, R, W, and B channels as well as an rdata slice selection FIFO to assist the read response
   demultiplexer. This is needed because the AXI Lite response bits will be a slice of the wider 
   read response from the INIU. That happens because the AXI Lite transfer is implemented as an
   AXI4 narrow transfer, in which the base address of a data beat is always a multiple of the 
   fundamental transfer width. 

   Per-slave logic includes command and response counters, the difference between which is used
   to override the FIFO reades on the AR, AW, and W channels. This limits the number of commands
   or responses in-transit and thereby ensures that the response FIFOs can never fill up. 

   For the same reason the FIFO used to convey read slice IDs to the read response demultiplexer
   should never fill up. This presumption is based on all FIFOs having the same depth! 

   This module tracks the slave's in-flight requests in two different ways:

   1. In order to prevent FIFO overflow due to the arrival of responses that have been handed
      off to the NOC, there is a AW/AR pair of counts of the total number of requests received 
      from the user design and for which the user has not accepted the corresponding response.
      This includes requests within the AR, AW, and W FIFOs. These counters exist in the user
      clock domain. 

   2. The second kind of in-flight counter is intended to support arbitration. These counters
      are similar to the FIFO-control counters but do not count requests within the AR and AW 
      FIFOs. The AXI-Lite arbitration stage prefers interfaces that have the least number of
      recently accepted transactions - and uses this information to back-pressure the AR and AW
      FIFOs. Therefore transactions within those FIFOs cannot be counted as "accepted".
      Being intended for use in arbitration, these counters operate in the downstream clock
      domain.      
*/

module intel_axi4lite_injector_ph2_axi4lite_slave #(
    parameter  ACTIVE              = 0,
    parameter  AXI4LITE_ADDR_WIDTH = 44,
    parameter  AXI4LITE_DATA_WIDTH = 32,
    parameter  RDATA_SLICEID_WIDTH = 3,
    parameter  FIFO_DEPTH_LOG2     = 5,
    localparam FIFO_DEPTH          = (1 << FIFO_DEPTH_LOG2)
) (
    input  wire                                s_axi4lite_aclk,     
    input  wire                                s_axi4lite_aresetn,
    input  wire  [AXI4LITE_ADDR_WIDTH-1:0]     s_axi4lite_awaddr,   
    input  wire  [2:0]                         s_axi4lite_awprot,   
    input  wire                                s_axi4lite_awvalid,  
    output logic                               s_axi4lite_awready,
    input  wire  [AXI4LITE_DATA_WIDTH-1:0]     s_axi4lite_wdata,    
    input  wire  [(AXI4LITE_DATA_WIDTH/8)-1:0] s_axi4lite_wstrb,    
    input  wire                                s_axi4lite_wvalid,   
    output logic                               s_axi4lite_wready,
    output logic [1:0]                         s_axi4lite_bresp,    
    output logic                               s_axi4lite_bvalid,   
    input  wire                                s_axi4lite_bready,
    input  wire  [AXI4LITE_ADDR_WIDTH-1:0]     s_axi4lite_araddr,   
    input  wire  [2:0]                         s_axi4lite_arprot,   
    input  wire                                s_axi4lite_arvalid,  
    output logic                               s_axi4lite_arready,
    output logic [AXI4LITE_DATA_WIDTH-1:0]     s_axi4lite_rdata,    
    output logic [1:0]                         s_axi4lite_rresp,    
    output logic                               s_axi4lite_rvalid,
    input  wire                                s_axi4lite_rready,   
    input  wire                                m_axi4lite_aclk,     
    input  wire                                m_axi4lite_aresetn,
    output logic [AXI4LITE_ADDR_WIDTH-1:0]     m_axi4lite_awaddr,   
    output logic [2:0]                         m_axi4lite_awprot,   
    output logic                               m_axi4lite_awvalid,  
    input  wire                                m_axi4lite_awready,
    output logic [AXI4LITE_DATA_WIDTH-1:0]     m_axi4lite_wdata,    
    output logic [(AXI4LITE_DATA_WIDTH/8)-1:0] m_axi4lite_wstrb,    
    output logic                               m_axi4lite_wvalid,   
    input  wire                                m_axi4lite_wready,
    input  wire [1:0]                          m_axi4lite_bresp,    
    input  wire                                m_axi4lite_bvalid,   
    output logic                               m_axi4lite_bready,
    output logic [AXI4LITE_ADDR_WIDTH-1:0]     m_axi4lite_araddr,   
    output logic [2:0]                         m_axi4lite_arprot,   
    output logic                               m_axi4lite_arvalid,  
    input  wire                                m_axi4lite_arready,
    input  wire [AXI4LITE_DATA_WIDTH-1:0]      m_axi4lite_rdata,    
    input  wire [1:0]                          m_axi4lite_rresp,    
    input  wire                                m_axi4lite_rvalid,   
    output logic                               m_axi4lite_rready,  
    output logic [RDATA_SLICEID_WIDTH-1:0]     rdata_slice_selector_sliceid,  
    output logic                               rdata_slice_selector_valid,  
    input  wire                                rdata_slice_selector_ready,
    output logic [FIFO_DEPTH_LOG2-1:0]         arbitrated_ar_requests_in_flight,
    output logic [FIFO_DEPTH_LOG2-1:0]         arbitrated_aw_requests_in_flight,
    output logic                               alarm  
);

    initial begin
        assert ((AXI4LITE_DATA_WIDTH == 32) || (AXI4LITE_DATA_WIDTH == 64));
    end

    logic [FIFO_DEPTH_LOG2-1:0] r_occupancy;
    logic [FIFO_DEPTH_LOG2-1:0] b_occupancy;
    logic [FIFO_DEPTH_LOG2-1:0] ar_requests_outstanding_downstream;
    logic [FIFO_DEPTH_LOG2-1:0] aw_requests_outstanding_downstream;

    generate
        if (!ACTIVE) begin : gen_inactive_slave 

            assign s_axi4lite_arready               = 1'b0;      
            assign s_axi4lite_rdata                 = {(AXI4LITE_DATA_WIDTH){1'b0}};     
            assign s_axi4lite_rresp                 = 2'b0;     
            assign s_axi4lite_rvalid                = 1'b0;    
            assign s_axi4lite_awready               = 1'b0;
            assign s_axi4lite_wready                = 1'b0;
            assign s_axi4lite_bresp                 = 2'b0;     
            assign s_axi4lite_bvalid                = 1'b0;
            assign m_axi4lite_arvalid               = 1'b0;
            assign m_axi4lite_araddr                = {(AXI4LITE_ADDR_WIDTH){1'b0}};
            assign m_axi4lite_arprot                = 3'b0;
            assign m_axi4lite_rready                = 1'b1;
            assign m_axi4lite_awvalid               = 1'b0;
            assign m_axi4lite_awaddr                = {(AXI4LITE_ADDR_WIDTH){1'b0}};
            assign m_axi4lite_awprot                = 3'b0;
            assign m_axi4lite_wvalid                = 1'b0;
            assign m_axi4lite_wdata                 = {(AXI4LITE_DATA_WIDTH){1'b0}};     
            assign m_axi4lite_wstrb                 = {(AXI4LITE_DATA_WIDTH / 8){1'b0}};     
            assign m_axi4lite_bready                = 1'b1;
            assign rdata_slice_selector_sliceid     = {(RDATA_SLICEID_WIDTH){1'b0}};
            assign rdata_slice_selector_valid       = 1'b0;
            assign r_occupancy                      = {(FIFO_DEPTH_LOG2){1'b0}};
            assign b_occupancy                      = {(FIFO_DEPTH_LOG2){1'b0}};
            assign arbitrated_ar_requests_in_flight = {(FIFO_DEPTH_LOG2){1'b0}};
            assign arbitrated_aw_requests_in_flight = {(FIFO_DEPTH_LOG2){1'b0}};
            assign alarm                            = 1'b0;

        end else begin : gen_active_slave

            logic ar_fifo_upstream_valid, ar_fifo_upstream_ready;
            logic aw_fifo_upstream_valid, aw_fifo_upstream_ready;
            logic w_fifo_upstream_valid,  w_fifo_upstream_ready;
            
            intel_axi4lite_injector_ph2_clock_crossing_fifo #(
                .WIDTH                    (AXI4LITE_ADDR_WIDTH + 3 /* prot */),
                .LOG2_DEPTH               (FIFO_DEPTH_LOG2),
                .UPSTREAM_READY_LATENCY   (0),
                .DOWNSTREAM_READY_LATENCY (0)
            ) ar_cc_fifo (
                .upstream_clk       (s_axi4lite_aclk),
                .upstream_aresetn   (s_axi4lite_aresetn),
                .upstream_ready     (ar_fifo_upstream_ready),           
                .upstream_valid     (ar_fifo_upstream_valid),            
                .upstream_data      ({s_axi4lite_araddr,s_axi4lite_arprot}),
                .downstream_clk     (m_axi4lite_aclk),
                .downstream_aresetn (m_axi4lite_aresetn),
                .downstream_ready   (m_axi4lite_arready),           
                .downstream_valid   (m_axi4lite_arvalid),            
                .downstream_data    ({m_axi4lite_araddr,m_axi4lite_arprot}),
                .upstream_occupancy ()
            ); 
            intel_axi4lite_injector_ph2_clock_crossing_fifo #(
                .WIDTH                    (AXI4LITE_DATA_WIDTH + 2 /* resp */),
                .LOG2_DEPTH               (FIFO_DEPTH_LOG2),
                .UPSTREAM_READY_LATENCY   (0),
                .DOWNSTREAM_READY_LATENCY (0)
            ) r_cc_fifo (
                .upstream_clk       (m_axi4lite_aclk),
                .upstream_aresetn   (m_axi4lite_aresetn),
                .upstream_ready     (m_axi4lite_rready),           
                .upstream_valid     (m_axi4lite_rvalid),            
                .upstream_data      ({m_axi4lite_rdata,m_axi4lite_rresp}),
                .downstream_clk     (s_axi4lite_aclk),
                .downstream_aresetn (s_axi4lite_aresetn),
                .downstream_ready   (s_axi4lite_rready),           
                .downstream_valid   (s_axi4lite_rvalid),            
                .downstream_data    ({s_axi4lite_rdata,s_axi4lite_rresp}),
                .upstream_occupancy (r_occupancy)
            );  
            intel_axi4lite_injector_ph2_clock_crossing_fifo #(
                .WIDTH                    (AXI4LITE_ADDR_WIDTH + 3 /* prot */),
                .LOG2_DEPTH               (FIFO_DEPTH_LOG2),
                .UPSTREAM_READY_LATENCY   (0),
                .DOWNSTREAM_READY_LATENCY (0)
            ) aw_cc_fifo (
                .upstream_clk       (s_axi4lite_aclk),
                .upstream_aresetn   (s_axi4lite_aresetn),
                .upstream_ready     (aw_fifo_upstream_ready),           
                .upstream_valid     (aw_fifo_upstream_valid),            
                .upstream_data      ({s_axi4lite_awaddr,s_axi4lite_awprot}),
                .downstream_clk     (m_axi4lite_aclk),
                .downstream_aresetn (m_axi4lite_aresetn),
                .downstream_ready   (m_axi4lite_awready),           
                .downstream_valid   (m_axi4lite_awvalid),            
                .downstream_data    ({m_axi4lite_awaddr,m_axi4lite_awprot}),
                .upstream_occupancy ()
            ); 
            intel_axi4lite_injector_ph2_clock_crossing_fifo #(
                .WIDTH                    (AXI4LITE_DATA_WIDTH + (AXI4LITE_DATA_WIDTH/8)),
                .LOG2_DEPTH               (FIFO_DEPTH_LOG2),
                .UPSTREAM_READY_LATENCY   (0),
                .DOWNSTREAM_READY_LATENCY (0)
            ) w_cc_fifo (
                .upstream_clk       (s_axi4lite_aclk),
                .upstream_aresetn   (s_axi4lite_aresetn),
                .upstream_ready     (w_fifo_upstream_ready),           
                .upstream_valid     (w_fifo_upstream_valid),            
                .upstream_data      ({s_axi4lite_wdata,s_axi4lite_wstrb}),
                .downstream_clk     (m_axi4lite_aclk),
                .downstream_aresetn (m_axi4lite_aresetn),
                .downstream_ready   (m_axi4lite_wready),           
                .downstream_valid   (m_axi4lite_wvalid),            
                .downstream_data    ({m_axi4lite_wdata,m_axi4lite_wstrb}),
                .upstream_occupancy ()
            ); 
            intel_axi4lite_injector_ph2_clock_crossing_fifo #(
                .WIDTH                    (2 /* resp*/ ),
                .LOG2_DEPTH               (FIFO_DEPTH_LOG2),
                .UPSTREAM_READY_LATENCY   (0),
                .DOWNSTREAM_READY_LATENCY (0)
            ) b_cc_fifo (
                .upstream_clk       (m_axi4lite_aclk),
                .upstream_aresetn   (m_axi4lite_aresetn),
                .upstream_ready     (m_axi4lite_bready),           
                .upstream_valid     (m_axi4lite_bvalid),            
                .upstream_data      (m_axi4lite_bresp),
                .downstream_clk     (s_axi4lite_aclk),
                .downstream_aresetn (s_axi4lite_aresetn),
                .downstream_ready   (s_axi4lite_bready),           
                .downstream_valid   (s_axi4lite_bvalid),            
                .downstream_data    (s_axi4lite_bresp),
                .upstream_occupancy (b_occupancy)
            );  


            logic rdata_slice_selector_fifo_ready; 

            intel_axi4lite_injector_ph2_fifo #(
                .WIDTH                    (RDATA_SLICEID_WIDTH),
                .LOG2_DEPTH               (FIFO_DEPTH_LOG2),
                .UPSTREAM_READY_LATENCY   (0),
                .DOWNSTREAM_READY_LATENCY (0)
            ) rdata_slice_selector_fifo (
                .aclk             (m_axi4lite_aclk),
                .aresetn          (m_axi4lite_aresetn),
                .upstream_ready   (rdata_slice_selector_fifo_ready),           
                .upstream_valid   (m_axi4lite_arvalid & m_axi4lite_arready),            
                .upstream_data    (m_axi4lite_araddr[$clog2(AXI4LITE_DATA_WIDTH/8)+:RDATA_SLICEID_WIDTH]),
                .downstream_ready (rdata_slice_selector_ready),           
                .downstream_valid (rdata_slice_selector_valid),            
                .downstream_data  (rdata_slice_selector_sliceid)
            );  


            logic [FIFO_DEPTH_LOG2-1:0] read_commands_in_flight;
            logic [FIFO_DEPTH_LOG2-1:0] write_commands_in_flight;
            logic [FIFO_DEPTH_LOG2-1:0] write_data_in_flight;
            logic sufficient_r_response_buffering;
            logic sufficient_b_response_buffering;
            
            logic new_read_command;
            logic new_read_response;
            logic new_write_command;
            logic new_write_data;
            logic new_write_response;

            assign new_read_command   = (s_axi4lite_arready & s_axi4lite_arvalid);
            assign new_read_response  = (s_axi4lite_rready  & s_axi4lite_rvalid);
            assign new_write_command  = (s_axi4lite_awready & s_axi4lite_awvalid);
            assign new_write_data     = (s_axi4lite_wready  & s_axi4lite_wvalid);
            assign new_write_response = (s_axi4lite_bready  & s_axi4lite_bvalid);

            always @(posedge s_axi4lite_aclk or negedge s_axi4lite_aresetn) begin
                 if (~s_axi4lite_aresetn) begin
                     read_commands_in_flight  <= {(FIFO_DEPTH_LOG2){1'b0}};
                     write_commands_in_flight <= {(FIFO_DEPTH_LOG2){1'b0}};
                     write_data_in_flight     <= {(FIFO_DEPTH_LOG2){1'b0}};
                     sufficient_r_response_buffering <= 1'b0;
                     sufficient_b_response_buffering <= 1'b0;
                 end else begin
                     read_commands_in_flight  <= read_commands_in_flight  - new_read_response  + new_read_command;
                     write_commands_in_flight <= write_commands_in_flight - new_write_response + new_write_command;
                     write_data_in_flight     <= write_data_in_flight     - new_write_response + new_write_data;
                     sufficient_r_response_buffering <= (read_commands_in_flight < (FIFO_DEPTH-2));
                     sufficient_b_response_buffering <= (  (write_commands_in_flight < (FIFO_DEPTH-2)) 
                                                         & (write_data_in_flight     < (FIFO_DEPTH-2)));
                 end   
            end

            assign s_axi4lite_arready = ar_fifo_upstream_ready & sufficient_r_response_buffering;
            assign s_axi4lite_awready = aw_fifo_upstream_ready & sufficient_b_response_buffering;
            assign s_axi4lite_wready  = w_fifo_upstream_ready  & sufficient_b_response_buffering;
            assign ar_fifo_upstream_valid = s_axi4lite_arvalid & sufficient_r_response_buffering;
            assign aw_fifo_upstream_valid = s_axi4lite_awvalid & sufficient_b_response_buffering;
            assign w_fifo_upstream_valid  = s_axi4lite_wvalid  & sufficient_b_response_buffering;


            always @(posedge m_axi4lite_aclk or negedge m_axi4lite_aresetn) begin
                if (~m_axi4lite_aresetn) begin
                    ar_requests_outstanding_downstream <= {(FIFO_DEPTH_LOG2){1'b0}};
                    aw_requests_outstanding_downstream <= {(FIFO_DEPTH_LOG2){1'b0}};
                end else begin
                    ar_requests_outstanding_downstream <= ar_requests_outstanding_downstream 
                                                        + (m_axi4lite_arvalid & m_axi4lite_arready)
                                                        - (m_axi4lite_rvalid  & m_axi4lite_rready);
                    aw_requests_outstanding_downstream <= aw_requests_outstanding_downstream 
                                                        + (m_axi4lite_awvalid & m_axi4lite_awready)
                                                        - (m_axi4lite_bvalid  & m_axi4lite_bready);
                end
            end

            assign arbitrated_ar_requests_in_flight = ar_requests_outstanding_downstream + r_occupancy;
            assign arbitrated_aw_requests_in_flight = aw_requests_outstanding_downstream + b_occupancy;


            logic internal_alarm;

            always @(posedge m_axi4lite_aclk or negedge m_axi4lite_aresetn) begin
                if (~m_axi4lite_aresetn) begin
                    internal_alarm <= 1'b0;
                end else begin
                    logic rdata_slice_selector_fifo_overflow;
                    rdata_slice_selector_fifo_overflow = m_axi4lite_arvalid 
                                                       & m_axi4lite_arready
                                                       & m_axi4lite_rready
                                                       & ~rdata_slice_selector_fifo_ready;
                    internal_alarm <= internal_alarm | rdata_slice_selector_fifo_overflow; 
                end
            end

            assign alarm = internal_alarm;

        end
    endgenerate
    
endmodule 

/* AXI-Lite arbitration

   The same arbitration logic is used for AR and AW, and is supposed to sit downstream
   of a set of clock-crossing FIFOs from the user's clock domain. 
   It also receives the in-flight request/response counts computed by the module owning the
   clock crossing FIFOs. These include all requests selected by arbitration and responses 
   that are buffered on their way to the user clock domain. Requests sitting in input 
   FIFOs are not taken into consideration.   

   User backpressure can result in in-flight count reflecting responsesu waiting in FIFOs 
   feeding the user design. That is useful because when user logic is not ready to receive
   results, commands from another soure should be preferred. 

   Arbitration uses a tree-structure to compare the in-flight command counts, and this
   implementation is hard-coded for a maximum of 4 AXI Lite interfaces. 
   However the principle is extensible to a larger number of interfaces.

   Note: since the comparison is multi-stage with registers between stages, "last winner" 
         state within the comparison module cannot take account of whether the
         previous cycle's winner won in the arbitration against mainband traffic.
         Therefore intermediate winner values will "ping-pong" when the candidates have
         the same number of in-flight requests. In a pathological case this may lead to 
         starvation - when mainband arbitration accepts every other AXI-Lite arbitration
         winner, and that AXI-Lite channel is consuming responses at exactly the same rate
         at which it is generating requests.
         
   The "comparison" sub-module immediately following the main module declaration performs
   a two-way comparison based on the in-flight transaction count, FIFO ready, and 
   previous winner status. 
*/

module intel_axi4lite_injector_ph2_axi4lite_channel_arbiter #(
    parameter  NUM_CHANNELS          = 4,
    parameter  NUM_ACTIVE_CHANNELS   = NUM_CHANNELS,
    parameter  REQUEST_COUNTER_WIDTH = 6,
    localparam CHANNEL_ID_WIDTH      = $clog2(NUM_CHANNELS-1)
) (
    input  wire                              aclk,        
    input  wire                              aresetn,
    input  wire                              channel_valids    [NUM_CHANNELS],
    input  wire  [REQUEST_COUNTER_WIDTH-1:0] requests_in_flight[NUM_CHANNELS],
    output logic                             arbitration_has_result,
    output logic [CHANNEL_ID_WIDTH-1:0]      arbitration_winner_id        
);

    initial begin
        assert (NUM_CHANNELS == 4);
        assert (NUM_ACTIVE_CHANNELS <= NUM_CHANNELS); 
    end

    generate


        wire [CHANNEL_ID_WIDTH-1:0]       stage1_winner_id[NUM_CHANNELS/2];
        wire                              stage1_winner_has_pending_requests[NUM_CHANNELS/2];
        wire [REQUEST_COUNTER_WIDTH-1:0]  stage1_winner_requests_in_flight[NUM_CHANNELS/2];
    
        if (NUM_ACTIVE_CHANNELS < 2) begin: gen_dummy_stage1_reduction

            assign stage1_winner_requests_in_flight[0] = {(REQUEST_COUNTER_WIDTH){1'b0}};
            assign stage1_winner_id[0]                 = {(CHANNEL_ID_WIDTH){1'b0}};

        end else begin: gen_stage1_reduction
     
            for (genvar stage1_check = 0; stage1_check < (NUM_CHANNELS+1)/2; stage1_check = stage1_check + 1) 
            begin: gen_stage1_check

                if (stage1_check < (NUM_ACTIVE_CHANNELS+1)/2)
                begin: gen_stage1_check_inst
                    intel_axi4lite_injector_ph2_axi4lite_channel_arbiter_comparison #(
                        .CHANNEL_ID_WIDTH      (CHANNEL_ID_WIDTH),
                        .REQUEST_COUNTER_WIDTH (REQUEST_COUNTER_WIDTH)
                    ) comparison (
                        .aclk                        (aclk),
                        .aresetn                     (aresetn),
                        .channel_ids                 ('{stage1_check*2, 
                                                        stage1_check*2+1}),
                        .has_pending_requests        ('{channel_valids[stage1_check*2], 
                                                        channel_valids[stage1_check*2+1]}),
                        .requests_in_flight          ('{requests_in_flight[stage1_check*2],
                                                        requests_in_flight[stage1_check*2+1]}),
                        .winner_id                   (stage1_winner_id[stage1_check]),
                        .winner_has_pending_requests (stage1_winner_has_pending_requests[stage1_check]),
                        .winner_requests_in_flight   (stage1_winner_requests_in_flight[stage1_check])
                    );
                end else begin: gen_stage1_check_dummy
                    assign stage1_winner_id[stage1_check]                   = {(CHANNEL_ID_WIDTH){1'b0}};
                    assign stage1_winner_has_pending_requests[stage1_check] = 1'b0;
                    assign stage1_winner_requests_in_flight[stage1_check]   = {REQUEST_COUNTER_WIDTH {1'b0}};
                end
            end    
        end


        
        if (NUM_ACTIVE_CHANNELS < 2) begin: gen_predetermined_winner

            assign arbitration_has_result     = (NUM_ACTIVE_CHANNELS == 0) ? 1'b0
                                                                           : channel_valids[0];
            assign arbitration_winner_id      = {(CHANNEL_ID_WIDTH){1'b0}};

        end else begin: gen_final_comparison

            intel_axi4lite_injector_ph2_axi4lite_channel_arbiter_comparison #(
                .CHANNEL_ID_WIDTH      (CHANNEL_ID_WIDTH),
                .REQUEST_COUNTER_WIDTH (REQUEST_COUNTER_WIDTH)
            ) comparison (
                .aclk                        (aclk),
                .aresetn                     (aresetn),
                .channel_ids                 ('{stage1_winner_id[0], 
                                                stage1_winner_id[1]}),
                .has_pending_requests        ('{stage1_winner_has_pending_requests[0], 
                                                stage1_winner_has_pending_requests[1]}),
                .requests_in_flight          ('{stage1_winner_requests_in_flight[0],
                                                stage1_winner_requests_in_flight[1]}),
                .winner_id                   (arbitration_winner_id),
                .winner_has_pending_requests (arbitration_has_result),
                .winner_requests_in_flight   ()
            );
        end 
    endgenerate

endmodule


module intel_axi4lite_injector_ph2_axi4lite_channel_arbiter_comparison #(
    parameter CHANNEL_ID_WIDTH = 2,
    parameter REQUEST_COUNTER_WIDTH = 6
) (
    input  wire  aclk,
    input  wire  aresetn,
    input  wire  [CHANNEL_ID_WIDTH-1:0]       channel_ids[2],
    input  wire                               has_pending_requests[2],
    input  wire  [REQUEST_COUNTER_WIDTH-1:0]  requests_in_flight[2],
    output logic [CHANNEL_ID_WIDTH-1:0]       winner_id,
    output logic                              winner_has_pending_requests,
    output logic [REQUEST_COUNTER_WIDTH-1:0]  winner_requests_in_flight
);

    wire is_candidate[2]; 
    wire winner;
    reg  last_winner;

    assign is_candidate[0] = has_pending_requests[0] 
                            & (requests_in_flight[0] <= requests_in_flight[1]);
    assign is_candidate[1] = has_pending_requests[1] 
                            & (requests_in_flight[1] <= requests_in_flight[0]);

    assign winner = (~is_candidate[0]) ? 1'b1
                  : (~is_candidate[1]) ? 1'b0
                                       : ~last_winner;

    always @(posedge aclk or negedge aresetn) begin
        if (~aresetn) begin
            last_winner                 <= 1'b0;
            winner_id                   <= {CHANNEL_ID_WIDTH {1'b0}};
            winner_has_pending_requests <= 1'b0;
            winner_requests_in_flight   <= {REQUEST_COUNTER_WIDTH {1'b0}};
        end else begin
            last_winner <= has_pending_requests[winner] ? winner : last_winner; 
            winner_id                   <= channel_ids[winner];
            winner_has_pending_requests <= has_pending_requests[winner];
            winner_requests_in_flight   <= requests_in_flight[winner];
        end
    end

endmodule

/* Ax channel merge module

   This module merges AXI-Lite command traffic onto the mainband interface.
   In the case of write commands, this action is coordinated with the W channel merge
   module. The W coordination takes wlast into account, so that a write command and
   its accompanying data from are injected at the same point in the mainband streams 
   to the INIU. When write tracking is enabled, the axilite_axvalid signal should
   only be asserted by external logic when _both_ the AW and W channels of the AXI 
   lite inteface have data available.  

   Write commands and data are taken from the AXI-Lite interface in the same cycle.
   There is only one AXI-Lite command interface, as arbitration between AXI-Lite
   interfaces is expected to occur between the customer facing interfaces and this
   module.   

   The module is parameterizable for read and write command interfaces; when merging
   read commands the TRACK_AXI4_S_W_TRANSFERS parameter should be set to zero. Then the
   wlast and wvalid inputs will be ignored, and wready will be driven to zero. 

   Since AW and W transfers need to be coordinated it is necessary to implement a
   FIFO on the upstream S_AXI4 AW channel, and delay acceptance of an S_AXI4 AW command
   until its data becomes available on W.

   The FIFO is optional on AR. Set FIFO_DEPTH_LOG2 to zero if a FIFO should not be
   instantiated. 

   AXI IDs are generated by prepending '1' for AXI-Lite transactions, and using the 
   ID of the originating interface for the low-order bits. 

   This module implements an AXI-Lite ingress limiter by matching a transfer from the
   output of the AXI-Lite domain with one or more data beats on the mainband interface. 
   Thus AXI-lite to AXI4 mainband transfer ratios of 1:1 (50%), 1:2 (33%), 1:3 (25%) 
   all the way through to 1:31 (3%) are possible. 

   TODO: wready de-assertion behaviour on the s_axi4 interface must be AXI-compliant or
         mediated by a FIFO, unless that interface isn't enabled. 

   TODO: Try to implement the S_AXI4 command interface without a FIFO. 

   TODO: (potentially) take flag indicating whether to ignore the AXI-Lite interface

*/

module intel_axi4lite_injector_ph2_ax_channel_merge #(
    parameter        NUM_ACTIVE_AXI4_S_INTERFACES = 4,
    parameter        INIU_AXI4_ID_WIDTH = 7,       
    parameter        INIU_AXI4_ADDR_WIDTH = 44,     
    parameter        INIU_AXI4_AXUSER_WIDTH = 11,  
    parameter        AXI4LITE_DATA_WIDTH = 32,         
    parameter  [3:0] AXI4LITE_QOS = 4'b0,
    parameter        TRACK_AXI4_S_W_TRANSFERS = 0,
    parameter        AXI4_S_TRANSFER_MULTIPLE = 9,
    parameter        FIFO_DEPTH_LOG2 = 5,              
    localparam       MAX_AXI4_S_TRANSFER_MULTIPLE = 63
) (
    input  wire                               aclk,
    input  wire                               aresetn,
    input  wire  [INIU_AXI4_ID_WIDTH-2:0]     axi4lite_interface_id,   
    input  wire  [INIU_AXI4_ADDR_WIDTH-1:0]   axi4lite_axaddr,
    input  wire  [2:0]                        axi4lite_axprot,
    input  wire                               axi4lite_axvalid,
    output logic                              axi4lite_axready,
    input  wire  [INIU_AXI4_ID_WIDTH-2:0]     s_axi4_axid,   
    input  wire  [INIU_AXI4_ADDR_WIDTH-1:0]   s_axi4_axaddr, 
    input  wire  [7:0]                        s_axi4_axlen,  
    input  wire  [2:0]                        s_axi4_axsize, 
    input  wire  [1:0]                        s_axi4_axburst,
    input  wire                               s_axi4_axlock, 
    input  wire  [2:0]                        s_axi4_axprot, 
    input  wire  [3:0]                        s_axi4_axqos,  
    input  wire  [INIU_AXI4_AXUSER_WIDTH-1:0] s_axi4_axuser, 
    input  wire                               s_axi4_axvalid,
    output logic                              s_axi4_axready,
    input  wire                               s_axi4_wlast,  
    input  wire                               s_axi4_wvalid, 
    output logic                              s_axi4_wready, 
    output logic [INIU_AXI4_ID_WIDTH-1:0]     m_axi4_axid,     
    output logic [INIU_AXI4_ADDR_WIDTH-1:0]   m_axi4_axaddr,   
    output logic [7:0]                        m_axi4_axlen,    
    output logic [2:0]                        m_axi4_axsize,   
    output logic [1:0]                        m_axi4_axburst,  
    output logic                              m_axi4_axlock,   
    output logic [2:0]                        m_axi4_axprot,   
    output logic [3:0]                        m_axi4_axqos,    
    output logic [INIU_AXI4_AXUSER_WIDTH-1:0] m_axi4_axuser,   
    output logic                              m_axi4_axvalid,  
    input  wire                               m_axi4_axready,
    input  wire                               m_axi4_wready
);
    initial begin
        assert ((NUM_ACTIVE_AXI4_S_INTERFACES == 0) || (NUM_ACTIVE_AXI4_S_INTERFACES == 1));
        assert ((TRACK_AXI4_S_W_TRANSFERS == 0) || (TRACK_AXI4_S_W_TRANSFERS == 1));
        assert ((FIFO_DEPTH_LOG2 > 0) || (TRACK_AXI4_S_W_TRANSFERS == 0) || (NUM_ACTIVE_AXI4_S_INTERFACES == 0));  
        assert ((AXI4_S_TRANSFER_MULTIPLE > 0) && (AXI4_S_TRANSFER_MULTIPLE <= MAX_AXI4_S_TRANSFER_MULTIPLE));
    end


    wire  [INIU_AXI4_ID_WIDTH-2:0]     internal_axi4_axid;   
    wire  [INIU_AXI4_ADDR_WIDTH-1:0]   internal_axi4_axaddr; 
    wire  [7:0]                        internal_axi4_axlen;  
    wire  [2:0]                        internal_axi4_axsize; 
    wire  [1:0]                        internal_axi4_axburst;
    wire                               internal_axi4_axlock; 
    wire  [2:0]                        internal_axi4_axprot; 
    wire  [3:0]                        internal_axi4_axqos;  
    wire  [INIU_AXI4_AXUSER_WIDTH-1:0] internal_axi4_axuser; 
    wire                               internal_axi4_axvalid;
    wire                               internal_axi4_axready;

    generate
        if ((FIFO_DEPTH_LOG2 == 0) || (NUM_ACTIVE_AXI4_S_INTERFACES == 0)) begin: gen_s_axi4_command_passthrough

            assign internal_axi4_axid    = s_axi4_axid;
            assign internal_axi4_axaddr  = s_axi4_axaddr;
            assign internal_axi4_axlen   = s_axi4_axlen;
            assign internal_axi4_axsize  = s_axi4_axsize;
            assign internal_axi4_axburst = s_axi4_axburst;
            assign internal_axi4_axlock  = s_axi4_axlock;
            assign internal_axi4_axprot  = s_axi4_axprot;
            assign internal_axi4_axqos   = s_axi4_axqos;
            assign internal_axi4_axuser  = s_axi4_axuser; 
            assign internal_axi4_axvalid = s_axi4_axvalid;
            assign s_axi4_axready        = internal_axi4_axready;

        end else begin: gen_s_axi4_command_fifo

            intel_axi4lite_injector_ph2_fifo #(
                .WIDTH                    ((INIU_AXI4_ID_WIDTH-1) + INIU_AXI4_ADDR_WIDTH + 8 + 3 + 2  + 1  + 3 + 4 + INIU_AXI4_AXUSER_WIDTH),
                .LOG2_DEPTH               (FIFO_DEPTH_LOG2),                        
                .UPSTREAM_READY_LATENCY   (0),  
                .DOWNSTREAM_READY_LATENCY (0)   
            ) mainband_command_fifo (
                .aclk             (aclk),
                .aresetn          (aresetn),
                .upstream_ready   (s_axi4_axready),           
                .upstream_valid   (s_axi4_axvalid),            
                .upstream_data    ({s_axi4_axid,
                                    s_axi4_axaddr,
                                    s_axi4_axlen,
                                    s_axi4_axsize,
                                    s_axi4_axburst,
                                    s_axi4_axlock,
                                    s_axi4_axprot,
                                    s_axi4_axqos,
                                    s_axi4_axuser}), 
                .downstream_ready (internal_axi4_axready),           
                .downstream_valid (internal_axi4_axvalid),            
                .downstream_data  ({internal_axi4_axid,
                                    internal_axi4_axaddr,
                                    internal_axi4_axlen,
                                    internal_axi4_axsize,
                                    internal_axi4_axburst,
                                    internal_axi4_axlock,
                                    internal_axi4_axprot,
                                    internal_axi4_axqos,
                                    internal_axi4_axuser}) 
            );

        end

    endgenerate

    
    logic has_outstanding_axi4_s_wdata_transfers;

    generate

        if (TRACK_AXI4_S_W_TRANSFERS == 0) begin: no_w_transfer_tracking

            assign has_outstanding_axi4_s_wdata_transfers = 1'b0;

        end else begin: w_transfer_tracking  

            always @(posedge aclk or negedge aresetn) begin
                if (~aresetn) begin
                    has_outstanding_axi4_s_wdata_transfers <= 1'b0;
                end else begin
                    if (internal_axi4_axvalid & internal_axi4_axready) begin
                        has_outstanding_axi4_s_wdata_transfers <= ~s_axi4_wlast;
                    end else if (has_outstanding_axi4_s_wdata_transfers & 
                                 (s_axi4_wvalid & s_axi4_wready & s_axi4_wlast)) begin
                        has_outstanding_axi4_s_wdata_transfers <= 1'b0;
                    end
                end
            end

        end

    endgenerate


    localparam AXI4_S_TRANSFER_COUNT_WIDTH = $clog2(MAX_AXI4_S_TRANSFER_MULTIPLE);

    logic [AXI4_S_TRANSFER_COUNT_WIDTH-1:0] unmatched_axi4_s_transfer_count;
    wire  [AXI4_S_TRANSFER_COUNT_WIDTH:0]   next_unmatched_axi4_s_transfer_count;
    wire                                    prefer_to_merge_axi4lite;

    assign next_unmatched_axi4_s_transfer_count 
         = ~(m_axi4_axready & m_axi4_axvalid)              ? {1'b0,unmatched_axi4_s_transfer_count}
         : (internal_axi4_axready & internal_axi4_axvalid) ? unmatched_axi4_s_transfer_count 
                                                             + internal_axi4_axlen[AXI4_S_TRANSFER_COUNT_WIDTH:0] + 1'b1
         : (unmatched_axi4_s_transfer_count < AXI4_S_TRANSFER_MULTIPLE) ? {(AXI4_S_TRANSFER_COUNT_WIDTH+1){1'b0}}
                                                                        : unmatched_axi4_s_transfer_count 
                                                                          - AXI4_S_TRANSFER_MULTIPLE[AXI4_S_TRANSFER_COUNT_WIDTH:0];

    always @(posedge aclk or negedge aresetn) begin
        if (~aresetn) begin
            unmatched_axi4_s_transfer_count <= {(AXI4_S_TRANSFER_COUNT_WIDTH){1'b0}};
        end else begin
            unmatched_axi4_s_transfer_count <= (next_unmatched_axi4_s_transfer_count > MAX_AXI4_S_TRANSFER_MULTIPLE) 
                                             ? MAX_AXI4_S_TRANSFER_MULTIPLE 
                                             : next_unmatched_axi4_s_transfer_count[0 +: AXI4_S_TRANSFER_COUNT_WIDTH];
        end
    end

    assign prefer_to_merge_axi4lite = ((NUM_ACTIVE_AXI4_S_INTERFACES == 0) || 
                                       (unmatched_axi4_s_transfer_count >= AXI4_S_TRANSFER_MULTIPLE));



    wire merge_axi4lite;

    generate

        if (TRACK_AXI4_S_W_TRANSFERS == 0) begin: no_w_transfer_merge

            assign axi4lite_axready      = m_axi4_axready
                                         & (axi4lite_axvalid)
                                         & (prefer_to_merge_axi4lite || ~internal_axi4_axvalid);
            assign internal_axi4_axready = m_axi4_axready 
                                         & ~(prefer_to_merge_axi4lite & axi4lite_axvalid);
            assign merge_axi4lite = axi4lite_axready;

        end else begin: w_transfer_merge


            assign axi4lite_axready      = (m_axi4_axready & m_axi4_wready) 
                                         & (axi4lite_axvalid)
                                         & (prefer_to_merge_axi4lite || ~internal_axi4_axvalid)
                                         & ~has_outstanding_axi4_s_wdata_transfers;
            assign internal_axi4_axready = (m_axi4_axready & m_axi4_wready)
                                         & (s_axi4_wvalid) 
                                         & ~(prefer_to_merge_axi4lite & axi4lite_axvalid)
                                         & ~has_outstanding_axi4_s_wdata_transfers;
            assign merge_axi4lite = axi4lite_axready;
            assign s_axi4_wready = m_axi4_wready 
                                 & (has_outstanding_axi4_s_wdata_transfers ||
                                    (internal_axi4_axready & internal_axi4_axvalid));

        end
 
    endgenerate


    localparam axi4lite_axsize = $clog2(AXI4LITE_DATA_WIDTH / 8);

    assign m_axi4_axid    = merge_axi4lite ? {1'b1,axi4lite_interface_id}     : {1'b0,internal_axi4_axid};
    assign m_axi4_axaddr  = merge_axi4lite ? axi4lite_axaddr                  : internal_axi4_axaddr;
    assign m_axi4_axlen   = merge_axi4lite ? 8'b0                             : internal_axi4_axlen;
    assign m_axi4_axsize  = merge_axi4lite ? axi4lite_axsize                  : internal_axi4_axsize;
    assign m_axi4_axburst = merge_axi4lite ? 2'b01 /* INCR */                 : internal_axi4_axburst;
    assign m_axi4_axlock  = merge_axi4lite ? 2'b00                            : internal_axi4_axlock;
    assign m_axi4_axprot  = merge_axi4lite ? axi4lite_axprot                  : internal_axi4_axprot;
    assign m_axi4_axqos   = merge_axi4lite ? AXI4LITE_QOS                     : internal_axi4_axqos;
    assign m_axi4_axuser  = merge_axi4lite ? {(INIU_AXI4_AXUSER_WIDTH){1'b0}} : internal_axi4_axuser;
    assign m_axi4_axvalid = merge_axi4lite ? axi4lite_axvalid                 : (internal_axi4_axvalid & internal_axi4_axready);
    
endmodule

/* W channel merge

   Unusually, the upstream W channel readies are inputs - that is because the 
   AW and W activity need to be coordinated in a single place, which is the 
   Ax merge module. 

   The downstream (INIU) wready is not used here because it is taken into account
   in the AW merge decision performed by the Ax merge module. 

   TODO: (potentially) take flag indicating whether to ignore the AXI-Lite interface
*/ 

module intel_axi4lite_injector_ph2_w_channel_merge #(
    parameter NUM_ACTIVE_AXI4_S_INTERFACES = 4,
    parameter INIU_AXI4_DATA_WIDTH = 256,
    parameter AXI4LITE_DATA_WIDTH = 32,
    parameter WDATA_SLICEID_WIDTH = 3
) (
    input  wire                                 aclk,
    input  wire                                 aresetn,
    input  wire  [AXI4LITE_DATA_WIDTH-1:0]      axi4lite_wdata,
    input  wire  [(AXI4LITE_DATA_WIDTH/8)-1:0]  axi4lite_wstrb,
    input  wire                                 axi4lite_wvalid,
    input  wire                                 axi4lite_wready,
    input  wire  [WDATA_SLICEID_WIDTH-1:0]      wdata_slice_selector_sliceid,
    input  wire  [INIU_AXI4_DATA_WIDTH-1:0]     s_axi4_wdata,  
    input  wire  [(INIU_AXI4_DATA_WIDTH/8)-1:0] s_axi4_wstrb,  
    input  wire                                 s_axi4_wlast,  
    input  wire  [(INIU_AXI4_DATA_WIDTH/8)-1:0] s_axi4_wuser,  
    input  wire                                 s_axi4_wvalid, 
    input  wire                                 s_axi4_wready, 
    output logic [INIU_AXI4_DATA_WIDTH-1:0]     m_axi4_wdata,  
    output logic [(INIU_AXI4_DATA_WIDTH/8)-1:0] m_axi4_wstrb,  
    output logic                                m_axi4_wlast,  
    output logic [(INIU_AXI4_DATA_WIDTH/8)-1:0] m_axi4_wuser,  
    output logic                                m_axi4_wvalid
);

    initial begin
        assert ((NUM_ACTIVE_AXI4_S_INTERFACES == 0) || (NUM_ACTIVE_AXI4_S_INTERFACES == 1));
        assert ((AXI4LITE_DATA_WIDTH == 32) || (AXI4LITE_DATA_WIDTH == 64));
        assert((INIU_AXI4_DATA_WIDTH % AXI4LITE_DATA_WIDTH) == 0);
    end


    localparam NUM_WDATA_SLICES    = INIU_AXI4_DATA_WIDTH/AXI4LITE_DATA_WIDTH;

    wire [(INIU_AXI4_DATA_WIDTH/8)-1:0] widened_axi4lite_wstrb;

    generate
        for (genvar wdata_sliceid = 0; wdata_sliceid < NUM_WDATA_SLICES; wdata_sliceid = wdata_sliceid + 1)
        begin: gen_wdata_sliceid
            assign widened_axi4lite_wstrb[(wdata_sliceid*(AXI4LITE_DATA_WIDTH/8)) +:(AXI4LITE_DATA_WIDTH/8)]
                 = (wdata_sliceid == wdata_slice_selector_sliceid) ? axi4lite_wstrb
                                                                   : {(AXI4LITE_DATA_WIDTH/8){1'b0}}; 
        end
    endgenerate

    generate
        if (NUM_ACTIVE_AXI4_S_INTERFACES == 0) begin: gen_axi4lite_wdata_passthrough
            assign m_axi4_wdata  = {(INIU_AXI4_DATA_WIDTH/AXI4LITE_DATA_WIDTH){axi4lite_wdata}};
            assign m_axi4_wstrb  = widened_axi4lite_wstrb;
            assign m_axi4_wlast  = 1'b1;
            assign m_axi4_wuser  = {(INIU_AXI4_DATA_WIDTH/8){1'b0}};
            assign m_axi4_wvalid = axi4lite_wvalid;
        end else begin: gen_wdata_selector
            assign m_axi4_wdata  = axi4lite_wready ? {(INIU_AXI4_DATA_WIDTH/AXI4LITE_DATA_WIDTH){axi4lite_wdata}}
                                                   : s_axi4_wdata;
            assign m_axi4_wstrb  = axi4lite_wready ? widened_axi4lite_wstrb           : s_axi4_wstrb;
            assign m_axi4_wlast  = axi4lite_wready ? 1'b1                             : s_axi4_wlast;
            assign m_axi4_wuser  = axi4lite_wready ? {(INIU_AXI4_DATA_WIDTH/8){1'b0}} : s_axi4_wuser;
            assign m_axi4_wvalid = axi4lite_wready ? axi4lite_wvalid                  : (s_axi4_wvalid & s_axi4_wready);
        end
    endgenerate

endmodule

/* Write response demultiplexer

   The BID bits are used to steer the response to the correct slave interface of the IP:
   * top bit indicates whether the response must go to a user AXI4Lite interface
   * the bottom 2 bits indicate which AXI4lite interface the response goes to.

   For this reason the AXI ID port facing the user design is 1 bit narrower than the 
   INIU-facing port. 

   An MLAB FIFO is employed on the B channel to the mainband slave interface, so that 
   brief periods of mainband backpressure do not interfere with the flow of AXI4Lite write 
   responses. Since the write response data path is so narrow, only a single MLAB is required. 

   It is assumed that the AXI4Lite interfaces already have FIFOs, and that the flow of
   AXI4Lite commands has been throttled so that those FIFOs will never overflow. Therefore
   backpressure from any of the AXI4Lite B channels is treated as an error condition. 
*/

module intel_axi4lite_injector_ph2_write_response_demultiplexer #(
    parameter INIU_AXI4_ID_WIDTH                 = 7,
    parameter NUM_AXI4LITE_S_INTERFACES          = 4, 
    parameter NUM_ACTIVE_AXI4LITE_S_INTERFACES   = 1,
    parameter NUM_ACTIVE_AXI4_S_INTERFACES       = 1
) (
    input  wire                          aclk,
    input  wire                          aresetn,
    output wire [INIU_AXI4_ID_WIDTH-2:0] s_axi4_bid,
    output wire [1:0]                    s_axi4_bresp,
    output wire                          s_axi4_bvalid,
    input  wire                          s_axi4_bready, 
    input  wire [INIU_AXI4_ID_WIDTH-1:0] m_axi4_bid,
    input  wire [1:0]                    m_axi4_bresp,
    input  wire                          m_axi4_bvalid,
    output wire                          m_axi4_bready, 
    output wire [1:0]                    s_axi4lite_bresps  [NUM_AXI4LITE_S_INTERFACES],
    output wire                          s_axi4lite_bvalids [NUM_AXI4LITE_S_INTERFACES],
    input  wire                          s_axi4lite_breadies[NUM_AXI4LITE_S_INTERFACES], 
    output wire                          alarm
);
    initial begin
        assert (NUM_ACTIVE_AXI4LITE_S_INTERFACES <= NUM_AXI4LITE_S_INTERFACES);
        assert (NUM_AXI4LITE_S_INTERFACES    <= 4);
        assert (NUM_ACTIVE_AXI4_S_INTERFACES <= 1);
    end


    generate
        if (NUM_ACTIVE_AXI4_S_INTERFACES == 0) begin: gen_dummy_axi4_s_interface
            assign s_axi4_bvalid = 1'b0;
            assign s_axi4_bid    = {(INIU_AXI4_ID_WIDTH){1'b0}};
            assign s_axi4_bresp  = 2'b0;
            assign m_axi4_bready = 1'b1;
        end else begin: gen_real_axi4_s_interface
            intel_axi4lite_injector_ph2_fifo #(
                .WIDTH                    ((INIU_AXI4_ID_WIDTH-1)+2),  
                .LOG2_DEPTH               (5),                         
                .UPSTREAM_READY_LATENCY   (0),  
                .DOWNSTREAM_READY_LATENCY (0)   
            ) mainband_b_fifo (
                .aclk             (aclk),
                .aresetn          (aresetn),
                .upstream_ready   (m_axi4_bready),           
                .upstream_valid   (m_axi4_bvalid & ~m_axi4_bid[INIU_AXI4_ID_WIDTH-1]),            
                .upstream_data    ({m_axi4_bid[(INIU_AXI4_ID_WIDTH-2):0],m_axi4_bresp}), 
                .downstream_ready (s_axi4_bready),           
                .downstream_valid (s_axi4_bvalid),            
                .downstream_data  ({s_axi4_bid,s_axi4_bresp})
            );
        end
    endgenerate


    generate
        for (genvar dest_axi4lite_b_channel = 0; dest_axi4lite_b_channel < NUM_AXI4LITE_S_INTERFACES; dest_axi4lite_b_channel = dest_axi4lite_b_channel + 1)
        begin: gen_dest_axi4lite_b_channel
            if (dest_axi4lite_b_channel >= NUM_ACTIVE_AXI4LITE_S_INTERFACES) begin
                assign s_axi4lite_bvalids[dest_axi4lite_b_channel] = 1'b0;
                assign s_axi4lite_bresps[dest_axi4lite_b_channel]  = 2'b0;
            end else begin
                assign s_axi4lite_bvalids[dest_axi4lite_b_channel] = m_axi4_bvalid 
                                                                   & m_axi4_bid[INIU_AXI4_ID_WIDTH-1]
                                                                   & (m_axi4_bid[1:0] == dest_axi4lite_b_channel);
                assign s_axi4lite_bresps[dest_axi4lite_b_channel]  = m_axi4_bresp;
            end
        end
    endgenerate


    logic internal_alarm;

    always @(posedge aclk or negedge aresetn) begin
        if (~aresetn) begin
            internal_alarm <= 1'b0;
        end else begin
            internal_alarm <= m_axi4_bvalid 
                            & m_axi4_bid[INIU_AXI4_ID_WIDTH-1] 
                            & ~s_axi4lite_breadies[m_axi4_bid[1:0]]; 
        end
    end

    assign alarm = internal_alarm;

endmodule

/* Read response demultiplexer

   The RID bits are used to steer the response to the correct slave interface of the IP:
   * top bit indicates whether the response must go to a user AXI4Lite interface
   * the bottom 2 bits indicate which AXI4lite interface the response goes to.

   For this reason the AXI ID port facing the user design is 1 bit narrower than the 
   INIU-facing port. 

   Since the INIU R channel is 256 bits wide and the AXI Lite interfaces are much narrower
   (32 or 64 bits, of which 32 bits is typical of FP devices), this module needs to know
   which of the INIU R channel bits contain the response. This information is obtained from
   a "read response slice" FIFO for each AXI4 lite interface. The slice width is the same as
   the AXI4 Lite read response width, so for example a 256b wide INIU interface has 8 slices
   of 32 bits [it woid have been nice to use AXI ID bits to tag the expected slice, but that 
   could result in out-of-order responses which would not be expected by an AXI4 Lite master].

   If configured via the BUFFER_AXI4_S_READ_RESPONSES parameter, an MLAB FIFO is employed on 
   the R channel to the mainband slave interface, so that brief periods of mainband backpressure
   do not interfere with the flow of AXI4Lite read responses at times when there is a steady
   flow of mainband read responses. 
   
   This is an optional feature because it results in the instantiation of a nearly 300b wide 
   FIFO which consumes significant area and may affect fMax. 

   It is assumed that the AXI4Lite interfaces already have FIFOs, and that the flow of
   AXI4Lite commands has been throttled so that those FIFOs will never overflow. Therefore
   backpressure from any of the AXI4Lite R channels is treated as an error condition. 
*/

module intel_axi4lite_injector_ph2_read_response_demultiplexer #(
    parameter INIU_AXI4_ID_WIDTH                 = 7,
    parameter INIU_AXI4_DATA_WIDTH               = 256,
    parameter AXI4LITE_DATA_WIDTH                = 32,
    parameter RDATA_SLICEID_WIDTH                = 3,
    parameter NUM_AXI4LITE_S_INTERFACES          = 4, 
    parameter NUM_ACTIVE_AXI4LITE_S_INTERFACES   = 1,
    parameter NUM_ACTIVE_AXI4_S_INTERFACES       = 1,
    parameter BUFFER_AXI4_S_READ_RESPONSES       = 1
) (
    input  wire                                aclk,
    input  wire                                aresetn,
    output wire [INIU_AXI4_ID_WIDTH-2:0]       s_axi4_rid,
    output wire [INIU_AXI4_DATA_WIDTH-1:0]     s_axi4_rdata,
    output wire [1:0]                          s_axi4_rresp,
    output wire                                s_axi4_rlast,
    output wire [(INIU_AXI4_DATA_WIDTH/8)-1:0] s_axi4_ruser,
    output wire                                s_axi4_rvalid,
    input  wire                                s_axi4_rready, 
    input  wire [INIU_AXI4_ID_WIDTH-1:0]       m_axi4_rid,
    input  wire [INIU_AXI4_DATA_WIDTH-1:0]     m_axi4_rdata,
    input  wire [1:0]                          m_axi4_rresp,
    input  wire                                m_axi4_rlast,
    input  wire [(INIU_AXI4_DATA_WIDTH/8)-1:0] m_axi4_ruser,
    input  wire                                m_axi4_rvalid,
    output wire                                m_axi4_rready, 
    output wire [1:0]                          s_axi4lite_rresps  [NUM_AXI4LITE_S_INTERFACES],
    output wire [AXI4LITE_DATA_WIDTH-1:0]      s_axi4lite_rdatas  [NUM_AXI4LITE_S_INTERFACES],
    output wire                                s_axi4lite_rvalids [NUM_AXI4LITE_S_INTERFACES],
    input  wire                                s_axi4lite_rreadies[NUM_AXI4LITE_S_INTERFACES],
    input  wire [RDATA_SLICEID_WIDTH-1:0]      rdata_slice_selector_sliceids[NUM_AXI4LITE_S_INTERFACES],  
    input  wire                                rdata_slice_selector_valids  [NUM_AXI4LITE_S_INTERFACES],  
    output wire                                rdata_slice_selector_readies [NUM_AXI4LITE_S_INTERFACES],  
    output wire                                alarm
);
    initial begin
        assert (INIU_AXI4_DATA_WIDTH == 256); 
        assert ((AXI4LITE_DATA_WIDTH == 32) || (AXI4LITE_DATA_WIDTH == 64));
        assert (RDATA_SLICEID_WIDTH == $clog2(INIU_AXI4_DATA_WIDTH/AXI4LITE_DATA_WIDTH));
        assert (NUM_ACTIVE_AXI4LITE_S_INTERFACES <= NUM_AXI4LITE_S_INTERFACES);
        assert (NUM_AXI4LITE_S_INTERFACES    <= 4);
        assert (NUM_ACTIVE_AXI4_S_INTERFACES <= 1);
    end


    generate
        if (NUM_ACTIVE_AXI4_S_INTERFACES == 0) begin: gen_dummy_axi4_s_interface
            assign m_axi4_rready = 1'b1;
            assign s_axi4_rvalid = 1'b0;
            assign s_axi4_rid    = {(INIU_AXI4_ID_WIDTH){1'b0}};
            assign s_axi4_rresp  = 2'b0;
            assign s_axi4_rlast  = 1'b0;
            assign s_axi4_rdata  = {(INIU_AXI4_DATA_WIDTH){1'b0}};
            assign s_axi4_ruser  = {(INIU_AXI4_DATA_WIDTH/8){1'b0}};
        end else if (BUFFER_AXI4_S_READ_RESPONSES) begin: gen_buffered_axi4_s_interface
            intel_axi4lite_injector_ph2_fifo #(
                .WIDTH                    ((INIU_AXI4_ID_WIDTH-1) + 2   + 1 + INIU_AXI4_DATA_WIDTH + (INIU_AXI4_DATA_WIDTH/8)),   
                .LOG2_DEPTH               (5),                         
                .UPSTREAM_READY_LATENCY   (0),  
                .DOWNSTREAM_READY_LATENCY (0)   
            ) mainband_r_fifo (
                .aclk             (aclk),
                .aresetn          (aresetn),
                .upstream_ready   (m_axi4_rready),           
                .upstream_valid   (m_axi4_rvalid & ~m_axi4_rid[INIU_AXI4_ID_WIDTH-1]),            
                .upstream_data    ({m_axi4_rid[(INIU_AXI4_ID_WIDTH-2):0],m_axi4_rresp,m_axi4_rlast,m_axi4_rdata,m_axi4_ruser}), 
                .downstream_ready (s_axi4_rready),           
                .downstream_valid (s_axi4_rvalid),            
                .downstream_data  ({s_axi4_rid,s_axi4_rresp,s_axi4_rlast,s_axi4_rdata,s_axi4_ruser})
            );
        end else begin: gen_unbuffered_axi4_s_interface
            assign m_axi4_rready = s_axi4_rready;
            assign s_axi4_rvalid = m_axi4_rvalid & ~m_axi4_rid[INIU_AXI4_ID_WIDTH-1];
            assign s_axi4_rid    = m_axi4_rid[(INIU_AXI4_ID_WIDTH-2):0];
            assign s_axi4_rresp  = m_axi4_rresp;            
            assign s_axi4_rlast  = m_axi4_rlast;
            assign s_axi4_rdata  = m_axi4_rdata;            
            assign s_axi4_ruser  = m_axi4_ruser;                        
        end
    endgenerate


    generate
        for (genvar dest_axi4lite_r_channel = 0; dest_axi4lite_r_channel < NUM_AXI4LITE_S_INTERFACES; dest_axi4lite_r_channel = dest_axi4lite_r_channel + 1)
        begin: gen_dest_axi4lite_r_channel
            if (dest_axi4lite_r_channel >= NUM_ACTIVE_AXI4LITE_S_INTERFACES) begin
                assign s_axi4lite_rvalids[dest_axi4lite_r_channel] = 1'b0;
                assign s_axi4lite_rdatas[dest_axi4lite_r_channel]  = {(AXI4LITE_DATA_WIDTH){1'b0}};
                assign s_axi4lite_rresps[dest_axi4lite_r_channel]  = 2'b0;
            end else begin
                assign s_axi4lite_rvalids[dest_axi4lite_r_channel] = m_axi4_rvalid 
                                                                   & m_axi4_rready
                                                                   & m_axi4_rid[INIU_AXI4_ID_WIDTH-1]
                                                                   & (m_axi4_rid[1:0] == dest_axi4lite_r_channel);
                assign s_axi4lite_rdatas[dest_axi4lite_r_channel]  = m_axi4_rdata[(rdata_slice_selector_sliceids[dest_axi4lite_r_channel]*AXI4LITE_DATA_WIDTH) 
                                                                                  +: AXI4LITE_DATA_WIDTH];
                assign s_axi4lite_rresps[dest_axi4lite_r_channel]  = m_axi4_rresp;
            end
            assign rdata_slice_selector_readies[dest_axi4lite_r_channel] = s_axi4lite_rvalids[dest_axi4lite_r_channel];
        end
    endgenerate


    logic internal_alarm;

    always @(posedge aclk or negedge aresetn) begin
        if (~aresetn) begin
            internal_alarm <= 1'b0;
        end else begin
            logic r_fifo_overflow;
            logic rdata_slice_fifo_underflow;
            r_fifo_overflow = m_axi4_rvalid 
                            & m_axi4_rid[INIU_AXI4_ID_WIDTH-1] 
                            & ~s_axi4lite_rreadies[m_axi4_rid[1:0]];
            rdata_slice_fifo_underflow = m_axi4_rvalid
                                       & m_axi4_rready
                                       & m_axi4_rid[INIU_AXI4_ID_WIDTH-1] 
                                       & ~rdata_slice_selector_valids[m_axi4_rid[1:0]];
            internal_alarm <= internal_alarm | r_fifo_overflow | rdata_slice_fifo_underflow; 
        end
    end

    assign alarm = internal_alarm;

endmodule

/* FIFO for AXI4-like command or write data channels with potentially different upstream and downstream (hardware-side)
   ready latencies. Ready latencies can be specified as 0 (standard AXI handshaking), 1, or 2. 
   By AXI like it is meant that the signals are as per AXI, but the transfer handshake permits a delay of 1 or 2 cycles
   between de-assertion of ready and the flow of data. The logic is robust in that it does not require the upstream logic
   to de-assert valid when ready has been de-asserted, and it correctly de-asserts valid to downstream logic in response
   to de-assertion of ready from downstream. 
   This version of the module uses the standard scfifo IP which is known to limit fMax on Hyperflex devices and may
   therefore need to switch to a different FIFO IP such as fifo2. 
   The FIFO is always implemented in MLABs. LOG2_DEPTH of 5 results in very similar resource utilization to all smaller depths.
*/
module intel_axi4lite_injector_ph2_fifo #(
        parameter WIDTH                    = 32,
        parameter LOG2_DEPTH               = 5,  
        parameter UPSTREAM_READY_LATENCY   = 2,  
        parameter DOWNSTREAM_READY_LATENCY = 2   
    ) (
        input  wire            aclk,
        input  wire            aresetn,
        output wire            upstream_ready,           
        input  wire            upstream_valid,            
        input  wire[WIDTH-1:0] upstream_data, 
        input  wire            downstream_ready,           
        output wire            downstream_valid,            
        output wire[WIDTH-1:0] downstream_data 
    );

    initial begin
        assert (UPSTREAM_READY_LATENCY   >= 0 && UPSTREAM_READY_LATENCY   <= 2);
        assert (DOWNSTREAM_READY_LATENCY >= 0 && DOWNSTREAM_READY_LATENCY <= 2);
    end

    localparam DEPTH = (1 << LOG2_DEPTH) - 1;

    wire empty;
    wire rdreq;
    reg  rdreq_r;
    wire wrreq;
    wire almost_full;
    reg  almost_full_r;
    reg  almost_full_rr;


    reg  downstream_ready_r;

    always @(posedge aclk or negedge aresetn) begin
        if (~aresetn) begin
            downstream_ready_r <= 1'b0;
        end else begin
            downstream_ready_r <= downstream_ready;
        end
    end

    assign rdreq = (~empty) & ((DOWNSTREAM_READY_LATENCY == 2) ? downstream_ready_r : downstream_ready);


    assign wrreq = upstream_valid & ((UPSTREAM_READY_LATENCY == 0) ? ~almost_full
                                    :(UPSTREAM_READY_LATENCY == 1) ? ~almost_full_r
                                    :(UPSTREAM_READY_LATENCY == 2) ? ~almost_full_rr 
                                                                   : 1'b0);


    assign downstream_valid = (DOWNSTREAM_READY_LATENCY == 0) ? ~empty : rdreq_r;                                      

    scfifo # (
        .intended_device_family("Agilex"),
        .lpm_hint              ("RAM_BLOCK_TYPE=MLAB"),
        .lpm_width             (WIDTH),
        .lpm_widthu            (LOG2_DEPTH),
        .lpm_numwords          (DEPTH),  
        .lpm_showahead         ((DOWNSTREAM_READY_LATENCY == 0) ? "ON" : "OFF"),
        .almost_full_value     (DEPTH-UPSTREAM_READY_LATENCY), 
        .use_eab               ("ON"),                         // always "ON", to enable MLAB implementation
        .overflow_checking     ("OFF"),
        .underflow_checking    ("OFF")
    ) fifo (
        .clock       (aclk),
        .sclr        (~aresetn),
        .aclr        (1'b0),
        .wrreq       (wrreq),
        .data        (upstream_data),
        .rdreq       (rdreq), 
        .q           (downstream_data),
        .empty       (empty),
        .almost_empty(), 
        .almost_full (almost_full),
        .full        (),
        .usedw       (),
        .eccstatus   ()
    );

    assign upstream_ready = ~almost_full;

    always @(posedge aclk) begin
        rdreq_r        <= rdreq;
        almost_full_r  <= almost_full;
        almost_full_rr <= almost_full_r;
    end

endmodule


/* clock crossing fifo, adapted from the backpressure tester's fifo module
   This module places no expectations on the relationship between clock and reset, leveraging 
   the dcfifo reset synchronization option to aviod race conditions and enabling the user of 
   the module to use either upstream or downstream reset at will.   
   The almost_full condition cannot be directly obtained from a dcfifo, so must be based on rdusedw.
   The dcfifo takes 2 cycles to reflect writes in wrusedw, and there is an internal register
   stage in this module's conversion of wrusedw to wralmostfull. Therefore upstream is backpressured when
   rdusedw >= (2**LOG2_DEPTH) - (UPSTREAM_READY_LATENCY+4)
*/

module intel_axi4lite_injector_ph2_clock_crossing_fifo #(
        parameter WIDTH                    = 32,
        parameter LOG2_DEPTH               = 5,  
        parameter UPSTREAM_READY_LATENCY   = 2,  
        parameter DOWNSTREAM_READY_LATENCY = 2   
    ) (
        input  wire                 upstream_aresetn,
        input  wire                 upstream_clk,
        output wire                 upstream_ready,           
        input  wire                 upstream_valid,            
        input  wire[WIDTH-1:0]      upstream_data, 
        input  wire                 downstream_aresetn,
        input  wire                 downstream_clk,
        input  wire                 downstream_ready,           
        output wire                 downstream_valid,            
        output wire[WIDTH-1:0]      downstream_data,
        output wire[LOG2_DEPTH-1:0] upstream_occupancy
    );

    localparam DEPTH = (1 << LOG2_DEPTH) - 1;

    initial begin
        assert (UPSTREAM_READY_LATENCY   >= 0 && UPSTREAM_READY_LATENCY   <= 2);
        assert (DOWNSTREAM_READY_LATENCY >= 0 && DOWNSTREAM_READY_LATENCY <= 2);
        assert (DEPTH > (UPSTREAM_READY_LATENCY+4));
    end

    wire                  wrreq;
    wire [LOG2_DEPTH-1:0] wrusedw;
    reg                   wralmost_full;
    reg                   wralmost_full_r;
    reg                   wralmost_full_rr;
    wire                  rdreq;
    wire                  rdempty;
    reg                   rdreq_r;

    reg  downstream_ready_r;
    always @(posedge downstream_clk or negedge downstream_aresetn) begin
        if (~downstream_aresetn) begin
            downstream_ready_r <= 1'b0;
        end else begin
            downstream_ready_r <= downstream_ready;
        end
    end

    assign rdreq = (~rdempty) & ((DOWNSTREAM_READY_LATENCY == 2) ? downstream_ready_r : downstream_ready);

    assign wrreq = upstream_valid & ((UPSTREAM_READY_LATENCY == 0) ? ~wralmost_full
                                    :(UPSTREAM_READY_LATENCY == 1) ? ~wralmost_full_r
                                    :(UPSTREAM_READY_LATENCY == 2) ? ~wralmost_full_rr 
                                                                   : 1'b0);
                                                                   
    assign downstream_valid = (DOWNSTREAM_READY_LATENCY == 0) ? ~rdempty : rdreq_r; 
                                         
    intel_axi4lite_injector_dcfifo_s # (
        .WIDTH              (WIDTH),
        .LOG_DEPTH          (LOG2_DEPTH),
        .ALMOST_FULL_VALUE  (DEPTH-1 - UPSTREAM_READY_LATENCY - 2),
        .FAMILY             ("Agilex"),
        .SHOW_AHEAD         ((DOWNSTREAM_READY_LATENCY == 0) ? 1 : 0),
        .OVERFLOW_CHECKING  (0),
        .UNDERFLOW_CHECKING (0)
    ) fifo (
        .wrclk           (upstream_clk),
        .wraresetn       (upstream_aresetn),
        .wrreq           (wrreq),
        .data            (upstream_data),
        .wrfull          (),
        .wrempty         (),
        .wr_almost_empty (),
        .wr_almost_full  (),
        .wrusedw         (wrusedw),
        .rdclk           (downstream_clk),
        .rdaresetn       (downstream_aresetn),
        .rdreq           (rdreq), 
        .q               (downstream_data),
        .rdfull          (),
        .rdempty         (rdempty),
        .rd_almost_empty (),
        .rd_almost_full  (),
        .rdusedw         ()
    );

    always @(posedge upstream_clk or negedge upstream_aresetn) begin
        if (~upstream_aresetn) begin
            wralmost_full    <= 1'b0;
            wralmost_full_r  <= 1'b0;
            wralmost_full_rr <= 1'b0;            
        end else begin
            wralmost_full    <= (wrusedw > (DEPTH-1 - UPSTREAM_READY_LATENCY - 2));
            wralmost_full_r  <= wralmost_full;
            wralmost_full_rr <= wralmost_full_r;
        end
    end

    assign upstream_ready = ~wralmost_full;

    always @(posedge downstream_clk or negedge downstream_aresetn) begin
        if (~downstream_aresetn) begin
            rdreq_r <= 1'b0;
        end else begin
            rdreq_r <= rdreq;            
        end
    end

    assign upstream_occupancy = wrusedw;
endmodule

/* Example instantiation

module axilite_injector_tb #(
    parameter  NUM_ACTIVE_AXI4LITE_S_INTERFACES = 4,
    parameter  AXI4LITE_QOS                     = 0,   
    parameter  NUM_ACTIVE_AXI4_S_INTERFACES     = 1,
    parameter  BUFFER_AXI4_S_READ_RESPONSES     = 0,   
    parameter  AXI4_S_TRANSFER_MULTIPLE         = 9,   
    localparam INIU_AXI4_ID_WIDTH               = 7,   
    localparam INIU_AXI4_ADDR_WIDTH             = 44,  
    localparam INIU_AXI4_AWUSER_WIDTH           = 11,  
    localparam INIU_AXI4_ARUSER_WIDTH           = 11,  
    localparam INIU_AXI4_DATA_WIDTH             = 256, 
    localparam AXI4LITE_ADDR_WIDTH              = INIU_AXI4_ADDR_WIDTH,
    localparam AXI4LITE_DATA_WIDTH              = 32,
    localparam NUM_AXI4LITE_S_INTERFACES        = 4
) (
);
    wire                                user_axi4lite_aclk   [NUM_AXI4LITE_S_INTERFACES];     
    wire                                user_axi4lite_aresetn[NUM_AXI4LITE_S_INTERFACES];
    wire [AXI4LITE_ADDR_WIDTH-1:0]      user_axi4lite_awaddr [NUM_AXI4LITE_S_INTERFACES];   
    wire [2:0]                          user_axi4lite_awprot [NUM_AXI4LITE_S_INTERFACES];   
    wire                                user_axi4lite_awvalid[NUM_AXI4LITE_S_INTERFACES];  
    wire                                user_axi4lite_awready[NUM_AXI4LITE_S_INTERFACES];
    wire [AXI4LITE_DATA_WIDTH-1:0]      user_axi4lite_wdata  [NUM_AXI4LITE_S_INTERFACES];    
    wire [(AXI4LITE_DATA_WIDTH/8)-1:0]  user_axi4lite_wstrb  [NUM_AXI4LITE_S_INTERFACES];    
    wire                                user_axi4lite_wvalid [NUM_AXI4LITE_S_INTERFACES];   
    wire                                user_axi4lite_wready [NUM_AXI4LITE_S_INTERFACES];
    wire [1:0]                          user_axi4lite_bresp  [NUM_AXI4LITE_S_INTERFACES];    
    wire                                user_axi4lite_bvalid [NUM_AXI4LITE_S_INTERFACES];   
    wire                                user_axi4lite_bready [NUM_AXI4LITE_S_INTERFACES];
    wire [AXI4LITE_ADDR_WIDTH-1:0]      user_axi4lite_araddr [NUM_AXI4LITE_S_INTERFACES];   
    wire [2:0]                          user_axi4lite_arprot [NUM_AXI4LITE_S_INTERFACES];   
    wire                                user_axi4lite_arvalid[NUM_AXI4LITE_S_INTERFACES];  
    wire                                user_axi4lite_arready[NUM_AXI4LITE_S_INTERFACES];
    wire [AXI4LITE_DATA_WIDTH-1:0]      user_axi4lite_rdata  [NUM_AXI4LITE_S_INTERFACES];    
    wire [1:0]                          user_axi4lite_rresp  [NUM_AXI4LITE_S_INTERFACES];    
    wire                                user_axi4lite_rvalid [NUM_AXI4LITE_S_INTERFACES];   
    wire                                user_axi4lite_rready [NUM_AXI4LITE_S_INTERFACES]; 

    wire                                user_axi4_aclk;
    wire                                user_axi4_aresetn;
    wire [INIU_AXI4_ID_WIDTH-2:0]       user_axi4_awid;   
    wire [INIU_AXI4_ADDR_WIDTH-1:0]     user_axi4_awaddr; 
    wire [7:0]                          user_axi4_awlen;  
    wire [2:0]                          user_axi4_awsize; 
    wire [1:0]                          user_axi4_awburst;
    wire                                user_axi4_awlock; 
    wire [2:0]                          user_axi4_awprot; 
    wire [3:0]                          user_axi4_awqos;  
    wire [INIU_AXI4_AWUSER_WIDTH-1:0]   user_axi4_awuser; 
    wire                                user_axi4_awvalid;
    wire                                user_axi4_awready;
    wire [INIU_AXI4_DATA_WIDTH-1:0]     user_axi4_wdata;  
    wire [(INIU_AXI4_DATA_WIDTH/8)-1:0] user_axi4_wstrb;  
    wire                                user_axi4_wlast;  
    wire [(INIU_AXI4_DATA_WIDTH/8)-1:0] user_axi4_wuser;  
    wire                                user_axi4_wvalid; 
    wire                                user_axi4_wready; 
    wire [INIU_AXI4_ID_WIDTH-2:0]       user_axi4_bid;    
    wire [1:0]                          user_axi4_bresp;  
    wire                                user_axi4_bvalid; 
    wire                                user_axi4_bready; 
    wire [INIU_AXI4_ID_WIDTH-2:0]       user_axi4_arid;   
    wire [INIU_AXI4_ADDR_WIDTH-1:0]     user_axi4_araddr; 
    wire [7:0]                          user_axi4_arlen;  
    wire [2:0]                          user_axi4_arsize; 
    wire [1:0]                          user_axi4_arburst;
    wire                                user_axi4_arlock; 
    wire [2:0]                          user_axi4_arprot; 
    wire [3:0]                          user_axi4_arqos;  
    wire [INIU_AXI4_ARUSER_WIDTH-1:0]   user_axi4_aruser; 
    wire                                user_axi4_arvalid;
    wire                                user_axi4_arready;
    wire [INIU_AXI4_ID_WIDTH-2:0]       user_axi4_rid;
    wire [INIU_AXI4_DATA_WIDTH-1:0]     user_axi4_rdata;
    wire [1:0]                          user_axi4_rresp;
    wire                                user_axi4_rlast;
    wire [(INIU_AXI4_DATA_WIDTH/8)-1:0] user_axi4_ruser;
    wire                                user_axi4_rvalid;
    wire                                user_axi4_rready; 

    wire                                iniu_axi4_aclk;
    wire                                iniu_axi4_aresetn;
    wire [INIU_AXI4_ID_WIDTH-1:0]       iniu_axi4_awid;   
    wire [INIU_AXI4_ADDR_WIDTH-1:0]     iniu_axi4_awaddr; 
    wire [7:0]                          iniu_axi4_awlen;  
    wire [2:0]                          iniu_axi4_awsize; 
    wire [1:0]                          iniu_axi4_awburst;
    wire                                iniu_axi4_awlock; 
    wire [2:0]                          iniu_axi4_awprot; 
    wire [3:0]                          iniu_axi4_awqos;  
    wire [INIU_AXI4_AWUSER_WIDTH-1:0]   iniu_axi4_awuser; 
    wire                                iniu_axi4_awvalid;
    wire                                iniu_axi4_awready;
    wire [INIU_AXI4_DATA_WIDTH-1:0]     iniu_axi4_wdata;  
    wire [(INIU_AXI4_DATA_WIDTH/8)-1:0] iniu_axi4_wstrb;  
    wire                                iniu_axi4_wlast;  
    wire [(INIU_AXI4_DATA_WIDTH/8)-1:0] iniu_axi4_wuser;  
    wire                                iniu_axi4_wvalid; 
    wire                                iniu_axi4_wready;  
    wire [INIU_AXI4_ID_WIDTH-1:0]       iniu_axi4_bid;    
    wire [1:0]                          iniu_axi4_bresp;  
    wire                                iniu_axi4_bvalid; 
    wire                                iniu_axi4_bready;  
    wire [INIU_AXI4_ID_WIDTH-1:0]       iniu_axi4_arid;     
    wire [INIU_AXI4_ADDR_WIDTH-1:0]     iniu_axi4_araddr;   
    wire [7:0]                          iniu_axi4_arlen;    
    wire [2:0]                          iniu_axi4_arsize;   
    wire [1:0]                          iniu_axi4_arburst;  
    wire                                iniu_axi4_arlock;   
    wire [2:0]                          iniu_axi4_arprot;   
    wire [3:0]                          iniu_axi4_arqos;    
    wire [INIU_AXI4_ARUSER_WIDTH-1:0]   iniu_axi4_aruser;   
    wire                                iniu_axi4_arvalid;  
    wire                                iniu_axi4_arready;
    wire [INIU_AXI4_ID_WIDTH-1:0]       iniu_axi4_rid;
    wire [INIU_AXI4_DATA_WIDTH-1:0]     iniu_axi4_rdata;
    wire [1:0]                          iniu_axi4_rresp;
    wire                                iniu_axi4_rlast;
    wire [(INIU_AXI4_DATA_WIDTH/8)-1:0] iniu_axi4_ruser;
    wire                                iniu_axi4_rvalid;
    wire                                iniu_axi4_rready; 

    intel_axi4lite_injector_ph2 #(
        .NUM_ACTIVE_AXI4LITE_S_INTERFACES (NUM_ACTIVE_AXI4LITE_S_INTERFACES),
        .NUM_ACTIVE_AXI4_S_INTERFACES     (NUM_ACTIVE_AXI4_S_INTERFACES),
        .BUFFER_AXI4_S_READ_RESPONSES     (BUFFER_AXI4_S_READ_RESPONSES),
        .AXI4_S_TRANSFER_MULTIPLE         (AXI4_S_TRANSFER_MULTIPLE)
    ) axi4lite_injector_dut (
        .s0_axi4lite_aclk    (user_axi4lite_aclk   [0]),
        .s0_axi4lite_aresetn (user_axi4lite_aresetn[0]),
        .s0_axi4lite_awaddr  (user_axi4lite_awaddr [0]),   
        .s0_axi4lite_awprot  (user_axi4lite_awprot [0]),   
        .s0_axi4lite_awvalid (user_axi4lite_awvalid[0]),  
        .s0_axi4lite_awready (user_axi4lite_awready[0]),
        .s0_axi4lite_wdata   (user_axi4lite_wdata  [0]),    
        .s0_axi4lite_wstrb   (user_axi4lite_wstrb  [0]),    
        .s0_axi4lite_wvalid  (user_axi4lite_wvalid [0]),   
        .s0_axi4lite_wready  (user_axi4lite_wready [0]),
        .s0_axi4lite_bresp   (user_axi4lite_bresp  [0]),    
        .s0_axi4lite_bvalid  (user_axi4lite_bvalid [0]),   
        .s0_axi4lite_bready  (user_axi4lite_bready [0]),
        .s0_axi4lite_araddr  (user_axi4lite_araddr [0]),   
        .s0_axi4lite_arprot  (user_axi4lite_arprot [0]),   
        .s0_axi4lite_arvalid (user_axi4lite_arvalid[0]),  
        .s0_axi4lite_arready (user_axi4lite_arready[0]),
        .s0_axi4lite_rdata   (user_axi4lite_rdata  [0]),    
        .s0_axi4lite_rresp   (user_axi4lite_rresp  [0]),    
        .s0_axi4lite_rvalid  (user_axi4lite_rvalid [0]),   
        .s0_axi4lite_rready  (user_axi4lite_rready [0]), 
        .s1_axi4lite_aclk    (user_axi4lite_aclk   [1]),
        .s1_axi4lite_aresetn (user_axi4lite_aresetn[1]),
        .s1_axi4lite_awaddr  (user_axi4lite_awaddr [1]),   
        .s1_axi4lite_awprot  (user_axi4lite_awprot [1]),   
        .s1_axi4lite_awvalid (user_axi4lite_awvalid[1]),  
        .s1_axi4lite_awready (user_axi4lite_awready[1]),
        .s1_axi4lite_wdata   (user_axi4lite_wdata  [1]),    
        .s1_axi4lite_wstrb   (user_axi4lite_wstrb  [1]),    
        .s1_axi4lite_wvalid  (user_axi4lite_wvalid [1]),   
        .s1_axi4lite_wready  (user_axi4lite_wready [1]),
        .s1_axi4lite_bresp   (user_axi4lite_bresp  [1]),    
        .s1_axi4lite_bvalid  (user_axi4lite_bvalid [1]),   
        .s1_axi4lite_bready  (user_axi4lite_bready [1]),
        .s1_axi4lite_araddr  (user_axi4lite_araddr [1]),   
        .s1_axi4lite_arprot  (user_axi4lite_arprot [1]),   
        .s1_axi4lite_arvalid (user_axi4lite_arvalid[1]),  
        .s1_axi4lite_arready (user_axi4lite_arready[1]),
        .s1_axi4lite_rdata   (user_axi4lite_rdata  [1]),    
        .s1_axi4lite_rresp   (user_axi4lite_rresp  [1]),    
        .s1_axi4lite_rvalid  (user_axi4lite_rvalid [1]),   
        .s1_axi4lite_rready  (user_axi4lite_rready [1]), 
        .s2_axi4lite_aclk    (user_axi4lite_aclk   [2]),
        .s2_axi4lite_aresetn (user_axi4lite_aresetn[2]),
        .s2_axi4lite_awaddr  (user_axi4lite_awaddr [2]),   
        .s2_axi4lite_awprot  (user_axi4lite_awprot [2]),   
        .s2_axi4lite_awvalid (user_axi4lite_awvalid[2]),  
        .s2_axi4lite_awready (user_axi4lite_awready[2]),
        .s2_axi4lite_wdata   (user_axi4lite_wdata  [2]),    
        .s2_axi4lite_wstrb   (user_axi4lite_wstrb  [2]),    
        .s2_axi4lite_wvalid  (user_axi4lite_wvalid [2]),   
        .s2_axi4lite_wready  (user_axi4lite_wready [2]),
        .s2_axi4lite_bresp   (user_axi4lite_bresp  [2]),    
        .s2_axi4lite_bvalid  (user_axi4lite_bvalid [2]),   
        .s2_axi4lite_bready  (user_axi4lite_bready [2]),
        .s2_axi4lite_araddr  (user_axi4lite_araddr [2]),   
        .s2_axi4lite_arprot  (user_axi4lite_arprot [2]),   
        .s2_axi4lite_arvalid (user_axi4lite_arvalid[2]),  
        .s2_axi4lite_arready (user_axi4lite_arready[2]),
        .s2_axi4lite_rdata   (user_axi4lite_rdata  [2]),    
        .s2_axi4lite_rresp   (user_axi4lite_rresp  [2]),    
        .s2_axi4lite_rvalid  (user_axi4lite_rvalid [2]),   
        .s2_axi4lite_rready  (user_axi4lite_rready [2]), 
        .s3_axi4lite_aclk    (user_axi4lite_aclk   [3]),
        .s3_axi4lite_aresetn (user_axi4lite_aresetn[3]),
        .s3_axi4lite_awaddr  (user_axi4lite_awaddr [3]),   
        .s3_axi4lite_awprot  (user_axi4lite_awprot [3]),   
        .s3_axi4lite_awvalid (user_axi4lite_awvalid[3]),  
        .s3_axi4lite_awready (user_axi4lite_awready[3]),
        .s3_axi4lite_wdata   (user_axi4lite_wdata  [3]),    
        .s3_axi4lite_wstrb   (user_axi4lite_wstrb  [3]),    
        .s3_axi4lite_wvalid  (user_axi4lite_wvalid [3]),   
        .s3_axi4lite_wready  (user_axi4lite_wready [3]),
        .s3_axi4lite_bresp   (user_axi4lite_bresp  [3]),    
        .s3_axi4lite_bvalid  (user_axi4lite_bvalid [3]),   
        .s3_axi4lite_bready  (user_axi4lite_bready [3]),
        .s3_axi4lite_araddr  (user_axi4lite_araddr [3]),   
        .s3_axi4lite_arprot  (user_axi4lite_arprot [3]),   
        .s3_axi4lite_arvalid (user_axi4lite_arvalid[3]),  
        .s3_axi4lite_arready (user_axi4lite_arready[3]),
        .s3_axi4lite_rdata   (user_axi4lite_rdata  [3]),    
        .s3_axi4lite_rresp   (user_axi4lite_rresp  [3]),    
        .s3_axi4lite_rvalid  (user_axi4lite_rvalid [3]),   
        .s3_axi4lite_rready  (user_axi4lite_rready [3]), 
        .s_axi4_aclk         (user_axi4_aclk),   
        .s_axi4_aresetn      (user_axi4_aresetn),
        .s_axi4_awid         (user_axi4_awid),   
        .s_axi4_awaddr       (user_axi4_awaddr), 
        .s_axi4_awlen        (user_axi4_awlen),  
        .s_axi4_awsize       (user_axi4_awsize), 
        .s_axi4_awburst      (user_axi4_awburst),
        .s_axi4_awlock       (user_axi4_awlock), 
        .s_axi4_awprot       (user_axi4_awprot), 
        .s_axi4_awqos        (user_axi4_awqos),  
        .s_axi4_awuser       (user_axi4_awuser), 
        .s_axi4_awvalid      (user_axi4_awvalid),
        .s_axi4_awready      (user_axi4_awready),
        .s_axi4_wdata        (user_axi4_wdata),  
        .s_axi4_wstrb        (user_axi4_wstrb),  
        .s_axi4_wlast        (user_axi4_wlast),  
        .s_axi4_wuser        (user_axi4_wuser),  
        .s_axi4_wvalid       (user_axi4_wvalid), 
        .s_axi4_wready       (user_axi4_wready), 
        .s_axi4_bid          (user_axi4_bid),    
        .s_axi4_bresp        (user_axi4_bresp),  
        .s_axi4_bvalid       (user_axi4_bvalid), 
        .s_axi4_bready       (user_axi4_bready), 
        .s_axi4_arid         (user_axi4_arid),   
        .s_axi4_araddr       (user_axi4_araddr), 
        .s_axi4_arlen        (user_axi4_arlen),  
        .s_axi4_arsize       (user_axi4_arsize), 
        .s_axi4_arburst      (user_axi4_arburst),
        .s_axi4_arlock       (user_axi4_arlock), 
        .s_axi4_arprot       (user_axi4_arprot), 
        .s_axi4_arqos        (user_axi4_arqos),  
        .s_axi4_aruser       (user_axi4_aruser), 
        .s_axi4_arvalid      (user_axi4_arvalid),
        .s_axi4_arready      (user_axi4_arready),
        .s_axi4_rid          (user_axi4_rid),
        .s_axi4_rdata        (user_axi4_rdata),
        .s_axi4_rresp        (user_axi4_rresp),
        .s_axi4_rlast        (user_axi4_rlast),
        .s_axi4_ruser        (user_axi4_ruser),
        .s_axi4_rvalid       (user_axi4_rvalid),
        .s_axi4_rready       (user_axi4_rready), 
        .m_axi4_aclk         (iniu_axi4_aclk),   
        .m_axi4_aresetn      (iniu_axi4_aresetn),
        .m_axi4_awid         (iniu_axi4_awid),    
        .m_axi4_awaddr       (iniu_axi4_awaddr),  
        .m_axi4_awlen        (iniu_axi4_awlen),   
        .m_axi4_awsize       (iniu_axi4_awsize),  
        .m_axi4_awburst      (iniu_axi4_awburst),
        .m_axi4_awlock       (iniu_axi4_awlock),  
        .m_axi4_awprot       (iniu_axi4_awprot),  
        .m_axi4_awqos        (iniu_axi4_awqos),   
        .m_axi4_awuser       (iniu_axi4_awuser),  
        .m_axi4_awvalid      (iniu_axi4_awvalid),
        .m_axi4_awready      (iniu_axi4_awready),
        .m_axi4_wdata        (iniu_axi4_wdata),   
        .m_axi4_wstrb        (iniu_axi4_wstrb),   
        .m_axi4_wlast        (iniu_axi4_wlast),   
        .m_axi4_wuser        (iniu_axi4_wuser),   
        .m_axi4_wvalid       (iniu_axi4_wvalid),  
        .m_axi4_wready       (iniu_axi4_wready),   
        .m_axi4_bid          (iniu_axi4_bid),     
        .m_axi4_bresp        (iniu_axi4_bresp),   
        .m_axi4_bvalid       (iniu_axi4_bvalid),  
        .m_axi4_bready       (iniu_axi4_bready),   
        .m_axi4_arid         (iniu_axi4_arid),      
        .m_axi4_araddr       (iniu_axi4_araddr),    
        .m_axi4_arlen        (iniu_axi4_arlen),     
        .m_axi4_arsize       (iniu_axi4_arsize),    
        .m_axi4_arburst      (iniu_axi4_arburst),  
        .m_axi4_arlock       (iniu_axi4_arlock),    
        .m_axi4_arprot       (iniu_axi4_arprot),    
        .m_axi4_arqos        (iniu_axi4_arqos),     
        .m_axi4_aruser       (iniu_axi4_aruser),    
        .m_axi4_arvalid      (iniu_axi4_arvalid),  
        .m_axi4_arready      (iniu_axi4_arready),
        .m_axi4_rid          (iniu_axi4_rid),
        .m_axi4_rdata        (iniu_axi4_rdata),
        .m_axi4_rresp        (iniu_axi4_rresp),
        .m_axi4_rlast        (iniu_axi4_rlast),
        .m_axi4_ruser        (iniu_axi4_ruser),
        .m_axi4_rvalid       (iniu_axi4_rvalid),
        .m_axi4_rready       (iniu_axi4_rready) 
    );

endmodule
*/

`default_nettype wire
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "2vYdvEaWk6xQGlVKgsj/H/NO8ZDGz0QQfJhzSeiJ+x9svQmFHfFvPiO18aQ7DJy2tWQs2iCYx+dn740o8GvZCQwQsTi4jOjNn/+ewG5SFCB61Wugiqleh4JKRHDQw8nbDkruM1KvHdGibCAgjhEGHsfYRH9uMso38H9AxJZm/oDUJ7h0VPzAjkYXi/P4y96Dsu46Ddz1ybWwdwSPZCWetjErkh7B4ukW/hZDbx5EJW5jgj318CYiqCbQ42gsEHJFSWEJ+4BP/oKGFLFhvgPFDtwg16MYA0wqp69ln1Ck9Z0pW6edZbxpqPzDCC3ikDapGlK1ypn6u7NUUuF0dW15oH3dwk1yMdsuZKfB6Co1z8hLh4RnqI5z2BZuoJLHditFga+X2sXsfx506GUXwhQZG4RXLW6XZMO8a8ksPgPnfWDarKc4hrUVJiAiQVFosZVuBSDMQ8TU+PmcA/afOs7znPRFUsGC1mUNW4+VlPltIee1/tEEO0IruvfL+PHbulmu24qUoxoTbHT1zVt3R+nfedJhHS77rKKKmwlIp9rpDa8WDsuQcdlz31yacRku5DkIMlpq00qgEW+bqvPp/7l5oKP+rBbaYBXm7zutUVn1DZO41Nb0HuT69PdJDWZuZd61PqJ1BqC3at7qBDjlLnDVLabrQdmt4bHRZXZhroTJ6lIeL5AcjBY66LznHYeQjR4iBzv2xINoUsm5KaY8A2uNHKCC8E2UxJpJHHruawKeCeY4xsENdzwM8hOW9fAwVoPj1x55De3W1tI2mNLpHf+s7gHiEz/V3Xbjb8sDBeCdg/Z/UV2Hiil+SSyaeJgw7mYqPs7aLauBhxn4V7tD6pXunbyfhd8ZndWoSTNMDlI075MN4ohs1kAcJgOP3vTm+fyzfU+37kqYGCgPKs0Rt83fyHaikySrlsI/FIh/p3yW9i0jBcglY/a64IG1+0af9ufF9YyywxW586t0h0acNss1NI0XVhfv11suArh7NHwb+eDo2Qq2eD5M+7nAZp5vLbCh"
`endif