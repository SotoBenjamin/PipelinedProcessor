module hazard(
RegWriteM,
RegWriteW,
MemtoRegE,
Match_1E_M,
Match_1E_W,
Match_2E_M,
Match_2E_W,
Match_12D_E,
ForwardAE,
ForwardBE,
FlushE,
StallD,
StallF,
BranchTakenE,
PCSrcD,
PCSrcE,
PCSrcM,
FlushD,
PCSrcW
);
input wire RegWriteM;
input wire RegWriteW;
input wire Match_1E_M;
input wire Match_1E_W;
input wire Match_2E_M;
input wire Match_2E_W;
input wire Match_12D_E;
input wire MemtoRegE;
input wire BranchTakenE,PCSrcD,PCSrcE,PCSrcM,PCSrcW;

wire LDRStall;
wire PCWrPendingF;

output reg [1:0] ForwardAE;
output reg [1:0] ForwardBE;
output wire StallD;
output wire StallF;
output wire FlushE;
output wire FlushD;

always @(*) begin
    if (Match_1E_M && RegWriteM) ForwardAE = 2'b10; //ALUOutM
    else if (Match_1E_W && RegWriteW) ForwardAE = 2'b01; //ResultW
    else ForwardAE = 2'b00; //SrcAE from regfile
end

always @(*) begin
    if (Match_2E_M && RegWriteM) ForwardBE = 2'b10;
    else if (Match_2E_W && RegWriteW) ForwardBE = 2'b01;
    else ForwardBE = 2'b00;
end

assign LDRStall = Match_12D_E & MemtoRegE;
assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;

assign StallD = LDRStall;
assign StallF = LDRStall | PCWrPendingF;
assign FlushE = LDRStall | BranchTakenE;
assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE; 


endmodule