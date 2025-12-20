`timescale 1ns/1ps
`ifndef BMU_SUB_SEQ_SV
`define BMU_SUB_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_base_seq.sv"
`include "bmu_seq_item.sv"

// ----------------------------------------------------------
// BMU Subtraction Functional Sequence
// Covers all LEGAL subtraction scenarios
// ----------------------------------------------------------
class bmu_sub_seq extends bmu_base_seq;
  `uvm_object_utils(bmu_sub_seq)

  function new(string name="bmu_sub_seq");
    super.new(name);
  endfunction

  task body();
    bmu_seq_item tr;

    `uvm_info("BMU_SUB_SEQ", "Starting SUB functional sequence", UVM_LOW)

    // --------------------------------------------------
    // Case 0: Random positive subtraction
    // --------------------------------------------------
    tr = bmu_seq_item::type_id::create("sub_random_pos");
    start_item(tr);
    assert(tr.randomize() with {
      valid_in==1; csr_ren_in==0;
      a_in > b_in;
    });
    tr.ap='0; tr.ap.sub=1; tr.ap.zba=0;
    finish_item(tr);

    // --------------------------------------------------
    // Case 1: Negative result (a < b)
    // --------------------------------------------------
    tr = bmu_seq_item::type_id::create("sub_negative");
    start_item(tr);
    assert(tr.randomize() with {
      valid_in==1; csr_ren_in==0;
      a_in < b_in;
    });
    tr.ap='0; tr.ap.sub=1; tr.ap.zba=0;
    finish_item(tr);

    // --------------------------------------------------
    // Case 2: A = B → result = 0
    // --------------------------------------------------
    tr = bmu_seq_item::type_id::create("sub_equal");
    start_item(tr);
    assert(tr.randomize() with {
      valid_in==1; csr_ren_in==0;
      a_in == b_in;
    });
    tr.ap='0; tr.ap.sub=1; tr.ap.zba=0;
    finish_item(tr);

    // --------------------------------------------------
    // Case 3: Large operand difference
    // --------------------------------------------------
    tr = bmu_seq_item::type_id::create("sub_large_diff");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h7FFF_FFFF;
    tr.b_in=32'h0000_0001;
    tr.ap='0; tr.ap.sub=1; tr.ap.zba=0;
    finish_item(tr);

    // --------------------------------------------------
    // Case 4: Underflow edge
    // --------------------------------------------------
    tr = bmu_seq_item::type_id::create("sub_underflow");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h8000_0000;
    tr.b_in=32'h0000_0001;
    tr.ap='0; tr.ap.sub=1; tr.ap.zba=0;
    finish_item(tr);

    // --------------------------------------------------
    // Case 5: Overflow edge
    // --------------------------------------------------
    tr = bmu_seq_item::type_id::create("sub_overflow");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h7FFF_FFFF;
    tr.b_in=32'hFFFF_FFFF;
    tr.ap='0; tr.ap.sub=1; tr.ap.zba=0;
    finish_item(tr);

// --------------------------------------------------
// Case 6: A = 0
// --------------------------------------------------
tr = bmu_seq_item::type_id::create("sub_a_zero");
start_item(tr);
tr.valid_in   = 1;
tr.csr_ren_in = 0;
tr.a_in       = 32'h0;
tr.b_in       = 32'h0000_0005;
tr.ap         = '0;
tr.ap.sub     = 1;
tr.ap.zba     = 0;
finish_item(tr);

// --------------------------------------------------
// Case 7: B = 0
// --------------------------------------------------
tr = bmu_seq_item::type_id::create("sub_b_zero");
start_item(tr);
tr.valid_in   = 1;
tr.csr_ren_in = 0;
tr.a_in       = 32'h1234_5678;
tr.b_in       = 32'h0;
tr.ap         = '0;
tr.ap.sub     = 1;
tr.ap.zba     = 0;
finish_item(tr);

    `uvm_info("BMU_SUB_SEQ", "Finished SUB functional sequence", UVM_LOW)
  endtask

endclass
`endif
