module multi4(input[5:0] x, input[1:0] sel, input en, output[1:0] y);
	reg[1:0] y;
	
	always@(x, en, sel)
		if(en) begin
			y[1]=x[2*sel+1];
			y[0]=x[2*sel];	
		end
endmodule

module multi4_tb();
	reg[5:0] x;
	reg[1:0] sel;
	reg en;
	wire[1:0] y;
	
	multi4 m4 (x, sel, en, y);

	initial begin
	$monitor("%d en=%b sel=%d x=%b y=%b", $time, en, sel, x, y);
	#10
	x=6'b001101;
	sel=00;
	en=1;
	#10
	x=6'b001101;
	sel=01;
	end
endmodule
