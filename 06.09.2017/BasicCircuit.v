/*dataflow model*/
module CircuitDataflow(input a, input b, input c, output d, output e);
	assign d = a&b | ~c;
	assign e = ~c;
endmodule

/*structural model*/
module CircuitStruct(input a, input b, input c, output d, output e);
	wire w1;
	and g1(w1, a, b);
	not g2(e, c);
	or g3(d, w1, e);
endmodule

/*behavioral model*/
module CircuitBehavioral(input a, input b, input c, output d, output e);
	reg d, e;
	always @ (a, b, c)
		case({a, b, c})
			0: {d, e} = 2'b11;
			1: {d, e} = 2'b00;
			2: {d, e} = 2'b11;
			/*3: {d, e} = 2'b00;
			4: {d, e} = 2'b00;
			5: {d, e} = 2'b00;
			6: {d, e} = 2'b00;
			7: {d, e} = 2'b00;*/
		endcase
endmodule

