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


set script_dir [file dirname [info script]]
source "$script_dir/emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_timing_utils.tcl"
 
load_package sdc_ext
 
proc emif_get_ddr_pins { instname allpins var_array_name io_bank_inst} {
   # We need to make a local copy of the allpins associative array
   upvar allpins pins
   upvar 1 $var_array_name var
   set debug 0

   global ::GLOBAL_phy_arch_name
 
   set var(pll_inclock_search_depth) 30
   set var(pll_outclock_search_depth) 20
   set var(pll_vcoclock_search_depth) 5
 
   # ########################################
   #  1.0 find all of the PLL output clocks

   set pll_c0_periph_clock_pin_name     "out_clk_periph0";#"lvds_clk\[0\]"
   set pll_c1_periph_clock_pin_name     "out_clk_periph1";#"loaden\[0\]"
   set vco_clock_pin_name               "vcoph\[0\]";
   set vco_periph_clock_pin_name        "vco_clk_periph";
   set pll_path                         "${instname}|emif_arch_top|*.arch_${io_bank_inst}|wrapper_pll|pll";

   # Find the ncntr register in the pll
   set pins(pll_ncntr) [list]
   set pins(pll_ncntr_reg_id) [get_registers ${pll_path}*ncntr_reg]

   foreach_in_collection r $pins(pll_ncntr_reg_id) {
      set reg_name [get_register_info -name $r]
      lappend pins(pll_ncntr) [regsub -all {\\} $reg_name {\\\\}]
   }
   set pins(pll_ncntr) [emif_sort_duplicate_names $pins(pll_ncntr)]
 
   #  C0 output in the periphery
   set pins(pll_c0_periph_clock) [list]
   set pins(pll_c0_periph_reg) [list]
   set pins(pll_c0_periph_clock_pin_id) [get_pins -nowarn [list $pll_path*|$pll_c0_periph_clock_pin_name]]
 
   foreach_in_collection c $pins(pll_c0_periph_clock_pin_id) {
      set pin_info [get_pin_info -net $c]
      set net_name [get_net_info -name $pin_info]
 
      if {$debug} {
         puts "PLL pin -> PLL Net: [get_node_info -name $c] -> $net_name"
      }
      lappend pins(pll_c0_periph_clock) [regsub -all {\\} $net_name {\\\\}]
      array set creg_name [list]
      emif_traverse_fanin_up_to_depth $net_name emif_is_node_type_reg clock creg_name 2 
      lappend pins(pll_c0_periph_reg) [regsub -all {\\} [get_register_info -name [lindex [array names creg_name] 0]] {\\\\}]
      array unset creg_name
   }
   set pins(pll_c0_periph_clock) [emif_sort_duplicate_names $pins(pll_c0_periph_clock)]
 
   #  C1 output in the periphery
   set pins(pll_c1_periph_clock) [list]
   set pins(pll_c1_periph_reg) [list]
   set pins(pll_c1_periph_clock_pin_id) [get_pins -nowarn [list $pll_path*|$pll_c1_periph_clock_pin_name]]
 
   foreach_in_collection c $pins(pll_c1_periph_clock_pin_id) {
      set pin_info [get_pin_info -net $c]
      set net_name [get_net_info -name $pin_info]
 
      if {$debug} {
         puts "PLL pin -> PLL Net: [get_node_info -name $c] -> $net_name"
      }
 
      lappend pins(pll_c1_periph_clock) [regsub -all {\\} $net_name {\\\\}]
      array set creg_name [list]
      emif_traverse_fanin_up_to_depth $net_name emif_is_node_type_reg clock creg_name 2 
      lappend pins(pll_c1_periph_reg) [regsub -all {\\} [get_register_info -name [lindex [array names creg_name] 0]] {\\\\}]
      array unset creg_name
   }
   set pins(pll_c1_periph_clock) [emif_sort_duplicate_names $pins(pll_c1_periph_clock)]
 
   #  VCO clock (used for the system clock)
   set pins(vco_base_node) [list]
   set pins(vco_base_node_id) [get_nodes -nowarn [list ${pll_path}~vcoph\[0\]]]
   
   foreach_in_collection n $pins(vco_base_node_id) {
      set net_name [get_node_info -name $n]
 
      if {$debug} {
         puts "PLL pin -> PLL Net: [get_node_info -name $n] -> $net_name"
      }
 
      lappend pins(vco_base_node) [regsub -all {\\} $net_name {\\\\}]
   }
   set pins(vco_clock) [list]
   set pins(vco_clock_pin_id) [get_pins -nowarn [list $pll_path*~$vco_clock_pin_name]]
 
   foreach_in_collection c $pins(vco_clock_pin_id) {
      set pin_info [get_pin_info -net $c]
      set net_name [get_net_info -name $pin_info]
 
      if {$debug} {
         puts "PLL pin -> PLL Net: [get_node_info -name $c] -> $net_name"
      }
 
      lappend pins(vco_clock) [regsub -all {\\} $net_name {\\\\}]
   }

   #  VCO periph clock (used for the system clock)
   set pins(vco_periph_clock) [list]
   set pins(vco_periph_clock_pin_id) [get_pins -nowarn [list $pll_path*|$vco_periph_clock_pin_name]]
 
   foreach_in_collection c $pins(vco_periph_clock_pin_id) {
      set pin_info [get_pin_info -net $c]
      set net_name [get_net_info -name $pin_info]
 
      if {$debug} {
         puts "PLL pin -> PLL Net: [get_node_info -name $c] -> $net_name"
      }
 
      lappend pins(vco_periph_clock) [regsub -all {\\} $net_name {\\\\}]
   }

   set pins(vco_periph_clock) [emif_sort_duplicate_names $pins(vco_periph_clock)]
   set pins(pll_vco_clock) $pins(vco_clock)
   set pins(pll_phy_clock) $pins(pll_c0_periph_clock)
   set pins(pll_phy_clock_sync) $pins(pll_c1_periph_clock)
   set pins(pll_vco_periph_clock) $pins(vco_periph_clock)
   set pins(pll_phy_reg) $pins(pll_c0_periph_reg)
   set pins(pll_phy_reg_sync) $pins(pll_c1_periph_reg)
 
   if {$debug == 1} {
     puts "VCO:           $pins(pll_vco_clock)"
     puts "PHY:           $pins(pll_phy_clock)"
     puts "PHY_SYNC:      $pins(pll_phy_clock_sync)"
     puts ""
   }
 
   #########################################
   # 2.0  Find the actual master core clock
   #      As it could come from another interface
   #      In master/slave configurations
   #
   # Skip this if we're in HPS mode as core clocks don't exist
   
   set pins(master_vco_clock) ""
   set pins(master_vco_clock_sec) ""
   set pins(master_core_usr_clock) ""
   set pins(master_core_usr_half_clock) ""
   set pins(master_core_usr_clock_sec) ""
   set pins(master_core_usr_half_clock_sec) ""
   set pins(master_core_afi_clock) ""
   set pins(master_core_dft_cpa_1_clock) ""
   set pins(master_cal_master_clk) ""
   set pins(master_cal_slave_clk) ""
   
   
   if {($var(PHY_NOC_EN) || $var(MEM_CLK_ASYNC) || ($var(LOCKSTEP_ROLE) ne "OFF" && $io_bank_inst !=0))} {
      set pins(master_instname) $instname
   } else {
      #  CPA Clock
      set pins(cpa_clock) [list]
      set pins(cpa_clock_pin_id) [get_pins -nowarn [list ${instname}|emif_arch_top|*.arch_${io_bank_inst}|wrapper_cpa|cpa|o_core_clk_out]]
 
      foreach_in_collection c $pins(cpa_clock_pin_id) {
         set pin_info [get_pin_info -net $c]
         set net_name [get_net_info -name $pin_info]
 
         if {$debug} {
            puts "CPA pin -> CPA Net: [get_node_info -name $c] -> $net_name"
         }
 
         lappend pins(cpa_clock) [regsub -all {\\} $net_name {\\\\}]
      }
   }

   set pins(i_phyclk_div_reg) [get_registers -nowarn ${instname}|emif_arch_top|*.arch_${io_bank_inst}*div_reg]
   set pins(phyclk_div) [list]
   set pins(mipi_div) [list]
   foreach_in_collection r $pins(i_phyclk_div_reg) {
      set reg_name [get_register_info -name $r]
      if {[regexp hmc $reg_name]} {
         set hmclane "hmc" 
         if {[regexp wide $reg_name]} {
            set idx "wide"
         } else {
            set idx "slim"
         }
      } elseif {[regexp ssm $reg_name]}  {
         set hmclane "ssm"
         set idx ${io_bank_inst}
      } else {
         set hmclane "lane"
         regexp -expanded {gen_byte_conns\[(\d)\]} $reg_name {} idx
      }
      if {[regexp p2c $reg_name]} {
         set dir "p2c"
      } else {
         set dir "c2p"
      }
      if {![regexp mipi_div_reg $reg_name]} {
         lappend pins(phyclk_div) [list $reg_name $hmclane $idx $dir]
      } else {
         lappend pins(mipi_div) $reg_name
      }
   }

 
   # ########################################
   #  2.5 Find the reference clock input of the PLL
 
   set pins(pll_refclk_in) [get_pins -compatibility_mode ${pll_path}|ref_clk0]
   set pll_ref_clock_id [emif_get_input_clk_id $pins(pll_refclk_in) var]
   if {$pll_ref_clock_id == -1} {
      post_message -type critical_warning "emif_pin_map.tcl: Failed to find PLL reference clock"
   } else {
      set pll_ref_clock [get_node_info -name $pll_ref_clock_id]
   }
   set pins(pll_ref_clock) $pll_ref_clock
 
   if {$debug == 1} {
     puts "REF:     $pins(pll_ref_clock)"
     puts ""
   }
 
##########################################
## 3.0  find the FPGA pins
## The hierarchy paths to all the pins are stored in the *_ip_parameters.tcl
## file which is a generated file. Pins are divided into the following
## protocol-agnostic categories. For each pin category, we need to
## fully-resolve the hierarchy path patterns and store the results into
## the "pins" arrays.
#
    set pins(dqs_t) [emif_traverse_node_fanout_path $pins(vco_periph_clock) dqs_t 10]
    set pins(dqs_t_in) [get_nodes  ${instname}|emif_arch_top|*.arch_${io_bank_inst}|*bufs_mem*DQS*ibuf|i]
    set pins(rclk) [list]
    set dqs_t_empty [expr {[llength $pins(dqs_t)] == 0 }]
    if { $dqs_t_empty } { set pins(dqs_t) [list] }
    foreach_in_collection n $pins(dqs_t_in) {
       lappend pins(rclk) [get_node_info -name $n]
       if { $dqs_t_empty } {
         array set dqs_t_arr [list]
         emif_traverse_fanin_up_to_depth $n emif_is_node_type_pin clock dqs_t_arr 2
         if {[array size dqs_t_arr] == 1} {
            lappend pins(dqs_t) [get_node_info -name [lindex [array names dqs_t_arr] 0]]
         } 
         array unset dqs_t_arr
      }
    }

   set pin_categories [list ac_clk \
                            ac_sync \
                            ac_async \
                            rclk \
                            wclk \
                            dq \
                            dm \
                            dbi ]

   foreach pc $pin_categories {
      set pins($pc) [list]
   }
   foreach obuf [emif_traverse_node_fanout_path $pins(vco_periph_clock) ".*g_MEM.*obuf\\|o" 10 ] {
      set oport [get_ports [emif_traverse_node_fanout_path $obuf ".*" 2]]
      if {[regexp "MEM_CK_" $obuf]} {
         foreach p [emif_get_names_in_collection $oport] {lappend pins(ac_clk) $p}
      } elseif {[regexp "MEM_CKE_" $obuf] || [regexp "MEM_ODT_" $obuf] || [regexp "MEM_CS_" $obuf] || \
                [regexp "MEM_A_" $obuf] || [regexp "MEM_BA_" $obuf] || [regexp "MEM_BG_" $obuf] || \
                [regexp "MEM_ACT_N_" $obuf] || [regexp "MEM_PAR_" $obuf] || [regexp "MEM_CA_" $obuf] || \
                [regexp "MEM_C" $obuf]} {
         foreach p [emif_get_names_in_collection $oport] {lappend pins(ac_sync) $p}
      } elseif {[regexp "MEM_RESET_N_" $obuf] } { 
         foreach p [emif_get_names_in_collection $oport] {lappend pins(ac_async) $p}
      } elseif {[regexp "MEM_DQS_" $obuf] || [regexp "MEM_RDQS_" $obuf] || [regexp "MEM_WCK_" $obuf]} {
         if {[regexp "MEM_DQS_" $obuf] || [regexp "MEM_RDQS_" $obuf]} {
            foreach p [emif_get_names_in_collection $oport] {lappend pins(rclk) $p}
         }
         if {[regexp "MEM_DQS_" $obuf] || [regexp "MEM_WCK_" $obuf]} {
            foreach p [emif_get_names_in_collection $oport] {lappend pins(wclk) $p}
         }
      } elseif {[regexp "MEM_DQ_" $obuf]} {
         foreach p [emif_get_names_in_collection $oport] {lappend pins(dq) $p}
      } elseif {[regexp "MEM_DM_" $obuf]} {
         foreach p [emif_get_names_in_collection $oport] {lappend pins(dm) $p}
      } elseif {[regexp "MEM_DMI_" $obuf] || [regexp "MEM_DBI_" $obuf]} {
         foreach p [emif_get_names_in_collection $oport] {lappend pins(dbi) $p}
      } else {
         post_message -type warning "emif_pin_map.tcl: couldn't match $obuf to a pin type! ([foreach_in_collection p $oport {puts [get_port_info -name $p]}])"
      }

   } 

##########################################
## 4.0 Miscellanea
   set pins(phy_rxclk_gated) [list]
   set pins(phy_rxclk_gated_id) [get_pins -compatibility_mode "${instname}|emif_arch_top|*.arch_${io_bank_inst}*i_phy_rxclk_gated*"]
   set pins(dqsn_nff) [list]
 
   foreach_in_collection n $pins(phy_rxclk_gated_id) {
      set node_name [get_node_info -name $n]
      lappend pins(phy_rxclk_gated) [regsub -all {\\} $node_name {\\\\}]
   }
   set pins(phy_rxclk_gated) [lsort $pins(phy_rxclk_gated)]
 
   set pins(byte_rx_gated) [list]
   set pins(byte_rx_gated_id) [get_registers "${instname}|emif_arch_top|*.arch_${io_bank_inst}*byte_rx_gated_reg*"]
 
   foreach_in_collection n $pins(byte_rx_gated_id) {
      set node_name [get_node_info -name $n]
      lappend pins(byte_rx_gated) [regsub -all {\\} $node_name {\\\\}]
   }
   set pins(byte_rx_gated) [lsort $pins(byte_rx_gated)]

   foreach n $pins(dqs_t) {
      lappend pins(dqsn_nff) [emif_traverse_node_fanout_path $n "dqsn0_0" 10]
   }


}
 
