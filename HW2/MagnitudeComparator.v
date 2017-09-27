module MagnitudeComparator_8b(input[7:0] a, input[7:0] b, output eq, output lt, output gt);
	wire eqh, lth, gth;
	MagnitudeComparator_4b mg4b1 (a[7:4], b[7:4], eqh, lth, gth);
	wire eql, ltl, gtl;
	MagnitudeComparator_4b mg4b2 (a[3:0], b[3:0], eql, ltl, gtl);
	assign eq = eqh & eql;
	assign lt = lth | (eqh&ltl);
	assign gt = ~eq & ~lt;
endmodule

module MagnitudeComparator_4b(input[3:0] a, input[3:0] b, output eq, output lt, output gt);
	wire[3:0] x;
	assign x[0] = ~(a[0]^b[0]);
	assign x[1] = ~(a[1]^b[1]);
	assign x[2] = ~(a[2]^b[2]);
	assign x[3] = ~(a[3]^b[3]);

	assign eq = x[0] & x[1] & x[2] & x[3];
	assign lt = (~a[3]&b[3]) + (x[3]&~a[2]&b[2]) + (x[3]&x[2]&~a[1]&b[1]) + (x[3]&x[2]&x[1]&~a[0]&b[0]);
	assign gt = ~lt & ~eq;
endmodule

module MagnitudeComparator_tb();
	reg[7:0] a, b;
	wire eq, lt, gt;
	
	MagnitudeComparator_8b mc8b (a, b, eq, lt, gt);
	initial begin
		$monitor("%d a=%d b=%d eq=%b lt=%b gt=%b", $time, a, b, eq, lt, gt);
			#10
			a = 4'd10;
			b = 4'd10;

			#10
			a = 4'd14;
			b = 4'd10;

			#10
			a = -4'd14;
			b = -4'd10;
	end
endmodule
