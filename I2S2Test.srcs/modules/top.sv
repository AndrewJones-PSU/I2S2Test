// This module is the top connection module for the filter. It interfaces with
// the I2S2 pmod and connects it to the appropriate rx/tx modules and filters.

module Top (
		input boardclk, // 100 MHz Board clock from the Mimas A7 board
		input linData, // data in from the I2S2 pmod

		output linBclk, // Bit clock out to the I2S2 pmod
		output linLr, // LR/word select signal out to the I2S2 pmod
		output linMclk, // Master Clock out to the I2S2 pmod
		output loutData, // data out to the I2S2 pmod
		output loutBclk, // Bit clock out to the I2S2 pmod
		output loutLr, // LR/word select signal out to the I2S2 pmod
		output loutMclk // Master Clock out to the I2S2 pmod
	);
