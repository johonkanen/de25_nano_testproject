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

module  altera_merlin_address_alignment
#( 
   parameter 
            ADDR_W            = 12,
            BURSTWRAP_W       = 12,
            TYPE_W            = 2,
            SIZE_W            = 3,
            INCREMENT_ADDRESS = 1,
            NUMSYMBOLS        = 8,
            SELECT_BITS       = log2(NUMSYMBOLS),
            IN_DATA_W         = ADDR_W + (BURSTWRAP_W-1) + TYPE_W + SIZE_W,
            OUT_DATA_W        = ADDR_W + SELECT_BITS,
            SYNC_RESET        = 0 
)
(
    input                       clk,
    input                       reset,
 
    input [IN_DATA_W-1:0]       in_data, 
    input                       in_valid,
    input                       in_sop,
    input                       in_eop,

    output reg [OUT_DATA_W-1:0] out_data,
    input                       out_ready
        
);
typedef enum bit [1:0] 
{
    FIXED       = 2'b00,
    INCR        = 2'b01,
    WRAP        = 2'b10,
    RESERVED    = 2'b11
} AxiBurstType;

function reg[9:0] bytes_in_transfer;
    input [SIZE_W-1:0] axsize;
    case (axsize)
        4'b0000: bytes_in_transfer = 10'b0000000001;
        4'b0001: bytes_in_transfer = 10'b0000000010;
        4'b0010: bytes_in_transfer = 10'b0000000100;
        4'b0011: bytes_in_transfer = 10'b0000001000;
        4'b0100: bytes_in_transfer = 10'b0000010000;
        4'b0101: bytes_in_transfer = 10'b0000100000;
        4'b0110: bytes_in_transfer = 10'b0001000000;
        4'b0111: bytes_in_transfer = 10'b0010000000;
        4'b1000: bytes_in_transfer = 10'b0100000000;
        4'b1001: bytes_in_transfer = 10'b1000000000;
        default: bytes_in_transfer = 10'b0000000001;
    endcase
endfunction

AxiBurstType write_burst_type;

function AxiBurstType burst_type_decode 
(
    input [1:0] axburst
);
    AxiBurstType burst_type;
    begin
        case (axburst)
            2'b00    : burst_type = FIXED;
            2'b01    : burst_type = INCR;
            2'b10    : burst_type = WRAP;
            2'b11    : burst_type = RESERVED;
            default  : burst_type = INCR;
        endcase
        return burst_type;
    end
endfunction

function integer log2;
    input integer value;

    value = value - 1;        
    for(log2 = 0; value > 0; log2 = log2 + 1)
        value = value >> 1;
    
