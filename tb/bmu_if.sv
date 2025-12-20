// tb/bmu_if.sv
`timescale 1ns/1ps

import rtl_pkg::*; 

interface bmu_if (input logic clk, input logic rst_l);

  // -------- DUT inputs --------
  logic                scan_mode;       // Scan control
  logic                valid_in;        // Valid
  rtl_alu_pkt_t        ap;             // predecodes 
  logic                csr_ren_in;      // CSR select
  logic         [31:0] csr_rddata_in;   // CSR data
  logic signed  [31:0] a_in;            // A operand
  logic signed [31:0] b_in;            // B operand

  // -------- DUT outputs --------
  logic [31:0] result_ff;  // final result
  logic        error;

  // -------- Driver modport --------
  modport drv_mp (
    input  clk, rst_l,
    output scan_mode,
           valid_in,
           ap,
           csr_ren_in,
           csr_rddata_in,
           a_in,
           b_in,
    input  result_ff,
           error
  );

  // -------- Monitor modport --------
  modport mon_mp (
    input clk, rst_l,
          scan_mode,
          valid_in,
          ap,
          csr_ren_in,
          csr_rddata_in,
          a_in,
          b_in,
          result_ff,
          error
  );

endinterface
