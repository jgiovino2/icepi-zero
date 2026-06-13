module fastdec_32 #( parameter bit [31:0] SEED_32 = 32'd399999999 )
(
  input  logic        clk,
  input  logic        dec,
  input  logic        reset,
  output wire [31:0]  register
);

  // Packed interconnect for better Yosys synthesis
  logic [31:0] stage_out_flat;
  logic [7:0]  carry_chain;

  // Stage 0: Decrements immediately on the global 'dec'
  fastdec #(.SEED(SEED_32[3:0])) stage_0_dec (
    .clk(clk), .dec(dec), .reset(reset),
    .nibble(stage_out_flat[3:0]), .carry(carry_chain[0])
  );

  // Stages 1-7: Pipelined borrow chain
  fastdec #(.SEED(SEED_32[7:4])) stage_1_dec (
    .clk(clk), .dec(carry_chain[0]), .reset(reset),
    .nibble(stage_out_flat[7:4]), .carry(carry_chain[1])
  );

  fastdec #(.SEED(SEED_32[11:8])) stage_2_dec (
    .clk(clk), .dec(carry_chain[1]), .reset(reset),
    .nibble(stage_out_flat[11:8]), .carry(carry_chain[2])
  );

  fastdec #(.SEED(SEED_32[15:12])) stage_3_dec (
    .clk(clk), .dec(carry_chain[2]), .reset(reset),
    .nibble(stage_out_flat[15:12]), .carry(carry_chain[3])
  );

  fastdec #(.SEED(SEED_32[19:16])) stage_4_dec (
    .clk(clk), .dec(carry_chain[3]), .reset(reset),
    .nibble(stage_out_flat[19:16]), .carry(carry_chain[4])
  );

  fastdec #(.SEED(SEED_32[23:20])) stage_5_dec (
    .clk(clk), .dec(carry_chain[4]), .reset(reset),
    .nibble(stage_out_flat[23:20]), .carry(carry_chain[5])
  );

  fastdec #(.SEED(SEED_32[27:24])) stage_6_dec (
    .clk(clk), .dec(carry_chain[5]), .reset(reset),
    .nibble(stage_out_flat[27:24]), .carry(carry_chain[6])
  );

  fastdec #(.SEED(SEED_32[31:28])) stage_7_dec (
    .clk(clk), .dec(carry_chain[6]), .reset(reset),
    .nibble(stage_out_flat[31:28]), .carry(carry_chain[7])
  );

  // Directly drive output from packed stage vector
  assign register = stage_out_flat;

endmodule
