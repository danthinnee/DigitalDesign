module Multiplexer_4to1bit(input e, input[3:0] x, output y, input[1:0] s);
	reg y;
	always@(e,x,s)
		if(e)
			y=x[s];
		else
			y=0;
endmodule
