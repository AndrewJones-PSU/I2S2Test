// This module acts as an I2S transmitter and receiver.

module I2SInterface(
		input sclk, // 25 MHz System clock
		input bclk, // 6.25 MHz Bit Clock
		input lr, // Left/Right Channel Select
		input linData, // Line In Data
		output loutData, // Line Out Data

		input [23:0] inLeft, // left signal to line out
		input [23:0] inRight, // right signal to line out

		output [23:0] outLeft, // left signal from line in
		output [23:0] outRight, // right signal from line in

		output sync // sync signal
	);

	reg [63:0] inputShift;
	reg [63:0] outputShift;
	reg [1:0] bclkEdge; // track the rising/falling edge of the bit clock
	reg [1:0] lrEdge; // track the rising/falling edge of the left/right channel select
	reg frameSync; // track the rising/falling edge of the frame sync

	always @(posedge sclk)
	begin
		// frane syncing
		if (lrEdge == 2'b10)
			frameSync <= 1'b1;
		else if (bclkEdge == 2'b01)
			frameSync <= 1'b0;

		// input shifting
		if (bclkEdge == 2'b10)
		begin
			inputShift <= {inputShift[62:0], linData};
			if (lrEdge == 2'b10)
			begin
				outLeft <= signed(inputShift[62:39]);
				outRight <= signed(inputShift[30:7]);
				sync <= 1;
			end
		end
		else
			sync <= 0;

		// output shifting
		if (bclkEdge == 2'b01)
		begin
			loutData <= outputShift[63];
			outputShift <= {outputShift[62:0], 1'b0};
		end
		else if (bclkEdge == b'00 && frameSync == 1'b1)
			outputShift <= {inLeft, 8'b0, inRight, 8'b0};

		// edge tracking
		bclkEdge <= {bclkEdge[0], bclk};
		lrEdge <= {lrEdge[0], lr};

	end
endmodule
