module top(
	input        clk,
	input        usb_rx,

	output       usb_tx,
	output [2:0] led
);
	logic [7:0] data_in;
	logic [7:0] data_out;

  logic [31:0] count;


  // added notion of output enable pin and enable pin to conform to 
  // HW wiring of physical device
  // both virtual pins are edge triggers or single clock pulses
  logic putc_en;
  logic putc_oe;
  putc TX (clk, putc_en, data_out, putc_oe, usb_tx);

  logic getc_oe;
  getc RX (clk, usb_rx, getc_oe, data_in);


  buffer[] = "some string"
  logic puts_en;
  logic puts_oe;
  logic puts_ptr;
  logic [15:0] puts_len;
  puts PUTS (clk, puts_en, puts_ptr, puts_len, puts_oe, putc);

 
  always @(posedge clk) begin

   // dump beffer every 2 seconds
   if (count == 100000000) begin
     // puts ok te enable
     if (puts_oe == 0) begin
       puts_ptr <= buffer;
       puts_len <= 5
       puts_en <= 1; // trigger puts module on next clock
     else begin
       // waiting for puts module to finish
       puts_en <= 0;
     end
   else begin
     count <= count +1;
   end
  end





	// Indicator leds
	assign led[0] = rx_finish;
	assign led[1] = ~usb_rx;
	assign led[2] = ~usb_tx;
endmodule

