# 
# Synthesis run script generated by Vivado
# 

set_param gui.test TreeTableDev
set_param xicom.use_bs_reader 1
debug::add_scope template.lib 1
set_msg_config -id {Common-41} -limit 4294967295
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

create_project -in_memory -part xc7a35tcpg236-1
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir H:/ZYNQ_prj/DigitalCircuitExp/DigitalFrequencyMeter/DigitalFrequencyMeter.cache/wt [current_project]
set_property parent.project_path H:/ZYNQ_prj/DigitalCircuitExp/DigitalFrequencyMeter/DigitalFrequencyMeter.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
read_verilog -library xil_defaultlib {
  H:/ZYNQ_prj/DigitalCircuitExp/DigitalFrequencyMeter/DigitalFrequencyMeter.srcs/sources_1/new/bin2bcd.v
  H:/ZYNQ_prj/DigitalCircuitExp/DigitalFrequencyMeter/DigitalFrequencyMeter.srcs/sources_1/new/freq_meter.v
}
read_xdc H:/ZYNQ_prj/DigitalCircuitExp/DigitalFrequencyMeter/constraints/Basys3_Master.xdc
set_property used_in_implementation false [get_files H:/ZYNQ_prj/DigitalCircuitExp/DigitalFrequencyMeter/constraints/Basys3_Master.xdc]

catch { write_hwdef -file freq_meter.hwdef }
synth_design -top freq_meter -part xc7a35tcpg236-1
write_checkpoint -noxdef freq_meter.dcp
catch { report_utilization -file freq_meter_utilization_synth.rpt -pb freq_meter_utilization_synth.pb }
