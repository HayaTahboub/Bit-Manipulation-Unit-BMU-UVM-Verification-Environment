`timescale 1ns/1ps
`ifndef BMU_SUB_ERR_SEQ_SV
`define BMU_SUB_ERR_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_base_seq.sv"
`include "bmu_seq_item.sv"

// ----------------------------------------------------------
// BMU Subtraction Error / Guard Sequence
// Verifies illegal configurations & overlaps
// ----------------------------------------------------------
class bmu_sub_err_seq extends bmu_base_seq;
  `uvm_object_utils(bmu_sub_err_seq)

  function new(string name="bmu_sub_err_seq");
    super.new(name);
  endfunction

  task automatic send_err(
    string name,
    rtl_alu_pkt_t ap_cfg,
    bit csr_conflict = 0
  );
    bmu_seq_item tr;

    tr = bmu_seq_item::type_id::create(name);
    start_item(tr);
    assert(tr.randomize() with {
      valid_in==1;
      csr_ren_in==csr_conflict;
    });
    tr.ap = ap_cfg;
    finish_item(tr);
  endtask

  task body();
    rtl_alu_pkt_t ap;

    `uvm_info("BMU_SUB_ERR_SEQ", "Starting SUB error sequence", UVM_LOW)

    // --------------------------------------------------
    // Case 0: SUB with ZBA = 1 (illegal)
    // --------------------------------------------------
    ap='0; ap.sub=1; ap.zba=1;
    send_err("err_sub_zba_set", ap);

    // --------------------------------------------------
    // Case 1: SUB + OR overlap
    // --------------------------------------------------
    ap='0; ap.sub=1; ap.lor=1;
    send_err("err_sub_or_overlap", ap);

    // --------------------------------------------------
    // Case 2: SUB + XOR overlap
    // --------------------------------------------------
    ap='0; ap.sub=1; ap.lxor=1;
    send_err("err_sub_xor_overlap", ap);

    // --------------------------------------------------
    // Case 3: SUB + SRL overlap
    // --------------------------------------------------
    ap='0; ap.sub=1; ap.srl=1;
    send_err("err_sub_srl_overlap", ap);

    // --------------------------------------------------
    // Case 4: SUB + SRA overlap
    // --------------------------------------------------
    ap='0; ap.sub=1; ap.sra=1;
    send_err("err_sub_sra_overlap", ap);

    // --------------------------------------------------
    // Case 5: SUB + BINV overlap
    // --------------------------------------------------
    ap='0; ap.sub=1; ap.binv=1;
    send_err("err_sub_binv_overlap", ap);

    // --------------------------------------------------
    // Case 6: CSR conflict
    // --------------------------------------------------
    ap='0; ap.sub=1;
    send_err("err_sub_csr_conflict", ap, 1);

    // --------------------------------------------------
    // Case 7: Everything ON
    // --------------------------------------------------
    ap='1;
    send_err("err_sub_all_on", ap);

    `uvm_info("BMU_SUB_ERR_SEQ", "Finished SUB error sequence", UVM_LOW)
  endtask

endclass
`endif