proc emif_initialize_ddr_db { ddr_db_par var_array_name} {
   upvar $ddr_db_par local_ddr_db
   upvar 1 $var_array_name var
 
   global ::GLOBAL_phy_arch_name
   global ::io_only_analysis
 
   post_sdc_message info "Initializing DDR database for CORE $::GLOBAL_phy_arch_name"
   set instance_list [emif_get_core_instance_list $::GLOBAL_phy_arch_name]
 
   foreach instname $instance_list {
 
      for {set io_bank_inst [expr $var(MEM_NUM_IO96)-1]} {$io_bank_inst >= 0} {set io_bank_inst [expr $io_bank_inst-1]} {
      if {$::io_only_analysis == 0}  {
         post_sdc_message info "Finding port-to-pin mapping for CORE: $::GLOBAL_phy_arch_name INSTANCE: $instname BANK:$io_bank_inst"
            emif_get_ddr_pins $instname allpins var $io_bank_inst
         }
 
      set local_ddr_db(${instname}_${io_bank_inst}) [ array get allpins ]
      }
   }
}
 
 
proc emif_get_all_instances_dqs_pins { ddr_db_par } {
   upvar $ddr_db_par local_ddr_db
 
   set dqs_pins [ list ]
   set instnames [ array names local_ddr_db ]
   foreach instance $instnames {
      array set pins $local_ddr_db($instance)
 
      foreach { dqs_pin } $pins(dqs_pins) {
         lappend dqs_pins ${dqs_pin}_IN
         lappend dqs_pins ${dqs_pin}_OUT
      }
      foreach { dqsn_pin } $pins(dqsn_pins) {
         lappend dqs_pins ${dqsn_pin}_OUT
      }
      foreach { ck_pin } $pins(ck_pins) {
         lappend dqs_pins $ck_pin
      }
   }
 
   return $dqs_pins
}
 
