module alu(
    input [31:0] a,
    input [31:0] b,
    input [4:0] ALUControl,
    input carryE,
    output reg [31:0] Result,
    output wire [3:0] ALUFlags
);
wire neg,zero,carry,overflow;
wire [31:0] condinva;
wire [31:0] condinvb;

wire [31:0] condinvb_log;

wire [32:0] sum;

wire [31:0] sum_carry;

assign condinva = ALUControl[3] ? ~a : a;//For RSB
assign condinvb = ALUControl[0] ? ~b : b; 
assign condinvb_log = (ALUControl[4] ? ~b : b);

/*
    4'b0101: ALUControl = 5'b00100 //ADC
    4'b0110: ALUControl = 5'b00101 //SBC
    4'b0111: ALUControl = 5'b01100 //RSC
*/

assign sum_carry = condinva + condinvb + ((ALUControl[3] | ALUControl[0]) ? -(~carryE) : carryE);


assign sum = condinva + condinvb + (ALUControl[0] | ALUControl[3]);

always @(*) 
begin
    casex (ALUControl[2:0])
        3'b00?: Result = sum;
        3'b010: Result = a & condinvb_log;
        3'b011: Result = a | b;
        3'b110: Result = a ^ b;
        3'b10?: Result = sum_carry;
    endcase
end
assign neg = Result[31];
assign zero = (Result == 32'b0);
assign carry = (ALUControl[1] == 1'b0) & sum[32];
assign overflow = (ALUControl[1] == 1'b0) & ~(a[31] ^ b[31] ^ ALUControl[0]) &(a[31]^ sum[31]);
assign ALUFlags = {neg, zero, carry,overflow};
endmodule