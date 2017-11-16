module Register_32b(input clock, input clear, input inc, output reg[31:0] value);
	always@(negedge clock, posedge clear)
		if (inc)
			value = clear ? 0 : value+3;
		else
			value = clear ? 0 : value;
endmodule

module Register32b_tb;
	reg inc, clock, clear;
	wire[31:0] value;
	
	Register_32b r32b (clock, clear, inc, value);
	initial begin
		clear=1;
		#10 clear=0;
	end

	initial begin
		clock=1;
		forever #5 clock=~clock;
	end
	
	initial begin
		inc=0;
		$monitor("%d clock:%b clear:%b inc=%b value:%d",$time,clock,clear,inc,value);
		#10 inc=1;
		#10 inc=0;
		#10 inc=1;
		#10 inc=0;
		#10 $finish;
	end
endmodule
