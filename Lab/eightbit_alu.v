module eightbit_alu(input[7:0] a, input[7:0] b, input[2:0] sel, output[7:0] f, output ovf, output take_branch);
	reg[7:0] f;
	reg ovf, take_branch;
	always @ (a, b, sel)
		case (sel)
			0: begin
				f=a+b; 
				ovf=(a[7]^f[7])&(b[7]^f[7]);
				take_branch=0;
			end
			1: begin
				f=~b;
				ovf=0;
				take_branch=0;
			end
                        2: begin
                                f=a&b;
                                ovf=0;
				take_branch=0;
                        end
                        3: begin
                                f=a|b;
                                ovf=0;
				take_branch=0;
                        end
                        4: begin
                                f= a>>>1;
                                ovf=0;
				take_branch=0;
                        end
                        5: begin
                                f= a<<1;
                                ovf=0;
				take_branch=0;
                        end
                        6: begin
                                f=0;
                                ovf=0;
				take_branch = (a==b) ? 1 : 0;
                        end
                        7: begin
                                f=0;
                                ovf=0;
				take_branch = (a==b) ? 0 : 1;
                        end
		endcase
endmodule

module eightbit_alu_tb;
	reg[7:0] a, b;
	reg[2:0] sel;
	wire[7:0] f;
	wire ovf, take_branch;
	
	eightbit_alu ebpl1 (a, b, sel, f, ovf, take_branch);

	initial begin
		$monitor("%d a=%b b=%b sel=%d f=%b ovf=%b take_branch=%b", $time, a, b, sel, f, ovf, take_branch);
		#10
		a=8'b00000000;
		b=8'b00000000;
		sel=3'b000;
	        #10
                a=8'b01111111;
                b=8'b01111111;
                sel=3'b000;
	        #10
                a=8'b11110000;
                b=8'b11110000;
                sel=3'b001;
	        #10
                a=8'b10101010;
                b=8'b10101010;
                sel=3'b010;
                #10
                a=8'b10101010;
                b=8'b00001111;
                sel=3'b011;
                #10
                a=8'b10100101;
                b=8'b00100000;
                sel=3'b111;
	end
endmodule
