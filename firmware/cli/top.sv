module top(
	input        clk,
	input        usb_rx,

	output       usb_tx,
	output [2:0] led
);
	logic [7:0] data_in;
	logic [7:0] data_out;


  // added notion of output enable pin and enable pin to conform to 
  // HW wiring of physical device
  // both virtual pins are edge triggers or single clock pulses
  logic putc_en;
  logic putc_oe;
  putc TX (clk, putc_en, data_out, putc_oe, usb_tx);

  logic getc_oe;
  getc RX (clk, usb_rx, getc_oe, data_in);

  //logic puts_en;
  //logic puts_oe;
  //logic [7:0] puts_len;
  //logic [
  //puts PUTS (clock, 

  cli CLI (clk, getc_oe, data_in, putc_oe, putc_en, data_out);

	// Indicator leds
	assign led[0] = rx_finish;
	assign led[1] = ~usb_rx;
	assign led[2] = ~usb_tx;
endmodule

