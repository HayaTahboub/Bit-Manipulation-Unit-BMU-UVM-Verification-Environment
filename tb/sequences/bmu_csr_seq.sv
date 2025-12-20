`timescale 1ns/1ps
`ifndef BMU_CSR_SEQ_SV
`define BMU_CSR_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_base_seq.sv"
`include "bmu_seq_item.sv"

// ----------------------------------------------------------
// BMU CSR Functional Sequence (Legal cases only)
// ----------------------------------------------------------
class bmu_csr_seq extends bmu_base_seq;
  `uvm_object_utils(bmu_csr_seq)

  function new(string name="bmu_csr_seq");
    super.new(name);
  endfunction

  task body();
    bmu_seq_item tr;

    `uvm_info("BMU_CSR_SEQ", "Starting CSR functional sequence", UVM_LOW)

    // ==========================================
    // CSR Write – Immediate mode
    // result = b_in
    // ==========================================
    tr = bmu_seq_item::type_id::create("csr_write_imm");
    start_item(tr);
    tr.valid_in   = 1;
    tr.csr_ren_in= 0;
    tr.a_in       = 32'hAAAA_AAAA;
    tr.b_in       = 32'h1234_5678;
    tr.ap         = '0;
    tr.ap.csr_write = 1;
    tr.ap.csr_imm   = 1;
    finish_item(tr);

    // ==========================================
    // CSR Write – Register mode
    // result = a_in
    // ==========================================
    tr = bmu_seq_item::type_id::create("csr_write_reg");
    start_item(tr);
    tr.valid_in   = 1;
    tr.csr_ren_in= 0;
    tr.a_in       = 32'hDEAD_BEEF;
    tr.b_in       = 32'h0000_0000;
    tr.ap         = '0;
    tr.ap.csr_write = 1;
    tr.ap.csr_imm   = 0;
    finish_item(tr);

    `uvm_info("BMU_CSR_SEQ", "Finished CSR functional sequence", UVM_LOW)
  endtask

endclass
`endif