proc emif_calculate_counter_value { cnt_hi cnt_lo cnt_bypass } {
   if {$cnt_bypass} {
      set result 1
   } else {
      set result [expr {$cnt_hi + $cnt_lo}]
   }
   return $result
}
 
proc emif_get_input_clk_id { pll_inclk_id var_array_name} {
   upvar 1 $var_array_name var
 
   array set results_array [list]
 
   emif_traverse_fanin_up_to_depth $pll_inclk_id emif_is_node_type_pin clock results_array $var(pll_inclock_search_depth)
   if {[array size results_array] == 1} {
      set pin_id [lindex [array names results_array] 0]
      set result $pin_id
   } else {
      post_message -type critical_warning "Could not find PLL clock for [get_node_info -name $pll_inclk_id]"
      set result -1
   }
 
   return $result
}
 
proc emif_get_output_clock_id { pin_list pin_type msg_list_name var_array_name} {
   upvar 1 $msg_list_name msg_list
   upvar 1 $var_array_name var
   set output_clock_id -1
 
   set output_id_list [list]
   set pin_collection [get_keepers -no_duplicates $pin_list]
   if {[get_collection_size $pin_collection] == [llength $pin_list]} {
      foreach_in_collection id $pin_collection {
         lappend output_id_list $id
      }
   } elseif {[get_collection_size $pin_collection] == 0} {
      lappend msg_list "warning" "Could not find any $pin_type pins"
   } else {
      lappend msg_list "warning" "Could not find all $pin_type pins"
   }
   emif_get_pll_clock $output_id_list $pin_type output_clock_id $var(pll_outclock_search_depth)
   return $output_clock_id
}
 
