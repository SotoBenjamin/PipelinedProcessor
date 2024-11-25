module flopen_mw (
	clk,
	reset,
	en,
	ReadDataM,
	ALUOutM,
	WA3M,
	ReadDataW,
	ALUOutW,
	WA3W
);
	input wire clk;
	input wire reset;
	input wire en;
	input wire [31:0] ReadDataM;
	input wire [31:0] ALUOutM;
	input wire [3:0] WA3M;
	output reg [31:0] ReadDataW;
	output reg [31:0] ALUOutW;
	output reg [3:0] WA3W;
	always @(posedge clk or posedge reset)
		if (reset)
		begin
            ReadDataW <= 0;
            ALUOutW <= 0;
            WA3W <= 0;
		end
		else if (en)
		begin
			ReadDataW <= ReadDataM;
			ALUOutW <= ALUOutM;
			WA3W <= WA3M;
		end
endmodule
