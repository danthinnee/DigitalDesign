`include "./BasicCircuit.v"

module TestCircuit;
	reg a, b, c;
	wire d, e;
	CircuitStruct circuit (a, b, c, d, e);
	initial begin
		$monitor("%d abc=%b%b%b de=%b%b", $time, a, b, c, d, e);
		#10 {a, b, c} = 0;
		#10 {a, b, c} = 1;
		#10 {a, b, c} = 2;
		#10 {a, b, c} = 3;
		#10 {a, b, c} = 4;
		#10 {a, b, c} = 5;
		#10 {a, b, c} = 6;
		#10 {a, b, c} = 7;
		#10 $finish;
	end
endmodule


