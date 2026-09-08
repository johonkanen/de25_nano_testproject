# HPS + LPDDR4A pin and IO-standard assignments for hps_min, extracted
# verbatim from the DE25-Nano GHRD's golden_top.qsf
# (Demonstration/SoC_FPGA/GHRD/golden_top.qsf) - see hps/README.md.

#============================================================
# LPDDR4A
#============================================================
set_instance_assignment -name IO_STANDARD "1.1-V TRUE DIFFERENTIAL SIGNALING" -to LPDDR4A_REFCLK_p
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_CS_n
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_CA[0]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_CA[1]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_CA[2]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_CA[3]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_CA[4]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_CA[5]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to LPDDR4A_CK
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_CKE
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to LPDDR4A_CK_n
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DM[0]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DM[1]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DM[2]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DM[3]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[0]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[1]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[2]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[3]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[4]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[5]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[6]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[7]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[8]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[9]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[10]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[11]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[12]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[13]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[14]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[15]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[16]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[17]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[18]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[19]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[20]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[21]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[22]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[23]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[24]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[25]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[26]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[27]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[28]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[29]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[30]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_DQ[31]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to LPDDR4A_DQS[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to LPDDR4A_DQS[1]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to LPDDR4A_DQS[2]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to LPDDR4A_DQS[3]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to LPDDR4A_DQS_n[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to LPDDR4A_DQS_n[1]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to LPDDR4A_DQS_n[2]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to LPDDR4A_DQS_n[3]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to LPDDR4A_RESET_n
set_instance_assignment -name IO_STANDARD "1.1-V" -to LPDDR4A_RZQ
set_location_assignment PIN_B55  -to LPDDR4A_REFCLK_p
set_location_assignment PIN_B58  -to LPDDR4A_CS_n
set_location_assignment PIN_B66  -to LPDDR4A_CA[0]
set_location_assignment PIN_A68  -to LPDDR4A_CA[1]
set_location_assignment PIN_B68  -to LPDDR4A_CA[2]
set_location_assignment PIN_A70  -to LPDDR4A_CA[3]
set_location_assignment PIN_B63  -to LPDDR4A_CA[4]
set_location_assignment PIN_A66  -to LPDDR4A_CA[5]
set_location_assignment PIN_J42  -to LPDDR4A_CK
set_location_assignment PIN_A61  -to LPDDR4A_CKE
set_location_assignment PIN_G42  -to LPDDR4A_CK_n
set_location_assignment PIN_J59  -to LPDDR4A_DM[0]
set_location_assignment PIN_T59  -to LPDDR4A_DM[1]
set_location_assignment PIN_J27  -to LPDDR4A_DM[2]
set_location_assignment PIN_A25  -to LPDDR4A_DM[3]
set_location_assignment PIN_T62  -to LPDDR4A_DQ[0]
set_location_assignment PIN_T56  -to LPDDR4A_DQ[1]
set_location_assignment PIN_G56  -to LPDDR4A_DQ[2]
set_location_assignment PIN_E56  -to LPDDR4A_DQ[3]
set_location_assignment PIN_G65  -to LPDDR4A_DQ[4]
set_location_assignment PIN_J65  -to LPDDR4A_DQ[5]
set_location_assignment PIN_M56  -to LPDDR4A_DQ[6]
set_location_assignment PIN_M62  -to LPDDR4A_DQ[7]
set_location_assignment PIN_W62  -to LPDDR4A_DQ[8]
set_location_assignment PIN_M65  -to LPDDR4A_DQ[9]
set_location_assignment PIN_M51  -to LPDDR4A_DQ[10]
set_location_assignment PIN_T51  -to LPDDR4A_DQ[11]
set_location_assignment PIN_AB48 -to LPDDR4A_DQ[12]
set_location_assignment PIN_W48  -to LPDDR4A_DQ[13]
set_location_assignment PIN_T65  -to LPDDR4A_DQ[14]
set_location_assignment PIN_AB62 -to LPDDR4A_DQ[15]
set_location_assignment PIN_G24  -to LPDDR4A_DQ[16]
set_location_assignment PIN_E24  -to LPDDR4A_DQ[17]
set_location_assignment PIN_J35  -to LPDDR4A_DQ[18]
set_location_assignment PIN_T32  -to LPDDR4A_DQ[19]
set_location_assignment PIN_M32  -to LPDDR4A_DQ[20]
set_location_assignment PIN_T24  -to LPDDR4A_DQ[21]
set_location_assignment PIN_G35  -to LPDDR4A_DQ[22]
set_location_assignment PIN_M24  -to LPDDR4A_DQ[23]
set_location_assignment PIN_A22  -to LPDDR4A_DQ[24]
set_location_assignment PIN_A23  -to LPDDR4A_DQ[25]
set_location_assignment PIN_A33  -to LPDDR4A_DQ[26]
set_location_assignment PIN_B33  -to LPDDR4A_DQ[27]
set_location_assignment PIN_B30  -to LPDDR4A_DQ[28]
set_location_assignment PIN_A36  -to LPDDR4A_DQ[29]
set_location_assignment PIN_A20  -to LPDDR4A_DQ[30]
set_location_assignment PIN_B22  -to LPDDR4A_DQ[31]
set_location_assignment PIN_G62  -to LPDDR4A_DQS[0]
set_location_assignment PIN_AB56 -to LPDDR4A_DQS[1]
set_location_assignment PIN_G32  -to LPDDR4A_DQS[2]
set_location_assignment PIN_B28  -to LPDDR4A_DQS[3]
set_location_assignment PIN_E62  -to LPDDR4A_DQS_n[0]
set_location_assignment PIN_W56  -to LPDDR4A_DQS_n[1]
set_location_assignment PIN_E32  -to LPDDR4A_DQS_n[2]
set_location_assignment PIN_A30  -to LPDDR4A_DQS_n[3]
set_location_assignment PIN_M48  -to LPDDR4A_RESET_n
set_location_assignment PIN_T48  -to LPDDR4A_RZQ


# HPS
#============================================================
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_CLK_25
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_MDC
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_MDIO
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_RX_CLK
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_RX_CTL
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_RX_DATA[0]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_RX_DATA[1]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_RX_DATA[2]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_RX_DATA[3]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_TX_CLK
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_TX_CTL
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_TX_DATA[0]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_TX_DATA[1]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_TX_DATA[2]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_ENET_TX_DATA[3]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_GSENSOR_I2C_EN
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_GSENSOR_INT
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_I2C_SCL
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_I2C_SDA
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_KEY
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_LED
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_SD_CLK
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_SD_CMD
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_SD_DATA[0]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_SD_DATA[1]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_SD_DATA[2]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_SD_DATA[3]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_UART_RX
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_UART_TX
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_CLK
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_DATA[0]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_DATA[1]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_DATA[2]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_DATA[3]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_DATA[4]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_DATA[5]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_DATA[6]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_DATA[7]
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_DIR
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_NXT
set_instance_assignment -name IO_STANDARD "1.8-V" -to HPS_USB_STP
set_location_assignment PIN_AN67 -to HPS_CLK_25
set_location_assignment PIN_D71  -to HPS_ENET_MDC
set_location_assignment PIN_C74  -to HPS_ENET_MDIO
set_location_assignment PIN_BL75 -to HPS_ENET_RX_CLK
set_location_assignment PIN_AP74 -to HPS_ENET_RX_CTL
set_location_assignment PIN_BD74 -to HPS_ENET_RX_DATA[0]
set_location_assignment PIN_AN71 -to HPS_ENET_RX_DATA[1]
set_location_assignment PIN_AJ74 -to HPS_ENET_RX_DATA[2]
set_location_assignment PIN_AJ75 -to HPS_ENET_RX_DATA[3]
set_location_assignment PIN_BP75 -to HPS_ENET_TX_CLK
set_location_assignment PIN_BL74 -to HPS_ENET_TX_CTL
set_location_assignment PIN_BG74 -to HPS_ENET_TX_DATA[0]
set_location_assignment PIN_AP75 -to HPS_ENET_TX_DATA[1]
set_location_assignment PIN_BD75 -to HPS_ENET_TX_DATA[2]
set_location_assignment PIN_AM74 -to HPS_ENET_TX_DATA[3]
set_location_assignment PIN_P75  -to HPS_GSENSOR_I2C_EN
set_location_assignment PIN_Y75  -to HPS_GSENSOR_INT
set_location_assignment PIN_N72  -to HPS_I2C_SCL
set_location_assignment PIN_L75  -to HPS_I2C_SDA
set_location_assignment PIN_F75  -to HPS_KEY
set_location_assignment PIN_AD71 -to HPS_LED
set_location_assignment PIN_AC74 -to HPS_SD_CLK
set_location_assignment PIN_AK69 -to HPS_SD_CMD
set_location_assignment PIN_AF75 -to HPS_SD_DATA[0]
set_location_assignment PIN_AC75 -to HPS_SD_DATA[1]
set_location_assignment PIN_AN64 -to HPS_SD_DATA[2]
set_location_assignment PIN_Y74  -to HPS_SD_DATA[3]
set_location_assignment PIN_AD72 -to HPS_UART_RX
set_location_assignment PIN_N71  -to HPS_UART_TX
set_location_assignment PIN_BC64 -to HPS_USB_CLK
set_location_assignment PIN_AN72 -to HPS_USB_DATA[0]
set_location_assignment PIN_AY69 -to HPS_USB_DATA[1]
set_location_assignment PIN_BC71 -to HPS_USB_DATA[2]
set_location_assignment PIN_AU74 -to HPS_USB_DATA[3]
set_location_assignment PIN_AY71 -to HPS_USB_DATA[4]
set_location_assignment PIN_AU75 -to HPS_USB_DATA[5]
set_location_assignment PIN_BC72 -to HPS_USB_DATA[6]
set_location_assignment PIN_BP74 -to HPS_USB_DATA[7]
set_location_assignment PIN_AY67 -to HPS_USB_DIR
set_location_assignment PIN_BA75 -to HPS_USB_NXT
set_location_assignment PIN_BC67 -to HPS_USB_STP

