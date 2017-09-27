module Adder3Bit(input[2:0] a,input[2:0] b,output[2:0] s,output c_out);
	wire [3:0] result;
	assign result = a + b;
	assign c_out = result[3];
	assign s = result[2:0];
endmodule

module Multiplier3BitStructural(
	input[2:0] a,
	input[2:0] b,
	output[5:0] p);
	// Intermediate products
	wire[2:0] ip0, ip1, ip2;
	and(ip0[0], a[0], b[0]);
	and(ip0[1], a[1], b[0]);
	and(ip0[2], a[2], b[0]);
	and(ip1[0], a[0], b[1]);
	and(ip1[1], a[1], b[1]);
	and(ip1[2], a[2], b[1]);
	and(ip2[0], a[0], b[2]);
	and(ip2[1], a[1], b[2]);
	and(ip2[2], a[2], b[2]);
	// Intermediate sums
	wire[3:0] s0, s1;
	Adder3Bit adder0(ip1, {1'b0, ip0[2], ip0[1]}, s0[2:0], s0[3]);
	Adder3Bit adder1(ip2, s0[3:1], s1[2:0], s1[3]);
	// Result
	assign p[0] = ip0[0];
	assign p[1] = s0[0];
	assign p[2] = s1[0];
	assign p[3] = s1[1];
	assign p[4] = s1[2];
	assign p[5] = s1[3];
endmodule

module Multiplier3BitDataflow(
	input[2:0] a,
	input[2:0] b,
	output[5:0] p);
	assign p = a * b;
endmodule

module Multiplier3BitTest;
	wire[5:0] p;
	reg[2:0] a, b;
	Multiplier3BitStructural multiplier_3_bit(a, b, p);
	initial begin
		$monitor("%d a=%b, b=%b, p=%b", $time, a, b, p);
			#10 a = 2;
			b = 2;
			#10 a = 1;
			b = 5;
			#10 a = 3;
			b = 7;
			#10 a = 8;
			b = 9;
	 end
endmodule
