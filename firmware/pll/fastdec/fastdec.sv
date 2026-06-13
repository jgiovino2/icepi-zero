module fastdec #( 
  parameter [3:0] SEED = 4'd0 
)
(
  input  logic       clk,
  input  logic       reset,
  output logic [3:0] nibble,
  output logic       borrow
);

  localparam bit [3:0] count_seed        = SEED;
  localparam bit       borrow_seed        = (SEED == 4'd0);
  localparam bit [3:0] prior_count_seed  = SEED + 4'd1;
  localparam bit       prior_borrow_seed  = (SEED == 4'd1);

  logic [3:0]  next_nibble;
  logic        next_borrow;

  initial begin
    next_nibble = count_seed;
    next_borrow = borrow_seed;
    nibble = prior_count_seed;
    borrow = prior_borrow_seed;
  end

  always_comb begin
    if (reset) begin
      next_nibble = count_seed;
      next_borrow = borrow_seed;
    end else begin
      next_nibble = nibble - 1'b1;
      next_borrow = (next_nibble == 4'b1111); 
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      nibble <= count_seed;
      borrow <= borrow_seed;
    end else begin
      nibble <= next_nibble;
      borrow <= next_borrow;
    end
  end

endmodule
