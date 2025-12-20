`timescale 1ns/1ps
`ifndef BMU_BITMANIP_SEQ_SV
`define BMU_BITMANIP_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_base_seq.sv"
`include "bmu_seq_item.sv"

// ----------------------------------------------------------
// BMU Bit Manipulation Functional Sequence
// Covers ALL LEGAL bit-manipulation operations (per spec)
// ----------------------------------------------------------
class bmu_bitmanip_seq extends bmu_base_seq;
  `uvm_object_utils(bmu_bitmanip_seq)

  function new(string name="bmu_bitmanip_seq");
    super.new(name);
  endfunction

  task body();
    bmu_seq_item tr;

    `uvm_info("BMU_BITMANIP_SEQ",
              "Starting Bit-Manipulation functional sequence",
              UVM_LOW)

    // ==================================================
    // A. SLT Unsigned (LEGAL: requires sub=1)
    // ==================================================
    tr=bmu_seq_item::type_id::create("sltu_neg_pos");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hFFFF_FFFF; tr.b_in=32'h0000_0001;
    tr.ap='0; tr.ap.slt=1; tr.ap.sub=1; tr.ap.unsign=1;
    finish_item(tr);

    tr=bmu_seq_item::type_id::create("sltu_pos_neg");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h0000_0001; tr.b_in=32'hFFFF_FFFF;
    tr.ap='0; tr.ap.slt=1; tr.ap.sub=1; tr.ap.unsign=1;
    finish_item(tr);

    tr=bmu_seq_item::type_id::create("sltu_equal");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h12345678; tr.b_in=32'h12345678;
    tr.ap='0; tr.ap.slt=1; tr.ap.sub=1; tr.ap.unsign=1;
    finish_item(tr);

    tr=bmu_seq_item::type_id::create("sltu_min_max");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h8000_0000; tr.b_in=32'h7FFF_FFFF;
    tr.ap='0; tr.ap.slt=1; tr.ap.sub=1; tr.ap.unsign=1;
    finish_item(tr);

tr=bmu_seq_item::type_id::create("sltu_random");
start_item(tr);
assert(tr.randomize() with { valid_in==1; csr_ren_in==0; });
tr.ap='0; tr.ap.slt=1; tr.ap.sub=1; tr.ap.unsign=1;
finish_item(tr);

    // ==================================================
    // B. SLT Signed (LEGAL: requires sub=1)
    // ==================================================
    tr=bmu_seq_item::type_id::create("slt_0_1");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=0; tr.b_in=1;
    tr.ap='0; tr.ap.slt=1; tr.ap.sub=1;
    finish_item(tr);

    tr=bmu_seq_item::type_id::create("slt_wrap");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hFFFFFFFF; tr.b_in=1;
    tr.ap='0; tr.ap.slt=1; tr.ap.sub=1;
    finish_item(tr);

    tr=bmu_seq_item::type_id::create("slt_equal");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hAAAA5555; tr.b_in=32'hAAAA5555;
    tr.ap='0; tr.ap.slt=1; tr.ap.sub=1;
    finish_item(tr);

