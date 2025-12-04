`timescale 1ns/1ps

`ifndef BMU_DRIVER_SV
`define BMU_DRIVER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;
`include "bmu_seq_item.sv"

class bmu_driver extends uvm_driver #(bmu_seq_item);

  // ---------------- Virtual Interface ----------------
  virtual bmu_if.drv_mp vif;

  // ---------------- Driver Component ----------------
  `uvm_component_utils(bmu_driver)

  // ---------------- Constructor ----------------
  function new(string name = "bmu_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // ---------------- Build Phase ----------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual bmu_if.drv_mp)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "bmu_driver: virtual interface not found")
    end
  endfunction

  // ---------------- Run Phase ----------------
  task run_phase(uvm_phase phase);
    bmu_seq_item req;

    // Ensure interface is initialized
    @(posedge vif.clk);
    wait (vif.rst_l == 1);

    forever begin
      seq_item_port.get_next_item(req);
      drive_one_item(req);
      seq_item_port.item_done();
    end
  endtask

  // ---------------- Drive One Transaction ----------------
  task drive_one_item(bmu_seq_item req);

    @(posedge vif.clk);

    vif.scan_mode     <= req.scan_mode;
    vif.valid_in      <= req.valid_in;
    vif.csr_ren_in    <= req.csr_ren_in;
    vif.csr_rddata_in <= req.csr_rddata_in;
    vif.a_in          <= req.a_in;
    vif.b_in          <= req.b_in;
    vif.ap            <= req.ap;

    @(posedge vif.clk);  // 1-cycle latency
  endtask

endclass : bmu_driver

`endif
