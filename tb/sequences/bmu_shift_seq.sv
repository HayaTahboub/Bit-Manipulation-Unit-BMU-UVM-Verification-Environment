`timescale 1ns/1ps
`ifndef BMU_SHIFT_SEQ_SV
`define BMU_SHIFT_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_base_seq.sv"
`include "bmu_seq_item.sv"

class bmu_shift_seq extends bmu_base_seq;
  `uvm_object_utils(bmu_shift_seq)

  function new(string name="bmu_shift_seq");
    super.new(name);
  endfunction

  task body();
    bmu_seq_item tr;
    int idx;

    int unsigned sh_vals[] = '{0, 1, 5, 31, 40};
    int unsigned binv_idx_vals[] = '{0, 15, 31};

    `uvm_info("BMU_SHIFT_SEQ",
              "Starting Shift & Mask Functional Sequence",
              UVM_LOW)

    // ==================================================
    // A. SRL – Logical Right Shift
    // ==================================================
    foreach (sh_vals[i]) begin
      tr = bmu_seq_item::type_id::create($sformatf("srl_rand_%0d", sh_vals[i]));
      start_item(tr);
      assert(tr.randomize() with {
        valid_in == 1;
        csr_ren_in == 0;
        b_in == sh_vals[i];
      });
      tr.ap = '0;
      tr.ap.srl = 1;
      finish_item(tr);
    end

    // SRL explicit edge cases
    tr = bmu_seq_item::type_id::create("srl_a_zero");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h0; tr.b_in=5;
    tr.ap='0; tr.ap.srl=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("srl_a_all_ones");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hFFFF_FFFF; tr.b_in=5;
    tr.ap='0; tr.ap.srl=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("srl_negative");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h8000_0001; tr.b_in=1;
    tr.ap='0; tr.ap.srl=1;
    finish_item(tr);

    // ==================================================
    // B. SRA – Arithmetic Right Shift
    // ==================================================
    tr = bmu_seq_item::type_id::create("sra_positive");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h4000_0000; tr.b_in=1;
    tr.ap='0; tr.ap.sra=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("sra_negative");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h8000_0000; tr.b_in=31;
    tr.ap='0; tr.ap.sra=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("sra_shift_0");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hF000_0000; tr.b_in=0;
    tr.ap='0; tr.ap.sra=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("sra_shift_gt31");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h8000_0000; tr.b_in=40;
    tr.ap='0; tr.ap.sra=1;
    finish_item(tr);

    // ==================================================
    // C. ROR – Rotate Right
    // ==================================================
    tr = bmu_seq_item::type_id::create("ror_0");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hA5A5_A5A5; tr.b_in=0;
    tr.ap='0; tr.ap.ror=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("ror_1");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hA5A5_A5A5; tr.b_in=1;
    tr.ap='0; tr.ap.ror=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("ror_31");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h8000_0001; tr.b_in=31;
    tr.ap='0; tr.ap.ror=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("ror_all_zero");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h0; tr.b_in=5;
    tr.ap='0; tr.ap.ror=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("ror_all_ones");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'hFFFF_FFFF; tr.b_in=5;
    tr.ap='0; tr.ap.ror=1;
    finish_item(tr);

tr = bmu_seq_item::type_id::create("ror_alternating");
start_item(tr);
tr.valid_in   = 1;
tr.csr_ren_in = 0;
tr.a_in       = 32'hAAAA_AAAA; // alternating
tr.b_in       = 7;             // small rotate
tr.ap         = '0;
tr.ap.ror     = 1;
finish_item(tr);

    // ==================================================
    // D. BINV – Bit Invert
    // ==================================================
    

foreach (binv_idx_vals[i]) begin
  idx = binv_idx_vals[i];
  tr = bmu_seq_item::type_id::create($sformatf("binv_idx_%0d", idx));
  start_item(tr);
  tr.valid_in=1; tr.csr_ren_in=0;
  tr.a_in=32'hFFFF_FFFF;
  tr.b_in=idx;
  tr.ap='0; tr.ap.binv=1;
  finish_item(tr);
end

    tr = bmu_seq_item::type_id::create("binv_all_zero");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h0; tr.b_in=5;
    tr.ap='0; tr.ap.binv=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("binv_index_gt31");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h1234_5678; tr.b_in=40;
    tr.ap='0; tr.ap.binv=1;
    finish_item(tr);

    // ==================================================
    // E. SH2ADD – Shift Left by 2 and Add
    // ==================================================
    tr = bmu_seq_item::type_id::create("sh2add_legal");
    start_item(tr);
    assert(tr.randomize() with {
      valid_in==1; csr_ren_in==0;
    });
    tr.ap='0; tr.ap.sh2add=1; tr.ap.zba=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("sh2add_a_zero");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=0; tr.b_in=32'h10;
    tr.ap='0; tr.ap.sh2add=1; tr.ap.zba=1;
    finish_item(tr);

    tr = bmu_seq_item::type_id::create("sh2add_overflow");
    start_item(tr);
    tr.valid_in=1; tr.csr_ren_in=0;
    tr.a_in=32'h4000_0000; tr.b_in=32'h4000_0000;
    tr.ap='0; tr.ap.sh2add=1; tr.ap.zba=1;
    finish_item(tr);

tr = bmu_seq_item::type_id::create("sh2add_b_zero");
start_item(tr);
tr.valid_in   = 1;
tr.csr_ren_in = 0;
tr.a_in       = 32'h10;
tr.b_in       = 0;
tr.ap         = '0;
tr.ap.sh2add  = 1;
tr.ap.zba     = 1;
finish_item(tr);

    `uvm_info("BMU_SHIFT_SEQ",
              "Finished Shift & Mask Functional Sequence",
              UVM_LOW)
  endtask

endclass
`endif
