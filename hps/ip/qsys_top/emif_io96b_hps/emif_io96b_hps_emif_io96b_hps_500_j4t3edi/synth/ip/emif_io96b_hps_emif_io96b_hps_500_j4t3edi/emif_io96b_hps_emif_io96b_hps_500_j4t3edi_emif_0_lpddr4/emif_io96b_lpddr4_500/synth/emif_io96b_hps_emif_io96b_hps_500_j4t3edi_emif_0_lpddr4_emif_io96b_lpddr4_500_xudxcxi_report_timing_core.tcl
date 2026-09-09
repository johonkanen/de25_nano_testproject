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







proc emif_ls_analyze_inst { opcond inst_in summary { npaths 1 } {fout stdout} {report_out 0} {ts ""} } {
    upvar $summary global_summary
    upvar emif_lockstep_instances emif_lockstep_instances
    set is_false 1
    set all_info [dict create]
    dict set all_info $inst_in [dict create]
    set clist [dict get $emif_lockstep_instances $inst_in clist]
    if { [dict get $emif_lockstep_instances $inst_in is_x40] } {
        set is_x40 1
    } else {
        set is_x40 0
    }
    set inst [regsub "_0\$" $inst_in {}]
    set opcond_name [get_operating_conditions_info -name $opcond]
    set tmp_info [dict create]
    emif_ls_clk_info_inst tmp_info pll_info $inst $is_x40
    emif_ls_get_info tmp_info c2p_0 [dict get $clist core] [dict get $clist phy0] $npaths $is_x40
    emif_ls_get_info tmp_info p2c_0 [dict get $clist phy0] [dict get $clist core] $npaths $is_x40
    if { $is_x40 == 0 } {
        emif_ls_get_info tmp_info c2p_1 [dict get $clist core] [dict get $clist phy1] $npaths $is_x40
        emif_ls_get_info tmp_info p2c_1 [dict get $clist phy1] [dict get $clist core] $npaths $is_x40
        }
    emif_ls_c2p_p2c_report_timing_analysis tmp_info global_summary $is_x40
}

proc emif_ls_clk_info_inst { pts_dict idx inst is_x40 } {
    upvar $pts_dict ldict
    set spe_optimistic 1
    dict set ldict $idx [dict create]
    foreach_in_collection node_id [get_nodes "$inst|*pll~vcoph[0]"] {
        set nd_name [get_node_info -name $node_id]
        if { [regexp {arch_emif_ls_(\d)} $nd_name -> pll_inst] || $is_x40 } {
            set pll [expr { $is_x40 ? 0 : $pll_inst } ]
            set max [emif_ls_get_pll_delay $pll 0]
            set min [emif_ls_get_pll_delay $pll 1]
            set uncertainty [emif_ls_get_pll_uncertainty $pll]
            dict set ldict $idx PLL$pll [dict create MAX $max MIN $min UNCERTAINTY $uncertainty] 
        }
    }
    if { $is_x40 } {
        dict set ldict $idx SKEW 0
        dict set ldict $idx SKEW_DIR 0
        dict set ldict $idx UNCERTAINTY_DIFF 0
        return
    } else {
        set skew_max [ expr { abs ( [dict get $ldict $idx PLL0 MAX] - [dict get $ldict $idx PLL1 MAX] ) } ]
        set skew_min [ expr { abs ( [dict get $ldict $idx PLL0 MIN] - [dict get $ldict $idx PLL1 MIN] ) } ]
    }
    dict set ldict $idx SKEW [expr { $skew_max > $skew_min ? $skew_max : $skew_min }]
    dict set ldict $idx SKEW_DIR [expr { [dict get $ldict $idx PLL1 MIN] > [dict get $ldict $idx PLL0 MIN] }]
    if { $spe_optimistic == 1 } {
        dict set ldict $idx UNCERTAINTY_DIFF [dict get $ldict $idx PLL1 UNCERTAINTY]
    } else {
        dict set ldict $idx UNCERTAINTY_DIFF [ expr { abs([dict get $ldict $idx PLL0 UNCERTAINTY] - [dict get $ldict $idx PLL1 UNCERTAINTY] ) } ]
    }
}


proc emif_ls_get_pll_delay { pll min } {
    upvar 2 clist clist
    set is_false 1
    if { $is_false } {
        set use_false "-false_path"
    } else {
        set use_false ""
    }
    if { $min == 1 } {  
        set paths [get_timing_paths $use_false -npaths 0 -hold -detail full_path -to_clock [dict get $clist core] -from_clock [dict get $clist phy$pll]]
    } else {  
        set paths [get_timing_paths $use_false -npaths 0 -hold -detail full_path -from_clock [dict get $clist core] -to_clock [dict get $clist phy$pll]]
    }
    set points [expr { $min == 1 ? "arrival_points" : "required_points" } ]
    foreach_in_collection path $paths {
        set rpoints [get_path_info $path -$points]
        set pll_done 0
        foreach_in_collection rpoint $rpoints {
            set rnd [get_point_info -node $rpoint]
            if { $rnd eq "" } {
                continue
            } else {
                set rnd [get_node_info -name $rnd]
            }
            if { [string match {*self_clk_in*} $rnd] } {
                set start_delay [get_point_info -total_delay $rpoint]
            }
            if { [string match {*vcoph*} $rnd] } {
                return [ expr { [get_point_info -total_delay $rpoint] - $start_delay } ]
            }
        }                            
    }
}

