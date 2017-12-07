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

// Multi-cycle control unit.
//
// State encoding:
//
//	State		Code
//	---------------------------
//	Fetch		0
//	Decode		1
//	Execute		2
//	AluWriteback	3
//	MemAddress	4
//	MemRead		5
//	MemWriteback	6
//	MemWrite	7
//	Branch		8
//
module ControlUnit(input clock,
		input clear,
		input[5:0] opcode,
		input[5:0] funct,
		output reg i_or_d,
		output reg mem_write,
		output reg inst_reg_write,
		output reg reg_dst,
		output reg mem_to_reg,
		output reg reg_write,
		output reg alu_src_a,
		output reg[1:0] alu_src_b,
		output reg[2:0] alu_op,
		output reg branch,
		output reg pc_write,
		output reg pc_src);

	reg[3:0] state;
	reg[3:0] next;

	// Block 1 - Reset of advance state
	always @(posedge clear, negedge clock)
		if (clear)
			state <= 0;
		else
			state <= next;
	
	// Block 2 - State transitions
	always @(state, opcode, funct)
		case (state)

			// Fetch
			0:
				// Fetch -> Decode
				next <= 1;

			// Decode
			1:
				case (opcode)

					// R-Type
					6'h00:

						// Decode -> Execute
						next <= 2;

					// lw, sw
					6'h23, 6'h2b:

						// Decode -> MemAddress
						next <= 4;

					// beq
					6'h04:

						// Decode -> Branch
						next <= 8;

					// Invalid
					default:

						// Undefined
						next <= 4'bx;
				endcase

			// Execute
			2:
				// Execute -> AluWriteback
				next <= 3;

			// AluWriteback
			3:
				// AluWriteback -> Fetch
				next <= 0;

			// MemAddress
			4:
				case (opcode)

					// lw
					6'h23:

						// MemAddress -> MemRead
						next <= 5;

					// sw
					6'h2b:

						// MemAddress -> MemWrite
						next <= 7;

					// Invalid
					default:
						
						// Undefined
						next <= 4'bx;
				endcase

			// MemRead
			5:
				// MemRead -> MemWriteback
				next <= 6;

			// MemWriteback
			6:
				// MemWriteback -> Fetch
				next <= 0;

			// MemWrite
			7:
				// MemWrite -> Fetch
				next <= 0;

			// Branch
			8:
				// Branch -> Fetch
				next <= 0;
		endcase
	
	// Block 3 - Outputs
	always @(state, funct) begin
		
		// Initially all undefined
		i_or_d = 1'bx;
		mem_write = 1'bx;
		inst_reg_write = 1'bx;
		reg_dst = 1'bx;
		mem_to_reg = 1'bx;
		reg_write = 1'bx;
		alu_src_a = 1'bx;
		alu_src_b = 2'bxx;
		alu_op = 3'bxxx;
		branch = 1'bx;
		pc_write = 1'bx;
		pc_src = 1'bx;

		// Check current state
		case (state)

			// Fetch
			0: begin
				// Signals
				i_or_d = 0;
				mem_write = 0;
				inst_reg_write = 1;
				reg_write = 0;
				alu_src_a = 0;
				alu_src_b = 1;
				alu_op = 3'b010;
				pc_write = 1;
				pc_src = 0;

				// Debug
				$display("-----------------------");
				$display("Fetch");
			end

			// Decode
			1: begin
				// Signals
				mem_write = 0;
				inst_reg_write = 0;
				reg_write = 0;
				alu_src_a = 0;
				alu_src_b = 3;
				alu_op = 3'b010;
				branch = 0;
				pc_write = 0;

				// Debug
				$display("Decode");
			end

			// Execute
			2: begin
				// Signals
				mem_write = 0;
				inst_reg_write = 0;
				reg_write = 0;
				alu_src_a = 1;
				alu_src_b = 0;
				branch = 0;
				pc_write = 0;

				// ALU operation
				case (funct)
					
					// add
					6'h20: alu_op = 3'b010;

					// sub
					6'h22: alu_op = 3'b110;

					// slt
					6'h2a: alu_op = 3'b111;

					// and
					6'h24: alu_op = 3'b000;

					// or
					6'h25: alu_op = 3'b001;

					// Invalid
					default: alu_op = 3'bxxx;
				
				endcase

				// Debug
				$display("Execute");
			end

			// AluWriteback
			3: begin
				// Signals
				mem_write = 0;
				inst_reg_write = 0;
				reg_dst = 1;
				mem_to_reg = 0;
				reg_write = 1;
				branch = 0;
				pc_write = 0;

				// Debug
				$display("AluWriteback");
			end

			// MemAddress
			4: begin
				// Signals
				mem_write = 0;
				inst_reg_write = 0;
				reg_write = 0;
				alu_src_a = 1;
				alu_src_b = 2;
				alu_op = 3'b010;
				branch = 0;
				pc_write = 0;

				// Debug
				$display("MemAddress");
			end

			// MemRead
			5: begin
				// Signals
				i_or_d = 1;
				mem_write = 0;
				inst_reg_write = 0;
				reg_write = 0;
				branch = 0;
				pc_write = 0;

				// Debug
				$display("MemRead");
			end

			// MemWriteback
			6: begin
				// Signals
				mem_write = 0;
				inst_reg_write = 0;
				reg_dst = 0;
				mem_to_reg = 1;
				reg_write = 1;
				branch = 0;
				pc_write = 0;

				// Debug
				$display("MemWriteback");
			end

			// MemWrite
			7: begin
				// Signals
				i_or_d = 1;
				mem_write = 1;
				inst_reg_write = 0;
				reg_write = 0;
				branch = 0;
				pc_write = 0;

				// Debug
				$display("MemWrite");
			end

			// Branch
			8: begin
				// Signals
				mem_write = 0;
				inst_reg_write = 0;
				reg_write = 0;
				alu_src_a = 1;
				alu_src_b = 0;
				alu_op = 3'b110;
				branch = 1;
				pc_write = 0;
				pc_src = 1;

				// Debug
				$display("Branch");
			end

		endcase
	end
