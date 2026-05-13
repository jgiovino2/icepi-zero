module uart_tx #(
	parameter CLK = 50000000,
	parameter BAUD_RATE = 115200,
	parameter BITS = 8
) (
	input                   clk,
	input                   send,
	input        [BITS-1:0] data,
  output                  sent,
	output logic            tx
);
	localparam CLK_DIVISOR = CLK / BAUD_RATE;

	logic [$clog2(CLK_DIVISOR):0] clkd;
	logic [$clog2(BITS)-1:0]      index;

  logic send_latch;

	enum {IDLE, START, TRANSMISSION, STOP} state;

	initial begin
		tx = 1'b1;
		clkd = 0;
		index = 0;
		state = IDLE;
    sent = 0;
    send_latch = 0;
	end

	always @(posedge clk) begin

    if (send) send_latch <= 1;
    if (sent) sent <= 0; // sent is also a single clock pulse

		case (state)
		IDLE: begin
			tx <= 1'b1;
			clkd <= 0 ;
			index <= 0;

      //sent <= 0;
      if (send_latch) begin //|| send) begin
				state <= START;
			end
		end

		START: begin
      send_latch <= 0;
			tx <= 1'b0;

			// For one clock cycle
			if (clkd < CLK_DIVISOR-1) begin
				clkd <= clkd + 1;
			end else begin
				clkd <= 0;
				state <= TRANSMISSION;
			end
		end
		TRANSMISSION: begin
			tx <= data[index];

			if (clkd < CLK_DIVISOR-1) begin
				clkd <= clkd + 1;
			end else begin
				clkd <= 0;

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
			tx <= 1'b1;

			if (clkd < CLK_DIVISOR-1) begin
				clkd <= clkd + 1;
			end else begin
				clkd <= 0;
				state <= IDLE;
        sent <= 1;
			end
		end
		endcase
	end
endmodule
