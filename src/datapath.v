module datapath (
	clk,
	reset,
	RegSrcD,
	RegWriteW,
	ImmSrcD,
	ALUSrcE,
	ALUControlE,
	MemtoRegW,
	PCSrcW,
	ALUFlags,
	PCF,
	InstrF,
	InstrD,
	ALUOutM,
	WriteDataM,
	ReadDataM,
	Match_1E_M,
	Match_1E_W,
	Match_2E_M,
	Match_2E_W,
	ForwardAE,
	ForwardBE,
	Match_12D_E,
	StallF,
	StallD,
	FlushE,
	FlushD,
	BranchTakenE,
	IgRnE,
	FlagCarryE
);
	//datapath recive  ImmSrcD,RegSrcD , ALUControlE,ALUSrcE, MemWriteM,MemtoRegW,RegWriteW,PCSrcW
	//cambiar ALUResult por ALUOutM
	//cambiar ReadData por ReadDataW
	input wire clk;
	input wire reset;
	input wire [1:0] RegSrcD;
	input wire RegWriteW;
	input wire [1:0] ImmSrcD;
	input wire ALUSrcE;
	input wire [4:0] ALUControlE;
	input wire MemtoRegW;
	input wire PCSrcW;
	input wire [31:0] ReadDataM;
	input wire [31:0] InstrF;
	input wire [1:0] ForwardAE;
	input wire [1:0] ForwardBE;
	input wire StallF;
	input wire StallD;
	input wire FlushE;
	input wire FlushD;
	input wire BranchTakenE;
	input wire IgRnE;
	input wire FlagCarryE; //

	output wire [3:0] ALUFlags;
	output wire [31:0] PCF;
	output wire [31:0] InstrD;
	output wire [31:0] ALUOutM;
	output wire [31:0] WriteDataM;
	output wire Match_1E_M;
	output wire Match_1E_W;
	output wire Match_2E_M;
	output wire Match_2E_W;
	output wire Match_12D_E;

	wire [31:0] PCNext;
	wire [31:0] PCNextB;
	wire [31:0] PCPlus4F;
	wire [31:0] PCPlus8;
	wire [31:0] ExtImmD;
	wire [31:0] ExtImmE; //
	wire [31:0] RD1D; //
	wire [31:0] RD2D; //
	wire [31:0] RD1E;
	wire [31:0] RD2E;
	wire [31:0] SrcAE;
	wire [31:0] SrcBE;
	wire [3:0] WA3E; //
	wire [3:0] WA3M; //
	wire [3:0] WA3W; //
	wire [31:0] ALUResultE; //
	wire [31:0] WriteDataE; //
	wire [31:0] ResultW;
	wire [3:0] RA1D;
	wire [3:0] RA2D;
	wire [3:0] RA1E;
	wire [3:0] RA2E;
	wire [31:0] ReadDataW;
	wire [31:0] ALUOutW;
	wire [31:0] InstrE;


//fetch stage
	mux2 #(32) pcmux(
		.d0(PCPlus4F),
		.d1(ResultW),
		.s(PCSrcW),
		.y(PCNext)
	);


	mux2 #(32) pcmux2(
		.d0(PCNext),
		.d1(ALUResultE)	,
		.s(BranchTakenE),
		.y(PCNextB)
	);


	flopenr #(32) pcreg(
		.clk(clk),
		.reset(reset),
		.en(~StallF),
		.d(PCNextB),
		.q(PCF)
	);

	
	adder #(32) pcadd1(
		.a(PCF),
		.b(32'b100),
		.y(PCPlus4F)
	);
	// adder #(32) pcadd2(
	// 	.a(PCPlus4F),
	// 	.b(32'b100),
	// 	.y(PCPlus8)
	// );
	//optimización
	assign PCPlus8 = PCPlus4F;
	
	flopenrc #(32) instreg (
		.clk(clk),
		.reset(reset),
		.clear(FlushD),
		.en(~StallD),
		.d(InstrF),
		.q(InstrD)
	);

//decode stage
	mux2 #(4) ra1mux(
		.d0(InstrD[19:16]),
		.d1(4'b1111),
		.s(RegSrcD[0]),
		.y(RA1D)
	);
	mux2 #(4) ra2mux(
		.d0(InstrD[3:0]),
		.d1(InstrD[15:12]),
		.s(RegSrcD[1]),
		.y(RA2D)
	);
	regfile rf(
		.clk(~clk),
		.we3(RegWriteW),
		.ra1(RA1D),
		.ra2(RA2D),
		.wa3(WA3W),
		.wd3(ResultW),
		.r15(PCPlus8),
		.rd1(RD1D),
		.rd2(RD2D)
	);
	
	extend ext(
		.Instr(InstrD[23:0]),
		.ImmSrc(ImmSrcD),
		.ExtImm(ExtImmD)
	);
