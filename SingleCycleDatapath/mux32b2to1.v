module(input s, input[31:0] in0, input[31:0] in1, output[31:0] out);
	assign out = s ? in0 : in1
endmodule
