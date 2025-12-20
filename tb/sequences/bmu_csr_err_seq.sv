`timescale 1ns/1ps
`ifndef BMU_CSR_ERR_SEQ_SV
`define BMU_CSR_ERR_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_base_seq.sv"
`include "bmu_seq_item.sv"

// ----------------------------------------------------------
// BMU CSR Error / Guard Sequence
// ----------------------------------------------------------
class bmu_csr_err_seq extends bmu_base_seq;
  `uvm_object_utils(bmu_csr_err_seq)

  function new(string name="bmu_csr_err_seq");
    super.new(name);
  endfunction

  task send_err(string name, rtl_alu_pkt_t ap_cfg, bit csr);
    bmu_seq_item tr;
    tr = bmu_seq_item::type_id::create(name);
    start_item(tr);
    tr.valid_in    = 1;
    tr.csr_ren_in = csr;
    tr.ap          = ap_cfg;
    finish_item(tr);
  endtask

  task body();
    rtl_alu_pkt_t ap;

    `uvm_info("BMU_CSR_ERR_SEQ", "Starting CSR error sequence", UVM_LOW)

    // ==========================================
    // csr_ren_in + BitManip → ERROR
    // ==========================================
    ap = '0; ap.ctz = 1;
    send_err("err_csr_read_ctz", ap, 1);

    ap = '0; ap.slt = 1;
    send_err("err_csr_read_slt", ap, 1);

    ap = '0; ap.pack = 1;
    send_err("err_csr_read_pack", ap, 1);

    // ==========================================
    // csr_write + any ap.* → ERROR
    // ==========================================
    ap = '0; ap.csr_write = 1; ap.pack = 1;
    send_err("err_csr_write_or", ap, 0);

    ap = '0; ap.csr_write = 1; ap.srl = 1;
    send_err("err_csr_write_shift", ap, 0);

    ap = '0; ap.csr_write = 1; ap.grev = 1;
    send_err("err_csr_write_grev", ap, 0);

    // ==========================================
    // Everything ON
    // ==========================================
    ap = '1;
    send_err("err_csr_all_on", ap, 1);

    `uvm_info("BMU_CSR_ERR_SEQ", "Finished CSR error sequence", UVM_LOW)
  endtask

endclass
`endif
