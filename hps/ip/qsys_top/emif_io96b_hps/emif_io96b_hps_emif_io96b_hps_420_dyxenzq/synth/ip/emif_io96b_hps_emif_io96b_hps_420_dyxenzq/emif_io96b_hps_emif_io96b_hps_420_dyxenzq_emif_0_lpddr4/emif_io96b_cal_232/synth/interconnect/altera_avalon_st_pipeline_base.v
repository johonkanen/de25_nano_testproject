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

module altera_avalon_st_pipeline_base (
                                       clk,
                                       reset,
                                       in_ready,
                                       in_valid,
                                       in_data,
                                       out_ready,
                                       out_valid,
                                       out_data
                                       );

   parameter  SYMBOLS_PER_BEAT  = 1;
   parameter  BITS_PER_SYMBOL   = 8;
   parameter  PIPELINE_READY    = 1;
   parameter  SYNC_RESET        = 0;
   parameter  BACKPRESSURE_DURING_RESET = 0;
   localparam DATA_WIDTH = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL;
   
   input clk;
   input reset;
   
   output in_ready;
   input  in_valid;
   input [DATA_WIDTH-1:0] in_data;
   
   input                  out_ready;
   output                 out_valid;
   output [DATA_WIDTH-1:0] out_data;
   
   reg                     full0;
   reg                     full1;
   reg [DATA_WIDTH-1:0]    data0;
   reg [DATA_WIDTH-1:0]    data1;

   assign out_valid = full1;
   assign out_data  = data1;    
   
   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate

   generate if (PIPELINE_READY == 1) 
     begin : REGISTERED_READY_PLINE
        
        assign in_ready  = !full0;

        always @(posedge clk) begin
              if (~full0)
                data0 <= in_data;
              if (~full1 || (out_ready && out_valid)) begin
                 if (full0)
                   data1 <= data0;
                 else
                   data1 <= in_data;
              end
        end
       
        if (SYNC_RESET == 0) begin : async_rst0 
           always @(posedge clk or posedge reset) begin
              if (reset) begin
                 full0    <= BACKPRESSURE_DURING_RESET ? 1'b1 : 1'b0;
                 full1    <= 1'b0;
              end else begin
                 if(~full1 & full0)begin
                     full0 <= 1'b0;
                 end

                 if (~full0 & ~full1) begin
                    if (in_valid) begin
                       full1 <= 1'b1;
                    end
                 end 

                 if (full1 & ~full0) begin
                    if (in_valid & ~out_ready) begin
                       full0 <= 1'b1;
                    end
                    if (~in_valid & out_ready) begin
                       full1 <= 1'b0;
                    end
                 end 
                 
                 if (full1 & full0) begin
                    if (out_ready) begin
                       full0 <= 1'b0;
                    end
                 end 
              end
           end
       end 
       else begin 
           always @(posedge clk ) begin
              if (internal_sclr) begin
                 full0    <= BACKPRESSURE_DURING_RESET ? 1'b1 : 1'b0;
                 full1    <= 1'b0;
              end else begin
                 if(~full1 & full0)begin
                     full0 <= 1'b0;
                 end

                 if (~full0 & ~full1) begin
                    if (in_valid) begin
                       full1 <= 1'b1;
                    end
                 end 

                 if (full1 & ~full0) begin
                    if (in_valid & ~out_ready) begin
                       full0 <= 1'b1;
                    end
                    if (~in_valid & out_ready) begin
                       full1 <= 1'b0;
                    end
                 end 
                 
                 if (full1 & full0) begin
                    if (out_ready) begin
                       full0 <= 1'b0;
                    end
                 end 
              end
           end
       end 
     end 
   else 
     begin : UNREGISTERED_READY_PLINE
	
	assign in_ready = (~full1) | out_ready;

   if (SYNC_RESET == 0) begin : async_rst1	
	   always @(posedge clk or posedge reset) begin
	      if (reset) begin
	         data1 <= 'b0;
	         full1 <= BACKPRESSURE_DURING_RESET ? 1'b1 : 1'b0;
	      end
	      else begin
	         if (in_ready) begin
	   	 data1 <= in_data;
	   	 full1 <= in_valid;
	         end
	      end
	   end
   end 
   else begin 
      always @(posedge clk ) begin
	      if (internal_sclr) begin
	         data1 <= 'b0;
	         full1 <= BACKPRESSURE_DURING_RESET ? 1'b1 : 1'b0;
	      end
	      else begin
	         if (in_ready) begin
	   	 data1 <= in_data;
	   	 full1 <= in_valid;
	         end
	      end
	   end
	end 
     end
   endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "+AbvKNif4wIR5q/igDfM4DePC0l9exDgETX/dMtFAe71y0qcBHKGD6iKoAonAc18tp3+n/dPcXHqqPQcDPaTTmk7OKjrFa3Pkst/YjYx7bmo6SUfrzaVl9kc3zT+f1aRSGKf5IVl/Ez3tpEbJU8K9v/gNVYnzYrHsEy/PmUF70jGx1Y0gg9VJp9ZA4cKQBHvpOeIQDAu1e1V9vqrigbcMJYaagQ8BdQNgGlG54uA9jkeuJGToVB/w0SRZv7vWkHAzy4Kt1CiWFvCd6zJYjSPeLWe6moaY3yNeegErACTuP3xEjI2JtzMm8lHEhSvib+52ZRzcmWf2HX/qHTq3KZeVNAUJF1boYeN2B2s+TtPz2xamQ+itIWJbO7S4C1bxDFEXrZ/rX3Oc8rgPhPCXIx/SwLiXYUuVc+SjdO95Zb1ydeqQh3HEI8j7i+RAy76jv1/E+Ph7e1BWey1tf0MBbI06N3r7cz+VvAdRaUlhViAR2KN/Givzdxrab6o84xhLxO/VSKtbwP2okPpu/ULYd0o2MIgs+tktL1UK8kk8Om0zW8JbYIQLNTYJcI3uGkAJPWWyshRZdliDtKdfiXndHDvCD+feDG/iJ6sLfsHmIAUZZXiWC4HqeCW1hwS44DMPV86WYBmwe0c1QsIG9wlK9QyEy0fZeaKcVOTbiinTRtCSgyCTZUR8BoY5d/PhDcm0vXNEgRWs5B6QNU9U5nSnOoT0AhMtiDrc+2+U1KggIpWPTzAP72cJpXim6RCQlcw67LtY2+CWVwjVeDO8Z0OTrCInuJZs5ZX/HH00Z5DDSHJjqxzaBA1e658Q8pVZzSaQbSOv3TwrFZj42AADRs38L41S26w7XuP0bt0pyH1ZIZXqHWWVYs5jhJJkzObhEq1PPmoUGLamtr7sYO05bvAdWBlqSuYHJBY3/Mi+P8lFn1XolhFrsKIKApYzvVFpLJiqmX3atA2rM1WQMJ2l1n3Jv54co7gFk/s2Wczerlxny75seicGEiBISvmsuWJPoqVG21f"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc8n4bUWfkkdkXRV8T7DTOfYI0ktNYxtMfo0H5CQED9dfFplt2eZI0Yjjlx/MMvMKk5LErDLB+2NLH+gD0Sj6PZN5+LN6vDC6qOnW/VbmXXmjPXEKwSX1loaIyRpLzMc4ne8ygzVpLV0FdimHmdYqrhG6YmDwMnzEziymtPhcVUJLEZKbjTYldYmFWhWzdvdvEhjH2MqqVWZxHRZb3Cq59NKvGoxoUY3L8AbC7ZuRT4IPUg8SzKAumnpxtsCoMV4jNqAIOAMjcOFEeGZ5Ty2sAnC34a7Awp22KSDkvbHIzIV2MZmykkSC56D+56JuVgsmmGuJeVuG8L42e/Tz/1bWQQOefUBpvVEdfPDS0VN50i/pcNiLaiBEVxs6gOC4pCAQuL6Lkm28rFfpDNpICouj2JVq+tcOxtwa2A/9H2uHsWw1QVp5tCUW/BaBE8gO1SNg3YzenVff3bh5/1Jw/dfa3bm5RGDv2egGhUJWVRuKS7HLGtcQpTKEI5INV1Ib3ug9kLBfYDbugBpNkBayr6Tu0BuV53fY4XtHjYcgX3R3vNUlzCttfU31Pl9Lok25tdbbJyzlHcym3qZRmHsql3WAb/WH8VJJb54LFaVmgjEtNrcSM3OHQf4puU1Xb8edWPG5VCdXh1nIv2HBkuT2tcRiw+a14NGUIuHJ7f6wsCrWQ3vzXeUP9NmqRbdxEmGWRytCz0ssspcPEfIkvOJhKoq46HULSMu28ZOLFyPitdLcxdeOqyia7gJLDey4evIt6SgdlLBmlrN6LgwjHtHw2IA9V56"
`endif