endmodule

module Datapath(input clock,
		input clear);

	// PC register
	wire pc_enable;
	wire[31:0] pc_in;
	wire[31:0] pc_out;
	PcRegister pc_register(
			clock,
			clear,
			pc_enable,
			pc_in,
			pc_out);

	// Memory MUX
	wire[31:0] memory_mux_in0;
	wire[31:0] memory_mux_in1;
	wire memory_mux_sel;
	wire[31:0] memory_mux_out;
	Mux32Bit2To1 memory_mux(
			memory_mux_in0,
			memory_mux_in1,
			memory_mux_sel,
			memory_mux_out);

	// Connections for Memory MUX
	assign memory_mux_in0 = pc_out;

	// Memory
	wire[31:0] memory_address;
	wire memory_write;
	wire[31:0] memory_write_data;
	wire[31:0] memory_read_data;
	Memory memory(clock,
			clear,
			memory_address,
			memory_write,
			memory_write_data,
			memory_read_data);
	
	// Connections for memory
	assign memory_address = memory_mux_out;

	// Register 1
	wire register1_enable;
	wire[31:0] register1_in;
	wire[31:0] register1_out;
	Register register1(clock,
			clear,
			register1_enable,
			register1_in,
			register1_out);
	
	// Connections for Register 1
	assign register1_in = memory_read_data;

	// Register 2
	wire register2_enable;
	wire[31:0] register2_in;
	wire[31:0] register2_out;
	Register register2(clock,
			clear,
			register2_enable,
			register2_in,
			register2_out);
	
	// Connections for Register 2
	assign register2_enable = 1;
	assign register2_in = memory_read_data;

	// Register File MUX 1
	wire[4:0] register_file_mux1_in0;
	wire[4:0] register_file_mux1_in1;
	wire register_file_mux1_sel;
	wire[4:0] register_file_mux1_out;
	Mux5Bit2To1 register_file_mux1(
			register_file_mux1_in0,
			register_file_mux1_in1,
			register_file_mux1_sel,
			register_file_mux1_out);
	
	// Connections for Register File MUX 1
	assign register_file_mux1_in0 = register1_out[20:16];
	assign register_file_mux1_in1 = register1_out[15:11];
	
	// Register File MUX 2
	wire[31:0] register_file_mux2_in0;
	wire[31:0] register_file_mux2_in1;
	wire register_file_mux2_sel;
	wire[31:0] register_file_mux2_out;
	Mux32Bit2To1 register_file_mux2(
			register_file_mux2_in0,
			register_file_mux2_in1,
			register_file_mux2_sel,
			register_file_mux2_out);
	
	// Connections for Register File MUX 2
	assign register_file_mux2_in1 = register2_out;

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

	// Connections for Register File
	assign register_file_read_index1 = register1_out[25:21];
	assign register_file_read_index2 = register1_out[20:16];
	assign register_file_write_index = register_file_mux1_out;
	assign register_file_write_data = register_file_mux2_out;

	// Register 3
	wire register3_enable;
	wire[31:0] register3_in;
	wire[31:0] register3_out;
	Register register3(clock,
			clear,
			register3_enable,
			register3_in,
			register3_out);

	// Connections for Register 3
	assign register3_enable = 1;
	assign register3_in = register_file_read_data1;

	// Register 4
	wire register4_enable;
	wire[31:0] register4_in;
	wire[31:0] register4_out;
	Register register4(clock,
			clear,
			register4_enable,
			register4_in,
			register4_out);
	
	// Connections for Register 4
	assign register4_enable = 1;
	assign register4_in = register_file_read_data2;
	assign memory_write_data = register4_out;

	// SignExtend
	wire[15:0] sign_extend_in;
	wire[31:0] sign_extend_out;
	SignExtend sign_extend(sign_extend_in,
			sign_extend_out);
	
	// Connections for SignExtend
	assign sign_extend_in = register1_out[15:0];

	// ShiftLeft
	wire[31:0] shift_left_in;
	wire[31:0] shift_left_out;
	ShiftLeft shift_left(shift_left_in,
			shift_left_out);
	
	// Connections for ShiftLeft
	assign shift_left_in = sign_extend_out;

	// ALU MUX 1
	wire[31:0] alu_mux1_in0;
	wire[31:0] alu_mux1_in1;
	wire alu_mux1_sel;
	wire[31:0] alu_mux1_out;
	Mux32Bit2To1 alu_mux1(
			alu_mux1_in0,
			alu_mux1_in1,
			alu_mux1_sel,
			alu_mux1_out);
	
	// Connections for ALU MUX 1
	assign alu_mux1_in0 = pc_out;
	assign alu_mux1_in1 = register3_out;

	// ALU MUX 2
	wire[31:0] alu_mux2_in0;
	wire[31:0] alu_mux2_in1;
	wire[31:0] alu_mux2_in2;
	wire[31:0] alu_mux2_in3;
	wire[1:0] alu_mux2_sel;
	wire[31:0] alu_mux2_out;
	Mux32Bit4To1 alu_mux2(
			alu_mux2_in0,
			alu_mux2_in1,
			alu_mux2_in2,
			alu_mux2_in3,
			alu_mux2_sel,
			alu_mux2_out);
	
	// Connections for ALU MUX 2
	assign alu_mux2_in0 = register4_out;
	assign alu_mux2_in1 = 4;
	assign alu_mux2_in2 = sign_extend_out;
	assign alu_mux2_in3 = shift_left_out;

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
	assign alu_op1 = alu_mux1_out;
	assign alu_op2 = alu_mux2_out;
	
	// Register 5
	wire register5_enable;
	wire[31:0] register5_in;
	wire[31:0] register5_out;
	Register register5(clock,
			clear,
			register5_enable,
			register5_in,
			register5_out);
	
	// Connections for Register 5
	assign register5_enable = 1;
	assign register5_in = alu_result;
	assign register_file_mux2_in0 = register5_out;
	assign memory_mux_in1 = register5_out;

	// AND gate
	wire and_gate_in1;
	wire and_gate_in2;
	wire and_gate_out;
	and and_gate(and_gate_out,
			and_gate_in1,
			and_gate_in2);
	
	// Connections for AND gate
	assign and_gate_in2 = alu_zero;
	
	// OR gate
	wire or_gate_in1;
	wire or_gate_in2;
	wire or_gate_out;
	or or_gate(or_gate_out,
			or_gate_in1,
			or_gate_in2);
	
	// Connections for OR gate
	assign or_gate_in2 = and_gate_out;
	assign pc_enable = or_gate_out;

	// PC MUX
	wire[31:0] pc_mux_in0;
	wire[31:0] pc_mux_in1;
	wire pc_mux_sel;
	wire[31:0] pc_mux_out;
	Mux32Bit2To1 pc_mux(
			pc_mux_in0,
			pc_mux_in1,
			pc_mux_sel,
			pc_mux_out);

	// Connections for PC MUX
	assign pc_mux_in0 = alu_result;
	assign pc_mux_in1 = register5_out;
	assign pc_in = pc_mux_out;

	// Control unit
	wire[5:0] control_unit_opcode;
	wire[5:0] control_unit_funct;
	wire control_unit_i_or_d;
	wire control_unit_mem_write;
	wire control_unit_inst_reg_write;
	wire control_unit_reg_dst;
	wire control_unit_mem_to_reg;
	wire control_unit_reg_write;
	wire control_unit_alu_src_a;
	wire[1:0] control_unit_alu_src_b;
	wire[2:0] control_unit_alu_op;
	wire control_unit_branch;
	wire control_unit_pc_write;
	wire control_unit_pc_src;
	ControlUnit control_unit(
			clock,
			clear,
			control_unit_opcode,
			control_unit_funct,
			control_unit_i_or_d,
			control_unit_mem_write,
			control_unit_inst_reg_write,
			control_unit_reg_dst,
			control_unit_mem_to_reg,
			control_unit_reg_write,
			control_unit_alu_src_a,
			control_unit_alu_src_b,
			control_unit_alu_op,
			control_unit_branch,
			control_unit_pc_write,
			control_unit_pc_src,
			control_unit_jal);
	
	// Connections for control unit
	assign control_unit_opcode = register1_out[31:26];
	assign control_unit_funct = register1_out[5:0];
	assign memory_mux_sel = control_unit_i_or_d;
	assign memory_write = control_unit_mem_write;
	assign register1_enable = control_unit_inst_reg_write;
	assign register_file_mux1_sel = control_unit_reg_dst;
	assign register_file_mux2_sel = control_unit_mem_to_reg;
	assign register_file_write = control_unit_reg_write;
	assign alu_mux1_sel = control_unit_alu_src_a;
	assign alu_mux2_sel = control_unit_alu_src_b;
	assign alu_f = control_unit_alu_op;
	assign and_gate_in1 = control_unit_branch;
	assign or_gate_in1 = control_unit_pc_write;
	assign pc_mux_sel = control_unit_pc_src;

	// Debug info for current instruction, activated when the content of the
	// instruction register is updated.
	always @(negedge clock) begin
		if (!clear && register1_enable) begin

			// Print PC and instruction word
			$display("\tPC %x, Instruction %x",
					memory_address,
					memory_read_data);
			
			// Check opcode
			case (memory_read_data[31:26])

			// R-Type
			6'h00:
				// Check funct
				case (memory_read_data[5:0])

					// add
					6'h20: $display("\tInstruction 'add'");

					// sub
					6'h22: $display("\tInstruction 'sub'");

					// slt
					6'h2a: $display("\tInstruction 'slt'");

					// and
					6'h24: $display("\tInstruction 'and'");

					// or
					6'h25: $display("\tInstruction 'or'");

					// Invalid
					default: $display("\tInvalid instruction");
				endcase

			// lw
			6'h23: $display("\tInstruction 'lw'");

			// sw
			6'h2b: $display("\tInstruction 'sw'");

			// beq
			6'h04: $display("\tInstruction 'beq'");

			// Invalid
			default: $display("\tInvalid instruction");

			endcase
		end
	end

