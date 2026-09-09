# (C) 2001-2026 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


#####################################################################
#
# THIS IS AN AUTO-GENERATED FILE!
# -------------------------------
# If you modify this files, all your changes will be lost if you
# regenerate the core!
#
# FILE DESCRIPTION
# ----------------
# This file specifies the timing constraints of the memory device and
# of the memory interface
 
# ------------------------------------------- #
# -                                         - #
# --- Some useful functions and variables --- #
# -                                         - #
# ------------------------------------------- #
 
set script_dir [file dirname [info script]]
source "$script_dir/emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_timing_parameters.tcl"
source "$script_dir/emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_timing_pins.tcl"
 
#--------------------------------------------#
# -                                        - #
# --- Determine when SDC is being loaded --- #
# -                                        - #
#--------------------------------------------#
 
set syn_flow 0
set sta_flow 0
set fit_flow 0
set pow_flow 0
if { $::TimeQuestInfo(nameofexecutable) == "quartus_map" || $::TimeQuestInfo(nameofexecutable) == "quartus_syn" } {
   set syn_flow 1
} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_sta" } {
   set sta_flow 1
} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_fit" } {
   set fit_flow 1
} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_pow" } {
   set pow_flow 1
}
set ::io_only_analysis 0
 
# ------------------------ #
# -                      - #
# --- GENERAL SETTINGS --- #
# -                      - #
# ------------------------ #
 
# This is a global setting and will apply to the whole design.
# This setting is required for the memory interface to be
# properly constrained.
derive_clock_uncertainty
 
# Debug switch. Change to 1 to get more run-time debug information
set debug 0
 
# All timing requirements will be represented in nanoseconds with up to 3 decimal places of precision
set_time_format -unit ns -decimal_places 3
 
# Determine if entity names are on
set entity_names_on [ emif_are_entity_names_on ]
 
# ---------------------- #
# -                    - #
# --- DERIVED TIMING --- #
# -                    - #
# ---------------------- #
 
# PLL multiplier to mem clk
#regexp {([0-9\.]+) ps} $var(PLL_REF_CLK_FREQ_PS_STR) match var(PHY_REF_CLK_FREQ_PS)
set vco_freq [ emif_round_3dp [expr $var(MEM_OPERATING_FREQ_MHZ)*$var(CLK_DIV_VCO_MEM)]]
set phy_freq [ emif_round_3dp [expr $var(MEM_OPERATING_FREQ_MHZ)/$var(CLK_DIV_MEM_PHY)]]
set vco_multiplier [emif_round_3dp [expr $vco_freq/$var(PHY_REFCLK_FREQ_MHZ)]]


# Half of memory clock cycle
#set half_period [ emif_round_3dp [ expr $var(UI) / 2.0 ] ]
 
# Half of reference clock
#set ref_period      [ emif_round_3dp [ expr $var(PHY_REF_CLK_FREQ_PS)/1000.0] ]
 
# Other clock periods
#set tCK_AFI     [ emif_round_3dp [ expr 1000.0/$var(PHY_MEM_CLK_FREQ_MHZ)*$var(USER_CLK_RATIO) ] ]
 
# Asymmetric uncertainties on address and command paths
#set ac_min_delay [ emif_round_3dp [ expr - $var(tIH) + $var(CA_TO_CK_BD_PKG_SKEW) ]]
 
# ---------------------- #
# -                    - #
# --- INTERFACE RATE --- #
# -                    - #
# ---------------------- #
 
# -------------------------------------------------------------------- #
# -                                                                  - #
# --- This is the main call to the netlist traversal routines      --- #
# --- that will automatically find all pins and registers required --- #
# --- to apply timing constraints.                                 --- #
# --- During the fitter, the routines will be called only once     --- #
# --- and cached data will be used in all subsequent calls.        --- #
# -                                                                  - #
# -------------------------------------------------------------------- #
 
