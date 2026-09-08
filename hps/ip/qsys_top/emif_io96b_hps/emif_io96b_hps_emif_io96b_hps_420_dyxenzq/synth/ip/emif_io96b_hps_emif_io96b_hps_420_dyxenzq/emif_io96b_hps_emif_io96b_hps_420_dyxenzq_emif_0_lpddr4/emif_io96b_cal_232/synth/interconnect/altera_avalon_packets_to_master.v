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





`timescale 1ns / 100ps
module altera_avalon_packets_to_master (
      input wire             clk,
      input wire             reset_n,
      output wire         in_ready,
      input  wire         in_valid,
      input  wire [ 7: 0] in_data,
      input  wire         in_startofpacket,
      input  wire         in_endofpacket,

      input  wire         out_ready,
      output wire         out_valid,
      output wire [ 7: 0] out_data,
      output wire         out_startofpacket,
      output wire         out_endofpacket,

      output wire [31: 0] address,
      input  wire [31: 0] readdata,
      output wire         read,
      output wire         write,
      output wire [ 3: 0] byteenable,
      output wire [31: 0] writedata,
      input  wire         waitrequest,
      input  wire         readdatavalid
);

    wire [ 35: 0] fifo_readdata;
    wire          fifo_read;
    wire          fifo_empty;
    wire [ 35: 0] fifo_writedata;
    wire          fifo_write;
    wire          fifo_write_waitrequest;
    
   parameter EXPORT_MASTER_SIGNALS = 0;
   parameter FIFO_DEPTHS           = 2;
   parameter FIFO_WIDTHU           = 1;
   parameter FAST_VER              = 0;
   
   generate
       if (FAST_VER) begin
            packets_to_fifo p2f (
                .clk                 (clk),
                .reset_n             (reset_n),
                .in_ready            (in_ready),
                .in_valid            (in_valid),
                .in_data             (in_data),
                .in_startofpacket    (in_startofpacket),
                .in_endofpacket      (in_endofpacket),
                .address             (address),
                .readdata            (readdata),
                .read                (read),
                .write               (write),
                .byteenable          (byteenable),
                .writedata           (writedata),
                .waitrequest         (waitrequest),
                .readdatavalid       (readdatavalid),
                .fifo_writedata      (fifo_writedata),
                .fifo_write          (fifo_write),
                .fifo_write_waitrequest (fifo_write_waitrequest)
            );
            
            fifo_to_packet f2p (
                .clk                 (clk),
                .reset_n             (reset_n),
                .out_ready           (out_ready),
                .out_valid           (out_valid),
                .out_data            (out_data),
                .out_startofpacket   (out_startofpacket),
                .out_endofpacket     (out_endofpacket),
                .fifo_readdata       (fifo_readdata),
                .fifo_read           (fifo_read),
                .fifo_empty          (fifo_empty)
            );
            
            fifo_buffer #(
                .FIFO_DEPTHS(FIFO_DEPTHS),
                .FIFO_WIDTHU(FIFO_WIDTHU)
            ) fb (
                .wrclock                          (clk),
                .reset_n                          (reset_n),
                .avalonmm_write_slave_writedata   (fifo_writedata),  
                .avalonmm_write_slave_write       (fifo_write),      
                .avalonmm_write_slave_waitrequest (fifo_write_waitrequest),
                .avalonmm_read_slave_readdata     (fifo_readdata),  
                .avalonmm_read_slave_read         (fifo_read),      
                .avalonmm_read_slave_waitrequest  (fifo_empty)
            );
       end else begin
           packets_to_master p2m (
                .clk                 (clk),
                .reset_n             (reset_n),
                .in_ready            (in_ready),
                .in_valid            (in_valid),
                .in_data             (in_data),
                .in_startofpacket    (in_startofpacket),
                .in_endofpacket      (in_endofpacket),
                .address             (address),
                .readdata            (readdata),
                .read                (read),
                .write               (write),
                .byteenable          (byteenable),
                .writedata           (writedata),
                .waitrequest         (waitrequest),
                .readdatavalid       (readdatavalid),
                .out_ready           (out_ready),
                .out_valid           (out_valid),
                .out_data            (out_data),
                .out_startofpacket   (out_startofpacket),
                .out_endofpacket     (out_endofpacket)
            );
       end
   endgenerate
endmodule

module packets_to_fifo (

      input              clk,
      input              reset_n,
      output reg         in_ready,
      input              in_valid,
      input      [ 7: 0] in_data,
      input              in_startofpacket,
      input              in_endofpacket,

      output reg [31: 0] address,
      input      [31: 0] readdata,
      output reg         read,
      output reg         write,
      output reg [ 3: 0] byteenable,
      output reg [31: 0] writedata,
      input              waitrequest,
      input              readdatavalid,
      
      output reg [ 35: 0] fifo_writedata,
      output reg        fifo_write,
      input wire        fifo_write_waitrequest
);

   localparam CMD_WRITE_NON_INCR = 8'h00;
   localparam CMD_WRITE_INCR     = 8'h04;
   localparam CMD_READ_NON_INCR  = 8'h10;
   localparam CMD_READ_INCR      = 8'h14;
   

   reg  [ 3: 0]  state;
   reg  [ 7: 0]  command;
   reg  [ 1: 0]  current_byte, byte_avail;
   reg  [ 15: 0] counter;
   reg  [ 31: 0] read_data_buffer;
   reg  [ 31: 0] fifo_data_buffer;
   reg           in_ready_0;
   reg           first_trans, last_trans, fifo_sop;
   reg  [ 3: 0]  unshifted_byteenable;
   wire enable;

   localparam READY           = 4'b0000,
              GET_EXTRA       = 4'b0001,
              GET_SIZE1       = 4'b0010,
              GET_SIZE2       = 4'b0011,
              GET_ADDR1       = 4'b0100,
              GET_ADDR2       = 4'b0101,
              GET_ADDR3       = 4'b0110,
              GET_ADDR4       = 4'b0111,
              GET_WRITE_DATA  = 4'b1000,
              WRITE_WAIT      = 4'b1001,
              READ_ASSERT     = 4'b1010,
              READ_CMD_WAIT   = 4'b1011,
              READ_DATA_WAIT  = 4'b1100,
              PUSH_FIFO       = 4'b1101,
              PUSH_FIFO_WAIT  = 4'b1110,
              FIFO_CMD_WAIT   = 4'b1111;

   assign enable = (in_ready & in_valid);

   always @* begin
      in_ready = in_ready_0;      
   end
   
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
            in_ready_0          <= 1'b0;
            fifo_writedata      <=  'b0;
            fifo_write          <= 1'b0;
            fifo_sop            <= 1'b0;
            read                <= 1'b0;
            write               <= 1'b0;
            byteenable          <=  'b0;
            writedata           <=  'b0;
            address             <=  'b0;
            counter             <=  'b0;
            command             <=  'b0;
            first_trans         <= 1'b0;
            last_trans          <= 1'b0;
            state               <=  'b0;
            current_byte        <=  'b0;
            read_data_buffer    <=  'b0;
            unshifted_byteenable <= 'b0;
            byte_avail          <=  'b0;
            fifo_data_buffer    <=  'b0;
      end else begin
            address[1:0]      <= 'b0;
            in_ready_0 <= 1'b0;
            
            if (counter > 3)       unshifted_byteenable <= 4'b1111;
            else if (counter == 3) unshifted_byteenable <= 4'b0111;
            else if (counter == 2) unshifted_byteenable <= 4'b0011;
            else if (counter == 1) unshifted_byteenable <= 4'b0001;

            case (state)
              READY : begin
                   in_ready_0        <= !fifo_write_waitrequest;
                   fifo_write        <= 1'b0;
              end
              GET_EXTRA : begin
                   in_ready_0        <= 1'b1;
                   byteenable        <=  'b0;
                   if (enable) state <= GET_SIZE1;
              end

              GET_SIZE1 : begin
                   in_ready_0        <= 1'b1;
                   counter[15:8]     <= command[4]?in_data:8'b0;
                   if (enable) state <= GET_SIZE2;
              end

              GET_SIZE2 : begin
                   in_ready_0        <= 1'b1;
                   counter[7:0]      <= command[4]?in_data:8'b0;
                   if (enable) state <= GET_ADDR1;
              end
              
              GET_ADDR1 : begin
                in_ready_0        <= 1'b1;
                first_trans       <= 1'b1;
                last_trans        <= 1'b0;
                address[31:24]    <= in_data;
                if (enable) state <= GET_ADDR2;
              end

              GET_ADDR2 : begin
                in_ready_0        <= 1'b1;
                address[23:16]    <= in_data;
                if (enable) state <= GET_ADDR3;
              end

              GET_ADDR3 : begin
                in_ready_0        <= 1'b1;
                address[15:8]     <= in_data;
                if (enable) state <= GET_ADDR4;
              end

              GET_ADDR4 : begin
                in_ready_0        <= 1'b1;
                address[7:2]      <= in_data[7:2];
                current_byte      <= in_data[1:0];
                if (enable) begin
                      if (command == CMD_WRITE_NON_INCR | command == CMD_WRITE_INCR) begin
                        state <= GET_WRITE_DATA; 
                        in_ready_0 <= 1'b1;
                      end
                      else if (command == CMD_READ_NON_INCR | command == CMD_READ_INCR) begin
                        state   <= READ_ASSERT; 
                        in_ready_0 <= 1'b0;
                      end
                      else begin
                        in_ready_0          <= 1'b0;
                        state <= FIFO_CMD_WAIT; 
                        fifo_writedata[7:0] <= (8'h80 | command);
                        fifo_writedata[35:8]<= {4'b1111,counter[7:0],counter[15:8],8'b0};
                        fifo_write          <= 1'b1;    
                        counter             <= 0;
                      end
                end
              end

              GET_WRITE_DATA : begin
                        in_ready_0 <= 1'b1; 
                        if (enable) begin
                          counter <= counter + 1'b1;
                          current_byte <= current_byte + 1'b1;
                          if (in_endofpacket || current_byte == 3) 
                          begin
                             in_ready_0 <= 1'b0;
                             write      <= 1'b1;
                             state      <= WRITE_WAIT;
                          end
                        end
                        if (in_endofpacket) begin
                          last_trans <= 1'b1;
                        end
                        case (current_byte)
                          0: begin
                            writedata[7:0]   <= in_data;
                            byteenable[0]    <= 1'b1;
                          end
                          1: begin
                            writedata[15:8]  <= in_data;
                            byteenable[1]    <= 1'b1;
                          end
                          2: begin
                            writedata[23:16] <= in_data;
                            byteenable[2]    <= 1'b1;
                          end
                          3: begin
                            writedata[31:24] <= in_data;
                            byteenable[3]    <= 1'b1;
                          end
                        endcase
              end
              WRITE_WAIT : begin
                        in_ready_0 <= 1'b0;
                        write      <= 1'b1;
                        if (~waitrequest) begin
                           write <= 1'b0;
                           state <= GET_WRITE_DATA;
                           in_ready_0 <= 1'b1;
                           byteenable <= 'b0;
                           if (command[2] == 1'b1) begin
                              address[31:2] <= (address[31:2] + 1'b1);
                           end
                           if (last_trans) begin
                               in_ready_0         <= 1'b0;
                               state <= FIFO_CMD_WAIT;
                               fifo_writedata[7:0] <= (8'h80 | command);
                               fifo_writedata[35:8]<= {4'b1111,counter[7:0],counter[15:8],8'b0};
                               fifo_write          <= 1'b1;
                               counter             <= 0;
                           end
                        end
              end
              READ_ASSERT : begin
                            if (current_byte == 3) byteenable <= unshifted_byteenable << 3;
                            if (current_byte == 2) byteenable <= unshifted_byteenable << 2;
                            if (current_byte == 1) byteenable <= unshifted_byteenable << 1;
                            if (current_byte == 0) byteenable <= unshifted_byteenable;
                            read             <= 1'b1;
                            fifo_write       <= 1'b0;
                            state            <= READ_CMD_WAIT;
              end
              READ_CMD_WAIT : begin
                        case (byteenable)
                            4'b0000 : byte_avail <= 1'b0;
                            4'b0001 : byte_avail <= 1'b0;
                            4'b0010 : byte_avail <= 1'b0;
                            4'b0100 : byte_avail <= 1'b0;
                            4'b1000 : byte_avail <= 1'b0;
                            4'b0011 : byte_avail <= 1'b1;
                            4'b0110 : byte_avail <= 1'b1;
                            4'b1100 : byte_avail <= 1'b1;
                            4'b0111 : byte_avail <= 2'h2;
                            4'b1110 : byte_avail <= 2'h2;
                            default : byte_avail <= 2'h3;
                        endcase
                        read_data_buffer <= readdata;
                        read             <= 1; 
                        if (readdatavalid) begin
                           state <= PUSH_FIFO;
                           read <= 0;
                        end else begin
                           if (~waitrequest) begin
                               state <= READ_DATA_WAIT;
                               read <= 0;
                           end
                        end
              end
              READ_DATA_WAIT : begin
                        read_data_buffer <= readdata;
                        if (readdatavalid) begin
                            state <= PUSH_FIFO;
                        end
              end              
              PUSH_FIFO : begin
                        fifo_write <= 1'b0;
                        fifo_sop   <= 1'b0;
                        if (first_trans) begin
                            first_trans <= 1'b0;
                            fifo_sop    <= 1'b1;
                        end
                        case (current_byte)
                            3 : begin
                                fifo_data_buffer <= read_data_buffer >> 24;
                                counter <= counter - 1'b1;
                            end
                            2 : begin
                                fifo_data_buffer <= read_data_buffer >> 16;
                                if (counter == 1) counter <= 0;
                                else counter <= counter - 2'h2;
                            end
                            1 : begin
                                fifo_data_buffer <= read_data_buffer >> 8;
                                if (counter < 3) counter <= 0;
                                else counter <= counter - 2'h3;
                            end
                            default : begin
                                fifo_data_buffer <= read_data_buffer;
                                if (counter < 4) counter <= 0;
                                else counter <= counter - 3'h4;
                            end
                        endcase
                        current_byte <= 0;
                        state <= PUSH_FIFO_WAIT;
              end
              PUSH_FIFO_WAIT : begin
                            fifo_write     <= 1'b1;
                            fifo_writedata <= {fifo_sop,(counter == 0)?1'b1:1'b0,byte_avail,fifo_data_buffer};
                            
                            if (counter == 0) begin
                                state <= FIFO_CMD_WAIT;
                            end else if (command[2]== 1'b1) begin
                                    state <= FIFO_CMD_WAIT;
                                    address[31:2] <= (address[31:2] + 1'b1);
                            end
              end
              FIFO_CMD_WAIT : begin
                        if (!fifo_write_waitrequest) begin
                            if (counter == 0) begin
                                state       <= READY;
                            end else begin
                                state <= READ_ASSERT;
                            end
                            fifo_write  <= 1'b0;
                        end
              end
           endcase
           if (enable & in_startofpacket) begin
              state      <= GET_EXTRA;
              command    <= in_data;
              in_ready_0 <= !fifo_write_waitrequest;
           end
      end  
   end  
endmodule

// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module fifo_buffer_single_clock_fifo (
                                                    aclr,
                                                    clock,
                                                    data,
                                                    rdreq,
                                                    wrreq,

                                                    empty,
                                                    full,
                                                    q
                                                 )
;

  parameter FIFO_DEPTHS = 2;
  parameter FIFO_WIDTHU = 1;

  output           empty;
  output           full;
  output  [ 35: 0] q;
  input            aclr;
  input            clock;
  input   [ 35: 0] data;
  input            rdreq;
  input            wrreq;

  wire             empty;
  wire             full;
  wire    [ 35: 0] q;
  scfifo single_clock_fifo
    (
      .sclr (1'b0),
      .aclr (aclr),
      .clock (clock),
      .data (data),
      .empty (empty),
      .full (full),
      .q (q),
      .rdreq (rdreq),
      .wrreq (wrreq)
    );

  defparam single_clock_fifo.add_ram_output_register = "OFF",
           single_clock_fifo.lpm_numwords = FIFO_DEPTHS,
           single_clock_fifo.lpm_showahead = "OFF",
           single_clock_fifo.lpm_type = "scfifo",
           single_clock_fifo.lpm_width = 36,
           single_clock_fifo.lpm_widthu = FIFO_WIDTHU,
           single_clock_fifo.overflow_checking = "ON",
           single_clock_fifo.underflow_checking = "ON",
           single_clock_fifo.use_eab = "OFF";


endmodule



// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module fifo_buffer_scfifo_with_controls (
                                                       clock,
                                                       data,
                                                       rdreq,
                                                       reset_n,
                                                       wrreq,

                                                       empty,
                                                       full,
                                                       q
                                                    )
;

  parameter FIFO_DEPTHS = 2;
  parameter FIFO_WIDTHU = 1;
  
  output           empty;
  output           full;
  output  [ 35: 0] q;
  input            clock;
  input   [ 35: 0] data;
  input            rdreq;
  input            reset_n;
  input            wrreq;

  wire             empty;
  wire             full;
  wire    [ 35: 0] q;
  wire             wrreq_valid;
  fifo_buffer_single_clock_fifo #(
            .FIFO_DEPTHS(FIFO_DEPTHS),
            .FIFO_WIDTHU(FIFO_WIDTHU)
  ) the_scfifo (
      .aclr  (~reset_n),
      .clock (clock),
      .data  (data),
      .empty (empty),
      .full  (full),
      .q     (q),
      .rdreq (rdreq),
      .wrreq (wrreq_valid)
    );

  assign wrreq_valid = wrreq & ~full;

endmodule

// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module fifo_buffer (
                                  avalonmm_read_slave_read,
                                  avalonmm_write_slave_write,
                                  avalonmm_write_slave_writedata,
                                  reset_n,
                                  wrclock,

                                  avalonmm_read_slave_readdata,
                                  avalonmm_read_slave_waitrequest,
                                  avalonmm_write_slave_waitrequest
                               )
;

  parameter FIFO_DEPTHS = 2;
  parameter FIFO_WIDTHU = 1;


  output  [ 35: 0] avalonmm_read_slave_readdata;
  output           avalonmm_read_slave_waitrequest;
  output           avalonmm_write_slave_waitrequest;
  input            avalonmm_read_slave_read;
  input            avalonmm_write_slave_write;
  input   [ 35: 0] avalonmm_write_slave_writedata;
  input            reset_n;
  input            wrclock;

  wire    [ 35: 0] avalonmm_read_slave_readdata;
  wire             avalonmm_read_slave_waitrequest;
  wire             avalonmm_write_slave_waitrequest;
  wire             clock;
  wire    [ 35: 0] data;
  wire             empty;
  wire             full;
  wire    [ 35: 0] q;
  wire             rdreq;
  wire             wrreq;
  fifo_buffer_scfifo_with_controls #(
      .FIFO_DEPTHS(FIFO_DEPTHS),
      .FIFO_WIDTHU(FIFO_WIDTHU)
  ) the_scfifo_with_controls
    (
      .clock   (clock),
      .data    (data),
      .empty   (empty),
      .full    (full),
      .q       (q),
      .rdreq   (rdreq),
      .reset_n (reset_n),
      .wrreq   (wrreq)
    );

  assign data = avalonmm_write_slave_writedata;
  assign wrreq = avalonmm_write_slave_write;
  assign avalonmm_read_slave_readdata = q;
  assign rdreq = avalonmm_read_slave_read;
  assign clock = wrclock;
  assign avalonmm_write_slave_waitrequest = full;
  assign avalonmm_read_slave_waitrequest = empty;

endmodule


module fifo_to_packet (

      input              clk,
      input              reset_n,

      input              out_ready,
      output reg         out_valid,
      output reg [ 7: 0] out_data,
      output reg         out_startofpacket,
      output reg         out_endofpacket,

      input  [ 35: 0]    fifo_readdata,
      output reg         fifo_read,
      input              fifo_empty 
);

reg [ 1: 0]     state;
reg             enable, sent_all;
reg [ 1: 0]     current_byte, byte_end;
reg             first_trans, last_trans;
reg [ 23:0]     fifo_data_buffer;

localparam    POP_FIFO        = 2'b00,
              POP_FIFO_WAIT   = 2'b01,
              FIFO_DATA_WAIT  = 2'b10,
              READ_SEND_ISSUE = 2'b11;

always @* begin
      enable = (!fifo_empty & sent_all);
end
          
always @(posedge clk or negedge reset_n) begin
          if (!reset_n) begin
                fifo_data_buffer  <=  'b0;
                out_startofpacket <= 1'b0;
                out_endofpacket   <= 1'b0;
                out_valid         <= 1'b0;
                out_data          <=  'b0;
                state             <=  'b0;
                fifo_read         <= 1'b0;
                current_byte      <=  'b0;
                byte_end          <=  'b0;
                first_trans       <= 1'b0;
                last_trans        <= 1'b0;
                sent_all          <= 1'b1;
          end else begin
                if (out_ready) begin
                  out_startofpacket <= 1'b0;
                  out_endofpacket   <= 1'b0;
                end
                
                case (state)
                  POP_FIFO : begin
                            if (out_ready) begin
                                out_startofpacket   <= 1'b0;
                                out_endofpacket     <= 1'b0;
                                out_valid           <= 1'b0;
                                first_trans         <= 1'b0;
                                last_trans          <= 1'b0;
                                byte_end            <=  'b0;
                                fifo_read           <= 1'b0;
                                sent_all            <= 1'b1;
                            end
                            if (enable) begin   
                                fifo_read       <= 1'b1;
                                out_valid       <= 1'b0;
                                state           <= POP_FIFO_WAIT;
                            end
                  end
                  POP_FIFO_WAIT : begin
                                fifo_read               <= 1'b0;
                                state                   <= FIFO_DATA_WAIT;
                  end
                  FIFO_DATA_WAIT : begin
                                sent_all                <= 1'b0;
                                first_trans             <= fifo_readdata[35];
                                last_trans              <= fifo_readdata[34];
                                out_data                <= fifo_readdata[7:0];
                                fifo_data_buffer        <= fifo_readdata[31:8];
                                byte_end                <= fifo_readdata[33:32];
                                current_byte            <= 1'b1;
                                out_valid               <= 1'b1;
                                
                                if (fifo_readdata[35] & fifo_readdata[34] & (fifo_readdata[33:32] == 0)) begin
                                    first_trans         <= 1'b0;
                                    last_trans          <= 1'b0;
                                    out_startofpacket   <= 1'b1;
                                    out_endofpacket     <= 1'b1;
                                    state <= POP_FIFO;
                                end else if (fifo_readdata[35] & (fifo_readdata[33:32] == 0)) begin
                                    first_trans         <= 1'b0;
                                    out_startofpacket   <= 1'b1;
                                    state               <= POP_FIFO;
                                end else if (fifo_readdata[35]) begin
                                   first_trans          <= 1'b0;
                                   out_startofpacket    <= 1'b1;
                                   state <= READ_SEND_ISSUE;
                                end else if (fifo_readdata[34] & (fifo_readdata[33:32] == 0)) begin
                                    last_trans          <= 1'b0;
                                    out_endofpacket     <= 1'b1;
                                    state               <= POP_FIFO;
                                end else begin
                                    state               <= READ_SEND_ISSUE;
                                end
                                
                  end
                  READ_SEND_ISSUE : begin
                            out_valid         <= 1'b1;
                            sent_all          <= 1'b0;
                            
                            if (out_ready) begin
                                out_startofpacket <= 1'b0;
                                if (last_trans & (current_byte == byte_end)) begin
                                        last_trans      <= 1'b0;
                                        out_endofpacket <= 1'b1;
                                        state           <= POP_FIFO;
                                end
                                case (current_byte)
                                       3: begin
                                          out_data <= fifo_data_buffer[23:16];
                                       end
                                       2: begin
                                          out_data <= fifo_data_buffer[15:8];
                                       end
                                       1: begin
                                          out_data <= fifo_data_buffer[7:0];
                                       end
                                       default: begin
                                       end
                                endcase
                                current_byte <= current_byte + 1'b1;
                                if (current_byte == byte_end) begin
                                    state <= POP_FIFO;
                                end else begin
                                    state <= READ_SEND_ISSUE;
                                end
                            end
                  end
                endcase
          end
    end
endmodule

module packets_to_master (

      input              clk,
      input              reset_n,
      output reg         in_ready,
      input              in_valid,
      input      [ 7: 0] in_data,
      input              in_startofpacket,
      input              in_endofpacket,

      input              out_ready,
      output reg         out_valid,
      output reg [ 7: 0] out_data,
      output reg         out_startofpacket,
      output reg         out_endofpacket,

      output reg [31: 0] address,
      input      [31: 0] readdata,
      output reg         read,
      output reg         write,
      output reg [ 3: 0] byteenable,
      output reg [31: 0] writedata,
      input              waitrequest,
      input              readdatavalid
      
);

   parameter EXPORT_MASTER_SIGNALS = 0;

   localparam CMD_WRITE_NON_INCR = 8'h00;
   localparam CMD_WRITE_INCR     = 8'h04;
   localparam CMD_READ_NON_INCR  = 8'h10;
   localparam CMD_READ_INCR      = 8'h14;
   

   reg  [ 3: 0]  state;
   reg  [ 7: 0]  command;
   reg  [ 1: 0]  current_byte; 
   reg  [ 15: 0] counter;
   reg  [ 23: 0] read_data_buffer;
   reg           in_ready_0;
   reg           first_trans, last_trans;
   reg  [ 3: 0]  unshifted_byteenable;
   wire enable;

   localparam READY          = 4'b0000, 
              GET_EXTRA      = 4'b0001,
              GET_SIZE1      = 4'b0010,
              GET_SIZE2      = 4'b0011,
              GET_ADDR1      = 4'b0100,
              GET_ADDR2      = 4'b0101,
              GET_ADDR3      = 4'b0110,
              GET_ADDR4      = 4'b0111,
              GET_WRITE_DATA = 4'b1000,      
              WRITE_WAIT     = 4'b1001,
              RETURN_PACKET  = 4'b1010,
              READ_ASSERT    = 4'b1011,
              READ_CMD_WAIT  = 4'b1100,
              READ_DATA_WAIT = 4'b1101,
              READ_SEND_ISSUE= 4'b1110,
              READ_SEND_WAIT = 4'b1111;
   
   

   assign enable = (in_ready & in_valid);

   always @*
      in_ready = in_ready_0;
   
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
            in_ready_0        <= 1'b0;
            out_startofpacket <= 1'b0;
            out_endofpacket   <= 1'b0;
            out_valid         <= 1'b0;
            out_data          <=  'b0;
            read              <= 1'b0;
            write             <= 1'b0;
            byteenable        <=  'b0;
            writedata         <=  'b0;
            address           <=  'b0;
            counter           <=  'b0;
            command           <=  'b0;
            first_trans       <= 1'b0;
            last_trans        <= 1'b0;
            state             <= 'b0;
            current_byte      <= 'b0;
            read_data_buffer  <= 'b0;
            unshifted_byteenable <= 'b0;
      end else begin
            address[1:0]      <= 'b0;
 
            if (out_ready) begin
              out_startofpacket <= 1'b0;
              out_endofpacket   <= 1'b0;
              out_valid         <= 1'b0;
            end
            in_ready_0 <= 1'b0;
            
            if (counter >= 3)      unshifted_byteenable <= 4'b1111;
            else if (counter == 3) unshifted_byteenable <= 4'b0111;
            else if (counter == 2) unshifted_byteenable <= 4'b0011;
            else if (counter == 1) unshifted_byteenable <= 4'b0001;

            case (state)
              READY : begin
                   out_valid         <= 1'b0;
                   in_ready_0        <= 1'b1;
              end
              GET_EXTRA : begin
                   in_ready_0        <= 1'b1;
                   byteenable        <=  'b0;
                   if (enable) state <= GET_SIZE1;
              end

              GET_SIZE1 : begin
                   in_ready_0        <= 1'b1;
                   counter[15:8]     <= command[4]?in_data:8'b0;
                   if (enable) state <= GET_SIZE2;
              end

              GET_SIZE2 : begin
                   in_ready_0        <= 1'b1;
                   counter[7:0]      <= command[4]?in_data:8'b0;
                   if (enable) state <= GET_ADDR1;
              end
              
              GET_ADDR1 : begin
                in_ready_0        <= 1'b1;
                first_trans       <= 1'b1;
                last_trans        <= 1'b0;
                address[31:24]    <= in_data;
                if (enable) state <= GET_ADDR2;
              end

              GET_ADDR2 : begin
                in_ready_0        <= 1'b1;
                address[23:16]    <= in_data;
                if (enable) state <= GET_ADDR3;
              end

              GET_ADDR3 : begin
                in_ready_0        <= 1'b1;
                address[15:8]     <= in_data;
                if (enable) state <= GET_ADDR4;
              end

              GET_ADDR4 : begin
                in_ready_0        <= 1'b1;
                address[7:2]      <= in_data[7:2];
                current_byte      <= in_data[1:0];
                if (enable) begin
                      if (command == CMD_WRITE_NON_INCR | command == CMD_WRITE_INCR) begin
                        state <= GET_WRITE_DATA; 
                        in_ready_0 <= 1'b1;
                      end
                      else if (command == CMD_READ_NON_INCR | command == CMD_READ_INCR) begin
                        state   <= READ_ASSERT; 
                        in_ready_0 <= 1'b0;
                      end
                      else begin
                        state <= RETURN_PACKET; 
                        out_startofpacket <= 1'b1;
                        out_data <= (8'h80 | command);
                        out_valid <= 1'b1;
                        current_byte <= 'h0;
                        in_ready_0 <= 1'b0;
                      end
                end
              end

              GET_WRITE_DATA : begin
                        in_ready_0 <= 1; 
                        if (enable) begin
                          counter <= counter + 1'b1;
                          current_byte <= current_byte + 1'b1;
                          if (in_endofpacket || current_byte == 3) 
                          begin
                             in_ready_0 <= 0;
                             write      <= 1'b1;
                             state      <= WRITE_WAIT;
                          end
                        end
                        if (in_endofpacket) begin
                          last_trans <= 1'b1;
                        end
                        case (current_byte)
                          0: begin
                            writedata[7:0]   <= in_data;
                            byteenable[0]    <= 1;
                          end
                          1: begin
                            writedata[15:8]  <= in_data;
                            byteenable[1]    <= 1;
                          end
                          2: begin
                            writedata[23:16] <= in_data;
                            byteenable[2]    <= 1;
                          end
                          3: begin
                            writedata[31:24] <= in_data;
                            byteenable[3]    <= 1;
                          end
                        endcase
              end

              WRITE_WAIT : begin
                        in_ready_0 <= 0;
                        write      <= 1'b1;
                        if (~waitrequest) begin
                           write <= 1'b0;
                           state <= GET_WRITE_DATA;
                           in_ready_0 <= 1;
                           byteenable <= 'b0;
                           if (command[2] == 1'b1) begin
                              address[31:2] <= (address[31:2] + 1'b1);
                           end
                           if (last_trans) begin
                              state <= RETURN_PACKET;
                              out_startofpacket <= 1'b1;
                              out_data <= (8'h80 | command);
                              out_valid <= 1'b1;
                              current_byte <= 'h0;
                              in_ready_0 <= 1'b0;
                           end
                        end
              end
              
              RETURN_PACKET : begin
                        out_valid <= 1'b1;
                        if (out_ready) begin
                           case (current_byte)
                             0: begin
                               out_data <= 8'b0;
                             end
                             1: begin
                               out_data <= counter[15:8];
                             end
                             2: begin
                               out_endofpacket <= 1'b1;
                               out_data <= counter[7:0];
                             end
                             default: begin
                             end
                           endcase
                           current_byte <= current_byte + 1'b1;
                           if (current_byte == 3) begin
                              state     <= READY;
                              out_valid <= 1'b0;
                           end
                           else                   state     <= RETURN_PACKET;
                        end
              end
              READ_ASSERT : begin
                        if (current_byte == 3) byteenable <= unshifted_byteenable << 3;
                        if (current_byte == 2) byteenable <= unshifted_byteenable << 2;
                        if (current_byte == 1) byteenable <= unshifted_byteenable << 1;
                        if (current_byte == 0) byteenable <= unshifted_byteenable;
                        read             <= 1;
                        state            <= READ_CMD_WAIT;
              end
              READ_CMD_WAIT : begin
                        read_data_buffer <= readdata[31:8];
                        out_data         <= readdata[7:0];
                        read             <= 1; 
                        if (readdatavalid) begin
                           state <= READ_SEND_ISSUE;
                           read <= 0;
                        end else begin
                           if (~waitrequest) begin
                               state <= READ_DATA_WAIT;
                               read <= 0;
                           end
                        end
              end
              READ_DATA_WAIT : begin
                        read_data_buffer <= readdata[31:8];
                        out_data         <= readdata[7:0];
                        if (readdatavalid) begin
                            state <= READ_SEND_ISSUE;
                        end
              end
              READ_SEND_ISSUE : begin
                        out_valid <= 1'b1;
                        out_startofpacket <= 'h0;
                        out_endofpacket   <= 'h0;
                        if (counter == 1) begin
                           out_endofpacket <= 1'b1;
                        end 
                        if (first_trans) begin
                           first_trans <= 1'b0;
                           out_startofpacket <= 1'b1;
                        end
                        case (current_byte)
                          3: begin
                             out_data        <= read_data_buffer[23:16];
                          end
                          2: begin
                             out_data        <= read_data_buffer[15:8];
                          end
                          1: begin
                             out_data        <= read_data_buffer[7:0];
                          end
                          default: begin
                             out_data        <= out_data; 
                          end
                        endcase
                        state <= READ_SEND_WAIT;
              end
              READ_SEND_WAIT : begin
                        out_valid <= 1'b1;
                        if (out_ready) begin
                           counter <= counter - 1'b1;
                           current_byte <= current_byte + 1'b1;
                           out_valid <= 1'b0;
                           
                           if (counter == 1) begin
                              state <= READY;
                           end else if (current_byte == 3) begin
                              if (command[2] == 1'b1) begin
                                 address[31:2] <= (address[31:2] + 1'b1);
                              end
                              state <= READ_ASSERT;
                           end else begin
                              state <= READ_SEND_ISSUE;
                           end
                        end 
              end
           endcase
           if (enable & in_startofpacket) begin
              state <= GET_EXTRA;
              command           <= in_data;
              in_ready_0 <= 1'b1;
           end
      end  
   end  
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FiZarn/1EfUfU7Kg2eR0Eo3TbARWsXLknUXtiTLDF2ftN6ZlsUVUgZbHAnMkV3HrqLGtgBkzkIYMG15ZY6/4W4IqCc3Dlvb9ORGVxxC6JfM1T2T9fL8X+p+dRUxf4qWEL6wOwxTgb6NAL86tERw+Mrfwm0Zkk6Pl0fUAoDQ8YB0svQk4RBKJfdaCTFQHEESD7qtqUX5Imxo+ePK0D3+FPeJ38bgEUI4iUWyxfmItrf4XdfEi9OnBMyc9XESRqatMU53dCNkiOd/oxcrw/tDTmn32S9ANr4eoQNzRF54HUDowlgT05MA04SCZXn8xO3lMFNJ2VGsurciiO9ozZ0Oaq2EhEiIfnUW6cingwsU8E2/OKoOhQ4IE7CEncQj7WC4gUw0IvTrhAOje0Mp84bdDO4NAGZhUc0XRgxecZ+voUqfjvMHcUGNlOx9FXcDpqKjD/nNCAQjp+u3jXNIhCFJL5ZDz5ajAb8WTvcIT6SoP/YCNXz30ZDHB/Avoiv9qwiyOEM3fKAQIgleI4i2avBmrKBA/jUmdcEjPyjyEkpZoQwqNDYwLuSkAUPe2lTstztngtOrk7iF5L6au5uJxa4hpo6/aYLbNMCnFRGY7ZsrI7LoDpEVaeJMyJ+zCEhB/lxvDqgwvLkpaNditBOGtYnlh9rnXfyIk2OdzGu42buLWhTKeiC3FVlQ4M9v68wsL6lAPboNloXrn1EPr6cu26UYcptvB9sKAPEKV78kRG8/c9hgASPlAOOR3rVn2+UyNxo7aaqLb6/XH0NBAtQSxfe+kSAz"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc+pRE1ZeUS+UZv9GlVV5HRf7Bc/eIRaoSanC1igjZidWmzgklO9hUULeeVPgx5r2iML9H+PJ5fuij8vw8HeZtUSPCps2+0CYzkgBCaYpG+Mix2W32ufhjwMDyVh/pxLf7eTY1T8qiXkl5bdHPExDnCWNd+AogMT1GN0+l3GqPSIaeQc/3ZoVAy0epICoCSab22jUWlQl4wQFznc2Ks4KMmMZG4VVNGkwiJNtXQRkymt+qY1vyNj0bDuV77ayPmFhXkd8lVk4i9X0ompN+clVs4HY5uzPuwrCxF0BU5qqKXVpom59sSK6fbEnAiZErS5UqHE81ab3AAV0wtgjWLV0txw5M1ALzGu4JLrOHDZQYsK5pvAg6rPCQQwLx+PrsDMFQEp5eaJ90XsDrsftXIJNOTCD/y7GsMWAUFSyTmQ3UJkWb2cyGTn/96k4Bz6542d2q9Icxmvyf5Y+Ykp99UW42HBMebQc8uS4RH2VvkUkV92Y9ANsahTdqmvedcEiPwT1JXE2Vlud2Ouq9FG+UiLYUl6LapdE9ufydm4sn3r1v+eZXR6wiQ/ls8nvifH1FBk75CNnrbgHP76xDPWMzyh/q+d8PunFGp/TuWmlBVwmQ2r4xc05e1W76cVQLCe09uMntGGJ6vmRqPsTS61qWgeKb8B5wC/6nCwLrQC3GkLx/YWLMVEgi5rvusapTBKnZAFLkcSc30vusBLaDdSaFoZSayqIQVxYiGjf2Pz62OBdQE5WdTxm1OrH5A2upwNJ5NZMT6DlG2glp7JHu+a/JXJKq+A"
`endif