/*

flopen_de regDE(
		.clk(clk),
		.reset(reset),
		.clr(1'b0),
		.en(1'b1),
		.RA1D(RA1D), //4bits
		.RA2D(RA2D), //4 bits
        .RD1D(RD1D), //32 bits
        .RD2D(RD2D), //32 bits
        .WA3(InstrD[15:12]),//4bits
        .ExtImmD(ExtImmD), // 32 bits
        .RD1E(RD1E), 
        .RD2E(RD2E),
        .WA3E(WA3E),
        .ExtImmE(ExtImmE),
		.RA1E(RA1E),
		.RA2E(RA2E)
	);

	32*3 + 12 = 108
*/	
	flopr #(140) de(
		.clk(clk),
		.reset(reset),
		.d({RA1D,RA2D,RD1D,RD2D,InstrD[15:12],ExtImmD,InstrD}),
		.q({RA1E,RA2E,RD1E,RD2E,WA3E,ExtImmE,InstrE})
	);
	
	wire [31:0] SrcAEp;
// execute stage
	mux3 #(32) srcaPmux(
		.d0(RD1E),
		.d1(ResultW),
		.d2(ALUOutM),
		.s(ForwardAE),
		.y(SrcAEp)
	);

	mux2 #(32) srcamux(
		.d0(SrcAEp),
		.d1(32'b0),
		.s(IgRnE),
		.y(SrcAE)
	);
	wire [31:0] WriteDataEp;

	mux3 #(32) writedatamux(
		.d0(RD2E),
		.d1(ResultW),
		.d2(ALUOutM),
		.s(ForwardBE),
		.y(WriteDataEp)
	);


	shift sh(
		.ShiftD(InstrE[11:5]),
		.WD(WriteDataEp),
		.en(1'b0),
		.WriteData(WriteDataE)
	);

	mux2 #(32) srcbmux(
		.d0(WriteDataE),
		.d1(ExtImmE),
		.s(ALUSrcE),
		.y(SrcBE)
	);
	
	alu alu(
		.a(SrcAE),
		.b(SrcBE),
		.ALUControl(ALUControlE),
		.carryE(FlagCarryE),
		.Result(ALUResultE),
		.ALUFlags(ALUFlags)
	);

/*
	flopen_em regEM(
		.clk(clk),
		.reset(reset),
		.en(1'b1),
        .ALUResultE(ALUResultE), // 32 bits
        .WriteDataE(WriteDataE), // 32 bits
        .WA3E(WA3E), //4bits
        .ALUOutM(ALUOutM), //32 bits
        .WriteDataM(WriteDataM), //32 bits 
        .WA3M(WA3M) //4bits
	);

	32*2 + 4 = 68

*/
	flopr #(68) em(
		.clk(clk),
		.reset(reset),
		.d({ALUResultE,WriteDataE,WA3E}),
		.q({ALUOutM,WriteDataM,WA3M})
	);


/*


flopen_mw regMW(
		.clk(clk),
		.reset(reset),
		.en(1'b1),
        .ReadDataM(ReadDataM),//32 bits
        .ALUOutM(ALUOutM), // 32 bits
        .WA3M(WA3M), // 4bits
        .ReadDataW(ReadDataW),
        .ALUOutW(ALUOutW),
        .WA3W(WA3W)
	);

	32*2 + 4 = 68
*/
	
	flopr #(68) mw(
		.clk(clk),
		.reset(reset),
		.d({ReadDataM,ALUOutM,WA3M}),
		.q({ReadDataW,ALUOutW,WA3W})
	);


	mux2 #(32) resmux(
		.d0(ALUOutW),
		.d1(ReadDataW),
		.s(MemtoRegW),
		.y(ResultW)
	);

	assign Match_1E_M = (RA1E == WA3M); 
	assign Match_1E_W = (RA1E == WA3W); 
	assign Match_2E_M = (RA2E == WA3M); 
	assign Match_2E_W = (RA2E == WA3W);
	assign Match_12D_E = (RA1D == WA3E) | (RA2D == WA3E);

endmodule