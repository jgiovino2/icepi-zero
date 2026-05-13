module uart_rx #(
	parameter CLK = 50000000,
	parameter BAUD_RATE = 115200,
	parameter BITS = 8
) (
	input                   clk,
	input                   rx,
	output logic            finish,
	output logic [BITS-1:0] data,
);
	localparam CLK_DIVISOR = CLK / BAUD_RATE;

	logic [$clog2(CLK_DIVISOR):0] clkd;
	logic [$clog2(BITS)-1:0]      index;

	enum {IDLE, START, TRANSMISSION, STOP} state;

	initial begin
		finish = 1'b0;
		data = 0;
		clkd = 0;
		index = 0;
		state = IDLE;
	end

	always @(posedge clk) begin
		case (state)
		IDLE: begin
			clkd <= 0;
			index <= 0;
			finish <= 1'b0;

      // we wait in side the IDLE state until we get the first start bit
      // meaning rx must be high all the time untill driven low;
			if (rx == 1'b0) begin
				state <= START;
			end
		end
		START: begin
			// Test at middle of clk cycle
			if (clkd == (CLK_DIVISOR-1)/2) begin
				clkd <= 0;

        // this is the instance of the second start bit expected to be low
        // still one baud later
				if (rx == 1'b0) begin
					state <= TRANSMISSION;
				end else begin
					state <= IDLE; // otherwise we try again
				end
			end else begin
        // at first we wait one full baud before testing
        // usb_rx pin from fdti again
				clkd <= clkd + 1;
			end
		end
		TRANSMISSION: begin
      // wait one full baud before sampling
			if (clkd < CLK_DIVISOR-1) begin
				clkd <= clkd + 1;
			end else begin
				clkd <= 0;
				data[index] <= rx;

				if (index < (BITS-1)) begin
					// Transmit a bit
					index <= index + 1;
				end else begin
					index <= 0;
					state <= STOP;
				end
			end
		end
		STOP: begin
			finish <= 1'b1;

			if (clkd < CLK_DIVISOR-1) begin
				clkd <= clkd + 1;
			end else begin
				clkd <= 0;
				state <= IDLE;
			end
		end
		endcase
	end
endmodule
