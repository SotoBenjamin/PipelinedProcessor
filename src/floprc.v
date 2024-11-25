module floprc (
	clk,
	reset,
    clr,
	d,
	q
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
    input wire clr;
	input wire [WIDTH - 1:0] d;
	output reg [WIDTH - 1:0] q;
	always @(posedge clk or posedge reset)
		if (reset)
			q <= 0;
		else 
        begin
            if(clr) q <= 0;
            else    q <= d;
        end
    
endmodule