endfunction

    
    function reg[(SELECT_BITS*2)-1 : 0] mask_select_and_align_address;
        input [ADDR_W-1:0] address;
        input [SIZE_W-1:0] size; 
        
        integer            i;
        reg [SELECT_BITS-1:0]  mask_address;
        reg [SELECT_BITS-1:0]  check_unaligned; 
        mask_address   = '1;
        check_unaligned  = '0;
        for(i = 0; i < SELECT_BITS ; i = i + 1) begin
            if (i < size) begin
                check_unaligned[i]  = address[i];
                mask_address[i]       = 1'b0;
            end 
        end
        mask_select_and_align_address   = {check_unaligned,mask_address};
    endfunction

   reg internal_sclr;
   generate if (SYNC_RESET == 1) begin : rst_syncronizer
      always @ (posedge clk) begin
         internal_sclr <= ~reset;
      end
   end
   endgenerate 

    reg [ADDR_W-1 : 0]     in_address;
    reg [ADDR_W-1 : 0]     first_address_aligned;
    reg [SIZE_W-1 : 0]     in_size;
    reg [(SELECT_BITS*2)-1 : 0] output_masks;
    assign in_address             = in_data[SIZE_W+ADDR_W-1 : SIZE_W];
    assign in_size                = in_data[SIZE_W-1 : 0];
    
    always_comb
        begin
            output_masks  = mask_select_and_align_address(in_address, in_size);
        end
    

    generate
        if (SELECT_BITS == 0)
            assign first_address_aligned = in_address;
        else begin
            wire [SELECT_BITS-1 : 0]    aligned_address_bits;
            if (SELECT_BITS == 1)
                assign aligned_address_bits   = in_address[0] & output_masks[0];
            else
                assign aligned_address_bits   = in_address[SELECT_BITS-1:0] & output_masks[SELECT_BITS-1:0];
            assign first_address_aligned  = {in_address[ADDR_W-1 : SELECT_BITS], aligned_address_bits};
        end
    endgenerate
    
    
    
    generate
        if (INCREMENT_ADDRESS)
            begin
                reg [ADDR_W-1 : 0] increment_address;
                reg [ADDR_W-1 : 0] out_aligned_address_burst;
                reg [ADDR_W-1 : 0] address_burst;
                reg [ADDR_W-1 : 0] base_address;
                reg [9 : 0]        number_bytes_transfer;
                reg [ADDR_W-1 : 0] burstwrap_mask;
                reg [ADDR_W-1 : 0] burst_address_high;
                reg [ADDR_W-1 : 0] burst_address_low;
                reg [BURSTWRAP_W-2 :0] in_burstwrap_boundary;
                reg [TYPE_W-1 : 0]     in_type;
                assign in_type                = in_data[SIZE_W+ADDR_W+TYPE_W-1 : SIZE_W+ADDR_W];
                assign in_burstwrap_boundary  = in_data[IN_DATA_W-1 : ADDR_W+TYPE_W+SIZE_W];
                assign burstwrap_mask         = {{(ADDR_W - BURSTWRAP_W){1'b0}}, in_burstwrap_boundary};
                assign burst_address_high     = out_aligned_address_burst & ~burstwrap_mask;
                assign burst_address_low      = out_aligned_address_burst;
                assign number_bytes_transfer  = bytes_in_transfer(in_size);
                assign write_burst_type       = burst_type_decode(in_type);

                always @*
                    begin
                        if (in_sop)
                            begin
                                out_aligned_address_burst  = in_address;
                                base_address               = first_address_aligned;
                            end
                        else
                            begin
                                out_aligned_address_burst  = address_burst;
                                base_address               = out_aligned_address_burst;
                            end
                        case (write_burst_type)
                            INCR:
                                increment_address  = base_address + number_bytes_transfer;
                            WRAP:
                                increment_address  = ((burst_address_low + number_bytes_transfer) & burstwrap_mask) | burst_address_high;
                            FIXED:
                                increment_address  = out_aligned_address_burst;
                            default:
                                increment_address  = base_address + number_bytes_transfer;
                        endcase 
                    end 
            
               if (SYNC_RESET == 0) begin : async_rst0 
                   always_ff @(posedge clk, negedge reset)
                       begin
                           if (!reset)
                               begin
                                   address_burst <= '0;
                               end
                           else
                               begin
                                   if (in_valid & out_ready)
                                       address_burst <= increment_address;
                               end
                       end
                end : async_rst0
 
                else begin : sync_rst0
                   always_ff @(posedge clk)
                       begin
                           if (internal_sclr)
                               begin
                                   address_burst <= '0;
                               end
                           else
                               begin
                                   if (in_valid & out_ready)
                                       address_burst <= increment_address;
                               end
                       end
                 end : sync_rst0  
            
                assign   out_data  = {output_masks[SELECT_BITS-1 : 0], out_aligned_address_burst};
            end 
        else
            begin
                assign   out_data  = {output_masks[SELECT_BITS-1 : 0], first_address_aligned};
            end 
        
    endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1Fhf1L1JHMW8nvKeWDdk4Zb6ejbK0ZGu/sDEZe5yq+7YUKvI59sYca7MB3EoYbGoT+bMnLpG8xoxKo2i8R827BVo4NGOJeeAMSOcJSaM4A2E1b5MWjRwoH1euB+ajqagEtjXbWiI6jDYLASqIlAq3X6/tvYZgRLuiXXP9m6hBBezLl1oxGBxXIyFAV3WeU6Q1HCHQVhEDCYeGQ2eeLXo8eeqQBixK8UulIdMj/dByQgUvmTCa9lTLSxbJsZzDi1Fv8hEfdTpZMBRWqNaDBdikoLOeV1BJIq+yMqvwBCE/U5GVDZ77mjJfkF7Wl1ZZP2o/e/4ueWwtPd3/CbAMH57RuuYoKnbrEu5YAK9/Mlr6+DBnTl9KuFOLNWRuEdOvH85WSSassU1vwdMVPCyPX9argBnAsk4lmKEJ4sP/uC/kyfNIZT2r03q6wRSx/UYGK5Z9KysD/8bOfgdCrAFKUidiRK0hYWXIPLbgJfxDd09GEMbA2oZeFGcLJulMtp1RM5+c4a+IuW7OOO9q5+vPHJh4/MrUurgH1MAqbz4WeaMGgm4YKijfxT9yH7o7w8gVkNAoTbjsmUhfMFnRAjfZotDgPeV/Vt2pUDOB+ACGrdZSJgdqEd+gOx07mwh4f9Ch/Ck3ALoSrZkgq8LZ44nbDn8ZFoba9pfluHW/IP3Qs1WTGj5no2aovavTqEOO6Cz6dcsLVfnNbKwe5ujga1HAioyU+wCBTRmfcu1ZJOrnyEn6RR7C4K0qYOTo0ST6sMGtNkksCTn+dCsEIZvkeVqD2O8BQY8"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "teYVLGZNsNaiPcWqMo30NLVhg9IMsUmKVYNVZA1g6YoMxCd3saFbjdspgxSuUGwJbR9kWeEFKaMzYwRfr2xaLMzQysyjOgYwIl9lo4FRttf7J9onFRZ+cQrE2NDuXtdJIIGO+/dKUOmyPPPV1hqZy6acKa90MKRpH3sijyxlOYLyV6T4kJRgD7++iamENcxEYRZnFpkQV+bUVDpbgF3G26MsZv5WeY2kTm/9hl8Mtc877Kgy2/VfB7/Iyw0SWnSuKgFAaz08doMaeBAWvppnWqy/zO8/qPyNAeynJgv4LngdnbYI3vpzDr/l1jb+NVE8EchhGQvm/vZFduiiVAyDBv+LxMtqj8ZBMV/iAtAdN/qz5j6k8g0PNeS0AmbIpmpfZHLA4wxs2BADUlitFU1qPy/DqdY8OBT2UeYdeWk7cmJptbC5Q676H23pPfh21lfc79J2XhTWoyXQfuMblkarplhuunSHGIgtarnlxlm+gpiHz8R23yfTTKrQOIaGA7pLR6tY9QmJwza7wlvopbFupCSvP5YGvVD7AukuzdBqQ50LSG1CPM/HQV4sp+1i7AorkFgPIeM1T0HT6XSmxKeQVktSLxKyCifgFjEwIwGBV/laTenBx/HSmBxKcjLjT0b19n0ERyXRZMpNt9+GVr+oMugqp7ogSe9MSiZcKn6C/G2pb+PbK+RuTqnO4oC2t3urA8l1enXBBH8W48n6eji7/h7q6ovcyMA1yO37iKkbQnwFAksT0SPHh4Xc8PuqcurnBx+A1gFtVSR6ZJwkR6Zggrwo3K0+vvgBENY1y/FmHZOcmu3A9uyjB0gW738Mw5QdAEs4uW2PixUGCRzu82dm397Ip2LR4ENo+ep04krvbROJa23eVcD8Bvc3ZePtrudUFw5lEdXFjg0CIcdX78NhSeD+20++4rvlzu8qecVVCRhNhhIWv7g33PAJpPeTkOz+6aSUVtYnaP16GNqpo3UyqQcEUlLp2BbGPIjZFlgHdqy1xahQaGfoZYi/CNjNcPjR"
`endif