`timescale 1ns/1ps
`ifndef BMU_SHIFT_ERR_SEQ_SV
`define BMU_SHIFT_ERR_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;
`include "bmu_base_seq.sv"
`include "bmu_seq_item.sv"

class bmu_shift_err_seq extends bmu_base_seq;
  `uvm_object_utils(bmu_shift_err_seq)

  function new(string name="bmu_shift_err_seq");
    super.new(name);
  endfunction

  task send_err(string name, rtl_alu_pkt_t ap_cfg, bit csr=0);
    bmu_seq_item tr;
    tr=bmu_seq_item::type_id::create(name);
    start_item(tr);
    assert(tr.randomize() with {valid_in==1; csr_ren_in==csr;});
    tr.ap=ap_cfg;
    finish_item(tr);
  endtask

  task body();
    rtl_alu_pkt_t ap;

    `uvm_info("BMU_SHIFT_ERR_SEQ", "Starting Shift Error Sequence", UVM_LOW)

    // SRL overlap
    ap='0; ap.srl=1; ap.sra=1;
    send_err("err_srl_overlap", ap);

    // SRA overlap
    ap='0; ap.sra=1; ap.lor=1;
    send_err("err_sra_overlap", ap);

    // ROR overlap
    ap='0; ap.ror=1; ap.lor=1;
    send_err("err_ror_overlap", ap);

    // BINV overlap
    ap='0; ap.binv=1; ap.grev =1;
    send_err("err_binv_overlap", ap);

    // SH2ADD without ZBA
    ap='0; ap.sh2add=1; ap.zba=0;
    send_err("err_sh2add_no_zba", ap);

    // CSR conflict
    ap='0; ap.srl=1;
    send_err("err_shift_csr", ap, 1);

    // Everything ON
    ap='1;
    send_err("err_shift_all_on", ap);

    `uvm_info("BMU_SHIFT_ERR_SEQ", "Finished Shift Error Sequence", UVM_LOW)
  endtask
endclass
`endif
