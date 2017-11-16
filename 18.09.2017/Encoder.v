module Encoder_4to2bit(input e, input[3:0] d, output[1:0] x);
	reg x;
	always@(e,d)
		if(e)
			case(d)
				4'b0001: x=0;
				4'b0010: x=1;
				4'b0100: x=2;
				4'b1000: x=3;
			endcase
		else
			x=0;
endmodule
