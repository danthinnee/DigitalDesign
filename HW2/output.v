module test(output fuck, input[1:0] s, input value, input[3:0] x, input[3:0] y);
	assign fuck = 1+1;
endmodule

module testbench;
	reg[1:0] s;
	reg value;
	reg[3:0] x;
	reg[3:0] y;
	wire fuck;

	test mytest (fuck, s, value, x, y);
	initial begin
	$monitor("%d x=%b s=%d value=%b y=%b", $time, x, s, value, y);
		#10
		x=4'b0000;
		s=2'b00;
		value=1'b0;
		y=4'b0000;

                #10
                x=4'b0001;
                s=2'b01;
                value=1'b1;
                y=4'b0011;

                #10
                x=4'b1100;
                s=2'b10;
                value=1'b0;
                y=4'b1000;

                #10
                x=4'b1111;
                s=2'b11;
                value=1'b0;
                y=4'b0111;

	end
endmodule
