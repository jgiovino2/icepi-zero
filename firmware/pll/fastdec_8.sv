module fastdec_8 #( parameter bit [7:0] SEED_8 = 8'd19 )
(
  input  logic        clk,
  input  logic        dec,
  input  logic        reset,
  output wire [7:0]  register
);

  // Packed interconnect for better Yosys synthesis
  logic [7:0] stage_out_flat;
  logic [1:0]  carry_chain;

  // Stage 0: Decrements immediately on the global 'dec'
  fastdec #(.SEED(SEED_8[3:0])) stage_0_dec (
    .clk(clk), .dec(dec), .reset(reset),
    .nibble(stage_out_flat[3:0]), .carry(carry_chain[0])
  );

  // Stages 1-7: Pipelined borrow chain
  fastdec #(.SEED(SEED_8[7:4])) stage_1_dec (
    .clk(clk), .dec(carry_chain[0]), .reset(reset),
    .nibble(stage_out_flat[7:4]), .carry(carry_chain[1])
  );

  // Directly drive output from packed stage vector
  assign register = stage_out_flat;

endmodule
