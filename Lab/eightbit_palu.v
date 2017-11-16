module eightbit_palu(input[7:0] a, input[7:0] b, input[1:0] sel, output[7:0] f, output ovf);
	reg[7:0] f;
	reg ovf;
	always @ (a, b, sel)
		case (sel)
			0: begin
				f=a+b; 
				ovf=(a[7]^f[7])&(b[7]^f[7]);
			end
			1: begin
				f=~b;
				ovf=0;
			end
                        2: begin
                                f=a&b;
                                ovf=0;
                        end
                        3: begin
                                f=a|b;
                                ovf=0;
                        end
		endcase
endmodule

module eightbit_palu_tb;
	reg[7:0] a, b;
	reg[1:0] sel;
	wire[7:0] f;
	wire ovf;
	
	eightbit_palu ebpl1 (a, b, sel, f, ovf);

	initial begin
		$monitor("%d a=%b b=%b sel=%d f=%b ovf=%b", $time, a, b, sel, f, ovf);
		#10
		a=8'b00000000;
		b=8'b00000000;
		sel=2'b00;
	        #10
                a=8'b01111111;
                b=8'b01111111;
                sel=2'b00;
	        #10
                a=8'b11110000;
                b=8'b11110000;
                sel=2'b01;
	        #10
                a=8'b10101010;
                b=8'b10101010;
                sel=2'b10;
                #10
                a=8'b10101010;
                b=8'b00001111;
                sel=2'b11;
	end
endmodule
