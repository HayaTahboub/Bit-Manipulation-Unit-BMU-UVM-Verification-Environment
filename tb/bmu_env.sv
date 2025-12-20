// tb/bmu_env.sv
`timescale 1ns/1ps

`ifndef BMU_ENV_SV
`define BMU_ENV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_agent.sv"
`include "bmu_seq_item.sv"
`include "bmu_scoreboard.sv"

class bmu_env extends uvm_env;

  `uvm_component_utils(bmu_env)

  bmu_agent      m_agent;
  bmu_scoreboard m_scoreboard;
  bmu_coverage m_cov;

  function new(string name = "bmu_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agent      = bmu_agent     ::type_id::create("m_agent", this);
    m_scoreboard = bmu_scoreboard::type_id::create("m_scoreboard", this);
    m_cov   = bmu_coverage::type_id::create("m_cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Direct connection: Monitor -> Scoreboard
    m_agent.m_monitor.item_ap.connect(m_scoreboard.item_imp);
    m_agent.m_monitor.item_ap.connect(m_cov.analysis_export);
  endfunction

endclass : bmu_env

`endif // BMU_ENV_SV
