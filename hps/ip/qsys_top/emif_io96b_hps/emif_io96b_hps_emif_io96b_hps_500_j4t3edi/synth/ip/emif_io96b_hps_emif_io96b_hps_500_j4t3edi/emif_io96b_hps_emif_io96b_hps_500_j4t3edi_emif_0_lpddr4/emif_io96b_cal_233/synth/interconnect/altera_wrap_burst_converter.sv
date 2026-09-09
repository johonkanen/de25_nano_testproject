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

module altera_wrap_burst_converter
#(
  parameter
    MAX_IN_LEN              = 16,
    MAX_OUT_LEN             = 4,
    ADDR_WIDTH              = 12,
    BNDRY_WIDTH             = 12,
    NUM_SYMBOLS             = 4,
    AXI_SLAVE               = 0,
    OPTIMIZE_WRITE_BURST    = 0,
    SYNC_RESET             =  0, 
    LEN_WIDTH       = log2ceil(MAX_IN_LEN) + 1,
    OUT_LEN_WIDTH   = log2ceil(MAX_OUT_LEN) + 1,
    LOG2_NUMSYMBOLS = log2ceil(NUM_SYMBOLS)
)
(
    input                           clk,
    input                           reset,
    input                           enable_write,
    input                           enable_read,

    input [LEN_WIDTH   - 1 : 0]     in_len,
    input [LEN_WIDTH   - 1 : 0]     first_len,
    input                           in_sop,

    input [ADDR_WIDTH  - 1 : 0]     in_addr,
    input [ADDR_WIDTH  - 1 : 0]     in_addr_reg,
    input [BNDRY_WIDTH - 1 : 0]     in_boundary,
    input [BNDRY_WIDTH - 1 : 0]     in_burstwrap,
    input [BNDRY_WIDTH - 1 : 0]     in_burstwrap_reg,

    output reg [LEN_WIDTH - 1 : 0]  out_len,
    output reg [LEN_WIDTH - 1 : 0]  uncompr_out_len,

    output reg [ADDR_WIDTH - 1 : 0] out_addr,
    output reg                      new_burst_export
);

    localparam
        OUT_BOUNDARY        = MAX_OUT_LEN * NUM_SYMBOLS,
        ADDR_SEL            = log2ceil(OUT_BOUNDARY);

    reg [LEN_WIDTH - 1 : 0]        remaining_len;
    reg [LEN_WIDTH - 1 : 0]        next_out_len;
    reg [LEN_WIDTH - 1 : 0]        next_rem_len;
    reg [LEN_WIDTH - 1 : 0]        uncompr_remaining_len;
    reg                            new_burst;
    reg                            uncompr_sub_burst;
    reg [LEN_WIDTH - 1 : 0]        next_uncompr_out_len;
    reg [LEN_WIDTH - 1 : 0]        next_uncompr_sub_len;

    wire [OUT_LEN_WIDTH - 1 : 0]   max_out_length;
    assign max_out_length  = MAX_OUT_LEN[OUT_LEN_WIDTH - 1 : 0];

    reg [ADDR_WIDTH - 1 : 0]       extended_burstwrap;
    reg [ADDR_WIDTH - 1 : 0]       extended_burstwrap_reg;

    always_comb begin
        extended_burstwrap      = {{(ADDR_WIDTH - BNDRY_WIDTH) {in_burstwrap[BNDRY_WIDTH - 1]}}, in_burstwrap};
        extended_burstwrap_reg  = {{(ADDR_WIDTH - BNDRY_WIDTH) {in_burstwrap_reg[BNDRY_WIDTH - 1]}}, in_burstwrap_reg};
        new_burst_export        = new_burst;
    end

   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= reset;
      end
   end
   endgenerate

    reg [LEN_WIDTH -1 : 0] next_uncompr_remaining_len;
    always_comb begin

        if (in_sop) begin
            uncompr_remaining_len = in_len;
        end
        else begin
            uncompr_remaining_len = next_uncompr_remaining_len;
        end
    end 

    always_comb begin : proc_compressed_read
        remaining_len  = in_len;
        if (!new_burst)
            remaining_len = next_rem_len;
    end

    always_comb begin
        next_uncompr_out_len = first_len;
        if (in_sop) begin
            next_uncompr_out_len = first_len;
        end
        else begin
            if (uncompr_sub_burst)
                next_uncompr_out_len = next_uncompr_sub_len;
            else begin
                if (uncompr_remaining_len < max_out_length)
                    next_uncompr_out_len = uncompr_remaining_len;
                else
                    next_uncompr_out_len = max_out_length;
            end
        end
    end

    always_comb begin
        if (new_burst) begin
            next_out_len = first_len;
        end
        else begin
            next_out_len = max_out_length;
            if (remaining_len < max_out_length) begin
                next_out_len = remaining_len;
            end
        end
    end 


    always_ff @(posedge clk) begin
        if (enable_read) begin
            if (new_burst)
                next_rem_len <= in_len - first_len;
            else
                next_rem_len <= next_rem_len - max_out_length;
        end
    end 

    

    always_ff @(posedge clk) begin
        if (enable_write) begin
            if (in_sop)
                next_uncompr_remaining_len  <= in_len - first_len;
            else if (!uncompr_sub_burst)
                next_uncompr_remaining_len  <= next_uncompr_remaining_len - max_out_length;
        end
    end 
    
    always_ff @(posedge clk) begin
        if (enable_write) begin
            next_uncompr_sub_len  <= next_uncompr_out_len - 1'b1; 
        end
    end

   generate 
   if (SYNC_RESET == 0) begin : async_rst2


       always_ff @(posedge clk, posedge reset) begin
           if (reset) begin
               uncompr_sub_burst <= 0;
           end
           else if (enable_write) begin
               uncompr_sub_burst <= (next_uncompr_out_len > 1'b1);
           end
       end
   end 
   else begin 


       always_ff @(posedge clk) begin
           if (internal_sclr) begin
               uncompr_sub_burst <= 0;
           end
           else if (enable_write) begin
               uncompr_sub_burst <= (next_uncompr_out_len > 1'b1);
           end
       end
   end 
   endgenerate

    wire end_compressed_sub_burst;
    assign end_compressed_sub_burst  = (remaining_len == next_out_len);

    generate
     if (SYNC_RESET == 0) begin : async_rst3
       always_ff @(posedge clk, posedge reset) begin
           if (reset) begin
               new_burst   <= 1;
           end
           else if (enable_read) begin
               new_burst   <= end_compressed_sub_burst;
           end
       end
     end 
     else begin 
       always_ff @(posedge clk) begin
           if (internal_sclr) begin
               new_burst   <= 1;
           end
           else if (enable_read) begin
               new_burst   <= end_compressed_sub_burst;
           end
       end
     end 
    endgenerate
    always_ff @(posedge clk) begin
        if (enable_read) begin
            out_len <= next_out_len;
        end
    end


    generate
        if (OPTIMIZE_WRITE_BURST) begin : optimized_write_burst_len
          always_ff @(posedge clk) begin
              if (enable_read) begin
                  uncompr_out_len <= first_len;
              end
          end

        end
        else begin : unoptimized_write_burst_len
          always_ff @(posedge clk) begin
              if (enable_write) begin
                  uncompr_out_len <= next_uncompr_out_len;
              end
          end

        end 
    endgenerate

    reg [ADDR_WIDTH - 1 : 0]        addr_incr;
    localparam [ADDR_WIDTH - 1 : 0] ADDR_INCR = MAX_OUT_LEN << LOG2_NUMSYMBOLS;
    assign addr_incr  = ADDR_INCR[ADDR_WIDTH - 1 : 0];

    reg [ADDR_WIDTH - 1 : 0]    next_out_addr;
    reg [ADDR_WIDTH - 1 : 0]    incremented_addr;
    
    always_ff @(posedge clk) begin
            if (enable_read) begin
                out_addr <=  (next_out_addr);
            end
    end 


    always_ff @(posedge clk) begin
        if (enable_read) begin
            incremented_addr <= ((next_out_addr + addr_incr) & extended_burstwrap_reg);
            if (new_burst) begin
                incremented_addr <= ((next_out_addr + (first_len << LOG2_NUMSYMBOLS)) & extended_burstwrap); 
            end
        end
    end 

  
    always_comb begin
        next_out_addr  = in_addr;
        if (!new_burst) begin
            next_out_addr = in_addr_reg & ~extended_burstwrap_reg | incremented_addr;
        end
    end

    function integer log2ceil;
        input integer val;
        reg[31:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i[30:0] << 1;
            end
        end
    endfunction

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FgX7fXRetecITTJAqdbkZBsCHzJq/Jytj7t5Txnwxy9ssrydFmy2BTmEsJnplde8gT/5Z8QfaR32L5HbYq69F24RC85ln/Re/7VLNnjYyPPB9rIQmswin58UILlVBEJpTgkjDP9oQbneipXCLBJ1GSj75M00bxvksj2EVvOJOeDH43r6CJRONHpyB6hHXe+8v/iaJp3r2XmmPF28YE05QiespwE43MLpe1lNptdNUdnloyWvFt0sdJ6bjThGMjfbGHUoXhygRKVQR19MFPoxnmthXkr6Y8l0Veh/6SyVy17U/CWUSNz6JN4MtV5p4WdDhZsUMapJkR83sXO0fBW/xBER5ys9rKq5b7n13HHftKdVp8vWaOicRKUriPsvJ9tO1x+mioCb7V4xpxaAgivOia0r9fu3oJMebjs5zwVt3NwNLfBdmhE1DstswGwswOR9sifgdyZeV4AYO9wC+3dvrvBl42cpx14z2210+w673Y0mqDu1bV/h4l5CbYz7xpoqqqQVUYRsiUIM35pZHPyCAKn1D6FE2xrMh4s3y9i19A6a3jNlbiWEsfW2oMH9zsXnLL2vFeVdzs2eQR32hVB7wav2ryqSMMm7Lz2GzBCR0ukesTgCjec0DdSpuNYAfS9A4k2ve5gdL+Tl5uM/kfGg9jy+RMV4YUeUYVSrfzqAdIZUVxncEns1FtcTG8LvaG3fjIY/RdlCy20cE9M2KFgGif7Wl2OpyBy7701q2zhsDWOM+3yyMgoXb26zt4mAw0hWgngkIz2etWf+gzYJgRawD0K"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX587MAsJFTYGqBjsqMJNi5JTfmw3e07wdWYHjhsmzgBiO/5ROm7Rg0yzmVS5In4x5gZnNN6PNhYUozoCWDZjkJj/gkgMYUu12lOw7kRhKgr7AKrZVkGO3413BBbiYwVjavRAHy9JDiLqnQkZHcPZJFaQiKuFnTBduvUus3ODlDNlKUUcr3US/hB2uyAzhG8Sm2fwAgDEIdYUjQBVxnkir8icbuU62wIE/igWXHTOBdfTVywS8ZE6j7GovM5/MPLLKKeUjbHX8lqhdO2YQOxqDliOpFK+dHPpENbsnPFY1W4dTazXSUxL6co0bs5Gg4l1UHilAmxAM+UCxQfOGAaEI1aMuvWkDQWhsnL/iG2lpXetMD/A4ZEUM8CzzXCVHYDnzueHMOo6DrRXuhSHMRDao8Vz1dJtnONVr2l1Fn3vj74NsI6zDGVDWesFMSjdPIddJWs8tf7XRchz4GTVonTnkFmz5JdzJmODIDgmnob7YcBGFhYEBAo8BKYTBrU3FDxc/oTBa/FE1OyhO09v1WdApRGgn1lh2SH3gF5oDD34Peipftqg0HneY9D7RDFqyO49ASnULSVrQVHczqHQr5Mqidc5N9VqSJjcm5OH8cIh5mzCGYPBjQ8cdCFhcNl6toDoZt0ScB0lAuPtvOD4oTBcdWJKPoFe2yJ6GjTomqdh6IhqeBtxhy0bdXpwq2yijRt5xi+4KRkUEkKpSbLXewSPxP5ngX8vwS+isJlAdGQV3YUo8fevbyL/6ZiXF37F3GHbZ3R5vLa05rOjzJFk/TwmauT"
`endif