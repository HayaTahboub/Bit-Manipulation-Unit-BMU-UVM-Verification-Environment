// tb/bmu_monitor.sv
`timescale 1ns/1ps

`ifndef BMU_MONITOR_SV
`define BMU_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_seq_item.sv"

// BMU Monitor
class bmu_monitor extends uvm_component;

  `uvm_component_utils(bmu_monitor)

  // Virtual interface (monitor modport)
  virtual bmu_if.mon_mp vif;

  // Analysis port لتصدير الترانزاكشنز
  uvm_analysis_port #(bmu_seq_item) item_ap;

  // Constructor
  function new(string name = "bmu_monitor", uvm_component parent = null);
    super.new(name, parent);
    item_ap = new("item_ap", this);
  endfunction

  // Build phase: احصل على الـ vif من ال config_db
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual bmu_if.mon_mp)::get(this, "", "mon_vif", vif)) begin
      `uvm_fatal("NOVIF", "bmu_monitor: virtual interface 'mon_vif' not found")
    end
  endfunction

  // Run phase: راقب الإشارات وصدّر الترانزاكشنز
  task run_phase(uvm_phase phase);
    bmu_seq_item tr;

    // انتظر خروج الـ DUT من reset
    @(posedge vif.clk);
    wait (vif.rst_l == 1);

    `uvm_info("BMU_MONITOR", "Monitor started sampling transactions", UVM_LOW)

    forever begin
      @(posedge vif.clk);

      if (vif.rst_l && vif.valid_in) begin
        tr = bmu_seq_item::type_id::create("tr", this);

        // تعبئة حقول الترانزاكشن من الإشارات
        tr.scan_mode     = vif.scan_mode;
        tr.valid_in      = vif.valid_in;
        tr.ap            = vif.ap;
        tr.csr_ren_in    = vif.csr_ren_in;
        tr.csr_rddata_in = vif.csr_rddata_in;
        tr.a_in          = vif.a_in;
        tr.b_in          = vif.b_in;


        tr.exp_result    = '0;
        tr.exp_error     = '0;

        // إرسال الترانزاكشن للـ scoreboard/coverage
        item_ap.write(tr);

        `uvm_info("BMU_MONITOR",
                  $sformatf("Sampled BMU transaction: a=0x%08h b=0x%08h valid=%0b",
                            tr.a_in, tr.b_in, tr.valid_in),
                  UVM_HIGH)
      end
    end
  endtask

endclass : bmu_monitor

`endif // BMU_MONITOR_SV
