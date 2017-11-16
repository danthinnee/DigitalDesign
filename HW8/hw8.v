module Adder(input[31:0] op1,
		input[31:0] op2,
		output[31:0] result);
	
	assign result = op1 + op2;

endmodule

module Adder4(input[31:0] in,
		output[31:0] out);

	assign out = in + 4;
endmodule

module Alu(input[31:0] op1,
		input[31:0] op2,
		input[2:0] f,
		output reg[31:0] result,
		output zero);

	always @(op1, op2, f)
		case (f)
			3'b000: result = op1 & op2;
			3'b001: result = op1 | op2;
			3'b010: result = op1 + op2;
			3'b011: result = 32'hxxxxxxxx;
			3'b100: result = op1 & ~op2;
			3'b101: result = op1 | ~op2;
			3'b110: result = op1 - op2;
			3'b111: result = op1 < op2;
		endcase
	
	assign zero = result == 0;
endmodule

module DataMemory(input clock,
		input clear,
		input[31:0] address,
		input write,
		input[31:0] write_data,
		output[31:0] read_data);

	// We model 1KB of data memory
	reg[31:0] content[255:0];
	integer i;
	
	always @(posedge clear, negedge clock)
		if (clear) begin

			// Reset memory
			for (i = 0; i < 256; i = i + 1)
				content[i] = 0;

			// Initial values
			// Mem[0x10010000] = 100
			// Mem[0x10010004] = 200
			content[0] = 100;
			content[1] = 200;

		end else if (write
				&& address >= 32'h10010000
				&& address < 32'h10011000)
		begin

			// Valid addresses
			content[(address - 32'h10001000) >> 2] = write_data;
			$display("\tM[%x] = %x (hex)", address, write_data);
		end

	// Return 0 if address is not valid
	assign read_data = address >= 32'h10010000
			&& address < 32'h10011000 ?
			content[(address - 32'h10010000) >> 2] : 0;
	
endmodule

module ControlUnit(input[5:0] opcode,
		input[5:0] funct,
		output reg reg_dst,
		output reg reg_write,
		output reg alu_src,
		output reg[2:0] alu_op,
		output reg branch,
		output reg mem_write,
		output reg mem_to_reg,
		output reg immextend);

	always @(opcode, funct) begin
		
		// Make sure that all output have an initial value assigned in
		// order to prevent synthesis of sequential logic.
		reg_dst = 1'bx;
		reg_write = 1'bx;
		alu_src = 1'bx;
		alu_op = 3'bxxx;
		branch = 1'bx;
		mem_write = 1'bx;
		mem_to_reg = 1'bx;

		// Check opcode
		case (opcode)

			// If opcode is 0, check funct
			6'h00: begin

				// Common signals
				reg_dst = 1;
				reg_write = 1;
				alu_src = 0;
				branch = 0;
				mem_write = 0;
				mem_to_reg = 0;
				immextend = 0;
				// ALU operation depends on funct
				case (funct)

					// add
					6'h20: begin
						alu_op = 3'b010;
						immextend = 0;
						$display("\tInstruction 'add'");
					end

					// sub
					6'h22: begin
						alu_op = 3'b110;
						immextend = 0;
						$display("\tInstruction 'sub'");
					end

					// slt
					6'h2a: begin
						alu_op = 3'b111;
						immextend = 0;
						$display("\tInstruction 'slt'");
					end

					// and
					6'h24: begin
						alu_op = 3'b000;
						immextend = 0;
						$display("\tInstruction 'and'");
					end

					// or
					6'h25: begin
						alu_op = 3'b001;
						immextend = 0;
						$display("\tInstruction 'or'");
					end
				endcase
			end

			// lw
			6'h23: begin
				reg_dst = 0;
				reg_write = 1;
				alu_src = 1;
				alu_op = 3'b010;
				branch = 0;
				mem_write = 0;
				mem_to_reg = 1;
				immextend = 0;
				$display("\tInstruction 'lw'");
			end

			// sw
			6'h2b: begin
				reg_write = 0;
				alu_src = 1;
				alu_op = 3'b010;
				branch = 0;
				mem_write = 1;
				immextend = 0;
				$display("\tInstruction 'sw'");
			end

			// beq
			6'h04: begin
				reg_write = 0;
				alu_src = 0;
				alu_op = 3'b110;
				branch = 1;
				mem_write = 0;
				immextend = 0;
				$display("\tInstruction 'beq'");
			end

			// addi
			6'h08: begin
                               	reg_dst = 0;
				reg_write = 1;
                                alu_src = 1;
                                alu_op = 3'b010;
                                branch = 0;
                                mem_write = 0;
				mem_to_reg = 0;
				immextend = 0;
                                $display("\tInstruction 'addi'");
                        end

			// ori
			6'h0d: begin
				reg_dst = 0;
                                reg_write = 1;
                                alu_src = 1;
                                alu_op = 3'b001;
                                branch = 0;
                                mem_write = 0;
                                mem_to_reg = 0;
				immextend = 1;
				$display("\tInstruction 'ori'");	
			end
		endcase
	end
endmodule

module Datapath(input clock,
		input clear);

	// PC register
	wire[31:0] pc_in;
	wire[31:0] pc_out;
	PcRegister pc_register(
			clock,
			clear,
			pc_in,
			pc_out);

	// Instruction memory
	wire[31:0] instruction_memory_address;
	wire[31:0] instruction_memory_instr;
	InstructionMemory instruction_memory(
			clock,
			clear,
			instruction_memory_address,
			instruction_memory_instr);
	
	// Connections for instruction memory
	assign instruction_memory_address = pc_out;
	
	// Adder4
	wire[31:0] adder4_in;
	wire[31:0] adder4_out;
	Adder4 adder4(adder4_in,
			adder4_out);
	
	// Connections for Adder4
	assign adder4_in = pc_out;
	
	// PC MUX
	wire[31:0] pc_mux_in0;
	wire[31:0] pc_mux_in1;
	wire[31:0] pc_mux_out;
	wire pc_mux_sel;
	Mux32Bit2To1 pc_mux(pc_mux_in0,
			pc_mux_in1,
			pc_mux_sel,
			pc_mux_out);
	
	// Connections for PC MUX
	assign pc_in = pc_mux_out;
	assign pc_mux_in0 = adder4_out;

	// Register file MUX
	wire[4:0] register_file_mux_in0;
	wire[4:0] register_file_mux_in1;
	wire[4:0] register_file_mux_out;
	wire register_file_mux_sel;
	Mux5Bit2To1 register_file_mux(
			register_file_mux_in0,
			register_file_mux_in1,
			register_file_mux_sel,
			register_file_mux_out);
	
	// Connections for register file MUX
	assign register_file_mux_in0 = instruction_memory_instr[20:16];
	assign register_file_mux_in1 = instruction_memory_instr[15:11];

	// Register file
	wire[4:0] register_file_read_index1;
	wire[31:0] register_file_read_data1;
	wire[4:0] register_file_read_index2;
	wire[31:0] register_file_read_data2;
	wire register_file_write;
	wire[4:0] register_file_write_index;
	wire[31:0] register_file_write_data;
	RegisterFile register_file(
			clock,
			clear,
			register_file_read_index1,
			register_file_read_data1,
			register_file_read_index2,
			register_file_read_data2,
			register_file_write,
			register_file_write_index,
			register_file_write_data);
	
	// Connections for register file
	assign register_file_read_index1 = instruction_memory_instr[25:21];
	assign register_file_read_index2 = instruction_memory_instr[20:16];
	assign register_file_write_index = register_file_mux_out;

	// ALU MUX
	wire[31:0] alu_mux_in0;
	wire[31:0] alu_mux_in1;
	wire[31:0] alu_mux_out;
	wire alu_mux_sel;
	Mux32Bit2To1 alu_mux(
			alu_mux_in0,
			alu_mux_in1,
			alu_mux_sel,
			alu_mux_out);
	
	// Connections for ALU MUX
	assign alu_mux_in0 = register_file_read_data2;

	// ALU
	wire[31:0] alu_op1;
	wire[31:0] alu_op2;
	wire[2:0] alu_f;
	wire[31:0] alu_result;
	wire alu_zero;
	Alu alu(alu_op1,
			alu_op2,
			alu_f,
			alu_result,
			alu_zero);
	
	// Connections for ALU
	assign alu_op1 = register_file_read_data1;
	assign alu_op2 = alu_mux_out;

	// Data memory
	wire[31:0] data_memory_address;
	wire data_memory_write;
	wire[31:0] data_memory_write_data;
	wire[31:0] data_memory_read_data;
	DataMemory data_memory(
			clock,
			clear,
			data_memory_address,
			data_memory_write,
			data_memory_write_data,
			data_memory_read_data);

	// Connections for data memory
	assign data_memory_address = alu_result;
	assign data_memory_write_data = register_file_read_data2;

	// Data memory MUX
	wire[31:0] data_memory_mux_in0;
	wire[31:0] data_memory_mux_in1;
	wire data_memory_mux_sel;
	wire[31:0] data_memory_mux_out;
	Mux32Bit2To1 data_memory_mux(
			data_memory_mux_in0,
			data_memory_mux_in1,
			data_memory_mux_sel,
			data_memory_mux_out);
	
	// Connections for data memory MUX
	assign data_memory_mux_in0 = alu_result;
	assign data_memory_mux_in1 = data_memory_read_data;
	assign register_file_write_data = data_memory_mux_out;

	// SignExtend
	wire[15:0] extend_in;
	wire[31:0] sign_extend_out;
	wire[31:0] zero_extend_out;
	SignExtend sign_extend(
			extend_in,
			sign_extend_out);
	ZeroExtend zero_extend(extend_in, zero_extend_out);
	
	wire[31:0] immextend_mux_out;
	wire immextend_mux_sel;
	Mux32Bit2To1 immextend_mux(sign_extend_out, zero_extend_out, immextend_mux_sel, immextend_mux_out);
	// Connections for SignExtend
	assign extend_in = instruction_memory_instr[15:0];
	assign alu_mux_in1 = immextend_mux_out;
	
	// ShiftLeft
	wire[31:0] shift_left_in;
	wire[31:0] shift_left_out;
	ShiftLeft shift_left(
			shift_left_in,
			shift_left_out);
	
	// Connections for ShiftLeft
	assign shift_left_in = immextend_mux_out;

	// Adder
	wire[31:0] adder_op1;
	wire[31:0] adder_op2;
	wire[31:0] adder_result;
	Adder adder(adder_op1,
			adder_op2,
			adder_result);
	
	// Connections for adder
	assign adder_op1 = shift_left_out;
	assign adder_op2 = adder4_out;
	assign pc_mux_in1 = adder_result;

	// And gate
	wire and_gate_in1;
	wire and_gate_in2;
	wire and_gate_out;
	and and_gate(and_gate_out,
			and_gate_in1,
			and_gate_in2);
	
	// Connections for and gate
	assign and_gate_in2 = alu_zero;
	assign pc_mux_sel = and_gate_out;

	// Control unit
	wire[5:0] control_unit_opcode;
	wire[5:0] control_unit_funct;
	wire control_unit_reg_dst;
	wire control_unit_reg_write;
	wire control_unit_alu_src;
	wire[2:0] control_unit_alu_op;
	wire control_unit_branch;
	wire control_unit_mem_write;
	wire control_unit_mem_to_reg;
	wire control_unit_immextend;
	ControlUnit control_unit(
			control_unit_opcode,
			control_unit_funct,
			control_unit_reg_dst,
			control_unit_reg_write,
			control_unit_alu_src,
			control_unit_alu_op,
			control_unit_branch,
			control_unit_mem_write,
			control_unit_mem_to_reg,
			control_unit_immextend);
	
	// Connections for control unit
	assign control_unit_opcode = instruction_memory_instr[31:26];
	assign control_unit_funct = instruction_memory_instr[5:0];
	assign register_file_mux_sel = control_unit_reg_dst;
	assign register_file_write = control_unit_reg_write;
	assign alu_mux_sel = control_unit_alu_src;
	assign alu_f = control_unit_alu_op;
	assign and_gate_in1 = control_unit_branch;
	assign data_memory_write = control_unit_mem_write;
	assign data_memory_mux_sel = control_unit_mem_to_reg;
	assign immextend_mux_sel = control_unit_immextend;

endmodule

module InstructionMemory(input clock,
		input clear,
		input[31:0] address,
		output [31:0] instr);

	reg[31:0] content[255:0];
	integer i;
	
	always @(posedge clear, negedge clock)
		if (clear) begin

			// Reset content
			for (i = 0; i < 256; i = i + 1)
				content[i] = 0;

			// Initial values
			/*content[0] = 32'h00221820;	// add $3, $1, $2  <- label 'main'
			content[1] = 32'h00221822;	// sub $3, $1, $2
			content[2] = 32'h00221824;	// and $3, $1, $2
			content[3] = 32'h00221825;	// or $3, $1, $2
			content[4] = 32'h0022182a;	// slt $3, $1, $2
			content[5] = 32'h0041182a;	// slt $3, $2, $1
			content[6] = 32'h1140fff9;	// beq $10, $0, main
			content[7] = 32'h8d430000;	// lw $3, 0($10)
			content[8] = 32'h8d430004;	// lw $3, 4($10)
			content[9] = 32'had430008;	// sw $3, 8($10)
			content[10] = 32'h1000fff5;	// beq $0, $0, main */

			content[0] = 32'h22000001;      // addi $s0, $zero, 0x1
                        content[1] = 32'h36108000;      // ori $s0, $s0, 0x8000
                        content[2] = 32'h2210ffff;      // addi $s0, $s0, -1

		end

	// Read instruction
	assign instr = address >= 32'h400000 && address < 32'h4001000 ?
			content[(address - 32'h400000) >> 2] : 0;

	// Display current instruction
	always @(instr)
		$display("Fetch at PC %08x: instruction %08x", address, instr);
	
endmodule

module Mux32Bit2To1(input[31:0] in0,
		input[31:0] in1,
		input sel,
		output[31:0] out);

	assign out = sel ? in1 : in0;

endmodule

module Mux5Bit2To1(input[4:0] in0,
		input[4:0] in1,
		input sel,
		output[4:0] out);

	assign out = sel ? in1 : in0;

endmodule

module PcRegister(input clock,
		input clear,
		input[31:0] in,
		output reg[31:0] out);

	// The initial value for the PC register is 0x400000;
	always @(posedge clear, negedge clock)
		if (clear)
			out = 32'h00400000;
		else
			out = in;
endmodule

module RegisterFile(input clock,
		input clear,
		input[4:0] read_index1,
		output[31:0] read_data1,
		input[4:0] read_index2,
		output[31:0] read_data2,
		input write,
		input[4:0] write_index,
		input[31:0] write_data);

	reg[31:0] content[31:0];
	integer i;

	always @(posedge clear, negedge clock)
		if (clear) begin

			// Reset all registers
			for (i = 0; i < 32; i = i + 1)
				content[i] = 0;

			// Set initial values
			content[1] = 1;			// $1 = 1
			content[2] = 2;			// $2 = 2
			content[10] = 32'h10010000;	// $10 = 0x10010000
		end else if (write) begin
			content[write_index] = write_data;
			$display("\tR[%d] = %x (hex)", write_index, write_data);
		end

	// A read to register 0 always returns 0
	assign read_data1 = read_index1 == 0 ? 0 : content[read_index1];
	assign read_data2 = read_index2 == 0 ? 0 : content[read_index2];

endmodule

module ShiftLeft(input[31:0] in,
		output[31:0] out);
	
	assign out = in << 2;

endmodule

module SignExtend(input[15:0] in,
		output[31:0] out);

	assign out = {{16{in[15]}}, in};

endmodule

module ZeroExtend(input[15:0] in, output[31:0] out);
	assign out = {{16'b0},in};
endmodule
// This is the test-bench for the single-cycle datapath supporting instructions
// add, sub, slt, and, or, lw, sw, beq. When sequential logic components are
// sent an asynchronous reset signal (clear), their content is set to the
// following values:
//
// * The initial value of register PC is 0x400000.
//
// * The initial value of all registers are 0, except for the following
//   registers:
//
//	$1 = 1
//	$2 = 2
//	#3 = 0x10010000 (base address of data segment)
//
// * The data memory is initialized with the following words:
//
//	[0x10010000] = 100
//	[0x10010004] = 200
//
// * The instruction memory has been initialized to contain the following
//   program:
//
//	main:
// 		add $3, $1, $2		# $3 = 1 + 2 = 3
// 		sub $3, $1, $2		# $3 = 1 - 2 = -1
// 		and $3, $1, $2		# $3 = 1 & 2 = 0
// 		or $3, $1, $2		# $3 = 1 | 2 = 3
// 		slt $3, $1, $2		# $3 = 1 < 2 = 1 (true)
// 		slt $3, $2, $1		# $3 = 2 < 1 = 0 (false)
// 		beq $10, $zero, main	# Doesn't jump, $10 is 0x10010000
// 		lw $3, 0($10)		# $3 = Mem[0x10010000] = 100
// 		lw $3, 4($10)		# $3 = Mem[0x10010004] = 200
// 		sw $3, 8($10)		# Mem[0x10010008] = 200
// 		beq $zero, $zero, main	# Jumps to main
// 
module Main;

	// The datapath
	reg clock;
	reg clear;
	Datapath datapath(clock, clear);

	// Initial pulse for 'clear'
	initial begin
		clear = 1;
		#5 clear = 0;
	end

	// Clock signal
	initial begin
		clock = 1;
		forever #5 clock = ~clock;
	end

	// Run for 11 cycles
	initial begin
		#110 $finish;
	end
endmodule

