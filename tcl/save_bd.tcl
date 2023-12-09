#vivado -mode batch -source mk/tcl/save_bd.tcl -tclargs  _x_test_lv_urw_net_freq_test_u55n
set prj_path [lindex $argv 0]
put $prj_path/link/vivado/vpl/prj/prj.xpr

open_project $prj_path/link/vivado/vpl/prj/prj.xpr
open_bd_design $prj_path/link/vivado/vpl/prj/prj.srcs/my_rm/bd/ulp/ulp.bd
start_gui
write_bd_layout -format pdf -force -orientation portrait $prj_path/bd.pdf
stop_gui