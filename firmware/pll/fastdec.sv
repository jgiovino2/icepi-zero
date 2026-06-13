// Minimal fastdec implementation (single 4-bit stage)
// If you already have fastdec in a file, skip this file or replace module name accordingly.
module fastdec #( parameter bit [3:0] SEED = 4'd0 )
(
  input  logic       clk,
  input  logic       dec,
  input  logic       reset,
  output logic [3:0] nibble = SEED,
  output logic       carry
);

  logic [3:0] next_nibble;
  logic       next_carry;


  // get a jump on the calculations
  always_comb begin
    next_nibble = nibble;
    next_carry  = 1'b0;

    //if (reset) begin
      //next_nibble <= SEED;
      //next_carry  <= (SEED == 4'd1); // this is slow
    //end else if (dec) begin
    if (dec) begin
      next_nibble = nibble - 4'd1;
      next_carry  = (nibble == 4'd1);
    end
  end
  //always_ff @(posedge clk) begin
    //next_nibble <= nibble;
    //next_carry  <= 1'b0;
    //if (dec) begin
      //next_nibble <= nibble - 4'd1;
      //next_carry <= (nibble == 4'd2);
    //end
  //end

  always_ff @(posedge clk) begin
    if (reset) begin
      nibble <= SEED;
      carry  <= (SEED == 4'd1); // this is slow
    end else begin
      carry  <= 1'b0;
      nibble <= next_nibble;
      if (next_carry)
        carry <= 1'b1; //carry <= next_carry; // somhow this is slow
    end
  end

  //always_ff @(posedge clk) begin
    //if (reset) begin
      //nibble <= SEED;
      //carry  <= (SEED == 4'd1);
    //end else begin
      //carry  <= 1'b0;
      //nibble <= nibble - 4'd1;
      //if (nibble == 1)
        //carry <= 1'b1;
    //end
  //end

endmodule
