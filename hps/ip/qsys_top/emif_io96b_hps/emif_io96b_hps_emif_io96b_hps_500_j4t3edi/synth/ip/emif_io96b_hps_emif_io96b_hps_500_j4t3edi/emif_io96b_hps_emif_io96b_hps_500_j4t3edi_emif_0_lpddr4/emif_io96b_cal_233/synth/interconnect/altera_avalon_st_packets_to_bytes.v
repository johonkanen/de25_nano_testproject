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
module altera_avalon_st_packets_to_bytes
#(    parameter CHANNEL_WIDTH = 8,
      parameter ENCODING      = 0) 
(
      input              clk,
      input              reset_n,
      output reg         in_ready,
      input              in_valid,
      input      [7: 0]  in_data,
      input      [CHANNEL_WIDTH-1: 0]  in_channel,
      input              in_startofpacket,
      input              in_endofpacket,

      input              out_ready,
      output reg         out_valid,
      output reg [7: 0]  out_data
);


   localparam CHN_COUNT = (CHANNEL_WIDTH-1)/7;
   localparam CHN_EFFECTIVE = CHANNEL_WIDTH-1;
   reg  sent_esc, sent_sop, sent_eop;
   reg  sent_channel_char, channel_escaped, sent_channel;
   reg  [CHANNEL_WIDTH-1:0] stored_channel;
   reg  [4:0] channel_count;
   reg    [((CHN_EFFECTIVE/7+1)*7)-1:0] stored_varchannel;
   reg     channel_needs_esc;



   wire need_sop, need_eop, need_esc, need_channel;


// synthesis read_comments_as_HDL on
//assign need_esc = (in_data == 8'h7a | in_data == 8'h7b | in_data == 8'h7c | in_data == 8'h7d );
// synthesis read_comments_as_HDL off

// synthesis translate_off
   assign need_esc = (in_data === 8'h7a | in_data === 8'h7b | in_data === 8'h7c | in_data === 8'h7d );
//  synthesis translate_on


   assign need_eop = (in_endofpacket);
   assign need_sop = (in_startofpacket);


