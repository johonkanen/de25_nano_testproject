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
module altera_avalon_st_bytes_to_packets
#(    parameter CHANNEL_WIDTH = 8,
      parameter ENCODING      = 0 ) 
(
      input              clk,
      input              reset_n,
      input              out_ready,
      output reg         out_valid,
      output reg [7: 0]  out_data,
      output reg [CHANNEL_WIDTH-1: 0]  out_channel,
      output reg         out_startofpacket,
      output reg         out_endofpacket,

      output reg         in_ready,
      input              in_valid,
      input      [7: 0]  in_data
);


   reg  received_esc, received_channel, received_varchannel;
   wire escape_char, sop_char, eop_char, channel_char, varchannelesc_char;

   wire [7:0] data_out;


   assign sop_char     = (in_data == 8'h7a);
   assign eop_char     = (in_data == 8'h7b);
   assign channel_char = (in_data == 8'h7c);
   assign escape_char  = (in_data == 8'h7d);

   assign data_out = received_esc ? (in_data ^ 8'h20) : in_data;

generate
if (CHANNEL_WIDTH == 0) begin
    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         received_esc      <= 0;
         out_startofpacket <= 0;
         out_endofpacket   <= 0;
      end else begin
         if (in_valid & in_ready) begin
            if (received_esc) begin
               if (out_ready) received_esc <= 0;
            end else begin
               if (escape_char)    received_esc      <= 1;
               if (sop_char)       out_startofpacket <= 1;
               if (eop_char)       out_endofpacket   <= 1;
            end
            if (out_ready  & out_valid) begin
               out_startofpacket <= 0;
               out_endofpacket   <= 0;
            end 
         end
      end
   end

   always @* begin
      in_ready = out_ready;

      out_valid = 0;
      if ((out_ready | ~out_valid) && in_valid) begin
         out_valid = 1;
            if (sop_char | eop_char | escape_char | channel_char) out_valid = 0;
      end
      out_data = data_out; 
   end

end else begin
    assign varchannelesc_char = in_data[7];
    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         received_esc <= 0;
         received_channel <= 0;
         received_varchannel <= 0;
         out_startofpacket <= 0;
         out_endofpacket <= 0;
      end else begin
         if (in_valid & in_ready) begin
            if (received_esc) begin
               if (out_ready | received_channel | received_varchannel) received_esc <= 0;
            end else begin
               if (escape_char)                received_esc        <= 1;
               if (sop_char)                   out_startofpacket   <= 1;
               if (eop_char)                   out_endofpacket     <= 1;
               if (channel_char & ENCODING )   received_varchannel <= 1;
               if (channel_char & ~ENCODING)   received_channel    <= 1;
            end
            if (received_channel & (received_esc | (~sop_char & ~eop_char & ~escape_char & ~channel_char ))) begin
               received_channel <= 0;
            end
            if (received_varchannel & ~varchannelesc_char & (received_esc | (~sop_char & ~eop_char & ~escape_char & ~channel_char))) begin
               received_varchannel <= 0;
            end
            if (out_ready  & out_valid) begin
               out_startofpacket <= 0;
               out_endofpacket <= 0;
            end 
         end
      end
   end

   always @* begin
      in_ready = out_ready;
      out_valid = 0;
      if ((out_ready | ~out_valid) && in_valid) begin
         out_valid = 1;
         if (received_esc) begin 
           if (received_channel | received_varchannel) out_valid = 0;
         end else begin
            if (sop_char | eop_char | escape_char | channel_char | received_channel | received_varchannel) out_valid = 0;
         end
      end
      out_data = data_out; 
   end
end 

endgenerate

generate
if (CHANNEL_WIDTH == 0) begin    
   always @(posedge clk) begin
      out_channel <= 'h0;
   end

end else if (CHANNEL_WIDTH < 8) begin
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         out_channel <= 'h0;
      end else begin
         if (in_ready & in_valid) begin
            if ((channel_char & ENCODING) & (~received_esc & ~sop_char & ~eop_char & ~escape_char )) begin
               out_channel <= 'h0;
            end else if (received_varchannel & (received_esc | (~sop_char & ~eop_char & ~escape_char & ~channel_char  & ~received_channel))) begin
               out_channel[CHANNEL_WIDTH-1:0] <= data_out[CHANNEL_WIDTH-1:0];
            end
         end
      end
   end

end else begin   
   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         out_channel <= 'h0;
      end else begin
         if (in_ready & in_valid) begin
            if (received_channel & (received_esc | (~sop_char & ~eop_char & ~escape_char & ~channel_char))) begin
               out_channel <= data_out;
            end else if ((channel_char & ENCODING) & (~received_esc & ~sop_char & ~eop_char & ~escape_char )) begin
               out_channel <= 'h0;
            end else if (received_varchannel & (received_esc | (~sop_char & ~eop_char & ~escape_char & ~channel_char  & ~received_channel))) begin
                out_channel <= out_channel <<7;
                out_channel[6:0] <= data_out[6:0];
            end
         end
      end
   end
   
end
endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FjZ6PhPa/ugBMTMfMVHMQR2C8/f/MZmxemf9lgbUBptxwWGvhsI17eMKAlzYHmhLwmLBjUP4tTHPXP1w7xbVA2PKny6QLUBaU4oXuRnyJn99ehRr7AOtK6Qp1zq2deglgqzxoTMsSozGkPa70lyoig5lsYeqkDO7Qic9T3Xs/II2KR0wZ3Tqhq87oEF0tSYvNfBpJqdvlUvdTPaeNOHV6YhCgi+AKH8WpuwL6ze5+hTvflmk8e5vjhqCLIxFYVeTUvWOBecN6lPXB7S661HZz01XBtSZvGbIlzjAPM6lSXCpLfEGQ6C8UPNO4P/VdK+1TyduHQcSYHTZ0Rsz9P2sZSvdwoLqwthDTu8/r2U0WQ+ssQFnlEKJ6Pviui8TjRt0a0jPn8fiYv1OyKQME9+GRgZ7MtosVWyFSq0XbcQvdhJIqUdk8Sl3sNihdgrEUnKvxUfME0sL3Z91q0vi1RVt6PSqY/YA02Vq1MqQdKA1nf0uZAEqcq77AiDreLrVDxCR2oDzZ+avCOvP4zLBn/nkYxzoFNZEB2GLxaHp8cfxuBqHoO2jjH6qK6ZhG0DRl67ctc7swzKnJs+Y71Jrye9GJwRBVZsdR/gR75qutFj9Sy1gM3OfCLLdy2NDmy6jA8euthrUbizzJ7Rfd0KA4vg3EZYRTbisMdbl5gV8ILqDBO2gNNR55u7CsIWjSYnzoBa8Xyq5vX3VJn+Ujo9KquLwr+Wn7oH0D8N9sqk2tHEtIh2pp7oSOPtZiJ70upVbojx8EywKNB5eQDD01CS+W/08b4v"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc9xd6cTHCfxqDhwZ5RVPYcLcJS6903KBCNRIBkDfzrNI0GHJUI+VlhCFTNloDHNQriag3AH68+ft0p59FMTcWpXTQRuwqju4RkIb+jTh16mWzpCSoMgdiM7kdgxNmx7GmkwTLB28IkvN09SKPYAaH5klbA47+EeBdr+NGdaaY5pC9zqrK88zvZhhDJdSIr+v6cqgsuCuSJuzGuhx7ZAjgxIjfPZXrwDFS9gNwSyMhfVjnM3Eudn+sGFHOePrVOPRfe8gctt4zkRSJYKu5d0AmV882klm5i9M+L45G6yDyWscQVOKok+V1kPKSttBH+oHh10ZIGz2FD2MdBZoSzN2P2CK78TZe0WUTfk9C2g3DR/BljyiB0K9xG7UrQ4tMOsAtpR2I+NBE1Pr5mvxi/tlxsJCb9wBcPnkjIy3Y+BAdb+keuPqNKjBgHxR7E1pcAImk7B+kiRVAnBCR54beEs0c5lMxJf3hh04OOHP2ud9lCSooSlccFTU0r6zLevZiq7RjtFtoE3sDQMXil/AJ35/AlVVO10jisQ8BucNyOnEM5sgpMlMAO89S/PS4UdJIcW65maGdbrJEgut8sxR+Uf8kr6aTyDvEI6iDu39TmXlMkgdkMKMDU+rsYZrpFjTC1j+b+pQEPVXXExnuC+bBOkacFJDBU/3cYjYxFLgiM1quAggejmpcOU1Q6+WmaJivsW3t87YTb5X8Cv1KFiTo7CIj9IF3oM6wNMo/S9SXJv0Ym8NFTQ6LXbXXMpRQQfRfWdQC4dTrb6qVbbu4peSw8RLYJ5"
`endif