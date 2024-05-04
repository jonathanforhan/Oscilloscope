`timescale 1ns / 1ps  //
`default_nettype none


/// Variable Frequency Clock Generator
module Clock_Var_Gen #(
    parameter int FREQ_IN = 100_000_000  // 100MHz
) (
    input wire clk_in,
    input wire rst,
    input wire [31:0] freq,
    output logic clk_out
);
  logic [31:0] i = 0;

  always_ff @(posedge clk_in, posedge rst) begin
    if (rst) begin
      i <= 0;
    end else begin
      if (i >= FREQ_IN / (freq * 2)) begin
        i <= 0;
        clk_out <= ~clk_out;
      end else begin
        i <= i + 1;
      end
    end
  end
endmodule
