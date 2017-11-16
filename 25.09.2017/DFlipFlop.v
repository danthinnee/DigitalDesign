module DFlipFlop(input clock, input clear, input d, output reg q);
	always@(negedge clock, posedge clear)
		q = clear ? 0 : d;
endmodule
