// tb/bmu_agent.sv
`timescale 1ns/1ps

`ifndef BMU_AGENT_SV
`define BMU_AGENT_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_seq_item.sv"
`include "bmu_sequencer.sv"
`include "bmu_driver.sv"
`include "bmu_monitor.sv"

// ----------------------------------------------------------
// BMU Agent
// - Groups sequencer, driver, and monitor
// - For now, env will access monitor.item_ap directly
// ----------------------------------------------------------
class bmu_agent extends uvm_agent;

  // Factory registration (including is_active field)
  `uvm_component_utils_begin(bmu_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
  `uvm_component_utils_end

  // Active/passive mode (default: active)
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  // Subcomponents
  bmu_sequencer m_sequencer;
  bmu_driver    m_driver;
  bmu_monitor   m_monitor;

  // Constructor
  function new(string name = "bmu_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase: create subcomponents
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Monitor is created in all modes (active/passive)
    m_monitor = bmu_monitor::type_id::create("m_monitor", this);

    // Driver + sequencer only in active mode
    if (is_active == UVM_ACTIVE) begin
      m_sequencer = bmu_sequencer::type_id::create("m_sequencer", this);
      m_driver    = bmu_driver   ::type_id::create("m_driver"   , this);
    end
  endfunction

  // Connect phase: hook up TLM connections
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect driver <-> sequencer in active mode
    if (is_active == UVM_ACTIVE) begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end

    // No analysis_export here; env will connect directly to m_monitor.item_ap
  endfunction

endclass : bmu_agent

`endif // BMU_AGENT_SV
