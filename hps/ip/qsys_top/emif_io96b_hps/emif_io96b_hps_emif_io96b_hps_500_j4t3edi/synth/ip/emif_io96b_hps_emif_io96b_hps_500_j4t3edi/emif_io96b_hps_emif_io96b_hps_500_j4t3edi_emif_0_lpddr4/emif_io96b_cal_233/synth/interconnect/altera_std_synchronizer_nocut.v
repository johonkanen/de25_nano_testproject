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

module altera_std_synchronizer_nocut (
                                clk, 
                                reset_n, 
                                din, 
                                dout
                                );

   parameter depth = 3; 
   parameter rst_value = 0;

   parameter retiming_reg_en = 0;
     
   input   clk;
   input   reset_n;    
   input   din;
   output  dout;
   

   (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name SYNCHRONIZER_IDENTIFICATION FORCED; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON  "} *) reg din_s1;

   (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [depth-2:0] dreg;    

   // synthesis translate_off
   `ifndef QUARTUS_CDC
   initial begin
     if (retiming_reg_en == 0 ) begin
       if (depth <2) begin 
         $display("%m: Error: synchronizer length: %0d less than 2.", depth);
       end
      end
     else begin
       if (depth <4) begin 
         $display("%m: Error: synchronizer length: %0d less than 4 with retiming enabled.", depth);
       end
     end
   end
   `endif 

   
`ifdef __ALTERA_STD__METASTABLE_SIM

   reg[31:0]  RANDOM_SEED = 123456;      
   wire  next_din_s1;
   wire  dout;
   reg   din_last;
   reg          random;
   event metastable_event; 

   initial begin
      $display("%m: Info: Metastable event injection simulation mode enabled");
      random = $random;
   end
   
   always @(posedge clk) begin
      if (reset_n == 0)
        random <= $random(RANDOM_SEED);
      else
        random <= $random;
   end

   assign next_din_s1 = (din_last ^ din) ? random : din;   

   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
         din_last <= (rst_value == 0)? 1'b0 : 1'b1;
       else
         din_last <= din;
   end

   always @(posedge clk or negedge reset_n) begin
       if (reset_n == 0) 
         din_s1 <= (rst_value == 0)? 1'b0 : 1'b1;
       else
         din_s1 <= next_din_s1;
   end
   
`else 

   // synthesis translate_on   
   generate if (rst_value == 0)
       always @(posedge clk or negedge reset_n) begin
           if (reset_n == 0) 
             din_s1 <= 1'b0;
           else
             din_s1 <= din;
       end
   endgenerate
   
   generate if (rst_value == 1)
       always @(posedge clk or negedge reset_n) begin
           if (reset_n == 0) 
             din_s1 <= 1'b1;
           else
             din_s1 <= din;
       end
   endgenerate
   // synthesis translate_off      

`endif

`ifdef __ALTERA_STD__METASTABLE_SIM_VERBOSE
   always @(*) begin
      if (reset_n && (din_last != din) && (random != din)) begin
         $display("%m: Verbose Info: metastable event @ time %t", $time);
         ->metastable_event;
      end
   end      
`endif

   // synthesis translate_on

   generate if (rst_value == 0) begin
      if (retiming_reg_en == 0) begin
         if (depth < 3) begin
            always @(posedge clk or negedge reset_n) begin
               if (reset_n == 0) 
                 dreg <= {depth-1{1'b0}};            
               else
                 dreg <= din_s1;
            end         
         end else begin
            always @(posedge clk or negedge reset_n) begin
               if (reset_n == 0) 
                 dreg <= {depth-1{1'b0}};
               else
                 dreg <= {dreg[depth-3:0], din_s1};
            end
         end

         assign dout = dreg[depth-2];
       end

       else begin 
          (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [1:0] dreg1;
          reg [depth-4:0] dreg2;
          wire [depth-2:0] dreg3;

          assign dreg3 = {dreg2,dreg1};

          if (depth <= 3) begin
             always @(posedge clk or negedge reset_n) begin
                if (reset_n == 0)
                  dreg1 <= {depth-1{1'b0}};
                else
                  dreg1 <= din_s1;
               end
           end
           else begin
              always @(posedge clk or negedge reset_n) begin
                if (reset_n == 0)
                  {dreg2,dreg1} <= {depth-1{1'b0}};
                else
                  {dreg2,dreg1} <= {dreg3[depth-3:0], din_s1};
              end
           end
           assign dout = dreg3[depth-2];
       end
    end

   
   else begin
      if (retiming_reg_en == 0) begin
         if (depth < 3) begin
            always @(posedge clk or negedge reset_n) begin
               if (reset_n == 0) 
                 dreg <= {depth-1{1'b1}};            
               else
                 dreg <= din_s1;
             end         
         end else begin
            always @(posedge clk or negedge reset_n) begin
               if (reset_n == 0) 
                 dreg <= {depth-1{1'b1}};
               else
                 dreg <= {dreg[depth-3:0], din_s1};
            end
         end
       assign dout = dreg[depth-2];
    end

      else begin
         (* altera_attribute = {"-name ADV_NETLIST_OPT_ALLOWED NEVER_ALLOW; -name DONT_MERGE_REGISTER ON; -name PRESERVE_REGISTER ON"} *) reg [1:0] dreg1;
         reg [depth-4:0] dreg2;
         wire [depth-2:0] dreg3;

         assign dreg3 = {dreg2,dreg1};

           if (depth <= 3) begin
               always @(posedge clk or negedge reset_n) begin
                  if (reset_n == 0)
                    dreg1 <= {depth-1{1'b1}};
                  else
                    dreg1 <= din_s1;
               end
           end
           else begin
               always @(posedge clk or negedge reset_n) begin
                  if (reset_n == 0)
                    {dreg2,dreg1} <= {depth-1{1'b1}};
                  else
                    {dreg2,dreg1} <= {dreg3[depth-3:0], din_s1};
               end
            end  
          assign dout = dreg3[depth-2];
        end
     end
   endgenerate

endmodule 
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nATEpDWf3CgajPjgH0t9FI3P3v7c7W2p1Bjo8KPiWXptDDKP83tHlZV4/kOjbfP5B3iPKq3r9UGmKAo7uM5E+NrMJJrWKQHFxNhuD9YH7WIm4w92BUZP4bPiPCFjEfA8Gg2F5To+TwSe7HVsQs+/7MZQj0QmDr2hjiVbFLL88xfR21RarRUIjnXzluc0JvTFFI13vcHyvhug/HSbBYjOOLVxyFVn/zaj46Yp0VXaMOw1nlZhJnKcXQsJx0gJoXbJzhqXMAEUYlyGq9c1wdgQSBXE8l1jREheSOvQ0cfeRX88+8g4+XINHMQVcPl0OjfoyRZ3JmyxFBhhTKaBFTuwa9JPGjKsP23EId66pNJyNHw+kx9hfuti4zKPh+4qDKzImqe3EvW9LvOpRFmLrX2Uxvpo1FTEMNxGrXb1ke0Z7vcuC95O72ct3MSS89UfL7tYbP1vXYWRLQ8C82nSl0K+WK6SnZZVbZLDHRpCCYtfelsLw7JJdfz2uhT+702K/cMywBt9oqHNmoTZubqV7787HlJwx1FqO2KI+EJorlVBtLfK7PJ4fOhDL7SQ23Tmb67gx0VsXcDYP/832+fsZsVMzSvS/3CiJjMDZAG0NuCMdvDXLySCkFUgqtHyScmaaundWnVAa+e66Sx7mp7VFD2d91rm0/mT6kUthgdXh1QRF/0/Ip6hP5huj45XBDVGZvX1ZQluQO/BXZXjyiuHXjM+ciVm9ZSPvoSKLFn9QolBYAEnDPQ3meQJpCkgBKNo6sG2vgaH89bYRlanB14+4Oqf7bAr3180nN8Z9LDTJRFfw0lWJ3OGhrRI1NyQ5YEzAsUO+H029+cDiasAmGbTULVUCBCkqyPlboA6mBIxBGWHngeFhEu5HagTbe2Xbew0EmTDW/5vz/BCGK4o27Md24EDRxAKVS/gyU4yVrE2LtGN26kHjxWvloc59PFbZL7EjLB+5tx8lFaZU+DwmAVNAwauX4DQYtDhS9XUFO0Pzj7ryCBHw0ifW2bHRF/R/fHkbo30"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "4+Nq/fVR43+TszDfPrwX9WusUKTd5OJtRsRr4mPMk1JEvdM2rcm40t5U7TP0bYLj7Jy/QfVRfaQPsCEt+NveYCec4WGq4uPAsb38KEuzJeJUs8Sl/Gmr4RufNjxnqOscFimeRrGu52lWE9DDg4RAxbOoy9VGYIQTUhV0GtBRgs8w2GnBE4PpTprzcBpIDeVXcmbXtquY7P5Yv3cqV8yAyUHnES6CAboK1fZNB3eZUX6L2sQmL6sBONu8cUbKf01oN5fvNArs9RpK1UCHs9oIXV6ILXEZtmIOq8+JuMYMrXmVF83I/t8oOK4fr6buQJ94099SIbdRx4MmUcSpZaLGYLR4SFk5rEes0JIbQfkviMqdpZV6drf4wVuO1L9r+g/gWGFEe8euxKW0Wm9OM0a7418IQ2ZLKhJ68+qreNHE/1uRdTyYM7Tqx+eaUo/gRclBZSDjg0fjS611XEzQW713YNiLXVEsyU3XawWbNTVzyvjzyG/FGudid9zrACcr5fJxoKpcGevj2G2sE0XdG202XSsjKwYMzSGQlDMqtVEbdeKLb+88vCuRooaESmKxHR0+U/vlEgnZObQS5s/mdVZbO36URFnm38ntcUhsC5Erj1/sqLY+sYWqguOeX/XBuGdwtJoAwCysfnORK3PBRXGhbk0xgZw5txAG7hBxoq+hVVBhVhe7PaDewl3K9RkQbL445H8/2M/qOZ42KqJ+0RgKCh7My1k/1kKB7wd1hwLfvuUY1hex/2rmeb+KkE6myVmnxOlyq9abd5lZUp10wI6rZwvKGbgAxbEqyTiB7fPJAqeso5oIts9I+Ds/SHn4Ym3xETQrnJsghcD3f35Y6mZoyeSZteli2Ai5eOIJNFfYzPvEsrR+kfOvnPfh2P1aPkRd/OX0brUbRj3SiCESL7W2t6FFEPMShSm+dtWMze/hYCdyoJUJnNHR4QgIybIYNgh+Gd/sL0UWHZvFUn/9AkEt3IIGGr5di2F+IYdK9O3EtqlvbhQLq72lakwDDaxVUw+c"
`endif