module putc #(
	parameter CLK = 50000000,
	parameter BAUD_RATE = 115200,
	parameter BITS = 8
) (
	input                   clk,
	input                   go,
	input        [BITS-1:0] data,
  output                  oe,
	output logic            tx
);
	localparam CLK_DIVISOR = CLK / BAUD_RATE;

	logic [$clog2(CLK_DIVISOR):0] clkd;
	logic [$clog2(BITS)-1:0]      index;

  logic en_latch;

	enum {IDLE, START, TRANSMISSION, STOP} state;

	initial begin
		tx = 1'b1;
		clkd = 0;
		index = 0;
		state = IDLE;
    oe = 0;
    en_latch = 0;
	end

	always @(posedge clk) begin

    if (en) en_latch <= 1;
    if (oe) oe <= 0; // oe is also a single clock pulse

		case (state)
		IDLE: begin
			tx <= 1'b1;  // an idle tx line is driven high
			clkd <= 0 ;
			index <= 0;

      if (en_latch) begin //|| en) begin
				state <= START;
			end
		end

		START: begin
      en_latch <= 0;
			tx <= 1'b0; // start bit driven low

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
			tx <= 1'b1; // stop bit driven high

			if (clkd < CLK_DIVISOR-1) begin
				clkd <= clkd + 1;
			end else begin
				clkd <= 0;
				state <= IDLE;
        oe <= 1;
			end
		end
		endcase
	end
endmodule
