module flopen_de (
	clk,
	reset,
	en,
	clr,
	RD1D,
	RA1D,
	RA2D,
	RD2D,
	WA3,
	ExtImmD,
	RD1E,
	RD2E,
	WA3E,
	ExtImmE,
	RA1E,
	RA2E
);
	input wire clk;
	input wire reset;
	input wire en;
	input wire clr;
	input wire [3:0] RA1D;
	input wire [3:0] RA2D;
	input wire [31:0] RD1D;
	input wire [31:0] RD2D;
	input wire [3:0] WA3;
	input wire [31:0] ExtImmD;

	output reg [31:0] RD1E;
	output reg [31:0] RD2E;
	output reg [3:0] WA3E;
	output reg [31:0] ExtImmE;
	output reg [3:0] RA1E;
	output reg [3:0] RA2E;
	always @(posedge clk or posedge reset)
		if (reset)
		begin
			RD1E <= 0;
			RD2E <= 0;
			WA3E <= 0;
			ExtImmE <= 0;
			RA1E <= 0;
			RA2E <= 0;
		end
		else if (en)
		begin
			if(clr) 
			begin
				RD1E <= 0;
				RD2E <= 0;
				WA3E <= 0;
				ExtImmE <= 0;
				RA1E <= 0;
				RA2E <= 0;
			end
			else 
			begin
				RD1E <= RD1D;
				RD2E <= RD2D;
				WA3E <= WA3;
				ExtImmE <= ExtImmD;
				RA1E <= RA1D;
				RA2E <= RA2D;
			end
			
		end

endmodule