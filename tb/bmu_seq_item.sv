`timescale 1ns/1ps

`ifndef BMU_SEQ_ITEM_SV
`define BMU_SEQ_ITEM_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

class bmu_seq_item extends uvm_sequence_item;

  // ---------------- DUT Inputs ----------------
  rand bit                scan_mode;
  rand bit                valid_in;
  rand rtl_alu_pkt_t      ap;              
  rand bit                csr_ren_in;
  rand bit [31:0]         csr_rddata_in;
  rand bit signed [31:0]  a_in;
  rand bit [31:0]         b_in;

  // ---------------- DUT Outputs (Expected) ----------------
  bit [31:0] exp_result;
  bit        exp_error;
  // ---------------- Actual DUT Outputs (captured by monitor) ----------------
  bit [31:0] act_result;
  bit        act_error;


  // ---------------- Registration ----------------
  `uvm_object_utils_begin(bmu_seq_item)
    `uvm_field_int(scan_mode     , UVM_ALL_ON)
    `uvm_field_int(valid_in      , UVM_ALL_ON)
    `uvm_field_int(csr_ren_in    , UVM_ALL_ON)
    `uvm_field_int(csr_rddata_in , UVM_ALL_ON)
    `uvm_field_int(a_in          , UVM_ALL_ON)
    `uvm_field_int(b_in          , UVM_ALL_ON)
    `uvm_field_int(exp_result    , UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_int(exp_error     , UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_int(act_result   , UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_int(act_error    , UVM_ALL_ON | UVM_NOPRINT)
  `uvm_object_utils_end

  function new(string name = "bmu_seq_item");
    super.new(name);
  endfunction

endclass : bmu_seq_item

`endif
