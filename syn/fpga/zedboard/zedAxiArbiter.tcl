create_project -force zedAxiArbiter ./zedAxiArbiter -part xc7z020clg484-1
set_property board_part digilentinc.com:zedboard:part0:1.1 [current_project]

# Sources (synthesizable)
add_files -norecurse ../../../src/axi_if.sv
add_files -norecurse ./zedAxiArbiter.sv
update_compile_order -fileset sources_1

# Simulation files (non-synthesizable)
#add_files -fileset sim_1 -norecurse ./sim/zedAxiArbiter_tb.sv

# Add constraints
add_files -fileset constrs_1 -norecurse ./zedAxiArbiter.xdc


