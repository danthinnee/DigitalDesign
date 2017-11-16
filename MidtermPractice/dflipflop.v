module dff (input[3:0] x, input en, input clk, input clr, output[3:0] y);
	reg[3:0] y;
	always@(posedge clr, negedge clk)
		if(clr)
			y=0;
		else
			y=x;

endmodule

module dff_tb();
	reg[3:0] x;
	reg en, clk, clr;
	wire[3:0] y;

	dff dff1(x, en, clk, clr, y);

	initial begin
		clr=1;
		#10 clr=0;
	end

	initial begin
		clk=0;
		forever #5 clk=~clk;
	end

	initial begin
		$monitor("%d %d %b %b %b %d", $time, x, en, clk, clr, y);
		#10
		x=4'b1000;
		en=1;
		#10
		x=4'b0000;

		$finish;
	end
endmodule
