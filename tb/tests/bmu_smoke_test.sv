// tb/bmu_smoke_test.sv
`timescale 1ns/1ps

`ifndef BMU_SMOKE_TEST_SV
`define BMU_SMOKE_TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_sequencer.sv"
`include "bmu_driver.sv"
`include "bmu_bitmanip_seq.sv"

// ----------------------------------------------------------
// Simple smoke test: sequencer + driver only, no agent/env
// ----------------------------------------------------------
class bmu_smoke_test extends uvm_test;

  `uvm_component_utils(bmu_smoke_test)

  bmu_env       m_env;
  bmu_bitmanip_seq seq;

  function new(string name = "bmu_smoke_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_env = bmu_env::type_id::create("m_env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    seq = bmu_bitmanip_seq::type_id::create("seq");
 

    // Run sequence on agent sequencer
    seq.start(m_env.m_agent.m_sequencer);

    phase.drop_objection(this);
  endtask

endclass

`endif // BMU_SMOKE_TEST_SV
