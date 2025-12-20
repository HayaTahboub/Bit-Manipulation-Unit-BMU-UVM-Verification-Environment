`timescale 1ns/1ps

`ifndef BMU_SCOREBOARD_SV
`define BMU_SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_seq_item.sv"


class bmu_scoreboard extends uvm_component;

  `uvm_component_utils(bmu_scoreboard)

  uvm_analysis_imp #(bmu_seq_item, bmu_scoreboard) item_imp;
  bmu_ref_model refm;

  int unsigned num_checked;
  int unsigned num_failed;

  function new(string name="bmu_scoreboard", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_imp = new("item_imp", this);
    refm     = bmu_ref_model::type_id::create("refm");
    num_checked = 0;
    num_failed  = 0;
  endfunction

  function void write(bmu_seq_item tr);

    refm.compute(tr);
    num_checked++;

    if ((tr.act_result !== tr.exp_result) ||
        (tr.act_error  !== tr.exp_error)) begin

      num_failed++;

      `uvm_error(
        "BMU_SB_MISMATCH",
        $sformatf(
          "Mismatch: a=0x%08h b=0x%08h valid=%0b act_res=0x%08h exp_res=0x%08h act_err=%0b exp_err=%0b ap=%p",
          tr.a_in, tr.b_in, tr.valid_in,
          tr.act_result, tr.exp_result,
          tr.act_error, tr.exp_error,
          tr.ap
        )
      )
    end
    else begin
      `uvm_info(
        "BMU_SB_MATCH",
        $sformatf("Match: result=0x%08h error=%0b",
                  tr.act_result, tr.act_error),
        UVM_LOW
      )
    end

  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(
      "BMU_SB_SUMMARY",
      $sformatf("Scoreboard summary: checked=%0d failed=%0d",
                num_checked, num_failed),
      UVM_NONE
    )
  endfunction

endclass

`endif
