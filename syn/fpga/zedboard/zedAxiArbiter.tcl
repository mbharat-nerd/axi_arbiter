create_project -force zedAxiArbiter ./zedAxiArbiter -part xc7z020clg484-1
set_property board_part digilentinc.com:zedboard:part0:1.1 [current_project]

# Sources (synthesizable)
add_files -norecurse ../../../src/axi_lite_if.sv
add_files -norecurse ../../../src/axi_lite_arbiter.sv
add_files -norecurse ../../../src/axi_if.sv
add_files -norecurse ../../../src/axi_arbiter.sv
add_files -norecurse ../../../src/sv_pipeline.sv

add_files -norecurse ./zedAxiArbiter.sv
update_compile_order -fileset sources_1

# Simulation/UVM files (non-synthesizable)
add_files -fileset sim_1 -norecurse ../../../sim/tb_axi_lite_arbiter.sv
add_files -fileset sim_1 -norecurse ../../../sim/tb_axi_arbiter.sv

set_property top tb_axi_arbiter [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

# Add constraints
add_files -fileset constrs_1 -norecurse ./zedAxiArbiter.xdc