proc emif_get_pll_clock { dest_id_list node_type clock_id_name search_depth} {
   if {$clock_id_name != ""} {
      upvar 1 $clock_id_name clock_id
   }
   set clock_id -1
 
   array set clk_array [list]
   foreach node_id $dest_id_list {
      emif_traverse_fanin_up_to_depth $node_id emif_is_node_type_pll_clk clock clk_array $search_depth
   }
   if {[array size clk_array] == 1} {
      set clock_id [lindex [array names clk_array] 0]
      set clk [get_node_info -name $clock_id]
   } elseif {[array size clk_array] > 1} {
      set clk ""
   } else {
      set clk ""
   }
 
   return $clk
}
 
proc emif_get_vco_clk_id { wf_clock_id var_array_name} {
   upvar 1 $var_array_name var
 
   array set results_array [list]
 
   emif_traverse_fanin_up_to_depth $wf_clock_id emif_is_node_type_vco clock results_array $var(pll_vcoclock_search_depth)
   if {[array size results_array] == 1} {
      set pin_id [lindex [array names results_array] 0]
      set result $pin_id
   } else {
      post_message -type critical_warning "Could not find VCO clock for [get_node_info -name $wf_clock_id]"
      set result -1
   }
 
   return $result
}
 
proc emif_is_node_type_pll_clk { node_id } {
   set cell_id [get_node_info -cell $node_id]
 
   if {$cell_id == ""} {
      set result 0
   } else {
      set atom_type [get_cell_info -atom_type $cell_id]
      if {$atom_type == "IOPLL"} {
         set node_name [get_node_info -name $node_id]
 
         if  {[regexp {pll_inst~.*OUTCLK[0-9]$} $node_name]} {
            set result 1
         } else {
            set result 0
         }
      } elseif {$atom_type == "TILE_CTRL"} {
         set node_name [get_node_info -name $node_id]
 
         if {[regexp {tile_ctrl_inst.*\|pa_core_clk_out\[[0-9]\]$} $node_name]} {
            set result 1
         } else {
            set result 0
         }
      } else {
         set result 0
      }
   }
   return $result
}
 