generate
if( CHANNEL_WIDTH > 0) begin
   wire   channel_changed;
   assign channel_changed = (in_channel != stored_channel);
   assign need_channel = (need_sop | channel_changed);

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         sent_esc <= 0;
         sent_sop <= 0;
         sent_eop <= 0;
         sent_channel <= 0;
         channel_escaped <= 0;
         sent_channel_char <= 0;
         out_data <= 0;
         out_valid <= 0;
         channel_count <= 0;
         channel_needs_esc <= 0;
      end else begin

         if (out_ready )
           out_valid <= 0;

         if ((out_ready | ~out_valid) && in_valid  )
           out_valid <= 1;

         if ((out_ready | ~out_valid) && in_valid) begin
            if (need_channel & ~sent_channel) begin
                 if (~sent_channel_char) begin
                    sent_channel_char <= 1;
                    out_data <= 8'h7c;
                    channel_count <= CHN_COUNT[4:0];
                    stored_varchannel <= in_channel;
                    if ((ENCODING == 0) | (CHANNEL_WIDTH == 7)) begin
                    channel_needs_esc <= (in_channel == 8'h7a |
                                          in_channel == 8'h7b |
                                          in_channel == 8'h7c |
                                          in_channel == 8'h7d );
                    end
                 end else if (channel_needs_esc & ~channel_escaped) begin
                    out_data <= 8'h7d;
                    channel_escaped <= 1;
                 end else if (~sent_channel) begin
                       if (ENCODING) begin
                               if (channel_count > 0) begin
                                   if (channel_needs_esc) out_data <= {1'b1, stored_varchannel[((CHN_EFFECTIVE/7+1)*7)-1:((CHN_EFFECTIVE/7+1)*7)-7]} ^ 8'h20;
                                   else                   out_data <= {1'b1, stored_varchannel[((CHN_EFFECTIVE/7+1)*7)-1:((CHN_EFFECTIVE/7+1)*7)-7]};
                                   stored_varchannel <= stored_varchannel<<7;

                                   channel_count <= channel_count - 1'b1;
                                   if (channel_count ==1 & CHANNEL_WIDTH > 7) begin
                                      channel_needs_esc <=
                                         ((stored_varchannel[((CHN_EFFECTIVE/7+1)*7)-8:((CHN_EFFECTIVE/7+1)*7)-14]  == 7'h7a)|
                                         (stored_varchannel[((CHN_EFFECTIVE/7+1)*7)-8:((CHN_EFFECTIVE/7+1)*7)-14] == 7'h7b) |
                                         (stored_varchannel[((CHN_EFFECTIVE/7+1)*7)-8:((CHN_EFFECTIVE/7+1)*7)-14] == 7'h7c) |
                                         (stored_varchannel[((CHN_EFFECTIVE/7+1)*7)-8:((CHN_EFFECTIVE/7+1)*7)-14] == 7'h7d) );
                                   end
                              end else begin
                                   if (channel_needs_esc) begin 
                                      channel_needs_esc <= 0; 
                                      out_data <= {1'b0, stored_varchannel[((CHN_EFFECTIVE/7+1)*7)-1:((CHN_EFFECTIVE/7+1)*7)-7]} ^ 8'h20;
                                   end else   out_data <= {1'b0, stored_varchannel[((CHN_EFFECTIVE/7+1)*7)-1:((CHN_EFFECTIVE/7+1)*7)-7]};
                                   sent_channel <= 1;
                              end
                       end else begin
                            if (channel_needs_esc) begin 
                               channel_needs_esc <= 0; 
                               out_data <= in_channel ^ 8'h20; 
                            end else out_data <= in_channel;
                            sent_channel <= 1;
                       end
                 end
            end else if (need_sop & ~sent_sop) begin
                 sent_sop <= 1;
                 out_data <= 8'h7a;

            end else if (need_eop & ~sent_eop) begin
                 sent_eop <= 1;
                 out_data <= 8'h7b;

            end else if (need_esc & ~sent_esc) begin
                 sent_esc <= 1;
                 out_data <= 8'h7d;
            end else begin
                 if (sent_esc)    out_data <= in_data ^ 8'h20;
                 else             out_data <= in_data;
                 sent_esc <= 0;
                 sent_sop <= 0;
                 sent_eop <= 0;
                 sent_channel <= 0;
                 channel_escaped <= 0;
                 sent_channel_char <= 0;
            end
         end
      end
   end

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         stored_channel <= {CHANNEL_WIDTH{1'b1}};
      end else begin
         if (sent_channel) stored_channel <= in_channel;
      end
   end
    always @* begin

      in_ready = (out_ready | !out_valid) & in_valid & (~need_esc | sent_esc)
                 & (~need_sop | sent_sop)
                 & (~need_eop | sent_eop)
                 & (~need_channel | sent_channel);
   end

end else begin

assign need_channel = (need_sop);

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         sent_esc <= 0;
         sent_sop <= 0;
         sent_eop <= 0;
         out_data <= 0;
         out_valid <= 0;
         sent_channel <= 0;
         sent_channel_char <= 0;
      end else begin

         if (out_ready )
           out_valid <= 0;

         if ((out_ready | ~out_valid) && in_valid  )
           out_valid <= 1;

         if ((out_ready | ~out_valid) && in_valid) begin
            if (need_channel & ~sent_channel) begin
                 if (~sent_channel_char) begin           
                    sent_channel_char <= 1;
                    out_data <= 8'h7c;
                 end else if (~sent_channel) begin
                    out_data <= 'h0;
                    sent_channel <= 1;
                 end
            end else if (need_sop & ~sent_sop) begin
                 sent_sop <= 1;
                 out_data <= 8'h7a;
            end else if (need_eop & ~sent_eop) begin
                 sent_eop <= 1;
                 out_data <= 8'h7b;
            end else if (need_esc & ~sent_esc) begin
                 sent_esc <= 1;
                 out_data <= 8'h7d;
            end else begin
                 if (sent_esc)    out_data <= in_data ^ 8'h20;
                 else             out_data <= in_data;
                 sent_esc <= 0;
                 sent_sop <= 0;
                 sent_eop <= 0;
            end
         end
     end
   end
   
 always @* begin
      in_ready = (out_ready | !out_valid) & in_valid & (~need_esc | sent_esc)
                 & (~need_sop | sent_sop)
                 & (~need_eop | sent_eop)
                 & (~need_channel | sent_channel);
   end
end
endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1Fig3TUJuloNCYSplZZPpOt6ID9qIdlWSlYE/EQHQ4Ky0MdnTvNp4UN2Aq5Q8Ji6GA1rRK7Eddd+jwCFm5/ibjNxL2L2ly/rGOWWHjQb3P2DZpYJHBbq1HeNQlWt9EuBYB8woM1byrDxGAySNv3cXzrfo08ZL+4AqiHT5/QKszSpMOdWEqQ8FEWn0sC4i+HyHAqhfHveRwxRAy0Y0HInc5kVNnuy7kAFzr/ntlETft3R3IehE2kOXxF+I1wu/ufRXMAwAjZ7nfQF1dOkljcrdtxNSCTiBWDFf1CCbS75CXQxA+QhW2+Lkuq3ux6FjzDWXKCWfXheD6PrqAtG8JNSdXIOWso7rYUCxeS7f0TCze/W1X5/0v5OVP4Wun1cyPWeOXRveYY2IUYBkMbA0WP2QRGhrYS7QKeRCJ4B2kH6gXVwaHhbdk7D6r7eX804biwxC8kN38fbsQW8sGP6pHTd9Apnq43bCmnGq/q/0TwSqSpOGrFGcN2L22nlsYnGSAJXwt+QWooBRxVctjgZUy+lBl65qkyXlvissvdMwVuxI4hSIcGpacz3OyEDq3FpEr35wbivbJj54Pv/Q/IHz8QiUhFqmrJfP3alz66Xmfm+vFPkj9mDGsSMGWLRxkFI3WQwyS+bn2LUrUmu3ByBJhCceze0TMpDILkdflPBsZzCZAV6hpEJCh9VHkdir3K5f1xz3ShmPACKt6tZYX0pDULc4bWpxIbDtmsHtkS7YotMWCe8bCFEOZHiFcSLi93z+OFaKeLDJMVBSqwfeo8LJeHw+2ah"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX4vcUpl7fbQuxaKIAO3uJwr8xU8qnTSlDWySM7+0kgqhiaNXdDSBYKkmAAgpnTlqdS5u9VBBLalmAKtapEijVq1j4+hRzOwJwUdx19e0nKUxzFqFoEWyGXb527gnUF2pE5yhI3lxHO6w2T+ujz9IUoHPxqL7rmciHG0leqf7EFRQBYv7M2rvAcsMeJqZUZ3x1YLCTLEf7QmttYm2wao5AfXOBDC8mBlsrErTybLkCf6MSl2X4KPhdmuhs0f3D1YG793k11bwbLHNbZHsnxcInsdn0GX9ooqF7/3dKNx9ttix9RmMApdgJ/7VfzVWUvqffzBaURfnenlMSYNtBG/AyyFJrrUQFnjhBpZMBt44nFszHWGDdACLH4QGoKVwPQ/5pYzgl5YJMjA05WgJfAJ0zNir2xkYrr+oL7CVaVZsbJ2XHIIxjwnX62KXmQsgUtle8U/STKFoQCSqf5GWw84bvZ0CZ9/fUUup2FW3i7cz3W7MY3DE9XTRjmZxQCLt4UIn3EtgevKiPXcvH+0Pekyn+yBBS/Mdz5MQzwMwsSYJOJTsotEnjvFUP2ZViyBKDueOo7/M7Yq/e/MxmKyoksj7T6Xc0iHB+1S+mOJr0/v+fbtE8TKf15ghSJolQcI+BJm2bBNq0BmPxCKd5ygU8Du8ZTzcB6cP8qLAlTj77GrwrHvsjJ9ZDprznvqyyC6BvlEdHqykUvvPFeN+sae+T6GEQ1hGWmVMOSW3Hlzz51ve52lQIDIXvFdZk8OgLp5VdMGdIkgKdL9dCGBvj99+p3NJtut"
`endif