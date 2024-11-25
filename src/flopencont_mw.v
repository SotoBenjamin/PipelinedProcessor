module flopencont_mw(
	clk,
	reset,
	PCSrcM,
	RegWriteM,
	MemtoRegM,
	en,
	PCSrcW,
	RegWriteW,
	MemtoRegW,
);
	input wire clk;
	input wire reset;
	input wire PCSrcM;
	input wire RegWriteM;
	input wire MemtoRegM;
	input wire en;

	output reg PCSrcW;
	output reg RegWriteW;
	output reg MemtoRegW;

	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			PCSrcW <= 0;
			RegWriteW <= 0;
			MemtoRegW <= 0;
		end
		else if(en)
		begin
			PCSrcW <= PCSrcM;
			RegWriteW <= RegWriteM;
			MemtoRegW <= MemtoRegM;
		end
	end
	
endmodule