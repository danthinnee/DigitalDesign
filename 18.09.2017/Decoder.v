module Decover_2to4bit(input e, input[1:0] x, output[3:0] d);
	assign d[0] = ~x[1] & ~x[0] & e;
	assign d[1] = ~x[1] & x[0] & e;
	assign d[2] = x[1] & ~x[0] & e;
	assign d[3] = x[1] & x[0] & e;
endmodule
