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
	output reg [3:0] ALUControl;
	//Add Branch output
	output wire Branch;
	//Add NoWrite for register
	output reg NoWrite;
	output reg IgRn;
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
	always @(*)
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0000: ALUControl = 4'b0010;//AND
				4'b0001: ALUControl = 4'b0110;//EOR
				4'b0010: ALUControl = 4'b0001;//SUB
				4'b0011: ALUControl = 4'b1001;//RSB
				
				4'b0100: ALUControl = 4'b0000;//ADD
				
				4'b1000: ALUControl = 4'b0010;//TST
				4'b1001: ALUControl = 4'b0110;//TEQ
				4'b1010: ALUControl = 4'b0001;//CMP
				4'b1011: ALUControl = 4'b0000;//CMN
				
				4'b1100: ALUControl = 4'b0011;//ORR

				4'b1101 : ALUControl = 4'b0000; //ADD;
				
				default: ALUControl = 4'bxxxx;
			endcase
			FlagW[1] = Funct[0];
			FlagW[0] = Funct[0] & ((ALUControl == 4'b0000) | (ALUControl == 4'b0001));
		end
		else begin
			ALUControl = 4'b0000;
			FlagW = 2'b00;
		end

	//Add cases for NoWrite and IgRn wire
	always @(*)
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0100: begin
					NoWrite = 1'b0;//ADD
					IgRn = 0;	
				end 	
				4'b0010: begin
					NoWrite = 1'b0;//SUB
					IgRn = 0;
				end
				4'b0000: begin 
					NoWrite = 1'b0;//AND
					IgRn = 0;
				end	
				4'b1100: begin 
					NoWrite = 1'b0;//ORR
					IgRn = 0;
				end	
				4'b0001: begin 
					NoWrite = 1'b0;//EOR
					IgRn = 0;
				end					
				4'b1000: begin 
					NoWrite = 1'b1;//TST
					IgRn = 0;
				end	
				4'b1010: begin 
					NoWrite = 1'b1;//CMP
					IgRn = 0;
				end		
				4'b1011: begin 
					NoWrite = 1'b1;//CMN
					IgRn = 0;
				end
				4'b1001: begin 
					NoWrite = 1'b1;//TEQ
					IgRn = 0;
				end	
				4'b1101: begin
					NoWrite = 1'b0; //MOV
					IgRn = 1;
				end
				default: begin 
					NoWrite = 1'bx;
					IgRn = 0;
				end
			endcase
		end
		else begin
			NoWrite = 1'b0;
			IgRn = 0;
		end
		
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch_;
	assign Branch = Branch_;
endmodule