proc emif_is_node_type_vco { node_id } {
   set cell_id [get_node_info -cell $node_id]
 
   if {$cell_id == ""} {
      set result 0
   } else {
      set atom_type [get_cell_info -atom_type $cell_id]
      if {$atom_type == "IOPLL"} {
         set node_name [get_node_info -name $node_id]
 
         if {[regexp {pll_inst.*\|.*vcoph\[0\]$} $node_name]} {
            set result 1
         } elseif {[regexp {pll_inst.*VCOPH0$} $node_name]} {
            set result 1
         } else {
            set result 0
         }
      } else {
         set result 0
      }
   }
   return $result
}
 
proc emif_does_ref_clk_exist { ref_clk_name } {
 
   set ref_clock_found 0
   foreach_in_collection iclk [get_clocks -nowarn] {
      if { ![is_clock_defined $iclk] } {
         continue
      }
      set clk_targets [get_clock_info -target $iclk]
      foreach_in_collection itgt $clk_targets {
         set node_name [get_node_info -name $itgt]
         if {[string compare $node_name $ref_clk_name] == 0} {
            set ref_clock_found 1
            break
         }
      }
      if {$ref_clock_found == 1} {
         break;
      }
   }
 
   return $ref_clock_found
}
 
 
proc emif_get_cp_current_from_setting { cp_setting } {
 
   set cp_current 0
 
   if {[string compare -nocase $cp_setting "PLL_CP_SETTING0"] == 0} {
      set cp_current 0
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING1"] == 0} {
      set cp_current 5	
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING2"] == 0} {
      set cp_current 10
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING3"] == 0} {
      set cp_current 15
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING4"] == 0} {
      set cp_current 20	
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING5"] == 0} {
      set cp_current 25		
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING6"] == 0} {
      set cp_current 30
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING7"] == 0} {
      set cp_current 35	
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING8"] == 0} {
      set cp_current 40	
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING9"] == 0} {
      set cp_current 45
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING10"] == 0} {
      set cp_current 50	
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING11"] == 0} {
      set cp_current 55			
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING12"] == 0} {
      set cp_current 60
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING13"] == 0} {
      set cp_current 65			
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING14"] == 0} {
      set cp_current 70	
   } elseif {[string compare -nocase $cp_setting "PLL_CP_SETTING15"] == 0} {
      set cp_current 75			
	} else {
      set cp_current 0
   }
 
   return $cp_current
}
 