tr=bmu_seq_item::type_id::create("slt_signed_random");
start_item(tr);
assert(tr.randomize() with { valid_in==1; csr_ren_in==0; });
tr.ap='0; tr.ap.slt=1; tr.ap.sub=1;
finish_item(tr);


    // ==================================================
    // C. CTZ
    // ==================================================
    tr=bmu_seq_item::type_id::create("ctz_bit_0");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h1;
    tr.ap='0; tr.ap.ctz=1;
    finish_item(tr);

    tr=bmu_seq_item::type_id::create("ctz_bit_5");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=(32'h1 << 5);
    tr.ap='0; tr.ap.ctz=1;
    finish_item(tr);

    tr=bmu_seq_item::type_id::create("ctz_bit_31");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=(32'h1 << 31);
    tr.ap='0; tr.ap.ctz=1;
    finish_item(tr);

tr=bmu_seq_item::type_id::create("ctz_zero");
start_item(tr);
tr.valid_in=1; tr.csr_ren_in=0;
tr.a_in=32'h0;
tr.ap='0; tr.ap.ctz=1;
finish_item(tr);

tr=bmu_seq_item::type_id::create("ctz_alternating");
start_item(tr);
tr.valid_in=1; tr.csr_ren_in=0;
tr.a_in=32'hAAAA_AAAA;
tr.ap='0; tr.ap.ctz=1;
finish_item(tr);

tr=bmu_seq_item::type_id::create("ctz_random");
start_item(tr);
assert(tr.randomize() with { valid_in==1; csr_ren_in==0; });
tr.ap='0; tr.ap.ctz=1;
finish_item(tr);


    // ==================================================
    // D. CPOP
    // ==================================================
    tr=bmu_seq_item::type_id::create("cpop_zero");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=0;
    tr.ap='0; tr.ap.cpop=1;
    finish_item(tr);

    tr=bmu_seq_item::type_id::create("cpop_all_ones");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hFFFF_FFFF;
    tr.ap='0; tr.ap.cpop=1;
    finish_item(tr);

tr=bmu_seq_item::type_id::create("cpop_random");
start_item(tr);
assert(tr.randomize() with { valid_in==1; csr_ren_in==0; });
tr.ap='0; tr.ap.cpop=1;
finish_item(tr);


    // ==================================================
    // E. Sign Extend Byte
    // ==================================================
    tr=bmu_seq_item::type_id::create("siext_pos");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=8'h7F;
    tr.ap='0; tr.ap.siext_b=1;
    finish_item(tr);

    tr=bmu_seq_item::type_id::create("siext_neg");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=8'h80;
    tr.ap='0; tr.ap.siext_b=1;
    finish_item(tr);

tr=bmu_seq_item::type_id::create("siext_random");
start_item(tr);
tr.valid_in=1; tr.csr_ren_in=0;
tr.a_in=$urandom_range(0,255);
tr.ap='0; tr.ap.siext_b=1;
finish_item(tr);


    // ==================================================
    // F. MAX (LEGAL: requires sub=1)
    // ==================================================
    tr=bmu_seq_item::type_id::create("max_signed");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=-5; tr.b_in=3;
    tr.ap='0; tr.ap.max=1; tr.ap.sub=1;
    finish_item(tr);

    tr=bmu_seq_item::type_id::create("max_equal");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=9; tr.b_in=9;
    tr.ap='0; tr.ap.max=1; tr.ap.sub=1;
    finish_item(tr);

tr=bmu_seq_item::type_id::create("max_large_mag");
start_item(tr);
tr.valid_in=1; tr.csr_ren_in=0;
tr.a_in=32'h8000_0000;
tr.b_in=32'h7FFF_FFFF;
tr.ap='0; tr.ap.max=1; tr.ap.sub=1;
finish_item(tr);


    // ==================================================
    // G. PACK
    // ==================================================
    tr=bmu_seq_item::type_id::create("pack_basic");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hAAAA_BBBB;
    tr.b_in=32'hCCCC_DDDD;
    tr.ap='0; tr.ap.pack=1;
    finish_item(tr);

tr=bmu_seq_item::type_id::create("pack_a_zero");
start_item(tr);
tr.valid_in=1; tr.csr_ren_in=0;
tr.a_in=0; tr.b_in=32'h12345678;
tr.ap='0; tr.ap.pack=1;
finish_item(tr);

tr=bmu_seq_item::type_id::create("pack_random");
start_item(tr);
assert(tr.randomize() with { valid_in==1; csr_ren_in==0; });
tr.ap='0; tr.ap.pack=1;
finish_item(tr);


    // ==================================================
    // H. GREV (LEGAL only when b_in[4:0]==24)
    // ==================================================
    tr=bmu_seq_item::type_id::create("grev_valid");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hA1B2C3D4;
    tr.b_in=24;
    tr.ap='0; tr.ap.grev=1;
    finish_item(tr);

tr=bmu_seq_item::type_id::create("grev_zero");
start_item(tr);
tr.valid_in=1; tr.csr_ren_in=0;
tr.a_in=32'h0; tr.b_in=24;
tr.ap='0; tr.ap.grev=1;
finish_item(tr);

tr=bmu_seq_item::type_id::create("grev_all_ones");
start_item(tr);
tr.valid_in=1; tr.csr_ren_in=0;
tr.a_in=32'hFFFF_FFFF; tr.b_in=24;
tr.ap='0; tr.ap.grev=1;
finish_item(tr);

tr=bmu_seq_item::type_id::create("grev_alternating");
start_item(tr);
tr.valid_in=1; tr.csr_ren_in=0;
tr.a_in=32'hA5A5_A5A5; tr.b_in=24;
tr.ap='0; tr.ap.grev=1;
finish_item(tr);

    `uvm_info("BMU_BITMANIP_SEQ",
              "Finished Bit-Manipulation functional sequence",
              UVM_LOW)
  endtask

endclass
`endif
