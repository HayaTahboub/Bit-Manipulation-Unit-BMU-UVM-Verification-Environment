`timescale 1ns/1ps

`ifndef BMU_DRIVER_SV
`define BMU_DRIVER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;
`include "bmu_seq_item.sv"

class bmu_driver extends uvm_driver #(bmu_seq_item);

  // Virtual interface
  virtual bmu_if.drv_mp vif;

  `uvm_component_utils(bmu_driver)

  function new(string name = "bmu_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual bmu_if.drv_mp)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "bmu_driver: virtual interface not found")
    end
  endfunction

  task run_phase(uvm_phase phase);
    bmu_seq_item req;

    // Wait for reset deassertion
    @(posedge vif.clk);
    wait (vif.rst_l == 1);
    repeat (2) @(negedge vif.clk);
    // Drive known idle values to avoid X propagation
    vif.scan_mode     <= 1'b0;
    vif.valid_in      <= 1'b0;
    vif.csr_ren_in    <= 1'b0;
    vif.csr_rddata_in <= '0;
    vif.a_in          <= '0;
    vif.b_in          <= '0;
    vif.ap            <= '0;

    forever begin
      seq_item_port.get_next_item(req);
      drive_one_item(req);
      seq_item_port.item_done();
    end
  endtask

  // Drive a single transaction:
  // - Drive data/control first
  // - Assert valid for one cycle
  // - Deassert valid on the next cycle
task drive_one_item(bmu_seq_item req);

  // Drive inputs before the sampling posedge
  @(negedge vif.clk);

  // Drive data/control
  vif.scan_mode     <= req.scan_mode;
  vif.csr_ren_in    <= req.csr_ren_in;
  vif.csr_rddata_in <= req.csr_rddata_in;
  vif.a_in          <= req.a_in;
  vif.b_in          <= req.b_in;
  vif.ap            <= req.ap;

  // Assert valid for a full cycle
  vif.valid_in      <= 1'b1;

  // Keep it asserted across the next posedge (DUT samples here)
  @(posedge vif.clk);

  // Deassert on the next negedge (safe for monitor sampling)
  @(negedge vif.clk);
  vif.valid_in      <= 1'b0;

endtask




endclass : bmu_driver

`endif
