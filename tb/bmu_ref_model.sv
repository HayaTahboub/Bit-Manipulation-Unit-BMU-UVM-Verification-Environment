`timescale 1ns/1ps
`ifndef BMU_REF_MODEL_SV
`define BMU_REF_MODEL_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;
`include "bmu_seq_item.sv"

class bmu_ref_model extends uvm_object;
  `uvm_object_utils(bmu_ref_model)

  function new(string name="bmu_ref_model");
    super.new(name);
  endfunction

  // -----------------------
  // Helpers
  // -----------------------
  function automatic int unsigned popcount32(input logic [31:0] x);
    int unsigned c = 0;
    for (int i=0;i<32;i++) if (x[i]) c++;
    return c;
  endfunction

  function automatic int unsigned ctz32(input logic [31:0] x);
    if (x == 0) return 32;
    for (int i=0;i<32;i++) if (x[i]) return i;
    return 32;
  endfunction

  function automatic logic [31:0] ror32(input logic [31:0] x, input logic [4:0] sh);
    return (x >> sh) | (x << (32-sh));
  endfunction

  // -----------------------
  // Compute
  // -----------------------
  function void compute(ref bmu_seq_item tr);

    logic [31:0] result = '0;
    bit error = 0;
    int op_cnt = 0;

    // -----------------------
    // Global CSR conflict
    // -----------------------
    if (tr.csr_ren_in == 1) begin
      error = 1;
      tr.exp_result = '0;
      tr.exp_error  = error;
      return;
    end

    // -----------------------
    // CSR WRITE
    // -----------------------
    if (tr.ap.csr_write) begin
      op_cnt++;
      result = tr.ap.csr_imm ? tr.b_in : tr.a_in;
    end

    // -----------------------
    // OR
    // -----------------------
    if (tr.ap.lor) begin
      op_cnt++;
      result = tr.ap.zbb ? (tr.a_in | ~tr.b_in) :
                            (tr.a_in |  tr.b_in);
    end

    // -----------------------
    // XOR
    // -----------------------
    if (tr.ap.lxor) begin
      op_cnt++;
      result = tr.ap.zbb ? (tr.a_in ^ ~tr.b_in) :
                            (tr.a_in ^  tr.b_in);
    end

    // -----------------------
    // SRL
    // -----------------------
    if (tr.ap.srl) begin
      op_cnt++;
      result = tr.a_in >> tr.b_in[4:0];
    end

    // -----------------------
    // SRA
    // -----------------------
    if (tr.ap.sra) begin
      op_cnt++;
      result = $signed(tr.a_in) >>> tr.b_in[4:0];
    end

    // -----------------------
    // ROR
    // -----------------------
    if (tr.ap.ror) begin
      op_cnt++;
      result = ror32(tr.a_in, tr.b_in[4:0]);
    end

    // -----------------------
    // BINV
    // -----------------------
    if (tr.ap.binv) begin
      op_cnt++;
      result = tr.a_in ^ (32'h1 << tr.b_in[4:0]);
    end

    // -----------------------
    // SH2ADD (Zba only)
    // -----------------------
    if (tr.ap.sh2add) begin
      op_cnt++;
      if (tr.ap.zba != 1) begin
        error = 1;
        result = '0;
      end else begin
        result = (tr.a_in << 2) + tr.b_in;
      end
    end

    // -----------------------
    // SUB
    // -----------------------
    if (tr.ap.sub && !tr.ap.slt && !tr.ap.max) begin
      op_cnt++;
      if (tr.ap.zba != 0) begin
        error = 1;
        result = '0;
      end else begin
        result = tr.a_in - tr.b_in;
      end
    end

    // -----------------------
    // SLT
    // -----------------------
    if (tr.ap.slt) begin
      op_cnt++;
      if (!tr.ap.sub) begin
        error = 1;
        result = '0;
      end else begin
        result = tr.ap.unsign ?
                 ($unsigned(tr.a_in) < $unsigned(tr.b_in)) :
                 ($signed(tr.a_in)   < $signed(tr.b_in));
      end
    end

    // -----------------------
    // CTZ
    // -----------------------
    if (tr.ap.ctz) begin
      op_cnt++;
      result = ctz32(tr.a_in);
    end

    // -----------------------
    // CPOP
    // -----------------------
    if (tr.ap.cpop) begin
      op_cnt++;
      result = popcount32(tr.a_in);
    end

    // -----------------------
    // SEXT.B
    // -----------------------
    if (tr.ap.siext_b) begin
      op_cnt++;
      result = {{24{tr.a_in[7]}}, tr.a_in[7:0]};
    end

    // -----------------------
    // MAX (signed)
    // -----------------------
    if (tr.ap.max) begin
      op_cnt++;
      if (!tr.ap.sub) begin
        error = 1;
        result = '0;
      end else begin
        result = ($signed(tr.a_in) > $signed(tr.b_in)) ?
                  tr.a_in : tr.b_in;
      end
    end

    // -----------------------
    // PACK
    // -----------------------
    if (tr.ap.pack) begin
      op_cnt++;
      result = {tr.b_in[15:0], tr.a_in[15:0]};
    end

    // -----------------------
    // GREV (byte reverse only, b[4:0]=24)
    // -----------------------
    if (tr.ap.grev) begin
      op_cnt++;
      if (tr.b_in[4:0] != 5'd24) begin
        error = 1;
        result = '0;
      end else begin
        result = { tr.a_in[7:0],
                   tr.a_in[15:8],
                   tr.a_in[23:16],
                   tr.a_in[31:24] };
      end
    end

    // -----------------------
    // Final guard
    // -----------------------
    if (op_cnt != 1) begin
      error = 1;
      result = '0;
    end

    tr.exp_result = result;
    tr.exp_error  = error;
  endfunction
endclass

`endif
