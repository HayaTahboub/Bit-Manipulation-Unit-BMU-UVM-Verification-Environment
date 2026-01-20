//============================================================
// tb/bmu_monitor.sv
// BMU UVM Monitor (Latency-aware, Xcelium-safe)
// - Captures request when valid_in==1
// - After LATENCY_CYCLES cycles, captures act_result/act_error
// - Sends complete transaction on analysis_port
//============================================================
`timescale 1ns/1ps

`ifndef BMU_MONITOR_SV
`define BMU_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_seq_item.sv"

class bmu_monitor extends uvm_monitor;

  `uvm_component_utils(bmu_monitor)

  // Virtual interface
  virtual bmu_if.mon_mp vif;

  // Analysis port to env/scoreboard/coverage
  uvm_analysis_port #(bmu_seq_item) item_ap;

  // If DUT produces response exactly 1 cycle after request -> set 1
  localparam int unsigned LATENCY_CYCLES = 1;

  typedef struct {
    bmu_seq_item  tr;
    int unsigned  cycles_left;
  } pending_t;

  pending_t pending_q[$];

  function new(string name="bmu_monitor", uvm_component parent=null);
    super.new(name, parent);
    item_ap = new("item_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual bmu_if.mon_mp)::get(this, "", "mon_vif", vif)) begin
      `uvm_fatal("NOVIF", "bmu_monitor: virtual interface 'mon_vif' not found")
    end
  endfunction

  // ----------------------------------------------------------
  // Helper: capture request fields into a new transaction
  // ----------------------------------------------------------
  function automatic bmu_seq_item capture_req();
    bmu_seq_item t;
    t = bmu_seq_item::type_id::create($sformatf("tr_%0t", $time), this);

    t.scan_mode     = vif.scan_mode;
    t.valid_in      = vif.valid_in;
    t.ap            = vif.ap;
    t.csr_ren_in    = vif.csr_ren_in;
    t.csr_rddata_in = vif.csr_rddata_in;
    t.a_in          = vif.a_in;
    t.b_in          = vif.b_in;

    return t;
  endfunction

  // ----------------------------------------------------------
  // Helper: capture response fields into an existing transaction
  // ----------------------------------------------------------
  function automatic void capture_rsp(ref bmu_seq_item t);
    t.act_result = vif.result_ff;
    t.act_error  = vif.error;
  endfunction

  task run_phase(uvm_phase phase);
    int i;

    `uvm_info("BMU_MONITOR", "Monitor started", UVM_LOW)

    // wait reset deassert
    @(posedge vif.clk);
    wait (vif.rst_l === 1'b1);

    forever begin
      @(posedge vif.clk);
      // إذا عندك clocking block بالمون_mp الأفضل تستخدمه بدل أي delay
      // #1ps;  // تجنّبها إذا بتسبب race عندك

      if (vif.rst_l !== 1'b1) begin
        pending_q.delete();
        continue;
      end

      // ------------------------------------------------------
      // 1) Decrement counters for already-pending transactions
      // ------------------------------------------------------
      for (i = 0; i < pending_q.size(); i++) begin
        if (pending_q[i].cycles_left > 0)
          pending_q[i].cycles_left--;
      end

      // ------------------------------------------------------
      // 2) Retire ready transactions (cycles_left == 0)
      // ------------------------------------------------------
      i = 0;
      while (i < pending_q.size()) begin
        if (pending_q[i].cycles_left == 0) begin
          capture_rsp(pending_q[i].tr);
          item_ap.write(pending_q[i].tr);
          pending_q.delete(i);
        end
        else begin
          i++;
        end
      end

      // ------------------------------------------------------
      // 3) Capture new request LAST (prevents same-cycle retire)
      // ------------------------------------------------------
      if (vif.valid_in === 1'b1) begin
        pending_t p;
        p.tr = capture_req();
        p.cycles_left = LATENCY_CYCLES; // exact latency in cycles
        pending_q.push_back(p);
      end

    end
  endtask

endclass : bmu_monitor

`endif // BMU_MONITOR_SV
