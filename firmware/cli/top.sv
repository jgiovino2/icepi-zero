module top(
	input        clk,
	input        usb_rx,

	output       usb_tx,
	output [2:0] led
);
	logic       rx_finish;
	logic       send;
	logic       sent;
	logic [7:0] data_in;
	logic [7:0] data_out;

  uart_rx RX (clk, usb_rx, rx_finish, data_in);
  uart_tx TX (clk, send, data_out, sent, usb_tx);
  //putc PUTC (clk, send, data_out, sent, usb_tx);
  cli CLI (clk, rx_finish, data_in, sent, send, data_out);

	// Indicator leds
	assign led[0] = rx_finish;
	assign led[1] = ~usb_rx;
	assign led[2] = ~usb_tx;
endmodule

