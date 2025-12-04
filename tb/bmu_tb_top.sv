// tb/bmu_tb_top.sv
`timescale 1ns/1ps

import rtl_pkg::*; 

module bmu_tb_top;

  // -------- Clock & Reset --------
  logic clk;
  logic rst_l;

  // -------- Interface Instance --------
  bmu_if bmu_vif (.clk(clk), .rst_l(rst_l));

  // -------- DUT Instance --------
  Bit_Manibulation_Unit dut (
    .clk          (clk),                 // Top level clock
    .rst_l        (rst_l),               // Reset
    .scan_mode    (bmu_vif.scan_mode),   // Scan control

    .valid_in     (bmu_vif.valid_in),    // Valid
    .ap           (bmu_vif.ap),          // predecodes
    .csr_ren_in   (bmu_vif.csr_ren_in),  // CSR select
    .csr_rddata_in(bmu_vif.csr_rddata_in), // CSR data
    .a_in         (bmu_vif.a_in),        // A operand
    .b_in         (bmu_vif.b_in),        // B operand

    .result_ff    (bmu_vif.result_ff),   // final result
    .error        (bmu_vif.error)
  );

  // -------- Clock Generation --------
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;   // 10ns period = 100MHz
  end

  // -------- Reset & Basic Stimulus --------
  initial begin
    // reset low
    rst_l = 1'b0;

    // init interface signals
    bmu_vif.scan_mode     = 1'b0;
    bmu_vif.valid_in      = 1'b0;
    bmu_vif.csr_ren_in    = 1'b0;
    bmu_vif.csr_rddata_in = '0;
    bmu_vif.a_in          = '0;
    bmu_vif.b_in          = '0;
    bmu_vif.ap            = '{default: 1'b0}; 

  
    repeat (5) @(posedge clk);
    rst_l = 1'b1;

    repeat (50) @(posedge clk);
    $finish;
  end

endmodule
