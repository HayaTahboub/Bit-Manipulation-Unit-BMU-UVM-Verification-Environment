`timescale 1ns/1ps

`ifndef BMU_LOGIC_ERR_SEQ_SV
`define BMU_LOGIC_ERR_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_base_seq.sv"
`include "bmu_seq_item.sv"

// ----------------------------------------------------------
// BMU Logic Error / Guard Sequence
// الهدف: إثبات شروط الـ guard / overlap / CSR conflict للـ OR/XOR
// ----------------------------------------------------------
class bmu_logic_err_seq extends bmu_base_seq;

  `uvm_object_utils(bmu_logic_err_seq)

  function new(string name="bmu_logic_err_seq");
    super.new(name);
  endfunction

  // Helper لتقليل التكرار
  task automatic send_err_case(
    string name,
    bit csr_conflict,
    rtl_alu_pkt_t ap_cfg
  );
    bmu_seq_item tr;

    tr = bmu_seq_item::type_id::create(name);
    start_item(tr);

    if (csr_conflict) begin
      assert(tr.randomize() with { valid_in==1; csr_ren_in==1; });
    end
    else begin
      assert(tr.randomize() with { valid_in==1; csr_ren_in==0; });
    end

    tr.ap = ap_cfg;

    // ضمان عدم Xs على الحقول غير المتعلقة (اختياري لكنه مفيد)
    tr.scan_mode     = 1'b0;
    tr.csr_rddata_in = '0;

    finish_item(tr);
  endtask

  task body();
    rtl_alu_pkt_t ap;

    `uvm_info("BMU_LOGIC_ERR_SEQ", "Starting Logic Error Sequence", UVM_LOW)

    // --------------------------------------------------
    // Case 0: OR + XOR overlap (يجب error)
    // --------------------------------------------------
    ap = '0;
    ap.lor  = 1;
    ap.lxor = 1;
    ap.zbb  = 0;
    send_err_case("err_or_and_xor_overlap", 0, ap);

    // --------------------------------------------------
    // Case 1: OR + SH2ADD overlap (يجب error)
    // --------------------------------------------------
    ap = '0;
    ap.lor    = 1;
    ap.sh2add = 1;
    send_err_case("err_or_and_sh2add_overlap", 0, ap);
    
    ap = '0;
    ap.lor    = 1;
    ap.sub = 1;
    send_err_case("err_or_and_sub_overlap", 0, ap);

    ap = '0;
    ap.lxor    = 1;
    ap.sh2add = 1;
    send_err_case("err_xor_and_sh2add_overlap", 0, ap);

    // --------------------------------------------------
    // Case 2: XOR + SUB overlap (يجب error حسب الخطة)
    // --------------------------------------------------
    ap = '0;
    ap.lxor = 1;
    ap.sub  = 1;
    send_err_case("err_xor_and_sub_overlap", 0, ap);

    // --------------------------------------------------
    // Case 3: XOR + SRL overlap (Logic + Shift) (يجب error حسب الخطة)
    // --------------------------------------------------
    ap = '0;
    ap.lxor = 1;
    ap.srl  = 1;
    send_err_case("err_xor_and_srl_overlap", 0, ap);

    // --------------------------------------------------
    // Case 4: XOR + CTZ overlap (Logic + Bitcount) (يجب error حسب الخطة)
    // --------------------------------------------------
    ap = '0;
    ap.lxor = 1;
    ap.ctz  = 1;
    send_err_case("err_xor_and_ctz_overlap", 0, ap);

    // --------------------------------------------------
    // Case 5: CSR conflict with OR (csr_ren_in=1) (يجب error)
    // --------------------------------------------------
    ap = '0;
    ap.lor = 1;
    send_err_case("err_csr_conflict_or", 1, ap);

    // --------------------------------------------------
    // Case 6: CSR conflict with XOR (csr_ren_in=1) (يجب error)
    // --------------------------------------------------
    ap = '0;
    ap.lxor = 1;
    send_err_case("err_csr_conflict_xor", 1, ap);

    // --------------------------------------------------
    // Case 7: Everything ON (guard worst-case) (يجب error)
    // --------------------------------------------------
    ap = '1;
    send_err_case("err_all_ap_bits_on", 0, ap);
    
    ap = '0;
    ap.lor = 1;
    ap.srl = 1;
    send_err_case("err_or_and_srl_overlap", 0, ap);

    `uvm_info("BMU_LOGIC_ERR_SEQ", "Finished Logic Error Sequence", UVM_LOW)
  endtask

endclass

`endif
