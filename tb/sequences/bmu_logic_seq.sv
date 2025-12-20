`timescale 1ns/1ps

`ifndef BMU_LOGIC_SEQ_SV
`define BMU_LOGIC_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_base_seq.sv"
`include "bmu_seq_item.sv"

// ----------------------------------------------------------
// BMU Logic Functional Sequence
// Covers:
//  - OR
//  - OR inverted
//  - XOR
//  - XOR inverted
// ----------------------------------------------------------
class bmu_logic_seq extends bmu_base_seq;

  `uvm_object_utils(bmu_logic_seq)

  function new(string name="bmu_logic_seq");
    super.new(name);
  endfunction

  // --------------------------------------------------
  // Init AP helper
  // --------------------------------------------------
  function void init_ap(
    ref rtl_alu_pkt_t ap,
    bit is_or,
    bit inverted
  );
    ap = '0;
    ap.zbb  = inverted;
    ap.lor  = is_or;
    ap.lxor = !is_or;
  endfunction

  // --------------------------------------------------
  // Run one logic op with multiple patterns
  // --------------------------------------------------
  task run_logic(string tag, bit is_or, bit inverted);
    bmu_seq_item tr;

    `uvm_info("BMU_LOGIC_SEQ",
      $sformatf("Starting %s (inverted=%0b)", tag, inverted),
      UVM_LOW)

    // Case 0: random A, B
    tr = bmu_seq_item::type_id::create({tag,"_rand"});
    start_item(tr);
    assert(tr.randomize() with { valid_in==1; csr_ren_in==0; });
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);

    // Case 1: A = 0
    tr = bmu_seq_item::type_id::create({tag,"_a0"});
    start_item(tr);
    assert(tr.randomize() with {
      valid_in==1; csr_ren_in==0; a_in==32'h0;
    });
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);

    // Case 2: A = all ones
    tr = bmu_seq_item::type_id::create({tag,"_a1"});
    start_item(tr);
    assert(tr.randomize() with {
      valid_in==1; csr_ren_in==0; a_in==32'hFFFF_FFFF;
    });
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);

    // Case 3: A = B
    tr = bmu_seq_item::type_id::create({tag,"_aeqb"});
    start_item(tr);
    assert(tr.randomize() with {
      valid_in==1; csr_ren_in==0; a_in==b_in;
    });
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);

    // Case 4: Edge MSB / LSB
    tr = bmu_seq_item::type_id::create({tag,"_edge"});
    start_item(tr);
    tr.valid_in   = 1;
    tr.csr_ren_in= 0;
    tr.a_in      = 32'h8000_0001;
    tr.b_in      = 32'h0000_0001;
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);

    // Case 5: Alternating pattern
    tr = bmu_seq_item::type_id::create({tag,"_alt"});
    start_item(tr);
    tr.valid_in   = 1;
    tr.csr_ren_in= 0;
    tr.a_in      = 32'hAAAA_AAAA;
    tr.b_in      = 32'h5555_5555;
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);
        tr = bmu_seq_item::type_id::create({tag,"_b0"});
    start_item(tr);
    tr.valid_in    = 1;
    tr.csr_ren_in  = 0;
    tr.a_in        = 32'h1234_5678;
    tr.b_in        = 32'h0000_0000;
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);

    tr = bmu_seq_item::type_id::create({tag,"_b1"});
    start_item(tr);
    tr.valid_in    = 1;
    tr.csr_ren_in  = 0;
    tr.a_in        = 32'h1234_5678;
    tr.b_in        = 32'h0000_0001;
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);

    tr = bmu_seq_item::type_id::create({tag,"_ball1"});
    start_item(tr);
    tr.valid_in    = 1;
    tr.csr_ren_in  = 0;
    tr.a_in        = 32'h1234_5678;
    tr.b_in        = 32'hFFFF_FFFF;
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);

    tr = bmu_seq_item::type_id::create({tag,"_b_f0"});
    start_item(tr);
    tr.valid_in    = 1;
    tr.csr_ren_in  = 0;
    tr.a_in        = 32'h0F0F_0F0F;
    tr.b_in        = 32'h0000_00F0; // 11110000 pattern in low byte
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);
    
         // Case 7: All zeros / all ones pairs
    tr = bmu_seq_item::type_id::create({tag,"_a0_b0"});
    start_item(tr);
    tr.valid_in   = 1;
    tr.csr_ren_in = 0;
    tr.a_in       = 32'h0000_0000;
    tr.b_in       = 32'h0000_0000;
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);

    tr = bmu_seq_item::type_id::create({tag,"_a1_b1"});
    start_item(tr);
    tr.valid_in   = 1;
    tr.csr_ren_in = 0;
    tr.a_in       = 32'hFFFF_FFFF;
    tr.b_in       = 32'hFFFF_FFFF;
    init_ap(tr.ap, is_or, inverted);
    finish_item(tr);


  endtask

  // --------------------------------------------------
  // Main body
  // --------------------------------------------------
  task body();
    `uvm_info("BMU_LOGIC_SEQ", "Starting Logic Functional Sequence", UVM_LOW)

    run_logic("OR",  1'b1, 1'b0); // OR
    run_logic("OR_INV",1'b1, 1'b1); // OR inverted
    run_logic("XOR", 1'b0, 1'b0); // XOR
    run_logic("XOR_INV",1'b0, 1'b1); // XOR inverted

    `uvm_info("BMU_LOGIC_SEQ", "Finished Logic Functional Sequence", UVM_LOW)
  endtask

endclass

`endif
