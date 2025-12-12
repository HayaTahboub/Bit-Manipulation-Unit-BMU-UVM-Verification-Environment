// tb/bmu_smoke_seq.sv
`timescale 1ns/1ps

`ifndef BMU_SMOKE_SEQ_SV
`define BMU_SMOKE_SEQ_SV

import uvm_pkg::*;
`include "uvm_macros.svh"
import rtl_pkg::*;

`include "bmu_seq_item.sv"
`include "bmu_base_seq.sv"

// ----------------------------------------------------------
// Simple smoke sequence to exercise the basic UVM plumbing
// ----------------------------------------------------------
class bmu_smoke_seq extends bmu_base_seq;

  `uvm_object_utils(bmu_smoke_seq)

  function new(string name = "bmu_smoke_seq");
    super.new(name);
  endfunction

  // نعمل override للـ body عشان نبعث أكثر من ترانزاكشن
  virtual task body();
    bmu_seq_item req;
    int i;

    `uvm_info("BMU_SMOKE_SEQ", "Starting BMU smoke sequence", UVM_LOW)

    // نرسل مثلاً 10 ترانزاكشنز بسيطة
    for (i = 0; i < 10; i++) begin
      req = bmu_seq_item::type_id::create($sformatf("req_%0d", i));

      // Randomize مع شوية constraints بسيطة
      if (!req.randomize() with {
            valid_in   == 1;
            csr_ren_in == 0;
          }) begin
        `uvm_error("SMOKE_RAND", $sformatf("Randomization failed for item %0d", i))
        continue;
      end

      start_item(req);
      finish_item(req);

      `uvm_info("BMU_SMOKE_SEQ",
                $sformatf("Sent smoke transaction %0d: a=0x%08h b=0x%08h valid=%0b",
                          i, req.a_in, req.b_in, req.valid_in),
                UVM_MEDIUM)
    end

    `uvm_info("BMU_SMOKE_SEQ", "Finished BMU smoke sequence", UVM_LOW)
  endtask

endclass : bmu_smoke_seq

`endif // BMU_SMOKE_SEQ_SV
