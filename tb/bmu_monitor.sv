// tb/bmu_monitor.sv
`timescale 1ns/1ps

`ifndef BMU_MONITOR_SV
`define BMU_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_seq_item.sv"

class bmu_monitor extends uvm_component;

  `uvm_component_utils(bmu_monitor)

  virtual bmu_if.mon_mp vif;
  uvm_analysis_port #(bmu_seq_item) item_ap;

  localparam int unsigned LATENCY_CYCLES = 1;

  typedef struct {
    bmu_seq_item  tr;
    int unsigned  countdown;
  } pending_t;

  pending_t pending_q[$];

  function new(string name = "bmu_monitor", uvm_component parent = null);
    super.new(name, parent);
    item_ap = new("item_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual bmu_if.mon_mp)::get(this, "", "mon_vif", vif)) begin
      `uvm_fatal("NOVIF", "bmu_monitor: virtual interface 'mon_vif' not found")
    end
  endfunction

  task run_phase(uvm_phase phase);
    int i;  // ✅ تعريف المتغير في بداية البلوك (مهم جدًا)

    `uvm_info("BMU_MONITOR", "Monitor started", UVM_LOW)

    @(posedge vif.clk);
    wait (vif.rst_l == 1'b1);

    forever begin
      @(posedge vif.clk);
      #1ps;

      if (!vif.rst_l) begin
        pending_q.delete();
        continue;
      end

      // -------- Capture request --------
      if (vif.valid_in === 1'b1) begin
        pending_t p;

        p.tr = bmu_seq_item::type_id::create("tr", this);

        p.tr.scan_mode     = vif.scan_mode;
        p.tr.valid_in      = vif.valid_in;
        p.tr.ap            = vif.ap;
        p.tr.csr_ren_in    = vif.csr_ren_in;
        p.tr.csr_rddata_in = vif.csr_rddata_in;
        p.tr.a_in          = vif.a_in;
        p.tr.b_in          = vif.b_in;

        p.tr.exp_result = '0;
        p.tr.exp_error  = '0;

        p.countdown = LATENCY_CYCLES;
        pending_q.push_back(p);
      end

      // -------- Advance countdown --------
      for (i = 0; i < pending_q.size(); i++) begin
        if (pending_q[i].countdown > 0)
          pending_q[i].countdown--;
      end

      // -------- Retire ready transactions --------
      i = 0;
      while (i < pending_q.size()) begin
        if (pending_q[i].countdown == 0) begin
          pending_q[i].tr.act_result = vif.result_ff;
          pending_q[i].tr.act_error  = vif.error;
          item_ap.write(pending_q[i].tr);
          pending_q.delete(i);
        end
        else begin
          i++;
        end
      end
    end
  endtask

endclass : bmu_monitor

`endif
