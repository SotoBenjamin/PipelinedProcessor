module alu(
    input [31:0] a,b,
    input [4:0] ALUControl,
    output reg [31:0] Result,
    output wire [3:0] ALUFlags
);
wire neg,zero,carry,overflow;
wire [31:0] condinva;
wire [31:0] condinvb;

wire [31:0] condinvb_log;

wire [32:0] sum;
assign condinva = ALUControl[3] ? ~a : a;//For RSB
assign condinvb = ALUControl[0] ? ~b : b; 
assign condinvb_log = (ALUControl[4] ? ~b : b);


assign sum = condinva + condinvb + (ALUControl[0] | ALUControl[3]);
always @(*) begin
    casex (ALUControl[2:0])
        3'b00?: Result = sum;
        3'b010: Result = a & condinvb_log;
        3'b011: Result = a | b;
        3'b110: Result = a ^ b;
    endcase
end
assign neg = Result[31];
assign zero = (Result == 32'b0);
assign carry = (ALUControl[1] == 1'b0) & sum[32];
assign overflow = (ALUControl[1] == 1'b0) & ~(a[31] ^ b[31] ^ ALUControl[0]) &(a[31]^ sum[31]);
assign ALUFlags = {neg, zero, carry,overflow};
endmodule