proc emif_get_spe_from_cp_current { cp_current } {
 
   set spe 158.0e-12
 
   if {$cp_current <= 15} {
      set spe 158e-012 
   } elseif {$cp_current <= 20} {
      set spe 130.62e-12 
   } elseif {$cp_current <= 25} {
      set spe 117.3e-12 
   } elseif {$cp_current <= 30} {
      set spe 109.5e-12 
   } elseif {$cp_current <= 35} {
      set spe 104.5e-12 
   } elseif {$cp_current <= 40} {
      set spe 100.9e-12 
   } elseif {$cp_current <= 60} {
      set spe 93.3e-12 
   } else {
      set spe 93.3e-12 
   }
   
   return $spe
}
 
proc emif_get_periphery_clock_uncertainty { results_array_name var_array_name } {
   upvar 1 $results_array_name results
   upvar 1 $var_array_name var
 
   if {$var(DIAG_TIMING_REGTEST_MODE)} {
      set c2p_setup  0.050
      set c2p_hold   0.0
      set p2c_setup  0.050
      set p2c_hold   0.0
   } else {
      set c2p_setup  0.0
      set c2p_hold   0.0
      set p2c_setup  0.0
      set p2c_hold   0.0
   }
 
   set results [list $c2p_setup $c2p_hold $p2c_setup $p2c_hold]
}
 
