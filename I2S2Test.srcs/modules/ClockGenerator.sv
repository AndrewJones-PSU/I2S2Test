// This file models a clock generator using a 7-series PLL. This is used to
// generate clock signals for our I2S interface.

module ClockGenerator(
		input clk, // 100 MHz clock from Mimas A7 board

		output reg lr    // 97.65625 kHz word select clock
		output reg bclk, // 6.25 MHz bit clock (64x lr)
		output reg mclk, // 12.5 MHz master clock (2x bclk)
		output reg sclk, // 25 MHz system clock (2x mclk)
	);

	reg lr2; // 195.3125 KHz signal for deriving lr

	initial
		lr2 = 0;

	always @(posedge lr2) // derive lr from lr2 (195.3125 KHz / 2 = 97.65625 KHz)
		lr <= ~lr;


	// Instantiate PLL, using Xilinx template as a base

	// PLLE2_BASE: Base Phase Locked Loop (PLL)
	// 7 Series
	// Xilinx HDL Language Template, version 2020.1
	PLLE2_BASE
		#(
			.BANDWIDTH("OPTIMIZED"), // OPTIMIZED, HIGH, LOW
			.CLKFBOUT_MULT(4), // Multiply value for all CLKOUT, (2-64)
			.CLKFBOUT_PHASE(0.0), // Phase offset in degrees of CLKFB, (-360.000-360.000).
			.CLKIN1_PERIOD(10.0), // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
			// CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
			.CLKOUT0_DIVIDE(1), // for output sclk (100MHz * 5 / 20 / 1 = 25 MHz)
			.CLKOUT1_DIVIDE(2), // for output mclk (100MHz * 5 / 20 / 2 = 12.5 MHz)
			.CLKOUT2_DIVIDE(4), // for output bclk (100MHz * 5 / 20 / 4 = 6.25 MHz)
			.CLKOUT3_DIVIDE(128),// for output lr2 (100MHz * 5 / 20 / 128 = 195.3125 kHz)
			.CLKOUT4_DIVIDE(1), // unused
			.CLKOUT5_DIVIDE(1), // unused
			// CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
			.CLKOUT0_DUTY_CYCLE(0.5),
			.CLKOUT1_DUTY_CYCLE(0.5),
			.CLKOUT2_DUTY_CYCLE(0.5),
			.CLKOUT3_DUTY_CYCLE(0.5),
			.CLKOUT4_DUTY_CYCLE(0.5),
			.CLKOUT5_DUTY_CYCLE(0.5),
			// CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
			.CLKOUT0_PHASE(0.0),
			.CLKOUT1_PHASE(0.0),
			.CLKOUT2_PHASE(0.0),
			.CLKOUT3_PHASE(0.0),
			.CLKOUT4_PHASE(0.0),
			.CLKOUT5_PHASE(0.0),
			.DIVCLK_DIVIDE(16), // Master division value, (1-56)
			.REF_JITTER1(0.0), // Reference input jitter in UI, (0.000-0.999).
			.STARTUP_WAIT("FALSE") // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
		)
		PLLE2_BASE_inst (
			// Clock Outputs: 1-bit (each) output: User configurable clock outputs
			.CLKOUT0(sclk), // 1-bit output: CLKOUT0
			.CLKOUT1(mclk), // 1-bit output: CLKOUT1
			.CLKOUT2(bclk), // 1-bit output: CLKOUT2
			.CLKOUT3(lr2), // 1-bit output: CLKOUT3
			// Feedback Clocks: 1-bit (each) output: Clock feedback ports
			.CLKIN1(clk), // 1-bit input: Input clock
		);
	// End of PLLE2_BASE_inst instantiation

endmodule
