`include "./Adder.v"

module Subtractor4BitStructural(input[3:0] a, input[3:0] b, output[3:0] d);
	wire c_out;
	wire[3:0] not_b;
	
	not(not_b[0], b[0]);
        not(not_b[1], b[1]);
        not(not_b[2], b[2]);
        not(not_b[3], b[3]);	
	
	Adder4BitStructural adder_4_bit(a, not_b, 1'b1, d, c_out);
endmodule
