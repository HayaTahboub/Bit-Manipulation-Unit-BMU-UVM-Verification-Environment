// tb/bmu_tb_top.sv
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

module bmu_tb_top;

  // -------- Clock & Reset --------
  logic clk;
  logic rst_l;

  // -------- Interface Instance --------
  bmu_if bmu_vif (.clk(clk), .rst_l(rst_l));

  // -------- DUT Instance --------
  Bit_Manipulation_Unit dut (
    .clk          (clk),
    .rst_l        (rst_l),
    .scan_mode    (bmu_vif.scan_mode),
    .valid_in     (bmu_vif.valid_in),
    .ap           (bmu_vif.ap),
    .csr_ren_in   (bmu_vif.csr_ren_in),
    .csr_rddata_in(bmu_vif.csr_rddata_in),
    .a_in         (bmu_vif.a_in),
    .b_in         (bmu_vif.b_in),
    .result_ff    (bmu_vif.result_ff),
    .error        (bmu_vif.error)
  );

  // -------- Clock --------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // -------- Reset --------
  initial begin
    rst_l = 0;
    repeat (5) @(posedge clk);
    rst_l = 1;
  end

  // -------- UVM Startup --------
  initial begin
    // Pass the virtual interface to UVM components
    uvm_config_db#(virtual bmu_if.drv_mp)::set(null, "*", "vif", bmu_vif);
    uvm_config_db#(virtual bmu_if.mon_mp)::set(null, "*", "mon_vif", bmu_vif);

    // Start UVM
        run_test("bmu_regression_test");
  end

endmodule