endmodule

// This is the test-bench for the multi-cycle datapath supporting instructions
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
		#10 clear = 0;
	end

	// Clock signal
	initial begin
		clock = 1;
		forever #5 clock = ~clock;
	end

	// Run for 11 cycles
	initial begin
		#460 $finish;
	end
endmodule

module Memory(input clock,
		input clear,
		input[31:0] address,
		input write,
		input[31:0] write_data,
		output reg[31:0] read_data);

	// Words 0-255 (first 1KB) represent addresses 0x400000-0x400400
	// Words 256-511 (last 1KB) represent addresses 0x10010000-0x10010400
	reg[31:0] content[511:0];
	integer i;
	
	always @(posedge clear, negedge clock)
		if (clear) begin

			// Reset content
			for (i = 0; i < 512; i = i + 1)
				content[i] = 0;

			// Initial values for instruction memory
			content[0] = 32'h00221820;	// add $3, $1, $2  <- label 'main'
			content[1] = 32'h00221822;	// sub $3, $1, $2
			content[2] = 32'h00221824;	// and $3, $1, $2
			content[3] = 32'h00221825;	// or $3, $1, $2
			content[4] = 32'h0022182a;	// slt $3, $1, $2
			content[5] = 32'h0041182a;	// slt $3, $2, $1
			content[6] = 32'h1140fff9;	// beq $10, $0, main
			content[7] = 32'h8d430000;	// lw $3, 0($10)
			content[8] = 32'h8d430004;	// lw $3, 4($10)
			content[9] = 32'had430008;	// sw $3, 8($10)
			content[10] = 32'h1000fff5;	// beq $0, $0, main
			
			// Initial values for data memory
			// Mem[0x10010000] = 100
			// Mem[0x10010004] = 200
			content[256] = 100;
			content[257] = 200;

		end else if (write &&
				address >= 32'h10010000 &&
				address < 32'h10010400) begin

			// Only write on valid addresses of data memory
			content[((address - 32'h10010000) >> 2) + 256] <= write_data;
			$display("\tMem[0x%x] = 0x%x", address, write_data);
		end

	// Read port
	always @(address)
		if (address >= 32'h400000 && address < 32'h400400)
			read_data <= content[(address - 32'h400000) >> 2];
		else if (address >= 32'h10010000 && address < 32'h10010400)
			read_data <= content[((address - 32'h10010000) >> 2) + 256];
		else
			read_data <= 0;
	
endmodule

module Mux32Bit2To1(input[31:0] in0,
		input[31:0] in1,
		input sel,
		output[31:0] out);

	assign out = sel ? in1 : in0;

endmodule

module Mux32Bit4To1(input[31:0] in0,
		input[31:0] in1,
		input[31:0] in2,
		input[31:0] in3,
		input[1:0] sel,
		output reg[31:0] out);
	
	always @(in0, in1, in2, in3, sel)
		case (sel)
			2'b00: out <= in0;
			2'b01: out <= in1;
			2'b10: out <= in2;
			2'b11: out <= in3;
		endcase
endmodule

module Mux5Bit2To1(input[4:0] in0,
		input[4:0] in1,
		input sel,
		output[4:0] out);

	assign out = sel ? in1 : in0;

endmodule

module PcRegister(input clock,
		input clear,
		input enable,
		input[31:0] in,
		output reg[31:0] out);

	// The initial value for the PC register is 0x400000;
	always @(posedge clear, negedge clock)
		if (clear)
			out = 32'h00400000;
		else if (enable)
			out = in;
endmodule

module Register(input clock,
		input clear,
		input enable,
		input[31:0] in,
		output reg[31:0] out);

	always @(posedge clear, negedge clock)
		if (clear)
			out = 0;
		else if (enable)
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

module SignExtend1(input[26:0] in,
                output[31:0] out);

        assign out = {{16{in[15]}}, in};

endmodule