proc emif_ls_get_pll_uncertainty { pll } {
    upvar 2 clist clist
    set is_false 1
    if { $is_false } {
        set use_false "-false_path"
    } else {
        set use_false ""
    }
    set paths [get_timing_paths $use_false -npaths 0 -hold -detail full_path -to_clock [dict get $clist core] -from_clock [dict get $clist phy$pll]]
    foreach_in_collection path $paths {
        return [get_path_info $path -clock_uncertainty]                           
    }
}


proc emif_ls_get_info { pts_dict idx from to {npaths 0} {is_x40 0} {no_setup 0} } {
    upvar $pts_dict ldict
    upvar clist clist
    set rpt_file "test.rpt"
    set report_out 0
    set is_false 1
    if { $is_false == 1 && $to ne $from } {
        set use_false "-false_path"
    } else {
        set use_false ""
    }
    dict set ldict $idx [dict create]
    set tpaths {setup hold}
    foreach tpath_ext $tpaths {
        set tpath $tpath_ext
        set paths [get_timing_paths $use_false -npaths $npaths -$tpath -detail full_path -from_clock $from -to_clock $to]
        if { $report_out } {
            report_timing -append $use_false -file $rpt_file -npaths $npaths -$tpath -detail full_path -from_clock $from -to_clock $to
        }
        dict set ldict $idx $tpath_ext [dict create]
        set pll_delay_diff 0
        set pll_delay_expr 0
        set skew_dir 0
        if { $is_x40 == 0 } {
            if { [dict get $clist core] eq $from && [dict get $clist phy1] eq $to } {
                if {$tpath eq "setup" || $tpath eq "recovery" } {
                    set skew_dir [expr { [dict get $ldict pll_info SKEW_DIR] ? "-" : "+" } ]
                    set pll_delay_expr "[dict get $ldict pll_info PLL0 MAX] - [dict get $ldict pll_info PLL0 MIN] - 0.250 + [dict get $ldict pll_info UNCERTAINTY_DIFF]"
                } else {
                    set skew_dir [expr { [dict get $ldict pll_info SKEW_DIR] ? "+" : "-" } ]
                    set pll_delay_expr "[dict get $ldict pll_info PLL1 MAX] - [dict get $ldict pll_info PLL1 MIN] - 0.250 + [dict get $ldict pll_info UNCERTAINTY_DIFF]"
                }
            }
            if { [dict get $clist core] eq $to && [dict get $clist phy1] eq $from } {
                if {$tpath eq "setup"  || $tpath eq "recovery" } {
                    set skew_dir [expr { [dict get $ldict pll_info SKEW_DIR] ? "+" : "-" } ]
                    set pll_delay_expr "[dict get $ldict pll_info PLL1 MAX] - [dict get $ldict pll_info PLL1 MIN] - 0.250 + [dict get $ldict pll_info UNCERTAINTY_DIFF]"
                } else {
                    set skew_dir [expr { [dict get $ldict pll_info SKEW_DIR] ? "-" : "+" } ]
                    set pll_delay_expr "[dict get $ldict pll_info PLL0 MAX] - [dict get $ldict pll_info PLL0 MIN] - 0.250 + [dict get $ldict pll_info UNCERTAINTY_DIFF]"
                }
            }
        }
        set slack_adjust 0
        if { [dict get $clist core] eq $from && [dict get $clist core] ne $to } {
            if {$tpath eq "setup"} {
                set slack_adjust [get_clock_info -period $to]
            } elseif { $tpath eq "hold" } {
                set slack_adjust 0
            }
        }
        if { [dict get $clist core] eq $to && [dict get $clist core] ne $from } {
            if {$tpath eq "setup" } {
                set slack_adjust 0
            } elseif { $tpath eq "hold" } {
                set slack_adjust [get_clock_info -period $from]
            }
        }
        
        set pll_delay_diff [expr $pll_delay_expr]
        if { $pll_delay_diff < 0 } { set pll_delay_diff 0 }
        set loc ""

        foreach_in_collection path $paths {
            set points [get_path_info $path -arrival_points]
            set slack [get_path_info $path -slack]
            if { $is_false } {
                set slack [expr ($slack + $slack_adjust)]
            }
            set opcond [get_path_info -operating_conditions $path]
            set loc ""
            foreach_in_collection point $points {
                set nd [get_point_info -node $point]
                if { $nd eq "" } {
                    continue
                } else {
                    set nd [get_node_info -name $nd]
                }
                if { [string match {*_fbr_*} $nd] || ($tpath_ext eq "c2c_hold" && [string match {*FABRICADAPTOR*} [get_point_info -location $point]]) } {
                    if { $tpath_ext eq "c2c_hold" } { set loc [get_point_info -location $point] }
                    regexp {([^\|]+)$} $nd -> sig
                    if { $loc eq "" } {
                        set rpoints [get_path_info $path -required_points]
                        foreach_in_collection rpoint $rpoints {
                        set rnd [get_point_info -node $rpoint]
                            if { $rnd eq "" } {
                                continue
                            } else {
                                set rnd [get_node_info -name $rnd]
                            }
                            if { ( [string match {*fa*} $rnd] || [string match {*FABRICADAPTOR*} [get_point_info -location $rpoint]]) && $loc eq ""} {
                                set loc [get_point_info -location $rpoint]
                            }
                        }                            
                    }
                    if { [dict exists $ldict $idx $tpath_ext $sig] } {
                        if { [dict get $ldict $idx $tpath_ext $sig slack] > $slack } {
                            dict set ldict $idx $tpath_ext $sig [dict create loc $loc slack $slack pll_delay $pll_delay_diff pll_delay_tot "($pll_delay_expr)"]
                        } else {
                        }                            
                    } else {
                        dict set ldict $idx $tpath_ext $sig [dict create loc $loc slack $slack pll_delay $pll_delay_diff pll_delay_tot "($pll_delay_expr)"]
                    }
                    
                    set loc ""
                    break
                }
                if { [string match {*fa*} $nd]} {
                    set loc [get_point_info -location $point]
                }      
            }
        }
    }
}

