
module TopdownRobInfoHelper_288_48 #(
  parameter integer IQ_ENTRY_NUM = 1,
  parameter integer ROB_ENTRY_NUM = 1,
  parameter integer INFO_WIDTH = 56
) (
  input  [16127:0] in,
  output reg [2687:0] out
);

  reg [ROB_ENTRY_NUM*INFO_WIDTH-1:0] dpi_out;

`ifndef SYNTHESIS
  import "DPI-C" function void topdown_rob_info_dpic_288_48(
    input  int unsigned iq_entries_num,
    input  int unsigned rob_entries_num,
    input  bit [IQ_ENTRY_NUM*INFO_WIDTH-1:0] in,
    output bit [ROB_ENTRY_NUM*INFO_WIDTH-1:0] out
  );
`endif // SYNTHESIS

  always @(*) begin
    /* verilator lint_off WIDTHCONCAT */
    out = '0;
    dpi_out = '0;
    /* verilator lint_on WIDTHCONCAT */
`ifndef SYNTHESIS
    topdown_rob_info_dpic_288_48(
      IQ_ENTRY_NUM,
      ROB_ENTRY_NUM,
      in[IQ_ENTRY_NUM*INFO_WIDTH-1:0],
      dpi_out
    );
`endif // SYNTHESIS
    out[ROB_ENTRY_NUM*INFO_WIDTH-1:0] = dpi_out;
  end

endmodule

