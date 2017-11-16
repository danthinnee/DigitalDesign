i/*module BitSetStructural_4bit(input[3:0] x, input[1:0] index, input value, output[3:0] y);
	wire[3:0] m;
	wire[3:0] nm;
	wire[3:0] w1, w2;
	wire[3:0] result;
	Demux1to4_4bit demux1 (1'b1, index, m);
	not n0(nm[0], m[0]);
	not n1(nm[1], m[1]);
	not n2(nm[2], m[2]);
	not n3(nm[3], m[3]);
	and g01(w1[0], m[0], value);
	and g02(w2[0], nm[0], x[0]);
	and g11(w1[1], m[1], value);
	and g12(w2[1], nm[1], x[1]);
	and g21(w1[2], m[2], value);
	and g22(w2[2], nm[2], x[2]);
	and g31(w1[3], m[3], value);
	and g32(w2[3], nm[3], x[3]);
	
	or(result[0], w1[0], w2[0]);
        or(result[1], w1[1], w2[1]);
        or(result[2], w1[2], w2[2]);
        or(result[3], w1[3], w2[3]);

	assign y[0] = result[0];
	assign y[1] = result[1];
	assign y[2] = result[2];
	assign y[3] = result[3];
endmodule

module Demux1to4_4bit(input x, input[1:0] s, output[3:0] y);
	reg y;
	always@(x, y)
		case (s)
			0: y={3'b000,x};
                        1: y={2'b00,x,1'b0};
                        2: y={1'b0,x,2'b00};
                        3: y={x,3'b000};
		endcase
endmodule

module Demux_tb;
	reg x;
	reg[1:0] s;
	wire[3:0] y;
	
	Demux1to4_4bit dm1 (x, s, y);
	
	initial begin
		$monitor("%d x=%b s=%d y=%b", $time, x,s,y);
                #10
                x=1'b1;
                s=2'b00;
                #10
                x=1'b1;
                s=2'b01;

                #10
                x=1'b1;
                s=2'b10;

                #10
                x=1'b1;
                s=2'b11;

	end
endmodule
*/
module BitSetStructural_tb;
	reg[3:0] x;
	reg[1:0] index;
	reg value;
	reg[3:0] y;
	
	//BitSetStructural_4bit bss4b (x, index, value, y);

	initial begin
		$monitor("%d x=%b index=%d value=%b y=%b", $time, x, index, value, y);
		#10
		x=4'b0000;
		index=2'b00;
		value=1'b0;
		y=4'b0000;
                #10
                x=4'b0001;
                index=2'b00;
                value=1'b0;
		#10
		x=4'b0001;
		index=2'b01;
		value=1'b0;
                #10
                x=4'b0000;
                index=2'b11;
                value=1'b1;
                #10
                x=4'b1111;
                index=2'b10;
                value=1'b0;
	end
endmodule

