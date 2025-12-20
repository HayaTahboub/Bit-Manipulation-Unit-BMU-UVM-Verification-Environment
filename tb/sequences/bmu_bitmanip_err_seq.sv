`timescale 1ns/1ps
`ifndef BMU_BITMANIP_ERR_SEQ_SV
`define BMU_BITMANIP_ERR_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_base_seq.sv"
`include "bmu_seq_item.sv"

// ----------------------------------------------------------
// BMU Bit Manipulation Error / Guard Sequence
// Covers ONLY illegal / error cases per spec
// ----------------------------------------------------------
class bmu_bitmanip_err_seq extends bmu_base_seq;
  `uvm_object_utils(bmu_bitmanip_err_seq)

  function new(string name="bmu_bitmanip_err_seq");
    super.new(name);
  endfunction

  task send_err(string name, rtl_alu_pkt_t ap_cfg,
                bit csr=0, logic [31:0] a='0, logic [31:0] b='0);
    bmu_seq_item tr;
    tr = bmu_seq_item::type_id::create(name);
    start_item(tr);
    tr.valid_in   = 1;
    tr.csr_ren_in= csr;
    tr.a_in       = a;
    tr.b_in       = b;
    tr.ap         = ap_cfg;
    finish_item(tr);
  endtask

  task body();
    rtl_alu_pkt_t ap;

    `uvm_info("BMU_BITMANIP_ERR_SEQ",
              "Starting Bit-Manipulation error sequence", UVM_LOW)

    // --------------------------------------------------
    // SLT بدون SUB -> error
    // --------------------------------------------------
    ap='0; ap.slt=1;
    send_err("err_slt_no_sub", ap);

    // --------------------------------------------------
    // MAX بدون SUB -> error
    // --------------------------------------------------
    ap='0; ap.max=1;
    send_err("err_max_no_sub", ap);

    // --------------------------------------------------
    // CTZ overlap with shift -> error
    // --------------------------------------------------
    ap='0; ap.ctz=1; ap.srl=1;
    send_err("err_ctz_shift_overlap", ap);

    // --------------------------------------------------
    // CPOP overlap with SUB -> error
    // --------------------------------------------------
    ap='0; ap.cpop=1; ap.sub=1;
    send_err("err_cpop_sub_overlap", ap);

    // --------------------------------------------------
    // PACK overlap with any other op -> error
    // --------------------------------------------------
    ap='0; ap.pack=1; ap.lor=1;
    send_err("err_pack_overlap", ap);

    // --------------------------------------------------
    // GREV invalid mode (b_in != 24) -> error
    // --------------------------------------------------
    ap='0; ap.grev=1;
    send_err("err_grev_invalid_mode", ap, 0, 32'hA1B2C3D4, 5);

    // --------------------------------------------------
    // GREV overlap with another op -> error
    // --------------------------------------------------
    ap='0; ap.grev=1; ap.binv=1;
    send_err("err_grev_binv_overlap", ap);

    // --------------------------------------------------
    // CSR conflict with bit-manip op -> error
    // --------------------------------------------------
    ap='0; ap.ctz=1;
    send_err("err_bitmanip_csr_conflict", ap, 1);

    // --------------------------------------------------
    // Everything ON -> error
    // --------------------------------------------------
    ap='1;
    send_err("err_bitmanip_all_on", ap);

    `uvm_info("BMU_BITMANIP_ERR_SEQ",
              "Finished Bit-Manipulation error sequence", UVM_LOW)
  endtask

endclass
`endif
