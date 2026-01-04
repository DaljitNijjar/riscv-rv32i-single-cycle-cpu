`timescale 1ns/1ps

module core_tb;

  logic clk, rst;
  logic [31:0] instr;

  // Debug taps
  logic [4:0]  dbg_rs1, dbg_rs2, dbg_rd;
  logic [31:0] dbg_imm;
  logic [3:0]  dbg_alu_op;
  logic        dbg_reg_write, dbg_alu_src_imm;
  logic [31:0] dbg_rs1_data, dbg_rs2_data, dbg_alu_b, dbg_alu_result;

  core dut (
    .clk(clk),
    .rst(rst),
    .instr(instr),

    .dbg_rs1(dbg_rs1),
    .dbg_rs2(dbg_rs2),
    .dbg_rd(dbg_rd),
    .dbg_imm(dbg_imm),
    .dbg_alu_op(dbg_alu_op),
    .dbg_reg_write(dbg_reg_write),
    .dbg_alu_src_imm(dbg_alu_src_imm),
    .dbg_rs1_data(dbg_rs1_data),
    .dbg_rs2_data(dbg_rs2_data),
    .dbg_alu_b(dbg_alu_b),
    .dbg_alu_result(dbg_alu_result)
  );

  // clock
  initial clk = 0;
  always #5 clk = ~clk;

  // helpers to build instructions
  function automatic [31:0] R_type(input [6:0] funct7, input [4:0] rs2, input [4:0] rs1,
                                   input [2:0] funct3, input [4:0] rd, input [6:0] opcode);
    R_type = {funct7, rs2, rs1, funct3, rd, opcode};
  endfunction

  function automatic [31:0] I_type(input [11:0] imm12, input [4:0] rs1,
                                   input [2:0] funct3, input [4:0] rd, input [6:0] opcode);
    I_type = {{20{imm12[11]}}, imm12, rs1, funct3, rd, opcode};
  endfunction

  // Apply an instruction for one cycle
  task do_instr(input [31:0] insn);
    begin
      instr = insn;
      @(posedge clk);
      #1; // allow combinational settle for viewing
    end
  endtask

  initial begin
    // init
    rst = 0;
    instr = 32'd0;

    // Let initial X settle
    repeat (2) @(posedge clk);

    // Program (no PC): just feed instructions sequentially
    // addi x1, x0, 5
    do_instr(I_type(12'd5, 5'd0, 3'b000, 5'd1, 7'b0010011));

    // addi x2, x1, 3
    do_instr(I_type(12'd3, 5'd1, 3'b000, 5'd2, 7'b0010011));

    // add  x3, x1, x2
    do_instr(R_type(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011));

    // srai x4, x3, 1  (I-type shift: funct7=0100000, shamt=1, funct3=101)
    // encoding: {funct7, shamt, rs1, funct3, rd, opcode}
    do_instr({7'b0100000, 5'd1, 5'd3, 3'b101, 5'd4, 7'b0010011});

    // stop
    $display("DONE. Check waves: x1=5, x2=8, x3=13, x4=6 (arith shift).");
    $finish;
  end

endmodule
