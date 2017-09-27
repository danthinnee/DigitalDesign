module HalfAdder(input x, input y, output s, output c);
	/*assign s = x | y;
	assign c = x & y;*/
	xor G1(s, a, b);
	and G2(c, a, b);
endmodule

module FullAdder(input x, input y, input z, output s, output c);
	wire w1, w2, w3;
	HalfAdder HA1(x, y, w2, w1);
	HalfAdder HA2(w2, z, s, w3);
	or G1(c, w1, w3);
endmodule

module Adder4BitStructural(input[3:0] a, input[3:0] b, input c_in, output[3:0] s, output c_out);
	wire[3:1] w;
	FullAdder FA1(a[0], b[0], c_in, s[0], w[1]);
	FullAdder FA2(a[1], b[1], w[1], s[1], w[2]);
	FullAdder FA3(a[2], b[2], w[2], s[2], w[3]);
	FullAdder FA4(a[3], b[3], w[3], s[3], c_out);
endmodule

module Adder4BitDataflow(input[3:0] a, input[3:0] b, input c_in, output[3:0] s, output c_out);
	wire [4:0] result;
	assign result = a + b + c_in;
	assign c_out = result[4];
	assign s = result[3:0];
endmodule

module Adder4BitTest;
	wire[3:0] s;
	wire c_out;
	reg[3:0] a, b;
	
	Adder4BitStructural adder_4_bit(a, b, 1'b0, s, c_out);
	initial begin
		$monitor("%d a=%b, b=%b, s=%b, c_out=%b", $time, a, b, s, c_out);
		#10
		a = 2;
		b = 2;
	end
endmodule
