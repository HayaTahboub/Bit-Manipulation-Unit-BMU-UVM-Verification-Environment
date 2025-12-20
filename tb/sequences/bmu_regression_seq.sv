`timescale 1ns/1ps
`ifndef BMU_REGRESSION_SEQ_SV
`define BMU_REGRESSION_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "bmu_logic_seq.sv"
`include "bmu_logic_err_seq.sv"
`include "bmu_shift_seq.sv"
`include "bmu_shift_err_seq.sv"
`include "bmu_sub_seq.sv"
`include "bmu_sub_err_seq.sv"
`include "bmu_bitmanip_seq.sv"
`include "bmu_bitmanip_err_seq.sv"
`include "bmu_csr_seq.sv"
`include "bmu_csr_err_seq.sv"

// ----------------------------------------------------------
// BMU Full Regression Sequence
// Runs ALL functional + error sequences
// ----------------------------------------------------------
class bmu_regression_seq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(bmu_regression_seq)

  function new(string name="bmu_regression_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("BMU_REGRESSION_SEQ",
              "Starting FULL BMU regression sequence",
              UVM_LOW)

    // ---------------- Logic ----------------
    bmu_logic_seq::type_id::create("logic_seq")
      .start(m_sequencer);
    bmu_logic_err_seq::type_id::create("logic_err_seq")
      .start(m_sequencer);

    // ---------------- Shift ----------------
    bmu_shift_seq::type_id::create("shift_seq")
      .start(m_sequencer);
    bmu_shift_err_seq::type_id::create("shift_err_seq")
      .start(m_sequencer);

    // ---------------- Subtraction ----------------
    bmu_sub_seq::type_id::create("sub_seq")
      .start(m_sequencer);
    bmu_sub_err_seq::type_id::create("sub_err_seq")
      .start(m_sequencer);

    // ---------------- Bit Manipulation ----------------
    bmu_bitmanip_seq::type_id::create("bitmanip_seq")
      .start(m_sequencer);
    bmu_bitmanip_err_seq::type_id::create("bitmanip_err_seq")
      .start(m_sequencer);

    // ---------------- CSR ----------------
    bmu_csr_seq::type_id::create("csr_seq")
      .start(m_sequencer);
    bmu_csr_err_seq::type_id::create("csr_err_seq")
      .start(m_sequencer);

    `uvm_info("BMU_REGRESSION_SEQ",
              "Finished FULL BMU regression sequence",
              UVM_LOW)
  endtask

endclass
`endif
