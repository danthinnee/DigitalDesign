module reg38 (input clk, input clr, input[7:0] writedata, input[1:0] writeindex, input writeenable, input[1:0] readindex, output[7:0] readdata);
	
	reg[8] y[3];
	integer i;
	always@(posedge clr, negedge clk)
		if(clr) begin
			for(i=0; i<4; i=i+1)
				y[i]=0;
		end
		else if(writeenable)
			y[writeindex]=writedata;
	assign readdata=y[readindex];	

endmodule

module reg38tb ();
	reg clk, clr, we;
	reg[7:0] wd;
	reg[1:0] wi, ri;
	wire[7:0] rd;

	reg38 r38 (clk, clr, wd, wi, we, ri, rd);

	initial begin
		clr=1;
		#10 clr=0;
	end

	initial begin
		clk=1;
		forever #5 clk=~clk;
	end

	initial begin
		#10
		$monitor("%b %b %d %d %d %d %d", $time, clk, clr, wd, wi, we, ri, rd);


	end
endmodule
