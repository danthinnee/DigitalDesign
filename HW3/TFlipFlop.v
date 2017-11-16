module TFlipFlop(input clock, input clear, input t, output reg q);
	always@(negedge clock, posedge clear)
		q = clear ? 0 : t^q;
endmodule

module TFlipFlop_tb;
	reg t, clock, clear;
	wire q;
	
	TFlipFlop tff (clock, clear, t, q);

	initial begin
		clear=1;
		#10 clear=0;
	end

	initial begin
		clock=1;
		forever #5 clock=~clock;
	end

	initial begin
		t=0;
		$monitor("%d clock:%d clear:%b t:%b q:%b", $time, clock, clear, t, q);
		#10 t=0;
		#10 t=1;
		#10 t=0;
		#10 t=1;
		#10 $finish;
	end
endmodule

