`timescale 1ns/1ps

module tb_top;
  logic        clk;
  wire [31:0]  register;
  logic        reset = 0;

  // Instantiate the actual hardware TOP module under test
  top uut (
    .clk(clk),
    .reset(reset),
    .register(register)
  );

  // Continuous Clock Generation: 100 MHz (10 ns period)
  initial clk = 0;
  always #5 clk = ~clk;


  // Simulation Stimulus Lifecycle
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_top); 
    
    // Assert reset condition
    reset = 1;
    repeat (4) @(posedge clk);
    
    // Release reset to start counting down automatically
    reset = 0;
    
    // Wait until the hardware top register drops to zero
    wait (register == 32'd0);
    
    // Allow padding cycles to view post-zero stability in GTKWave
    repeat (100) @(posedge clk);
    
    $display("SUCCESS: Reached zero at time %0t", $time);
    $finish;
  end

endmodule
