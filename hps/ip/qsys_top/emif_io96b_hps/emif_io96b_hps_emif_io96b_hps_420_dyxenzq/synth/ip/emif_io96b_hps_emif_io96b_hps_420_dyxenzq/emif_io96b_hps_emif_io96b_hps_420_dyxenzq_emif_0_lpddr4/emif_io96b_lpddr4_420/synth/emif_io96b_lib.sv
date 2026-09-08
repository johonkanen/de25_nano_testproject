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




module emif_ph2_gen_ff_init_1 (
    input wire clk,
    input wire d,
    output reg q 
    );
    
    initial
        q <= 1'b1;
        
    always @(posedge clk)
        q <= d;
    
    
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "g4C5XhiVgIsot17RhmniMaWr74zBSsEIWWpvrh2OfY7zsE/GRUwh+h8kwFouKZM7aDVnfodYGq3Rk/+aIV/LhmOnotIFWwTLHeCg4q58QY8ebBhDunmhEw9pVeSnxyIfZOF36bcFs+PPu8zFjUpUmwPp0ZayeeNNAzuyoBxofiuKXveyhtMEYKr58+sGPuygd1q2QgWCXeNeK3v7pUsh+Ke+UaVach9SikQZsUX/o1piHZUf3w7uRq+JfUZ6PYMYTUxRTOcdh0LOIiB91DK4jwCgdS8m5QEOIkNDyK0HHty6ryEeaAHEWGHgcKy5ufxSPwroysy5yT+10AieSzk2ZyYg6EdphTRKkghEjjepiFN22/4oZ4qt92INVvFXWILF32YZsUqwe/pzWHo2fGfUksuus8C0bdF3Qmz4r7suK5itFTGjgF2Xw8uYFswZTS/zZkanufkgKtj6pD4l332/XUrwtcLj7R4Euh9E5gtfFXdSY8NoaXnVJYZjBsZq2w8glfhlaDliZ1mS4d4c94R+KO+qvZFm2jYxWOaOqIYcBagXSnjYN2KW6tN79XWzzqeisb2e4eDpRGfo15H3+MG0fAj3TJYFN9K4j3oZJERhmmzyXxrz6ms36/cPOAAZfQn4wuJEafGjnPk17gDs9dTvBPXBnQyBkVRhDsZvy5lAShiyVpnukovQ0poW43UilKkCXNrVN8A6K3S3mT2eDPKqeRoXIwxhFqQbLWJbiTAITjSm5zaOUktUNKplCD5taWl6agh+FIigL5zdPD0j/vWUPGl+UN2NWigBTi5p2JCEvYbBDacILs5DFAaXFrKNKy85IdRgJuITu2r14Q53UMsI2LCHwKE9ZE5dNwBTEEtYoEZQOGrf2wUvvJCN3yGfiylZl93GAtOrAfKD2EOXFFaqu1cTGQMJPm60s8uqE4UEHNV6z2RFflzS3BvePs2iX4kKf2txPCgqVgXoR2fksZi/YBevqvwxoZe9UB2IEDhamx5aW8+5T93Ewn7US6EwCmYy"
`endif