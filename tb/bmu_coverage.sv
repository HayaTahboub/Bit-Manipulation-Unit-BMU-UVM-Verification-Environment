//============================================================
// tb/bmu_coverage.sv
// BMU Functional Coverage Model (UVM Subscriber)
// Xcelium-safe: covergroups declared directly as variables
//============================================================
`timescale 1ns/1ps
`ifndef BMU_COVERAGE_SV
`define BMU_COVERAGE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_seq_item.sv"

class bmu_coverage extends uvm_subscriber #(bmu_seq_item);
  `uvm_component_utils(bmu_coverage)

  bmu_seq_item tr;

  // ----------------------------------------------------------
  // Helper
  // ----------------------------------------------------------
  function automatic int unsigned ap_active_count(rtl_alu_pkt_t ap);
    int unsigned c;
    c = 0;

    // Logic
    c += ap.lor + ap.lxor + ap.zbb;

    // Shift/Mask
    c += ap.srl + ap.sra + ap.ror + ap.binv + ap.sh2add;

    // Arith
    c += ap.sub;

    // Bitmanip
    c += ap.slt + ap.unsign;
    c += ap.ctz + ap.cpop;
    c += ap.siext_b;
    c += ap.max;
    c += ap.pack;
    c += ap.grev;

    // CSR
    c += ap.csr_write + ap.csr_imm;

    // Enables (keep counted for guard)
    c += ap.zba;

    return c;
  endfunction

  // ==========================================================
  // COVERGROUP INSTANCES
  // ==========================================================

  // ----------------------------
  // GUARD / ILLEGAL
  // ----------------------------
  covergroup cg_guard;
    option.per_instance = 1;

    cp_multi_ap      : coverpoint (ap_active_count(tr.ap) > 1) { bins no={0}; bins yes={1}; }
    cp_sub_zba       : coverpoint (tr.ap.sub && tr.ap.zba)      { bins ok={0}; bins bad={1}; }
    cp_sh2add_no_zba : coverpoint (tr.ap.sh2add && !tr.ap.zba)  { bins ok={0}; bins bad={1}; }
    cp_grev_bad_mode : coverpoint (tr.ap.grev && (tr.b_in[4:0] != 5'd24)) { bins ok={0}; bins bad={1}; }
  endgroup

  // ----------------------------
  // LOGIC
  // ----------------------------
    covergroup cg_logic;
    option.per_instance = 1;

    // --------------------------------
    // Operation type
    // --------------------------------
    cp_op : coverpoint {tr.ap.lor, tr.ap.lxor, tr.ap.zbb} {
      bins or_n  = {3'b100};
      bins or_i  = {3'b101};
      bins xor_n = {3'b010};
      bins xor_i = {3'b011};
    }

    // --------------------------------
    // A patterns (OR / XOR focus)
    // --------------------------------
    cp_a : coverpoint tr.a_in {
      bins zero   = {32'h0000_0000};
      bins ones   = {32'hFFFF_FFFF};
      bins a_alt1 = {32'hAAAA_AAAA};
      bins a_alt2 = {32'h5555_5555};
      bins a_edge = {32'h8000_0001};
      bins other  = default;
    }

    // --------------------------------
    // B patterns (INV focus)
    // --------------------------------
    cp_b : coverpoint tr.b_in {
      bins zero  = {32'h0000_0000};
      bins one   = {32'h0000_0001};
      bins alt1  = {32'hAAAA_AAAA};
      bins alt2  = {32'h5555_5555};
      bins f0    = {32'h0000_00F0};
      bins other = default;
    }

    // --------------------------------
    // A == B requirement
    // --------------------------------
    cp_a_eq_b : coverpoint (tr.a_in == tr.b_in) {
      bins no  = {0};
      bins yes = {1};
    }

    // --------------------------------
    // SPEC-DRIVEN crosses 
    // --------------------------------
    x_logic_op_a  : cross cp_op, cp_a;
    x_logic_op_b  : cross cp_op, cp_b;
    x_logic_eq    : cross cp_op, cp_a_eq_b;

  endgroup


  // ----------------------------
  // SHIFT / MASK
  // ----------------------------
  // ----------------------------
// SHIFT / MASK (SPEC-DRIVEN)
// ----------------------------
covergroup cg_shift;
  option.per_instance = 1;

  // --------------------------------------------------
  // Operation selector
  // --------------------------------------------------
  cp_shift_op : coverpoint {tr.ap.srl, tr.ap.sra, tr.ap.ror, tr.ap.binv, tr.ap.sh2add} {
    bins srl    = {5'b10000};
    bins sra    = {5'b01000};
    bins ror    = {5'b00100};
    bins binv   = {5'b00010};
    bins sh2add = {5'b00001};
  }

  // --------------------------------------------------
  // Shift amount (raw)
  // --------------------------------------------------
  cp_shamt : coverpoint tr.b_in {
    bins sh0   = {32'd0};
    bins sh1   = {32'd1};
    bins sh5   = {32'd5};
    bins sh31  = {32'd31};
    bins gt31  = {[32'd32:32'd255]};
  }

  // --------------------------------------------------
  // Shift amount masked (for >31 behavior)
  // --------------------------------------------------
  cp_shamt_masked : coverpoint tr.b_in[4:0] {
    bins m0  = {5'd0};
    bins m1  = {5'd1};
    bins m5  = {5'd5};
    bins m31 = {5'd31};
  }

  // --------------------------------------------------
  // A operand patterns (signed + unsigned)
  // --------------------------------------------------
  cp_a_val : coverpoint tr.a_in {
    bins zero = {32'h0000_0000};
    bins ones = {32'hFFFF_FFFF};
    bins pos  = {[32'h0000_0001:32'h7FFF_FFFF]};
    bins neg  = {[32'h8000_0000:32'hFFFF_FFFE]};
  }

  // ==================================================
  // SRL coverage
  // ==================================================
  x_srl_amt : cross cp_shift_op, cp_shamt {
    ignore_bins not_srl =
      binsof(cp_shift_op) intersect {5'b01000,5'b00100,5'b00010,5'b00001};
  }

  x_srl_a : cross cp_shift_op, cp_a_val {
    ignore_bins not_srl =
      binsof(cp_shift_op) intersect {5'b01000,5'b00100,5'b00010,5'b00001};
  }

  // ==================================================
  // SRA coverage (sign matters)
  // ==================================================
  x_sra_amt : cross cp_shift_op, cp_shamt {
    ignore_bins not_sra =
      binsof(cp_shift_op) intersect {5'b10000,5'b00100,5'b00010,5'b00001};
  }

  x_sra_sign : cross cp_shift_op, cp_a_val {
    ignore_bins not_sra =
      binsof(cp_shift_op) intersect {5'b10000,5'b00100,5'b00010,5'b00001};
  }

  // ==================================================
  // ROR coverage
  // ==================================================
  x_ror_amt : cross cp_shift_op, cp_shamt_masked {
    ignore_bins not_ror =
      binsof(cp_shift_op) intersect {5'b10000,5'b01000,5'b00010,5'b00001};
  }

  x_ror_a : cross cp_shift_op, cp_a_val {
    ignore_bins not_ror =
      binsof(cp_shift_op) intersect {5'b10000,5'b01000,5'b00010,5'b00001};
  }

  // ==================================================
  // BINV coverage
  // ==================================================
  cp_binv_idx : coverpoint tr.b_in {
    bins idx0  = {32'd0};
    bins idx15 = {32'd15};
    bins idx31 = {32'd31};
    bins oob   = {[32'd32:32'd255]};
  }

  x_binv : cross cp_shift_op, cp_binv_idx {
    ignore_bins not_binv =
      binsof(cp_shift_op) intersect {5'b10000,5'b01000,5'b00100,5'b00001};
  }

  // ==================================================
  // SH2ADD legality (zba)
  // ==================================================
  cp_zba : coverpoint tr.ap.zba {
    bins off = {0};
    bins on  = {1};
  }

  x_sh2add_zba : cross cp_shift_op, cp_zba {
    ignore_bins not_sh2add =
      binsof(cp_shift_op) intersect {5'b10000,5'b01000,5'b00100,5'b00010};
  }

  // ==================================================
  // CSR conflict
  // ==================================================
  cp_shift_csr_conflict : coverpoint
    (tr.csr_ren_in &&
     (tr.ap.srl || tr.ap.sra || tr.ap.ror || tr.ap.binv || tr.ap.sh2add)) {
    bins no  = {0};
    bins yes = {1};
  }

endgroup


  // ----------------------------
  // ARITH (SUB)
  // ----------------------------
  covergroup cg_arith;
    option.per_instance = 1;

    cp_sub : coverpoint tr.ap.sub { bins no={0}; bins yes={1}; }

    cp_res : coverpoint $signed(tr.a_in) - $signed(tr.b_in) {
      bins zero = {0};
      bins pos  = {[1:$]};
      bins neg  = {[$:-1]};
    }
  endgroup

  // ----------------------------
  // BIT MANIP
  // ----------------------------
  covergroup cg_bitmanip;
    option.per_instance = 1;

    cp_slt : coverpoint {tr.ap.slt, tr.ap.unsign, tr.ap.sub} {
      bins slt_signed_ok   = {3'b101};
      bins slt_unsigned_ok = {3'b111};
      bins slt_bad_nosub   = {3'b100, 3'b110};
      bins other           = default;
    }

    cp_ctz : coverpoint tr.a_in {
      bins zero  = {32'h0000_0000};
      bins bit0  = {32'h0000_0001};
      bins bit5  = {32'h0000_0020};
      bins bit31 = {32'h8000_0000};
      bins other = default;
    }

    cp_cpop : coverpoint tr.a_in {
      bins all0  = {32'h0000_0000};
      bins all1  = {32'hFFFF_FFFF};
      bins other = default;
    }

    cp_sextb : coverpoint tr.a_in[7:0] {
      bins v7f   = {8'h7F};
      bins v80   = {8'h80};
      bins sign0 = {[8'h00:8'h7F]};
      bins sign1 = {[8'h80:8'hFF]};
    }

    cp_grev : coverpoint tr.b_in[4:0] {
      bins ok  = {5'd24};
      bins bad = default;
    }
  endgroup

  // ----------------------------
  // CSR
  // ----------------------------
  covergroup cg_csr;
    option.per_instance = 1;

    cp_write : coverpoint tr.ap.csr_write { bins no={0}; bins yes={1}; }
    cp_imm   : coverpoint tr.ap.csr_imm   { bins mode0={0}; bins mode1={1}; }
    x_mode   : cross cp_write, cp_imm;
  endgroup

  // ----------------------------------------------------------
  // Constructor
  // ----------------------------------------------------------
  function new(string name="bmu_coverage", uvm_component parent=null);
    super.new(name, parent);

    cg_guard    = new();
    cg_logic    = new();
    cg_shift    = new();
    cg_arith    = new();
    cg_bitmanip = new();
    cg_csr      = new();
  endfunction

  // ----------------------------------------------------------
  // Subscriber write -> sample
  // ----------------------------------------------------------
  virtual function void write(bmu_seq_item t);
    tr = t;

    cg_guard.sample();
    cg_logic.sample();
    cg_shift.sample();
    cg_arith.sample();
    cg_bitmanip.sample();
    cg_csr.sample();
  endfunction

  // ----------------------------------------------------------
  // report
  // ----------------------------------------------------------
  function void report_phase(uvm_phase phase);
    real total;
    total =
      (cg_guard.get_coverage() +
       cg_logic.get_coverage() +
       cg_shift.get_coverage() +
       cg_arith.get_coverage() +
       cg_bitmanip.get_coverage() +
       cg_csr.get_coverage()) / 6.0;

    `uvm_info("BMU_COVERAGE",
              $sformatf("TOTAL COVERAGE = %0.2f%%", total),
              UVM_LOW)
   `uvm_info("BMU_COVERAGE",
  $sformatf("guard=%0.2f logic=%0.2f shift=%0.2f arith=%0.2f bitmanip=%0.2f csr=%0.2f",
    cg_guard.get_coverage(),
    cg_logic.get_coverage(),
    cg_shift.get_coverage(),
    cg_arith.get_coverage(),
    cg_bitmanip.get_coverage(),
    cg_csr.get_coverage()),
  UVM_LOW)
  endfunction

endclass

`endif // BMU_COVERAGE_SV
