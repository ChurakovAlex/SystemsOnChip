set_property SRC_FILE_INFO {cfile:c:/SoC/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4_DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xdc rfile:../../../NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
