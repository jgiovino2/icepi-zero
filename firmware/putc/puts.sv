module puts #(
) (
	input                   clk,
	input                   en,
	input        [7:0]      data,
	input        [15:0]     len,
  output                  oe,
  output                  putc
);

  logic en_latch;
  logic [15:0] index;

	enum {IDLE, TRANSMIT, WAIT} state;

	initial begin
    state = IDLE;
    en_latch = 0;
    en = 0;
    oe = 0;
    index = 0;
	end

	always @(posedge clk) begin

    if (en) en_latch <= 1;

		case (state)

		IDLE: begin
      oe <= 0;
      if (en_latch) begin //|| en) begin
        en_latch <= 0;
				state <= TRANSMISSION;
        index <= 0;
        oe <= 1;
			end
		end

		TRANSMIT: begin
			putc.data <= data[index];
      index <= index +1;
      putc.en <= 1;
      state <= WAIT;
		end

		WAIT: begin
      if (putc.oe == 0)
        if (index == len) begin
          state <= IDLE;
        end
          state <= TRANSMIT;
			  end
			end
		end

		endcase
	end

endmodule
