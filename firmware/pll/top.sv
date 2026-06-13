module top(
	input        clk,
	output [4:0] led,
	inout [27:0] gpio
);

  wire gpsdo_dp_clk     = gpio[4];
  wire gpsdo_pwm_trim   = gpio[17];
  wire gpsdo_gnss_pps   = gpio[27];
  wire gpsdo_dp_ref_clk = gpio[24];
  wire gpsdo_dp_pps     = gpio[25];


  logic [31:0] precision_counter; // =0;
  logic [28:0] crystal_counter = 0;
  logic [28:0] vctcxo_counter = 0;
  logic [7:0] ref_counter; // = 0;

  wire crystal_clk = clk;
  wire precision_clk;
  wire pll_locked;

  gpsdo_pll PLL (gpsdo_dp_clk, precision_clk, pll_locked);
  // gpsdo_clk CLK (precision_clk, precision_counter, gpsdo_dp_pps, gpsdo_dp_ref_clk);
  

  wire dec = 1;
  wire p_reset = 0;
  wire r_reset = 0;

  localparam bit [31:0] P_SEED = 32'd199999999;
  fastdec_32 #(.SEED_32(P_SEED)) p_clk_dec (
    .clk(precision_clk),
    .dec(dec),
    .reset(p_reset),
    .register(precision_counter)
  );
  localparam bit [31:0] R_SEED = 8'd9;  // 9+1 = 10 cycles on 10 off
  fastdec_8 #(.SEED_8(R_SEED)) r_clk_dec (
    .clk(precision_clk),
    .dec(dec),
    .reset(r_reset),
    .register(ref_counter)
  );

  // precision count
  //
  always_ff @(posedge precision_clk) begin
    p_reset <=0;
    r_reset <=0;

    if (precision_counter == 0) begin
      p_reset <= 1; //precision_counter <= 199999999;
    end
    //end else begin
      //precision_counter <= precision_counter - 1;
    //end

    if (ref_counter == 0) begin
      gpsdo_dp_ref_clk = !gpsdo_dp_ref_clk; // toggle clock state
      //gpsdo_dp_pps = !gpsdo_dp_pps;
      r_reset <= 1; //ref_counter <= 9;
    end
    //end else begin
      //ref_counter <= ref_counter - 1;
    //end

  end


  always_ff @(posedge crystal_clk) begin
    crystal_counter <= crystal_counter + 1;
  end


	// Indicator leds
	assign led[0] = pll_locked & crystal_counter[2:1]; // [2:1] to dim bright LEDs
	assign led[1] = 0;
	assign led[2] = precision_counter[27];// & crystal_counter[2:1];
	assign led[3] = 0;
	assign led[4] = 0;//gpsdo_dp_pps;
endmodule

