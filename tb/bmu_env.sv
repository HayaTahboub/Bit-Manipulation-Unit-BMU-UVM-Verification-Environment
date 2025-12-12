// tb/bmu_env.sv
`timescale 1ns/1ps

`ifndef BMU_ENV_SV
`define BMU_ENV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_agent.sv"
`include "bmu_seq_item.sv"

// ----------------------------------------------------------
// BMU Environment
// - Contains BMU Agent
// - Exposes analysis_port for future scoreboard/coverage
// ----------------------------------------------------------
class bmu_env extends uvm_env;

  `uvm_component_utils(bmu_env)

  // Agent instance
  bmu_agent m_agent;

  // Analysis port (will be connected to scoreboard later)
  uvm_analysis_port #(bmu_seq_item) item_ap;

  // Constructor
  function new(string name = "bmu_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase: create agent and analysis port
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_agent = bmu_agent::type_id::create("m_agent", this);
    item_ap = new("item_ap", this);
  endfunction

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect monitor's analysis_port directly to env's analysis_port
    m_agent.m_monitor.item_ap.connect(item_ap);
  endfunction

endclass : bmu_env

`endif // BMU_ENV_SV
