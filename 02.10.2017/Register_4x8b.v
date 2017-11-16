module RegFile4x8(input clock, input clear, input[1:0] read_index1, input[1:0] read_index2, input write, input[1:0] write_index, input[7:0] write_data, output[7:0] read_data1, output[7:0] read_data2);
	reg[7:0] content[3:0];

	integer i;

	//write port
	always @ (posedge clear, negedge clock)
		if(clear) begin
			for(i=0; i<4; i=i+1)
				content[i] = 0;
		end else if(write)
			content[write_index] = write_data;

	// read ports
	assign read_data1 = content[read_index1];
	assign read_data2 = content[read_index2];
endmodule
