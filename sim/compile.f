+incdir+../dut
+incdir+../tb
+incdir+../tb/sequences
+incdir+../tb/tests
+xmelab+no_timescale
+xmelab+nospecify

// RTL files 
../dut/rtl_defines.sv
../dut/rtl_pdef.sv
../dut/rtl_def.sv
../dut/rtl_lib.sv
../dut/Bit_Manibulation_Unit.sv

// Testbench files
../tb/bmu_if.sv
../tb/bmu_seq_item.sv
../tb/sequences/bmu_base_seq.sv
../tb/bmu_sequencer.sv
../tb/bmu_driver.sv
../tb/bmu_ref_model.sv
../tb/bmu_scoreboard.sv
../tb/bmu_coverage.sv
../tb/bmu_monitor.sv
../tb/bmu_agent.sv
../tb/bmu_env.sv
../tb/sequences/bmu_csr_err_seq.sv
../tb/sequences/bmu_shift_err_seq.sv
../tb/sequences/bmu_shift_seq.sv
../tb/sequences/bmu_sub_err_seq.sv
../tb/sequences/bmu_sub_seq.sv
../tb/sequences/bmu_logic_seq.sv
../tb/sequences/bmu_logic_err_seq.sv
../tb/sequences/bmu_bitmanip_seq.sv
../tb/sequences/bmu_bitmanip_err_seq.sv
../tb/sequences/bmu_csr_seq.sv
../tb/sequences/bmu_regression_seq.sv
../tb/tests/bmu_regression_test.sv
../tb/tests/bmu_smoke_test.sv
../tb/bmu_tb_top.sv



