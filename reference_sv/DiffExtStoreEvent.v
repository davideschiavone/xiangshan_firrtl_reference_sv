
`ifndef SYNTHESIS
`ifdef DIFFTEST
`include "DifftestMacros.svh"
`endif // DIFFTEST
`endif // SYNTHESIS
module DiffExtStoreEvent(
  input         clock,
  input         enable,
  input         io_valid,
  input  [63:0] io_addr,
  input  [63:0] io_data,
  input  [63:0] io_highData,
  input  [15:0] io_mask,
  input         io_wLine,
  input         io_vecNeedSplit,
  input  [ 7:0] io_eew,
  input  [15:0] io_offset,
  input  [63:0] io_pc,
  input  [ 9:0] io_robidx,
  input  [ 7:0] io_coreid,
  input  [ 7:0] io_index
);
  wire _dummy_unused = 1'b1;
`ifndef SYNTHESIS
`ifdef DIFFTEST
`ifndef CONFIG_DIFFTEST_FPGA

import "DPI-C" function void v_difftest_StoreEvent (
  input   longint io_addr,
  input   longint io_data,
  input   longint io_highData,
  input  shortint io_mask,
  input       bit io_wLine,
  input       bit io_vecNeedSplit,
  input      byte io_eew,
  input  shortint io_offset,
  input   longint io_pc,
  input  shortint io_robidx,
  input      byte io_coreid,
  input      byte io_index
);


  always @(posedge clock) begin
    if (enable)
      v_difftest_StoreEvent (io_addr, io_data, io_highData, io_mask, io_wLine, io_vecNeedSplit, io_eew, io_offset, io_pc, io_robidx, io_coreid, io_index);
  end
`endif // CONFIG_DIFFTEST_FPGA
`endif // DIFFTEST
`endif // SYNTHESIS
endmodule