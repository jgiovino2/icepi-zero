module cli #(
  parameter CLK = 50000000,
	parameter BAUD_RATE = 115200,
	parameter BITS = 8,
	parameter BANNER_LENGTH = 2028 // TODO this should be passed in from 
                                 // -DBANNER_LENGTH=`wc -l < banner.mem`
) (
	input                   clk,
	input                   rx_finish,
	input logic [7:0]       data_in,
  input                   sent,
  output                  send,
	output logic [7:0]      data_out
);

  enum {WAIT, DUMP, ENTRY, READ_1, READ_2, SEND_COUNT, SEND_DATA, SEND_CR, SEND_LF} state;

  logic [31:0] delay;
  logic [31:0] local_count;
  logic sent_latch; // treat sent as a single clock pulse trigger

  logic [7:0] string_rom [0:BANNER_LENGTH];

	initial begin
    $readmemh("banner.mem", string_rom);
		send = 0;
    local_count = 0;
    state = WAIT;
    sent_latch = 0;
    delay = 0;
	end

	always @(posedge clk) begin

    if (sent) sent_latch=1;

    // send is a single clock pulse
    if (send) send <= 0;
    if (putc_go) putc_go <= 0;

		case (state)

    WAIT: begin
      // wait 3 seconds
      if (local_count > 150000000) begin

        data_out <= string_rom[0];
        local_count <= 1;

        send <= 1;
        sent_latch <= 0;
        state <= DUMP;
      end else begin
        local_count <= local_count+1;
      end
    end

    DUMP: begin
       if (sent_latch) begin
          sent_latch <= 0;

          data_out <= string_rom[local_count];
          send <= 1;

          if (local_count > BANNER_LENGTH) begin
            local_count <= 0;
            state <= READ_1;
          end else begin
            local_count <= local_count + 1;
          end
       end
    end

		ENTRY: begin
        local_count <= local_count + 1;
				state <= READ_1;
		end

		READ_1: begin
      if (rx_finish == 1) begin
        data_out <= 8'b00100000 + local_count[4:0]; // rep as ascii
        sent_latch <= 0;
        send <= 1;
        state <= SEND_COUNT;
      end
    end
		SEND_COUNT: begin
      if (sent_latch) begin
          data_out <= data_in;
          sent_latch <= 0;
          send <= 1;
					state <= SEND_DATA;
      end
		end
		SEND_DATA: begin
      if (sent_latch) begin
          data_out <= 8'b00001101;  // CR
          sent_latch <= 0;
          send <= 1;
					state <= SEND_CR;
			end
    end
		SEND_CR: begin
      if (sent_latch) begin
          data_out <= 8'b00001010;  // LF 
          sent_latch <= 0;
          send <= 1;
					state <= SEND_LF;
			end
    end
		SEND_LF: begin
      if (sent_latch) begin
					state <= ENTRY;
			end
    end
		endcase
	end
endmodule
