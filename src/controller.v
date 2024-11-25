module controller(
    clk,
    reset,
    Cond,
    Instr,
    ALUFlags,
    RegSrcD,
    ImmSrcD,
    ALUSrcE,
    ALUControlE,
    PCSrcW,
    RegWriteW,
    MemWriteM,
    MemtoRegW,
    RegWriteM,
    MemtoRegE,
    FlushE,
    BranchTakenE,
    PCSrcD,
    PCSrcE,
    PCSrcM,
    
);
	//controller vota de output ImmSrcD,RegSrcD , ALUControlE,ALUSrcE, MemWriteM,MemtoRegW,RegWriteW,PCSrcW

    input wire clk;
    input wire reset;
    input wire [31:28] Cond;
    input wire [27:12] Instr;
    input wire [3:0] ALUFlags;
    input wire FlushE;

    output wire [1:0] RegSrcD;
    output wire [1:0] ImmSrcD;
    output wire ALUSrcE;
    output wire [1:0] ALUControlE;
    output wire PCSrcW;
    output wire RegWriteW;
    output wire RegWriteM;
    output wire MemWriteM;
    output wire MemtoRegW;
    output wire MemtoRegE;
    output wire BranchTakenE;
    output wire PCSrcD;
    output wire PCSrcE;
    output wire PCSrcM;


    wire  RegWriteD, MemtoRegD, MemWriteD, BranchD, ALUSrcD;
    wire [1:0] ALUControlD, FlagWriteD;
    wire [3:0] Flags, CondE, FlagsE;
    wire RegWriteE, MemWriteE, BranchE;
    wire RegWriteEcond, PCSrcEcond , MemWriteEcond;
    wire [1:0] FlagWriteE;
    wire MemtoRegM;
    wire CondExE;

    
    // señales de control (fase de decode)
    control_unit cu(
        .Instr(Instr),
        .PCSrcD(PCSrcD),
        .RegWriteD(RegWriteD),
        .MemtoRegD(MemtoRegD),
        .MemWriteD(MemWriteD),
        .ALUControlD(ALUControlD),
        .BranchD(BranchD),
        .ALUSrcD(ALUSrcD),
        .FlagWriteD(FlagWriteD),
        .ImmSrcD(ImmSrcD),
        .RegSrcD(RegSrcD)
    );

    //fase de execute

    flopencont_de de(
        .clk(clk),
        .reset(reset),
        .clr(FlushE),
        .PCSrcD(PCSrcD),
        .RegWriteD(RegWriteD),
        .MemtoRegD(MemtoRegD),
        .MemWriteD(MemWriteD),
        .ALUControlD(ALUControlD),
        .BranchD(BranchD),
        .ALUSrcD(ALUSrcD),
        .FlagWriteD(FlagWriteD),
        .Cond(Cond),
        .Flags(Flags),
        .en(1'b1),
        .PCSrcE(PCSrcE),
        .RegWriteE(RegWriteE),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .ALUControlE(ALUControlE),
        .BranchE(BranchE),
        .ALUSrcE(ALUSrcE),
        .FlagWriteE(FlagWriteE),
        .CondE(CondE),
        .FlagsE(FlagsE)
    );

    //conditional

    cond_unit cu_cond(
        .clk(clk),
        .reset(reset),
        .FlagWriteE(FlagWriteE),
        .CondE(CondE),
        .FlagsE(FlagsE),
        .ALUFlags(ALUFlags),
        .Flags(Flags),
        .CondExE(CondExE)
    );

    assign RegWriteEcond = RegWriteE & CondExE;
    assign PCSrcEcond =  (PCSrcE & CondExE);
    assign MemWriteEcond = MemWriteE & CondExE;
    assign BranchTakenE = (BranchE & CondExE) ;


    // memory 
    flopencont_em em(
        .clk(clk),
        .reset(reset),
        .PCSrcE(PCSrcEcond),
        .RegWriteE(RegWriteEcond),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteEcond),
        .en(1'b1),
        .PCSrcM(PCSrcM),
        .RegWriteM(RegWriteM),
        .MemtoRegM(MemtoRegM),
        .MemWriteM(MemWriteM)
    );


    //writeback
    flopencont_mw mw(
        .clk(clk),
        .reset(reset),
        .PCSrcM(PCSrcM),
        .RegWriteM(RegWriteM),
        .MemtoRegM(MemtoRegM),
        .en(1'b1),
        .PCSrcW(PCSrcW),
        .RegWriteW(RegWriteW),
        .MemtoRegW(MemtoRegW)
    );

    
endmodule
