module top (
	clk,
	reset,
	WriteDataM,
	DataAdrM,
	MemWriteM
);
	input wire clk;
	input wire reset;
	output wire [31:0] WriteDataM;
	output wire [31:0] DataAdrM;
	output wire MemWriteM;
	wire [31:0] PCF;
	wire [31:0] ReadDataM;
	wire [31:0] InstrF;
	arm arm(
		.clk(clk),
		.reset(reset),
		.InstrF(InstrF),
		.PCF(PCF),
		.ReadDataM(ReadDataM),
		.MemWriteM(MemWriteM),
		.ALUOutM(DataAdrM),
		.WriteDataM(WriteDataM)
	);
	imem imem(
		.a(PCF),
		.rd(InstrF)
	);
	dmem dmem(
		.clk(clk),
		.we(MemWriteM),
		.a(DataAdrM),
		.wd(WriteDataM),
		.rd(ReadDataM)
	);
endmodule