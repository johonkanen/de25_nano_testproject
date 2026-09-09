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




if { ![info exists quartus(nameofexecutable)] || $quartus(nameofexecutable) != "quartus_sta" } {
   post_message -type error "This script must be run from quartus_sta"
   return 1
}

if { ! [ is_project_open ] } {
   if { [ llength $quartus(args) ] > 0 } {
                set project_name [lindex $quartus(args) 0]
                project_open -revision [ get_current_revision $project_name ] $project_name
        } else {
                post_message -type error "Missing project_name argument"
                return 1
        }
}


if { ! [timing_netlist_exist] } {
   create_timing_netlist
   read_sdc
   update_timing_netlist

   if { ! [timing_netlist_exist] } {
      post_message -type error "Timing Netlist has not been created. Run the 'Update Timing Netlist' task first."
      return 1
   }
}

load_package report
load_report

set script_dir [file dirname [info script]]
source "$script_dir/emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_timing_parameters.tcl"
source "$script_dir/emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_timing_pins.tcl"
source "$script_dir/emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi_report_timing_core.tcl"
set inst_id 0

set first_opcond ""
set last_opcond ""

foreach_in_collection op [get_available_operating_conditions] {
    if { $first_opcond eq "" } { set first_opcond $op}
    set last_opcond $op
}

set h_colours [list grey grey grey grey]
set r_colours [list blue white white white]
set w_colours [list white white white white]

set instances [emif_get_core_instance_list emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi]

 if { [info exists emif_lockstep_instances] } { 
    unset emif_lockstep_instances 
}

foreach { ls_inst } $instances {
   set inst ${ls_inst}_0
   if { ![info exists emif_lockstep_instances] } { set emif_lockstep_instances [dict create] }
   if { ![dict exists $emif_lockstep_instances $inst] } {
       dict set emif_lockstep_instances $inst [dict create]
       dict set emif_lockstep_instances $inst is_x40 [expr  ($var(MEM_CHANNEL_DATA_DQ_WIDTH) == 40) ]
       dict set emif_lockstep_instances $inst arch emif_io96b_hps_emif_io96b_hps_500_j4t3edi_emif_0_lpddr4_emif_io96b_lpddr4_500_xudxcxi
       dict set emif_lockstep_instances $inst clist [dict create]
       dict set emif_lockstep_instances $inst clist core ${ls_inst}_0_usr_clk
       dict set emif_lockstep_instances $inst clist core_period [get_clock_info -period ${ls_inst}_0_usr_clk]
       dict set emif_lockstep_instances $inst clist phy0 ${ls_inst}_0_phy_clk_0
       dict set emif_lockstep_instances $inst clist phy0_period [get_clock_info -period ${ls_inst}_0_phy_clk_0]
       if {  $var(LOCKSTEP_ROLE) ne "OFF" } {
           dict set emif_lockstep_instances $inst clist phy1 ${ls_inst}_1_phy_clk_0
           dict set emif_lockstep_instances $inst clist phy1_period [get_clock_info -period ${ls_inst}_0_phy_clk_0]
       }
   }
   if { $var(MEM_CHANNEL_DATA_DQ_WIDTH) == 40 } { continue }
   if { $var(LOCKSTEP_ROLE) eq "OFF" } { continue }

   set fname ""
   set arch [dict get $emif_lockstep_instances $inst arch]
   set fbasename "${arch}_${inst_id}"


   set summary [list]

   set opcname [get_operating_conditions_info [get_operating_conditions] -display_name]
   set opcname [string trim $opcname]
   emif_ls_analyze_inst [get_operating_conditions] $inst summary
   
   
   set root_folder_name [get_current_timequest_report_folder]
   if {[get_report_panel_id "$root_folder_name"] == -1} {
      create_report_panel -folder "$root_folder_name"
   }
   
   set f_rpt -1
   set fname_rpt  "${fbasename}_summary.rpt"
   if {  [string compare [get_operating_conditions] $first_opcond] == 0 } {
       set f_rpt [open $fname_rpt w]
   } else {
       set f_rpt [open $fname_rpt a]
   }

   puts $f_rpt "-------------------------"
   puts $f_rpt "$opcname"
   puts $f_rpt "-------------------------"
   close $f_rpt
   post_message -type info "Core: $arch - Instance: $ls_inst"
   post_message -type info [format "%10s %4s %6s %6s" "LS_IO_BANK" "Path" "Setup" "Hold"]


   set panel_name "$ls_inst"
   set panel_name "${root_folder_name}||$panel_name"
   set panel_id [get_report_panel_id $panel_name]
   if {$panel_id != -1} {
      delete_report_panel -id $panel_id
   }
   set total_failures 0
   set rows [list]
   set type info
   lappend rows "add_row_to_table -id \$panel_id \[list \"LS_IO_BANK\" \"Path\" \"Setup Slack\" \"Hold Slack\"\]"
   foreach summary_line $summary {
      foreach {io96 path su hold} $summary_line {}
      if { ($su != "" && $su < 0) || ($hold != "" && $hold < 0) } {
         incr total_failures
         set type critical_warning
      }
      post_message -type $type [format "%10s %4s %6s %6s" $io96 $path $su $hold]
      set fg_colours [list black black]
      if { $su != "" && $su < 0 } {
         lappend fg_colours red
      } else {
         lappend fg_colours black
      }

      if { $hold != "" && $hold < 0 } {
         lappend fg_colours red
      } else {
         lappend fg_colours black
      }      
      lappend rows "add_row_to_table -id \$panel_id -fcolors \"$fg_colours\" \[list \"$io96\" \"$path\" \"$su\" \"$hold\"\]"
   }
   if {$total_failures > 0} {
      post_message -type critical_warning "DDR Timing requirements not met. See KDB Article titled \"Why did the Timing report fail in the Agilex 7 FPGA M-Series External Memory Interface DDR4 DIMM Design Example?\" for more information."
      set panel_id [create_report_panel -table $panel_name -color red]
   } else {
      set panel_id [create_report_panel -table $panel_name]
   }
   foreach row $rows {
      eval $row
   }
   write_report_panel -file $fname_rpt -id $panel_id -append

   incr inst_id
}
