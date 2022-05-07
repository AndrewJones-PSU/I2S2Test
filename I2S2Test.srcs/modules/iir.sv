// This module acts as an IIR filter.

module iirFilter #(
		parameter int A0,
		parameter int A1,
		parameter int A2,
		parameter int B1,
		parameter int B2
	)	(
		input sclk, // 25 MHz System clock

		input [31:0] din, // Input data
		input dinValid, // Input data valid signal

		output reg [31:0] dout, // Output data
		output reg doutValid, // Output data valid signal

		output reg busy // Busy signal
	);

	reg[31:0] input;	// Input data (saved in case it becomes invalid during processing)

	signed reg [31:0] mula, mulb;	// Multiplication inputs A and B
	signed wire [63:0] multOut = mula * mulb;	// Multiplication output

	reg [3:0] state;	// State machine

	signed reg [39:0] temp;
	signed reg [31:0] tempin, inz1, inz2, outz1, outz2;


	always @(posedge sclk)
	begin
		case (state)
			3'h0:
			begin
				if (dinValid)
				begin
					mula <= din;
					tempin <= din;
					mulb <= to_signed(A0, 32);
					state <= 3'h1;
					busy <= 1;
					doutValid <= 0;
				end
			end
			3'h1:
			begin
				temp <= (multOut >> 30)[39:0];
				mula <= inz1;
				mulb <= to_signed(A1, 32);
				state <= 3'h2;
			end
			3'h2:
			begin
				temp <= temp + (multOut >> 30)[39:0];
				mula <= inz2;
				mulb <= to_signed(A2, 32);
				state <= 3'h3;
			end
			3'h3:
			begin
				temp <= temp + (multOut >> 30)[39:0];
				mula <= outz1;
				mulb <= to_signed(B1, 32);
				state <= 3'h4;
			end
			3'h4:
			begin
				temp <= temp - (multOut >> 30)[39:0];
				mula <= outz2;
				mulb <= to_signed(B2, 32);
				state <= 3'h5;
			end
			3'h5:
			begin
				temp <= temp - (multOut >> 30)[39:0];
				state <= 3'h6;
			end
			3'h6:
			begin
				dout <= temp[31:0];
				doutValid <= 1;
				outz1 <= temp[31:0];
				outz2 <= outz1;
				inz2 <= inz1;
				inz1 <= tempin;
				busy <= 0;
				state <= 3'h0;
			end
		endcase

	end



endmodule
