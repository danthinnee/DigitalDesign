module decoder4(input[1:0] x, input en, output[3:0] y);
	reg[3:0] y;
	always@(x, en)
		if(en)
			case(x)
				0:y=4'b0001;
				1:y=4'b0010;
				2:y=4'b0100;
				3:y=4'b1000;
			endcase
endmodule
