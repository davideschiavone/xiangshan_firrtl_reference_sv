
module TopdownIQInfoHelper_80 #(
  parameter integer ENTRY_NUM = 1,
  parameter integer INFO_WIDTH = 72,
  parameter integer OUT_WIDTH = 8
) (
  input                         clock,
  input  [5759:0] in,
  output reg [639:0] out
);

  wire _unused_clock = clock;
  reg [ENTRY_NUM*OUT_WIDTH-1:0] dpi_out;

`ifndef SYNTHESIS
  import "DPI-C" function void topdown_iq_info_dpic_80(
    input  int unsigned entries_num,
    input  bit [ENTRY_NUM*INFO_WIDTH-1:0] in,
    output bit [ENTRY_NUM*OUT_WIDTH-1:0] out
  );
`endif // SYNTHESIS

  always @(*) begin
    /* verilator lint_off WIDTHCONCAT */
    out = '0;
    dpi_out = '0;
    /* verilator lint_on WIDTHCONCAT */
`ifndef SYNTHESIS
    topdown_iq_info_dpic_80(
      ENTRY_NUM,
      in[ENTRY_NUM*INFO_WIDTH-1:0],
      dpi_out
    );
`endif // SYNTHESIS
    out[ENTRY_NUM*OUT_WIDTH-1:0] = dpi_out;
  end

endmodule

