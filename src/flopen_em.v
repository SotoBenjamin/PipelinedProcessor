module flopen_em (
	clk,
	reset,
	en,
	ALUResultE,
	WriteDataE,
	WA3E,
	ALUOutM,
	WriteDataM,
	WA3M
);
	input wire clk;
	input wire reset;
	input wire en;
	input wire [31:0] ALUResultE;
	input wire [31:0] WriteDataE;
	input wire [3:0] WA3E;
	output reg [31:0] ALUOutM;
	output reg [31:0] WriteDataM;
	output reg [3:0] WA3M;
	always @(posedge clk or posedge reset)
		if (reset)
		begin
            ALUOutM <= 0;
            WriteDataM <= 0;
            WA3M <= 0;
		end
		else if (en)
		begin
			ALUOutM <= ALUResultE;
			WriteDataM <= WriteDataE;
			WA3M <= WA3E;
		end
endmodule