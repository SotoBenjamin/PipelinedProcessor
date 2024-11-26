module decode (
	Op,
	Funct,
	Rd,
	FlagW,
	PCS,
	RegW,
	MemW,
	MemtoReg,
	ALUSrc,
	ImmSrc,
	RegSrc,
	Branch,
	ALUControl,
	NoWrite,
	IgRn
);
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	
	output reg [1:0] FlagW;
	output wire PCS;
	output wire RegW;
	output wire MemW;
	output wire MemtoReg;
	output wire ALUSrc;
	output wire [1:0] ImmSrc;
	output wire [1:0] RegSrc;
	output reg [4:0] ALUControl;
	//Add Branch output
	output wire Branch;
	//Add NoWrite for register
	output reg NoWrite;
	output wire IgRn;
	reg [9:0] controls;
	//Refactor Branch to Branch_
	wire Branch_;
	wire ALUOp;
	
	always @(*)
		casex (Op)
			2'b00:
				if (Funct[5])
					controls = 10'b0000101001;
				else
					controls = 10'b0000001001;
			2'b01:
				if (Funct[0])
					controls = 10'b0001111000;
				else
					controls = 10'b1001110100;
			2'b10: controls = 10'b0110100010;
			default: controls = 10'bxxxxxxxxxx;
		endcase
	assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch_, ALUOp} = controls;

	//ALUControl[2] => EOR
	//ALUControl[3] => RSB
	//ALUControl[4] => BIC
	
	always @(*)
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0000: ALUControl = 5'b00010;//AND
				4'b0001: ALUControl = 5'b00110;//EOR
				4'b0010: ALUControl = 5'b00001;//SUB
				4'b0011: ALUControl = 5'b01001;//RSB
				
				4'b0100: ALUControl = 5'b00000;//ADD
				
				4'b1000: ALUControl = 5'b00010;//TST
				4'b1001: ALUControl = 5'b00110;//TEQ
				4'b1010: ALUControl = 5'b00001;//CMP
				4'b1011: ALUControl = 5'b00000;//CMN
				
				4'b1100: ALUControl = 5'b00011;//ORR
				
				4'b1110: ALUControl = 5'b10011;//BIC
				
				4'b1101: ALUControl = 5'b00000;//MOV;
				
				default: ALUControl = 5'bxxxxx;
			endcase
			FlagW[1] = Funct[0];
			FlagW[0] = Funct[0] & ((ALUControl[1:0] == 2'b00) | (ALUControl[1:0] == 2'b01));
		end
		else begin
			ALUControl = 5'b00000;
			FlagW = 2'b00;
		end

	//Add cases for NoWrite and IgRn wire
		always @(*)
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0000: NoWrite = 1'b0;//AND
				4'b0001: NoWrite = 1'b0;//EOR
				4'b0010: NoWrite = 1'b0;//SUB
				4'b0011: NoWrite = 1'b0;//RSB
				
				4'b0100: NoWrite = 1'b0;//ADD
				
				4'b1000: NoWrite = 1'b1;//TST
				4'b1001: NoWrite = 1'b1;//TEQ
				4'b1010: NoWrite = 1'b1;//CMP
				4'b1011: NoWrite = 1'b1;//CMN
				
				4'b1100: NoWrite = 1'b0;//ORR
				
				4'b1110: NoWrite = 1'b0;//BIC
				
				4'b1101: NoWrite = 1'b0;//MOV;
				default: NoWrite = 1'bx;
			endcase
		end
		else begin
			NoWrite = 1'b0;
		end
	assign IgRn = ALUOp & (Funct[4:1] == 4'b1101); //MOV
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch_;
	assign Branch = Branch_;
endmodule