proc emif_get_core_clock_uncertainty { results_array_name var_array_name } {
   upvar 1 $results_array_name results
   upvar 1 $var_array_name var
 
   set c2c_same_setup  0
   set c2c_same_hold   0
   set c2c_diff_setup  0
   set c2c_diff_hold   0
 
   set results [list $c2c_same_setup $c2c_same_hold $c2c_diff_setup $c2c_diff_hold]
}
 
proc emif_get_core_overconstraints { results_array_name var_array_name } {
   upvar 1 $results_array_name results
   upvar 1 $var_array_name var
 
   set results [list $var(C2C_SAME_CLK_SETUP_OC_NS) $var(C2C_SAME_CLK_HOLD_OC_NS) $var(C2C_DIFF_CLK_SETUP_OC_NS) $var(C2C_DIFF_CLK_HOLD_OC_NS)]
}
 
proc emif_get_periphery_overconstraints { results_st_array_name results_mt_array_name var_array_name } {
   upvar 1 $results_st_array_name results_st
   upvar 1 $results_mt_array_name results_mt
   upvar 1 $var_array_name var
 
   set c2p_p2c_frequency [expr $var(PHY_MEM_CLK_FREQ_MHZ)/$var(C2P_P2C_CLK_RATIO)]
 
   set results_st [list $var(C2P_SETUP_OC_NS) $var(C2P_HOLD_OC_NS) $var(P2C_SETUP_OC_NS) $var(P2C_HOLD_OC_NS)]
   set results_mt [list [expr $var(C2P_SETUP_OC_NS) + 0.000] [expr $var(C2P_HOLD_OC_NS) + 0.000] [expr $var(P2C_SETUP_OC_NS) + 0.000] [expr $var(P2C_HOLD_OC_NS) + 0.000]]
 
}
 
 
proc emif_sort_duplicate_names { names_array } {
 
   set main_name ""
   set duplicate_names [list]
 
   # Find the main name as opposed to all the duplicate names
   foreach { name } $names_array {
      if  {[regexp {Duplicate} $name]} {
         lappend duplicate_names $name
      } else {
         if {$main_name == ""} {
            set main_name $name
         } else {
            post_message -type error "More than one main tile name ($main_name and $name).  Please verify the connectivity of these pins."
         }
      }
   }
 
   # Now sort the duplicate names
   set duplicate_names [lsort -decreasing $duplicate_names]
 
   # Prepend the main name and then return
   set result [join [linsert $duplicate_names 0 $main_name]]
 
   return $result
}
 

