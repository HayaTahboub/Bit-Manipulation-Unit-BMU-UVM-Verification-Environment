// tb/bmu_base_seq.sv
`timescale 1ns/1ps

`ifndef BMU_BASE_SEQ_SV
`define BMU_BASE_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_seq_item.sv"

// Base Sequence for BMU

class bmu_base_seq extends uvm_sequence #(bmu_seq_item);

  // Factory registration
  `uvm_object_utils(bmu_base_seq)

  // Constructor
  function new(string name = "bmu_base_seq");
    super.new(name);
  endfunction


  virtual task pre_randomize_hook();
  endtask

  virtual task post_randomize_hook(bmu_seq_item req);
  endtask

  // --------------------------------------------------------
  // BODY(): standard UVM sequence logic
  // --------------------------------------------------------
  virtual task body();
    bmu_seq_item req;

    // Create item
    req = bmu_seq_item::type_id::create("req");

    // Allow derived sequences to override behavior before randomization
    pre_randomize_hook();

    // Randomize seq_item
    if (!req.randomize()) begin
      `uvm_error("RANDFAIL", "bmu_base_seq: Failed to randomize sequence item")
      return;
    end

    // Callback for derived sequences to compute expected values, etc.
    post_randomize_hook(req);

    // Send item to sequencer/driver
    start_item(req);
    finish_item(req);

    `uvm_info("BMU_BASE_SEQ", "One BMU transaction executed", UVM_LOW)
  endtask

endclass : bmu_base_seq

`endif // BMU_BASE_SEQ_SV