proc emif_ls_check_timing_cxp { dict_in fout } {
    upvar $dict_in all_info
    set report_out 0
    set ret_val 0
    dict for {inst idict} $all_info {
        dict for {opcond ldict} $idict {
            foreach path [dict keys $ldict] {
                if { $path eq "pll_info"} {
                    if { $report_out } {
                        puts $fout [dict get $ldict pll_info HEADING]
                        puts $fout "PLL0 max path to vco out = [dict get $ldict pll_info PLL0 MAX]"
                        puts $fout "PLL0 min path to vco out = [dict get $ldict pll_info PLL0 MIN]"
                        puts $fout "PLL0 <-> core_clk uncertainy = [dict get $ldict pll_info PLL0 UNCERTAINTY]"
                        puts $fout "PLL1 max path to vco out = [dict get $ldict pll_info PLL1 MAX]"
                        puts $fout "PLL1 min path to vco out = [dict get $ldict pll_info PLL1 MIN]"
                        puts $fout "PLL1 <-> core_clk uncertainy = [dict get $ldict pll_info PLL1 UNCERTAINTY]"
                        puts $fout "PLL Skew used = [dict get $ldict pll_info SKEW]"
                        puts $fout "SPE adjustment used = [dict get $ldict pll_info UNCERTAINTY_DIFF]"
                    }
                    continue 
                }
                foreach type [dict keys [dict get $ldict $path]] {
                    foreach sig [dict keys [dict get $ldict $path $type]] {
                        if { $report_out } {
                            puts $fout "$path -> $type -> $sig -> [dict get $ldict $path $type $sig loc] -> [dict get $ldict $path $type $sig slack] -> [dict get $ldict $path $type $sig pll_delay] -> [dict get $ldict $path $type $sig pll_delay_tot]"
                        }
                        if { [expr { ( [dict get $ldict $path $type $sig slack] + [dict get $ldict $path $type $sig pll_delay] ) < 0 } ] } {
                            set ret_val 1
                            set slack [expr ([dict get $ldict $path $type $sig slack] + [dict get $ldict $path $type $sig pll_delay]) ]
                            if {$report_out == 0 } {
                                puts $fout "$path -> $type -> $sig -> $slack"
                            }
                        }
                    }
                }
            }
        }
    }
    return $ret_val
}

proc emif_ls_c2p_p2c_report_timing_analysis {dict_in summary is_x40} {
    upvar $summary global_summary
    upvar $dict_in all_info
    set report_out 0
    set all_ret [list]
    set types {setup hold}
    set paths { c2p_0  p2c_0 c2p_1 p2c_1 }
    if { $is_x40 } {
        set paths { c2p_0  p2c_0 }
    }
    foreach path $paths {
        set ret_list [list]
        regexp {(\S+)_(\d)} $path -> tpath io
        if { $io == 0 } { lappend ret_list Primary } else { lappend ret_list Secondary }
        lappend ret_list [string toupper $tpath]
        foreach type $types {
            set slack ""
            if [dict exists $all_info $path $type] {
                foreach sig [dict keys [dict get $all_info $path $type]] {
                    set slack [expr ([dict get $all_info $path $type $sig slack] + [dict get $all_info $path $type $sig pll_delay]) ]
                    break
                }
            } 
            lappend ret_list $slack
        }
        lappend global_summary $ret_list
    }
}
