// This module is the top connection module for the filter. It interfaces with
// the I2S2 pmod and connects it to the appropriate rx/tx modules and filters.

module Top (
		input boardclk, // 100 MHz Board clock from the Mimas A7 board
		input linData
, // data in from the I2S2 pmod

		output linBclk, // Bit clock out to the I2S2 pmod
		output linLr, // LR/word select signal out to the I2S2 pmod
		output linMclk, // Master Clock out to the I2S2 pmod
		output loutData, // data out to the I2S2 pmod
		output loutBclk, // Bit clock out to the I2S2 pmod
		output loutLr, // LR/word select signal out to the I2S2 pmod
		output loutMclk // Master Clock out to the I2S2 pmod
	);

	// clocks for the I2S interface
	wire lr;    // 97.65625 kHz word select clock
	wire bclk; // 6.25 MHz bit clock (64x lr)
	wire mclk; // 12.5 MHz master clock (2x bclk)
	wire sclk; // 25 MHz system clock (2x mclk)

	// data in and out of the I2S interface (for IIR, not I2S2 pmod)
	wire [23:0] lineoutLeft;
	wire [23:0] lineoutRight;
	wire [23:0] lineinLeft;
	wire [23:0] lineinRight;

	// Sync signals for IIR filters from I2S module
	wire sync;

	// assigning outputs to the I2S2 pmod
	assign linBclk = bclk;
	assign linLr = lr;
	assign linMclk = mclk;
	assign loutBclk = bclk;
	assign loutLr = lr;
	assign loutMclk = mclk;


	// Instantiate the clock generation module
	ClockGenerator clkgen(boardclk, lr, bclk, mclk, sclk);

	// Instantiate the I2S interface
	I2SInterface I2S2(sclk, bclk, lr, linData, loutData, lineinLeft, lineinRight, lineoutLeft, lineoutRight, sync);

	// Instantiate the left IRR filter
	// In this case, this will be a lowpass filter with a cutoff frequency of 1 KHz
	iirFilter #(
				  .A0(1098671),	// 0.0010232172047183973*(2^30)
				  .A1(2197342),	// 0.0020464344094367946*(2^30)
				  .A2(1098671),	// 0.0010232172047183973*(2^30)
				  .B1(-2048163407),	// -1.9075008174364765*(2^30)
				  .B2(978816267)	// 0.91159368625535*(2^30)
			  ) leftIRR (sclk, {{8{lineinLeft[23]}}, lineinLeft}, sync, lineoutLeft);

	// Instantiate the right IRR filter
	// In this case, this will just be a passthrough
	iirFilter #(
				  .A0(1073741824),	// 1.0*(2^30)
				  .A1(1073741824),	// 1.0*(2^30)
				  .A2(1073741824),	// 1.0*(2^30)
				  .B1(0),			// 0.0*(2^30)
				  .B2(0)			// 0.0*(2^30)
			  ) rightIRR (sclk, {{8{lineinRight[23]}}, lineinRight}, sync, lineoutRight);


	
endmodule
