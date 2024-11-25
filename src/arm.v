module arm (
	clk,
	reset,
	PCF,
	InstrF,
	MemWriteM,
	ALUOutM,
	WriteDataM,
	ReadDataM
);
	input wire clk;
	input wire reset;
	input wire [31:0] InstrF;
	input wire [31:0] ReadDataM;

	output wire [31:0] PCF;
	output wire MemWriteM;
	output wire [31:0] ALUOutM;
	output wire [31:0] WriteDataM;

	wire [31:0] InstrD;
	wire [3:0] ALUFlags;
	wire RegWriteW;
	wire RegWriteM; //controller bota RegWriteM
	wire ALUSrcE;
	wire MemtoRegW;
	wire MemtoRegE; //controller bota MemtoRegE
	wire PCSrcW;
	wire [1:0] RegSrcD;
	wire [1:0] ImmSrcD;
	wire [1:0] ALUControlE;
	wire Match_1E_M;
	wire Match_1E_W;
	wire Match_2E_M;
	wire Match_2E_W;
	wire Match_12D_E;
	wire [1:0] ForwardAE;
	wire [1:0] ForwardBE;
	wire StallF,StallD,FlushE,FlushD;
	wire PCSrcD , PCSrcE , PCSrcM , BranchTakenE;
	//controller vota de output ImmSrcD,RegSrcD , ALUControlE,ALUSrcE, MemWriteM,MemtoRegW,RegWriteW,PCSrcW
	controller c(
		.clk(clk),
		.reset(reset),
		.Cond(InstrD[31:28]),
		.Instr(InstrD[27:12]),
		.ALUFlags(ALUFlags),
		.RegSrcD(RegSrcD),
		.RegWriteW(RegWriteW),
		.MemtoRegE(MemtoRegE),
		.ImmSrcD(ImmSrcD),
		.ALUSrcE(ALUSrcE),
		.ALUControlE(ALUControlE),
		.MemWriteM(MemWriteM),
		.MemtoRegW(MemtoRegW),
		.PCSrcW(PCSrcW),
		.RegWriteM(RegWriteM),
		.FlushE(FlushE),
		.BranchTakenE(BranchTakenE),
		.PCSrcM(PCSrcM),
		.PCSrcE(PCSrcE),
		.PCSrcD(PCSrcD)
	);


	datapath dp(
		.ForwardAE(ForwardAE),
		.ForwardBE(ForwardBE),
		.clk(clk),
		.reset(reset),
		.RegSrcD(RegSrcD),
		.RegWriteW(RegWriteW),
		.ImmSrcD(ImmSrcD),
		.ALUSrcE(ALUSrcE),
		.ALUControlE(ALUControlE),
		.MemtoRegW(MemtoRegW),
		.PCSrcW(PCSrcW),
		.ALUFlags(ALUFlags),
		.PCF(PCF),
		.InstrF(InstrF),
		.InstrD(InstrD),
		.ALUOutM(ALUOutM),
		.WriteDataM(WriteDataM),
		.ReadDataM(ReadDataM),
		.Match_1E_M(Match_1E_M),
		.Match_1E_W(Match_1E_W),
		.Match_2E_M(Match_2E_M),
		.Match_2E_W(Match_2E_W),
		.Match_12D_E(Match_12D_E),
		.FlushE(FlushE),
		.BranchTakenE(BranchTakenE),
		.StallD(StallD),
		.StallF(StallF),
		.FlushD(FlushD)	
	);

	hazard hz(
		.RegWriteM(RegWriteM),
		.RegWriteW(RegWriteW),
		.MemtoRegE(MemtoRegE),
		.Match_1E_M(Match_1E_M),
		.Match_1E_W(Match_1E_W),
		.Match_2E_M(Match_2E_M),
		.Match_2E_W(Match_2E_W),
		.Match_12D_E(Match_12D_E),
		.ForwardAE(ForwardAE),
		.ForwardBE(ForwardBE),
		.StallD(StallD),
		.StallF(StallF),
		.FlushE(FlushE),
		.FlushD(FlushD),
		.PCSrcW(PCSrcW),
		.BranchTakenE(BranchTakenE),
		.PCSrcD(PCSrcD),
		.PCSrcE(PCSrcE),
		.PCSrcM(PCSrcM)
	);



endmodule