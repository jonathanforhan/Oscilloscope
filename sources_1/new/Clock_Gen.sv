`timescale 1ns / 1ps  //
`default_nettype none


/// Clock Generator
module Clock_Gen #(
    parameter int FREQ_IN  = 100_000_000,  // 100MHz
    parameter int FREQ_OUT = 25_175_000    // 25.175MHz
) (
    input  wire  clk_in,
    output logic clk_out
);
  localparam int TICKS = FREQ_IN / (FREQ_OUT * 2);

  logic [31:0] i;
  initial i = 0;

  always_ff @(posedge clk_in) begin
    if (i == TICKS) begin
      i <= 0;
      clk_out <= ~clk_out;
    end else begin
      i <= i + 1;
    end
  end
endmodule
