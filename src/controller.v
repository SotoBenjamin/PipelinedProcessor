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
    output wire [2:0] ALUControlE;
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


    wire  RegWriteD, MemtoRegD, MemWriteD, BranchD, ALUSrcD, NoWriteD;
    wire [1:0] FlagWriteD;
    wire [2:0] ALUControlD;
    wire [3:0] Flags, CondE, FlagsE;
    wire RegWriteE, MemWriteE, BranchE, NoWriteE;
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
        .RegSrcD(RegSrcD),
        .NoWriteD(NoWriteD)
    );

    //fase de execute
/*
  flopencont_de de(
        .clk(clk),
        .reset(reset),
        .clr(FlushE),
        .PCSrcD(PCSrcD),  1bit
        .RegWriteD(RegWriteD), 1bit
        .MemtoRegD(MemtoRegD), 1bit
        .MemWriteD(MemWriteD), 1bit
        .ALUControlD(ALUControlD), 3bit
        .BranchD(BranchD), 1bit
        .ALUSrcD(ALUSrcD), 1bit
        .FlagWriteD(FlagWriteD), 2bit
        .NoWriteD(NoWriteD), 1bit
        .Cond(Cond), 4bit
        .Flags(Flags), 4bit

        .en(1'b1),
        .PCSrcE(PCSrcE),
        .RegWriteE(RegWriteE),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .ALUControlE(ALUControlE),
        .BranchE(BranchE),
        .ALUSrcE(ALUSrcE),
        .FlagWriteE(FlagWriteE),
        .NoWriteE(NoWriteE) 1bit
        .CondE(CondE),
        .FlagsE(FlagsE)
    );
    6 + 2 + 3 +4 +4 + 1 = 19
*/
    floprc #(20) de(
        .clk(clk),
        .reset(reset),
        .clr(FlushE),
        .d({PCSrcD,RegWriteD,MemtoRegD,MemWriteD,ALUControlD,BranchD,ALUSrcD,FlagWriteD,NoWriteD,Cond,Flags}),
        .q({PCSrcE,RegWriteE,MemtoRegE,MemWriteE,ALUControlE,BranchE,ALUSrcE,FlagWriteE,NoWriteE,CondE,FlagsE})
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

    assign RegWriteEcond = RegWriteE & CondExE & ~NoWriteE;
    assign PCSrcEcond =  (PCSrcE & CondExE);
    assign MemWriteEcond = MemWriteE & CondExE;
    assign BranchTakenE = (BranchE & CondExE) ;

/*

 flopencont_em em(
        .clk(clk),
        .reset(reset),
        .PCSrcE(PCSrcEcond), 1bit
        .RegWriteE(RegWriteEcond), 1bit
        .MemtoRegE(MemtoRegE), 1bit
        .MemWriteE(MemWriteEcond), 1bit
        .en(1'b1),
        .PCSrcM(PCSrcM),
        .RegWriteM(RegWriteM),
        .MemtoRegM(MemtoRegM),
        .MemWriteM(MemWriteM)
    );
*/
    // memory 
   
    flopr #(4) em(
        .clk(clk),
        .reset(reset),
        .d({PCSrcEcond,RegWriteEcond,MemtoRegE,MemWriteEcond}),
        .q({PCSrcM,RegWriteM,MemtoRegM,MemWriteM})
    );



/*

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


*/


    //writeback
    flopr #(3) mw(
        .clk(clk),
        .reset(reset),
        .d({PCSrcM,RegWriteM,MemtoRegM}),
        .q({PCSrcW,RegWriteW,MemtoRegW})
    );

    
endmodule
