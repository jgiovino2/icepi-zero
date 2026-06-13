module fastdec_32 #( parameter [31:0] SEED_32 = 32'd399999999 )
(
  input  logic        clk,
  input  logic        reset,
  output wire [31:0]  register
  //output logic borrow
);

  logic [7:0] _borrow;

  // Stage 0
  fastdec #(.SEED(SEED_32[3:0])) stage_0 (
    .clk(clk), .reset(reset),
    .nibble(register[3:0]), .borrow(_borrow[0])
  );

  // Stage 1
  fastdec #(.SEED(SEED_32[7:4])) stage_1 (
    .clk(_borrow[0]), .reset(reset),
    .nibble(register[7:4]), .borrow(_borrow[1])
  );

  // Stage 2
  fastdec #(.SEED(SEED_32[11:8])) stage_2 (
    .clk(_borrow[1]), .reset(reset),
    .nibble(register[11:8]), .borrow(_borrow[2])
  );

  // Stage 3
  fastdec #(.SEED(SEED_32[15:12])) stage_3 (
    .clk(_borrow[2]), .reset(reset),
    .nibble(register[15:12]), .borrow(_borrow[3])
  );

  // Stage 4
  fastdec #(.SEED(SEED_32[19:16])) stage_4 (
    .clk(_borrow[3]), .reset(reset),
    .nibble(register[19:16]), .borrow(_borrow[4])
  );

  // Stage 5
  fastdec #(.SEED(SEED_32[23:20])) stage_5 (
    .clk(_borrow[4]), .reset(reset),
    .nibble(register[23:20]), .borrow(_borrow[5])
  );

  // Stage 6
  fastdec #(.SEED(SEED_32[27:24])) stage_6 (
    .clk(_borrow[5]), .reset(reset),
    .nibble(register[27:24]), .borrow(_borrow[6])
  );

  // Stage 7
  fastdec #(.SEED(SEED_32[31:28])) stage_7 (
    .clk(_borrow[6]), .reset(reset),
    .nibble(register[31:28]), .borrow(borrow)
  );



endmodule
