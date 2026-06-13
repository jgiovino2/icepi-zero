`timescale 1ns/1ps

module top (
  input  logic        clk,
  input  logic        reset,
  output wire [31:0]  register
);

  //logic borrow;

  // Instantiate your synchronous 32-bit counter core
  // This serves as the top-level wire mapping for your hardware pins
  fastdec_32 #(.SEED_32(32'd1000)) hardware_counter (
    .clk(clk),
    .reset(reset),
    .register(register)
    //borrow
  );

  //always_ff (@posedge clk) begin
    //if borrow begin
      //reset <= 1;
    //end
  //end

endmodule
