`include "./Adder.v"

module Multiplier4Bit(input[3:0] a, input[3:0] b, output[7:0] p);
	wire[7:0] w;
	wire[8:0] w2;
	wire[8:0] w3;	
	
	and g1(p[0], a[0], b[0]);

	and g2(w01[0], a[0], b[1]);
	and g3(w01[1], a[0], b[2]);
	and g4(w01[2], a[0], b[3]);
	assign w01[3] = 0;

	and g5(w[4], a[1], b[0]);
	and g6(w[5], a[1], b[1]);
	and g7(w[6], a[1], b[2]);
	and g8(w[7], a[1], b[3]);

	Adder4BitStructural adder1 (w[3:0],w[7:4],1'b0,w2[3:0],w2[4]);

	and g9(w2[5], a[2], b[0]);
        and g10(w2[6], a[2], b[1]);
        and g11(w2[7], a[2], b[2]);
        and g12(w2[8], a[2], b[3]);

	Adder4BitStructural adder2 (w2[4:1], w2[8:5], 1'b0, w3[3:0], w3[4]);
	
        and g9(w3[5], a[3], b[0]);
        and g10(w3[6], a[3], b[1]);
        and g11(w3[7], a[3], b[2]);
        and g12(w3[8], a[3], b[3]);

        Adder4BitStructural adder3 (w3[4:1], w3[8:5], 1'b0, p[6:3], p[7]);
	
	assign p[1] = w2[0];
	assign p[2] = w3[0];

endmodule

module Multiplier_tb;
	wire[7:0] p;
	reg[3:0] a, b;

	Multiplier4Bit multiplier (a, b, p);

	initial begin
		$monitor("%d a=%b, b=%b, p=%b", $time, a, b, p);
		#10 a=2;
		b=2;

		#10 a=15;
		b = 14;
	end
endmodule
