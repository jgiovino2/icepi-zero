`include "cli_rom.svh"
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

  enum {WAIT, PUTS, ENTRY, READ_1, READ_2, SEND_COUNT, PUT_SP, ECHO_CHAR, SEND_CR, SEND_LF} state;

  logic [31:0] delay;
  logic [31:0] local_count;
  logic sent_latch; // treat sent as a single clock pulse trigger

  logic [7:0] string_rom [0:`CLI_ROM_LEN];


  logic [15:0] decimation;

  logic [31:0] str_pos;
  logic [31:0] str_len;



	initial begin
    //$readmemh("banner.mem", string_rom);
    $readmemh("cli_rom.mem", string_rom);
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
        str_pos <= `BANNER_POS;
        str_len <= `BANNER_LEN;
        data_out <= string_rom[0 + `BANNER_POS];
        local_count <= 1;
        send <= 1;
        sent_latch <= 0;
        state <= PUTS;
      end else begin
        local_count <= local_count+1;
      end
    end

    PUTS: begin
       if (sent_latch) begin
          sent_latch <= 0;

          data_out <= string_rom[local_count + str_pos];
          send <= 1;

          if (local_count > str_len) begin
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
        data_out <= 8'b01000000 + local_count[5:0]; // rep as ascii
        send <= 1;
        state <= SEND_COUNT;
      end
    end
		SEND_COUNT: begin
      if (sent_latch) begin
          sent_latch <= 0;
          data_out <= 8'b00100000;  // SP
          send <= 1;
					state <= PUT_SP;
      end
		end
		PUT_SP: begin
      if (sent_latch) begin
          sent_latch <= 0;
          data_out <= data_in;
          send <= 1;
					state <= ECHO_CHAR;
      end
    end
    ECHO_CHAR: begin
      if (sent_latch) begin
          sent_latch <= 0;
          data_out <= 8'b00001101;  // CR
          send <= 1;
					state <= SEND_CR;
			end
    end
		SEND_CR: begin
      if (sent_latch) begin
          sent_latch <= 0;
          data_out <= 8'b00001010;  // LF 
          send <= 1;
					state <= SEND_LF;
			end
    end
		SEND_LF: begin
      if (sent_latch) begin
        sent_latch <= 0;
        case (data_in)
          8'b01010111 : begin // W wait
            state <= WAIT; 
          end
          8'b01000010 : begin // B banner
            str_pos = `BANNER_POS;
            str_len = `BANNER_LEN;
            local_count <= 0;
            send <= 1;
            state <= PUTS;
          end
          default : begin
            if (data_in < 8'h80) begin
              str_pos <= data_in * `RECORD_LEN;
              str_len <= 16;
              local_count <= 0;
              send <= 1;
              state <= PUTS;
            end else begin
              state <= ENTRY;
            end
          end
        endcase
			end
    end
		endcase
	end
endmodule
