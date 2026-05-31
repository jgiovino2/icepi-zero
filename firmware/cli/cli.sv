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

  enum {WAIT, PUTS, ENTRY, READ_1, READ_2, SEND_COUNT, PUT_SP, ECHO_CHAR, SEND_CR, SEND_LF, HELP} state;
  enum {PROMPT_MODE, HELP_MODE, ENTRY_MODE} mode;

  logic [31:0] wait_count;
  logic [31:0] read_count;
  logic sent_latch; // treat sent as a single clock pulse trigger

  logic [7:0] cli_rom [0:`CLI_ROM_LEN];


  logic [31:0] str_pos;
  logic [31:0] str_len;
  logic [31:0] str_count;

  logic help;
  logic [31:0] help_count;



	initial begin
    //$readmemh("banner.mem", cli_rom);
    $readmemh("cli_rom.mem", cli_rom);
		send = 0;
    str_count = 0;
    wait_count = 0;
    read_count = 0;
    state = WAIT;
    sent_latch = 0;
    help = 0;
    help_count = 0;
	end

	always @(posedge clk) begin

    if (sent) sent_latch=1;

    // send is a single clock pulse
    if (send) send <= 0;
    if (putc_go) putc_go <= 0;

		case (state)

    WAIT: begin
      // wait 3 seconds
      if (wait_count > 150000000) begin
        wait_count <= 0;
        str_pos <= `BANNER_POS;
        str_len <= `BANNER_LEN;
        str_count <= 0;
        send <= 1;
        sent_latch <= 0;
        state <= PUTS;
      end else begin
        wait_count <= wait_count+1;
      end
    end

    PUTS: begin
       if (sent_latch) begin
          sent_latch <= 0;

          if (str_count < str_len) begin
            data_out <= cli_rom[str_pos];
            str_pos <= str_pos + 1'b1;
            str_count <= str_count + 1'b1;
            send <= 1;
          end else if (str_count == str_len) begin
            data_out <= 8'b00001101;  // CR
            str_count <= str_count + 1'b1;
            send <= 1;
          end else if (str_count == (str_len+1)) begin
            data_out <= 8'b00001010;  // LF 
            str_count <= str_count + 1'b1;
            send <= 1;
          end else begin
            str_count <= 0;
            state <= ENTRY;
          end
       end
    end

		ENTRY: begin
      if (help) begin
        state <= HELP;
        str_pos <= help_count * `RECORD_LEN;
      end else begin
        read_count <= read_count + 1;
				state <= READ_1;
      end
		end

    HELP: begin
      if (help_count == 'h7f) begin
        state <= ENTRY;
        help <= 0;
      end

      help_count <= help_count + 1'b1;

      if (cli_rom[str_pos] != " ") begin
        str_len <= 24;
        str_count <= 0;
        send <= 1;
        state <= PUTS;
      end else begin
        //str_pos <= help_count * `RECORD_LEN; // precalculated
        state = ENTRY;
      end
    end

		READ_1: begin
      if (rx_finish == 1) begin
        data_out <= 8'b01000000 + read_count[5:0]; // rep as ascii
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

          "H" : begin // H help
            help <= 1;
            state <= HELP; 
            help_count <= 0;
            str_pos <= 0;
          end

          8'h3F : begin // ? help
            help <= 1;
            state <= HELP; 
            help_count <= 0;
            str_pos <= 0;
          end

          //8'b01010111 : begin // W wait
          "W" : begin // wait
            state <= WAIT; 
          end

          //8'b01000010 : begin // B banner
          "B" : begin // banner
            str_pos = `BANNER_POS;
            str_len = `BANNER_LEN;
            str_count <= 0;
            send <= 1;
            state <= PUTS;
          end

          "T" : begin // time
            str_pos = `BUILD_TIME_POS;
            str_len = `BUILD_TIME_LEN;
            str_count <= 0;
            send <= 1;
            state <= PUTS;
          end

          default : begin
            if (data_in < 8'h80) begin
              str_pos <= data_in * `RECORD_LEN;
              str_len <= 16;
              str_count <= 0;
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
