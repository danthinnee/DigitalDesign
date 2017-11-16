module reg_file(input rst, input clk, input wr_en, input[1:0] rd0_addr, input[1:0] rd1_addr, input[1:0] wr_addr, input[8:0] wr_data, output[8:0] rd0_data, output[8:0] rd1_data);
	integer i;
	reg[8:0] content[4:0];
	always@(posedge rst, negedge clk)
		
		if(rst) begin
		for(i=0; i<4; i=i+1)
			content[i]=0;
		end
		else if(wr_en)
			content[wr_addr]=wr_data;

	assign rd0_data=content[rd0_addr];
	assign rd1_data=content[rd1_addr];
endmodule

module reg_file_tb;
	reg rst, clk, wr_en;
	reg[1:0] rd0_addr, rd1_addr, wr_addr;
	reg[8:0] wr_data;
	wire[8:0] rd0_data, rd1_data;

	reg_file rf (rst, clk, wr_en, rd0_addr, rd1_addr, wr_addr, wr_data, rd0_data, rd1_data);
	
	initial begin
		rst=1;
		#10 rst=0;
	end

	initial begin
		clk=1;
		forever #5 clk=~clk;
	end
	
	initial begin
		wr_en=1;
		wr_addr=2'd0;
		wr_data=2'd0;
		$monitor("clk=%b wr_en=%b rd0_addr=%d rd1_addr=%d wr_addr=%d wr_data=%d rd0_data=%d rd1_data=%d", $time, clk, wr_en, rd0_addr, rd1_addr, wr_addr, wr_data, rd0_data, rd1_data);
		#10 // write values to register file
		wr_en=1;
		wr_addr=1;
		wr_data=9'd500;
		rd0_addr=2'd1;
		rd1_addr=2'd2;
		#10 // different mux combinations/outputs
                wr_en=0;
		wr_addr=2;
		wr_data=9'd200;
		rd0_addr=2'd1;
		rd1_addr=2'd1;
		#10 // possible ALU outputs
		
		#10 $finish;
		
	end
endmodule
