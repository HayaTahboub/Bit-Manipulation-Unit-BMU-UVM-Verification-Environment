// tb/bmu_sequencer.sv
`timescale 1ns/1ps

`ifndef BMU_SEQUENCER_SV
`define BMU_SEQUENCER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;
`include "bmu_seq_item.sv"

// ----------------------------------------------------
// BMU Sequencer
// مسؤول عن إعطاء الترانزاكشنز للـ driver
// ----------------------------------------------------
class bmu_sequencer extends uvm_sequencer #(bmu_seq_item);

  // ---- Factory Registration ----
  `uvm_component_utils(bmu_sequencer)

  // ---- Constructor ----
  function new(string name = "bmu_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass : bmu_sequencer

`endif // BMU_SEQUENCER_SV
