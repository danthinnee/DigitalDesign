module RegFile32x32(input clock, input clear, input write1, input write2, input[4:0] write_index1, input[4:0] write_index2, input[31:0] write_data1, input[31:0] write_data2, input[4:0] read_index, output[31:0] read_value);
	reg[31:0] content[31:0];

	integer i;

	//write port
	always @ (posedge clear, negedge clock)
		if(clear) begin
			for(i=0; i<31; i=i+1)
				content[i] = 0;
		end else if(write1)
			content[write_index1] = write_data1;
		else if(write2)
			content[write_index2] = write_data2;

	// read ports
	assign read_value = content[read_index];
endmodule

module RegFile32x32_tb;
	reg clock, clear;
	reg write1, write2;
	reg[4:0] write_index1, write_index2, read_index;
	reg[31:0] write_data1, write_data2;
	wire[31:0] read_value;

	RegFile32x32 rf3232 (clock, clear, write1, write2, write_index1, write_index2, write_data1, write_data2, read_index, read_value);

	initial begin
		clear=1;
		#10 clear=0;
	end
	
	initial begin
		clock=1;
		forever #5 clock=~clock;
	end

	initial begin
		$monitor("%d clk=%b clr=%b write1=%b write2=%b write_index1=%d write_index2=%d write_data1=%d write_data2=%d read_index=%d read_value=%d",$time, clock, clear, write1, write2, write_index1, write_index2, write_data1, write_data2, read_index, read_value);
		#10 // both write ports are active, different ports
		write1=1;
		write2=1;
		write_index1=5'd5;
		write_index2=5'd10;
		write_data1=32'd30;
		write_data2=32'd300;
		read_index=5'd5;
		#10 // both write ports are active, same ports
		write1=1;
		write2=1;
		write_index1=5'd30;
		write_index2=5'd30;
                write_data1=32'd30;
                write_data2=32'd300;
                read_index=5'd5;
		#10 $finish;
	end
endmodule
