proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param gui.test TreeTableDev
  debug::add_scope template.lib 1
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir E:/Basys3-master/Basys3-master/Projects/XADC_Demo/proj/XADC_Demo.cache/wt [current_project]
  set_property parent.project_path E:/Basys3-master/Basys3-master/Projects/XADC_Demo/proj/XADC_Demo.xpr [current_project]
  set_property ip_repo_paths {
  e:/Basys3-master/Basys3-master/Projects/XADC_Demo/proj/XADC_Demo.cache/ip
  E:/Basys3-master/Basys3-master/Projects/XADC_Demo/repo
} [current_project]
  set_property ip_output_repo e:/Basys3-master/Basys3-master/Projects/XADC_Demo/proj/XADC_Demo.cache/ip [current_project]
  add_files -quiet E:/Basys3-master/Basys3-master/Projects/XADC_Demo/proj/XADC_Demo.runs/synth_1/XADCdemo.dcp
  add_files -quiet e:/Basys3-master/Basys3-master/Projects/XADC_Demo/src/ip/xadc_wiz_0_1/xadc_wiz_0.dcp
  set_property netlist_only true [get_files e:/Basys3-master/Basys3-master/Projects/XADC_Demo/src/ip/xadc_wiz_0_1/xadc_wiz_0.dcp]
  read_xdc -ref xadc_wiz_0 -cells U0 e:/Basys3-master/Basys3-master/Projects/XADC_Demo/src/ip/xadc_wiz_0_1/xadc_wiz_0.xdc
  set_property processing_order EARLY [get_files e:/Basys3-master/Basys3-master/Projects/XADC_Demo/src/ip/xadc_wiz_0_1/xadc_wiz_0.xdc]
  read_xdc E:/Basys3-master/Basys3-master/Projects/XADC_Demo/src/constraints/Basys3_Master.xdc
  link_design -top XADCdemo -part xc7a35tcpg236-1
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design 
  write_checkpoint -force XADCdemo_opt.dcp
  catch {report_drc -file XADCdemo_drc_opted.rpt}
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  place_design 
  write_checkpoint -force XADCdemo_placed.dcp
  catch { report_io -file XADCdemo_io_placed.rpt }
  catch { report_clock_utilization -file XADCdemo_clock_utilization_placed.rpt }
  catch { report_utilization -file XADCdemo_utilization_placed.rpt -pb XADCdemo_utilization_placed.pb }
  catch { report_control_sets -verbose -file XADCdemo_control_sets_placed.rpt }
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force XADCdemo_routed.dcp
  catch { report_drc -file XADCdemo_drc_routed.rpt -pb XADCdemo_drc_routed.pb }
  catch { report_timing_summary -warn_on_violation -max_paths 10 -file XADCdemo_timing_summary_routed.rpt -rpx XADCdemo_timing_summary_routed.rpx }
  catch { report_power -file XADCdemo_power_routed.rpt -pb XADCdemo_power_summary_routed.pb }
  catch { report_route_status -file XADCdemo_route_status.rpt -pb XADCdemo_route_status.pb }
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  write_bitstream -force XADCdemo.bit -bin_file
  if { [file exists E:/Basys3-master/Basys3-master/Projects/XADC_Demo/proj/XADC_Demo.runs/synth_1/XADCdemo.hwdef] } {
    catch { write_sysdef -hwdef E:/Basys3-master/Basys3-master/Projects/XADC_Demo/proj/XADC_Demo.runs/synth_1/XADCdemo.hwdef -bitfile XADCdemo.bit -meminfo XADCdemo.mmi -file XADCdemo.sysdef }
  }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