if { ! [ info exists emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_sdc_cache ] } {
   emif_initialize_ddr_db emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_emif_ddr_db var
   set emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_sdc_cache 1
} else {
   if { $debug } {
      post_message -type info "SDC: reusing cached DDR DB"
   }
}
 
# ------------------------------------------------------------- #
# -                                                           - #
# --- If multiple instances of this core are present in the --- #
# --- design they will all be constrained through the       --- #
# --- following loop                                        --- #
# -                                                           - #
# ------------------------------------------------------------- #
 
set instances [ array names emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_emif_ddr_db ]
foreach { inst } $instances {
   if { [ info exists pins ] } {
      unset pins
   }
   array set pins $emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_emif_ddr_db($inst)

   # ----------------------- #
   # -                     - #
   # --- REFERENCE CLOCK --- #
   # -                     - #
   # ----------------------- #
 
   # First determine if a reference clock has already been created (i.e. Reference clock sharing)
   set ref_clock_exists [ emif_does_ref_clk_exist $pins(pll_ref_clock) ]
   if { $ref_clock_exists == 0 }  {
      # This is the reference clock used by the PLL to derive any other clock in the core
      if {$var(LOCKSTEP_ROLE) eq "OFF"} {
        create_clock -period "$var(PHY_REFCLK_FREQ_MHZ)MHz" $pins(pll_ref_clock) -add -name ${inst}_ref_clock
      } else {
        create_clock -period "$var(PHY_REFCLK_FREQ_MHZ)MHz" $pins(pll_ref_clock) -add -name $pins(pll_ref_clock)
      }
   }
   
   set pins(ref_clock_name) [emif_get_clock_name_from_pin_name $pins(pll_ref_clock)]
   # NCNTR clock division
   set pll_ncntr_clk [emif_get_or_add_generated_clock \
      -target $pins(pll_ncntr) \
      -name ${inst}_pll_ncntr \
      -source $pins(pll_ref_clock) \
      -multiply_by 1 \
      -divide_by $var(PLL_N_DIV) \
      -phase 0 ]
      
      set emifclks [get_clocks "${inst}_pll_ncntr"]

    if {$var(PLL_N_DIV)==1} {
       set srcclk $pins(pll_ref_clock)
    } else {
       set srcclk $pins(pll_ncntr)
    }

   # VCO clock
   set i_vco_clock 0
   foreach { vco_clock } $pins(pll_vco_clock) vco_base $pins(vco_base_node) {
 
      emif_get_or_add_generated_clock -target $vco_base \
         -name "${inst}_vco_base_${i_vco_clock}" \
         -source $srcclk \
         -multiply_by $var(PLL_M_DIV)  \
         -divide_by 1 \
         -phase 0 
      set emifclks [add_to_collection $emifclks [get_clocks "${inst}_vco_base_${i_vco_clock}"]]

      incr i_vco_clock
   }
   set i_vco_clock 0
   foreach { vco_clock } $pins(pll_vco_periph_clock) vco_base $pins(vco_base_node) {
      set local_pll_vco_clk__p${i_vco_clock} [ emif_get_or_add_generated_clock \
         -target $vco_clock \
         -name "${inst}_vco_clk_periph_${i_vco_clock}" \
         -source $srcclk \
         -multiply_by $var(PLL_M_DIV)  \
         -divide_by 1 \
         -phase 0 ]
      set emifclks [add_to_collection $emifclks [get_clocks "${inst}_vco_clk_periph_${i_vco_clock}"]]
      set_clock_uncertainty -from ${inst}_vco_clk_periph_${i_vco_clock} -to ${inst}_vco_clk_periph_${i_vco_clock} -setup 0.005
      set_clock_uncertainty -from ${inst}_vco_clk_periph_${i_vco_clock} -to ${inst}_vco_clk_periph_${i_vco_clock} -hold  0.005
      incr i_vco_clock
   }

   # Periphery clocks
   set periphery_clocks [list]
   set i_phy_clock 0
   foreach { phy_clock } $pins(pll_phy_clock) phy_reg $pins(pll_phy_reg) {
      set divide_by [expr {$var(CLK_DIV_VCO_MEM) * $var(CLK_DIV_MEM_PHY)}]
      set phase 0 ;
      emif_get_or_add_generated_clock -target $phy_reg \
         -name "${inst}_c0_cntr_${i_phy_clock}" \
         -source [lindex $pins(vco_base_node) $i_phy_clock] \
         -multiply_by 1 \
         -divide_by $divide_by \
         -phase $phase
      set emifclks [add_to_collection $emifclks [get_clocks "${inst}_c0_cntr_${i_phy_clock}"]]
      set local_phy_clk_${i_phy_clock} [ emif_get_or_add_generated_clock \
         -target $phy_clock \
         -name "${inst}_phy_clk_${i_phy_clock}" \
         -source $phy_reg \
         -multiply_by 1 \
         -divide_by 1 \
         -phase $phase ]
      set emifclks [add_to_collection $emifclks [get_clocks "${inst}_phy_clk_${i_phy_clock}"]]
      lappend periphery_clocks [set local_phy_clk_${i_phy_clock}]
      set_clock_uncertainty -from ${inst}_phy_clk_${i_phy_clock} -to ${inst}_phy_clk_${i_phy_clock} -setup 0.020
      set_clock_uncertainty -from ${inst}_phy_clk_${i_phy_clock} -to ${inst}_phy_clk_${i_phy_clock} -hold  0.020
      incr i_phy_clock
   }
 
   set i_phy_clock_l 0
   foreach { phy_clock_l } $pins(pll_phy_clock_sync) phy_reg_s $pins(pll_phy_reg_sync) {
      set divide_by $var(PLL_C_DIV_1)
      set phase 0
      emif_get_or_add_generated_clock -target $phy_reg_s \
         -name "${inst}_c1_cntr_${i_phy_clock_l}" \
         -source [lindex $pins(vco_base_node) $i_phy_clock_l] \
         -multiply_by 1 \
         -divide_by $divide_by \
         -phase $phase
      set emifclks [add_to_collection $emifclks [get_clocks "${inst}_c1_cntr_${i_phy_clock_l}"]]
      set local_phy_clk_sync_${i_phy_clock_l} [ emif_get_or_add_generated_clock \
         -target $phy_clock_l \
         -name "${inst}_phy_clk_sync_${i_phy_clock_l}" \
         -source $phy_reg_s \
         -multiply_by 1 \
         -divide_by 1 \
         -phase $phase ]
      set emifclks [add_to_collection $emifclks [get_clocks "${inst}_phy_clk_sync_${i_phy_clock_l}"]]
      lappend periphery_clocks [set local_phy_clk_sync_${i_phy_clock_l}]
      incr i_phy_clock_l
   }
   
   set usr_clock ""
   if {!($var(PHY_NOC_EN) || $var(MEM_CLK_ASYNC) || ($var(LOCKSTEP_ROLE) ne "OFF" && [regexp "1\$" $inst]))} {
      set phase 0
 
      set usr_clock [ emif_get_or_add_generated_clock \
         -target $pins(cpa_clock) \
         -name "${inst}_usr_clk" \
         -source [lindex $pins(vco_base_node) 0] \
         -multiply_by 1 \
         -divide_by $var(CLK_DIV_VCO_CORE) \
         -phase $phase ]
      set emifclks [add_to_collection $emifclks [get_clocks "${inst}_usr_clk"]]
   }

   # WRITE_CLK
   foreach {dqs_t} $pins(dqs_t) {

      set_false_path -to [get_ports $dqs_t]
      set_false_path -from [get_ports $dqs_t]

      create_clock -period "${vco_freq}MHz" $dqs_t -name "${inst}_${dqs_t}_in" -add
      set emifclks [add_to_collection $emifclks [get_clocks "${inst}_${dqs_t}_in"]]

      disable_min_pulse_width ${inst}_${dqs_t}_in
   }

   # READ_CLK
#set rclk_idx 0

   if {[regexp "_DDR4" $var(MEM_TECHNOLOGY)]} {
      set fa_div 2
   } else {
      set fa_div 4
   }
   foreach {fa_phyclk} $pins(phyclk_div) {
      emif_get_or_add_generated_clock \
         -target [lindex $fa_phyclk 0] \
         -name "${inst}_fa_[lindex $fa_phyclk 1]_[lindex $fa_phyclk 2]_[lindex $fa_phyclk 3]" \
         -source [lindex $pins(pll_phy_clock) 0] \
         -multiply_by 1 \
         -divide_by $fa_div \
         -phase 0
      set emifclks [add_to_collection $emifclks [get_clocks "${inst}_fa_[lindex $fa_phyclk 1]_[lindex $fa_phyclk 2]_[lindex $fa_phyclk 3]"]]
   }

   set lane 0
   foreach { phy_rxclk_gated } $pins(phy_rxclk_gated) byte_rx_gated $pins(byte_rx_gated) {
      create_clock -name "${inst}_lane_${lane}_rxclk_gated" -period 10.000 $phy_rxclk_gated
      set lane_${lane}_byte_rx_gated [ emif_get_or_add_generated_clock \
         -target $byte_rx_gated \
         -name "${inst}_lane_${lane}_byte_rx_gated" \
         -source $phy_rxclk_gated \
         -multiply_by 1 \
         -divide_by 1 \
         -phase 0 ]
      set_false_path -from [get_clocks "${inst}_lane_${lane}_byte_rx_gated"]
      incr lane
   }
   foreach t $pins(dqs_t) n $pins(dqsn_nff) {
      if {$var(MEM_DQ_WIDTH) >= 64 && $n == "" && \
            (($var(MEM_TECHNOLOGY) == "DDR5" && [llength $pins(dqs_t)] > 5) || \
             ($var(MEM_TECHNOLOGY) == "DDR4" && [llength $pins(dqs_t)] > 5)) } {   
         continue;
      }
      create_generated_clock \
         -name "${inst}_${t}_nff" \
         -source $t \
         -invert \
         $n
      set_false_path -from [get_clocks "${inst}_${t}_nff"]
   }
   foreach mipi $pins(mipi_div) {
      disable_min_pulse_width $mipi
   }
   
   if {!$var(PHY_NOC_EN) && $var(LOCKSTEP_ROLE)=="OFF" && $var(MEM_CHANNEL_DATA_DQ_WIDTH) != 40} {
      regexp {(.*)_(\d)} $inst "" baseinst instidx
      if {$var(DEVICE_REVISION) eq "B" && !$var(SM4A)} {
         set_min_delay -to [get_registers ${baseinst}*arch_${instidx}*hmc_core_reg] -0.170
      }
      if {$var(MEM_CLK_ASYNC)} {
         set_clock_groups -asynchronous -group $emifclks
      } else {
         set_clock_groups -asynchronous -group "${inst}_usr_clk" -group [get_clocks "${inst}_phy_clk_*"] 
      }
   }
   
   # LOCKSTEP
   if {$var(LOCKSTEP_ROLE) ne "OFF" && [regexp "0\$" $inst]} {
	set ls_inst [regsub "_0\$" $inst {}]
        if ${sta_flow} {
            set_min_delay -20 -from [get_keepers ${ls_inst}|emif_arch_top|lockstep.ls_sideband_adaptor|*|*_mcp*]
            set_max_delay  20 -from [get_keepers ${ls_inst}|emif_arch_top|lockstep.ls_sideband_adaptor|*|*_mcp*]
            set_data_delay -from [get_keepers ${ls_inst}|emif_arch_top|lockstep.ls_sideband_adaptor|*|*_mcp*] -get_value_from_clock_period dst_clock_period -no_synchronizer -value_multiplier 2
        } else { 
            set_min_delay -5 -from [get_keepers ${ls_inst}|emif_arch_top|lockstep.ls_sideband_adaptor|*|*_mcp*]
            set_max_delay  5 -from [get_keepers ${ls_inst}|emif_arch_top|lockstep.ls_sideband_adaptor|*|*_mcp*]
            set_data_delay -from [get_keepers ${ls_inst}|emif_arch_top|lockstep.ls_sideband_adaptor|*|*_mcp*] -get_value_from_clock_period dst_clock_period -no_synchronizer -value_multiplier 1
        }
        emif_add_false_path $sta_flow 5 -to [get_keepers ${ls_inst}|emif_arch_top|lockstep.ls_sideband_adaptor|*|*_sync_inst|din_s1]
        set_data_delay -to [get_keepers ${ls_inst}|emif_arch_top|lockstep.ls_sideband_adaptor|*|*_sync_inst|din_s1] -get_value_from_clock_period dst_clock_period -value_multiplier 1
        emif_add_false_path $sta_flow 10 -to [get_keepers ${ls_inst}|emif_arch_top|lockstep.ls_sideband_adaptor|*|*rst*_sync_inst|*]
        emif_add_false_path $sta_flow 5 -from [get_keepers ${ls_inst}|emif_arch_top|*|lock_sync_inst|dreg[1]] -to [get_keepers ${ls_inst}|emif_arch_top|lockstep.ls_sideband_adaptor|AXIL_ADAPTOR.rst_sync_inst|*]
        set_false_path -from  [get_keepers ${ls_inst}|emif_arch_top|*|AXIL_ADAPTOR.adaptor_inst|*hipi_c2p|inst] -to [get_keepers ${ls_inst}|emif_arch_top|*|wrapper_pll|pll~out_clk_periph0_reg]
        set_false_path -from  [get_keepers ${ls_inst}|emif_arch_top|*|AXIL_ADAPTOR.adaptor_inst|*hipi_c2p*] -to [get_keepers ${ls_inst}|emif_arch_top|*|wrapper_pll|pll~out_clk_periph0_reg]
         
        set_false_path -from [get_keepers ${ls_inst}|emif_arch_top|*hmc_*fa_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg]
        set_false_path -from [get_keepers ${ls_inst}|emif_arch_top|*lane_*fa_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg]
        set_false_path -from [get_keepers ${ls_inst}|emif_arch_top|*ssm_*fa_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg]
        if {[get_collection_size [get_keepers -nowarn ${ls_inst}|emif_arch_top|*seq~phy_a_reg]] > 0} {
           set_false_path -from [get_keepers ${ls_inst}|emif_arch_top|*ssm_*fa_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*seq~phy_a_reg]
        }
        if {[get_collection_size [get_keepers -nowarn ${ls_inst}|emif_arch_top|*seq~phy_b_reg]] > 0} {
           set_false_path -from [get_keepers ${ls_inst}|emif_arch_top|*ssm_*fa_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*seq~phy_b_reg]
        }
        set_false_path -from [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_*fa_reg]
        set_false_path -from [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*lane_*fa_reg]
        set_false_path -from [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*ssm_*fa_reg]                
        set_false_path -through ${ls_inst}|emif_arch_top|arch_emif_ls_0.arch0_1ch_per_io.arch_0|wrapper_cpa|cpa|o_core_clk_out -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg]
    } elseif {$var(MEM_CHANNEL_DATA_DQ_WIDTH) == 40} {
        set ls_inst [regsub "_0\$" $inst {}]
        set_multicycle_path -from [get_keepers ${ls_inst}|emif_arch_top|*hmc_*fa_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg] -end -setup 2
        set_multicycle_path -from [get_keepers ${ls_inst}|emif_arch_top|*hmc_*fa_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg] -hold 1
        set_multicycle_path -from [get_keepers ${ls_inst}|emif_arch_top|*lane_*fa_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg] -end -setup 2
        set_multicycle_path -from [get_keepers ${ls_inst}|emif_arch_top|*lane_*fa_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg] -hold 1
        set_multicycle_path -from [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_*fa_reg] -start -hold 1
        set_multicycle_path -from [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg] -to [get_keepers ${ls_inst}|emif_arch_top|*lane_*fa_reg] -start -hold 1
        set_false_path -through ${ls_inst}|emif_arch_top|arch_emif_*.arch*_1ch_per_io.arch_*|wrapper_cpa|cpa|o_core_clk_out -to [get_keepers ${ls_inst}|emif_arch_top|*hmc_periph_reg]
    }
    
   # DQ/DQS pins are calibrated
   if {[llength $pins(dq)] > 0} {
      set_false_path -to $pins(dq)
      set_false_path -from $pins(dq)
      set_output_delay -clock $pins(ref_clock_name) 0 $pins(dq) -add
      set_input_delay -clock $pins(ref_clock_name) 0 $pins(dq) -add
   }
   if {[llength $pins(dm)] > 0} {
      set_false_path -to $pins(dm)
      set_output_delay -clock $pins(ref_clock_name) 0 $pins(dm) -add
   }
   if {[llength $pins(dbi)] > 0} {
      set_false_path -to $pins(dbi)
      set_false_path -from $pins(dbi)
      set_output_delay -clock $pins(ref_clock_name) 0 $pins(dbi) -add
      set_input_delay -clock $pins(ref_clock_name) 0 $pins(dbi) -add
   }
   if {[llength $pins(wclk)] > 0} {
      set_false_path -to $pins(wclk)
      set_output_delay -clock $pins(ref_clock_name) 0 $pins(wclk) -add
   }
   if {[llength $pins(rclk)] > 0} {
      set_false_path -from $pins(rclk)
      if {$var(MEM_TECHNOLOGY) == "LPDDR5"} {
         foreach rdqs $pins(rclk) {
            if {[regexp "rdqs_t" $rdqs]} {
               set_output_delay -clock $pins(ref_clock_name) 0 $rdqs -add
            }
         }
      }
   }
   if {[llength $pins(ac_clk)] > 0} {
      set_false_path -to $pins(ac_clk)
      set_output_delay -clock $pins(ref_clock_name) 0 $pins(ac_clk) -add
   }
   if {[llength $pins(ac_async)] > 0} {
      set_false_path -to $pins(ac_async)
      set_false_path -from $pins(ac_async)
      foreach ac_async $pins(ac_async) {
         if {[string match "*alert*" $ac_async]} {
            set_input_delay -clock $pins(ref_clock_name) 0 $ac_async -add
         }
         if {[string match "*reset*" $ac_async]} {
            set_output_delay -clock $pins(ref_clock_name) 0 $ac_async -add
         }
      }
   }
   if {[llength $pins(ac_sync)] > 0} {
      set_false_path -to $pins(ac_sync)
      set_output_delay -clock $pins(ref_clock_name) 0 $pins(ac_sync) -add
   }

   if {$var(MEM_TECHNOLOGY) == "DDR5"} {
      disable_min_pulse_width [get_clocks "$inst*dqs_t*nff"]
   }
   if {$var(MEM_TECHNOLOGY) == "LPDDR5"} {
      disable_min_pulse_width [get_clocks "$inst*rdqs_t*nff"]
   }

   if {$var(SM4A)} {
      set_false_path -to [get_keepers "[regsub "_\\d\$" $inst {}]*.hmc~io96/x0/xiocenter_wrap/xiocenter_mcphymux_*/i_fbr_axi_aclk.reg"]
   }
}

set_false_path -to [get_registers *pa_hr_reg] -setup

if {  $var(LOCKSTEP_ROLE) ne "OFF" && $var(DEVICE_REVISION) eq "B"} {
    add_ddr_report_command "source [list [file join [file dirname [info script]] emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_report_timing.tcl]]"
}
