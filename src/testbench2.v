module testbench2;
	reg clk;
	reg reset;
	wire [31:0] WriteData;
	wire [31:0] DataAdr;
	wire MemWrite;
	top dut(
		.clk(clk),
		.reset(reset),
		.WriteDataM(WriteData),
		.DataAdrM(DataAdr),
		.MemWriteM(MemWrite)
	);
	initial begin
		$dumpfile("simulation.vcd");
		$dumpvars(0,testbench2);
		reset <= 1;
		#(22)
			;
		reset <= 0;
	end
	always begin
		clk <= 1;
		#(10)
			;
		clk <= 0;
		#(10)
			;
	end
	always @(negedge clk)
		if (MemWrite == 0)
			if ((DataAdr == 5)) begin
				$display("Simulation succeeded");
				$stop;
			end
			
endmodule