set hls_func [lindex $argv 0]
set part_name  [lindex $argv 1]
set input_source_file [lindex $argv 2]
set output_xo [lindex $argv 3]
open_project proj_${hls_func}
set_top ${hls_func}

add_files ${input_source_file}

open_solution -flow_target=vitis  -reset "solution_${hls_func}"

#set_part {xcvc1902-vsvd1760-2MP-e-S}
set_part ${part_name}

create_clock -period "500MHz"

#config_compile -pipeline_loops 1

#csim_design
csynth_design
#cosim_design -trace_level none -rtl verilog -tool xsim
#export_design -flow impl
export_design -format xo ${output_xo}
exit
