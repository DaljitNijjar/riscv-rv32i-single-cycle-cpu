`timescale 1ns/1ps

module decoder_tb;

  logic [31:0] instr;
  logic [4:0]  rs1, rs2, rd;
  logic [31:0] imm;
  logic        reg_write, alu_src_imm;
  logic [3:0]  alu_op;

  decoder dut (
    .instr(instr),
    .rs1(rs1), .rs2(rs2), .rd(rd),
    .imm(imm),
    .reg_write(reg_write),
    .alu_src_imm(alu_src_imm),
    .alu_op(alu_op)
  );

  // ALU opcode mirrors
  localparam [3:0]
    ALU_ADD  = 4'h0,
    ALU_SUB  = 4'h1,
    ALU_AND  = 4'h2,
    ALU_OR   = 4'h3,
    ALU_XOR  = 4'h4,
    ALU_SLL  = 4'h5,
    ALU_SRL  = 4'h6,
    ALU_SRA  = 4'h7,
    ALU_SLT  = 4'h8,
    ALU_SLTU = 4'h9;

  integer errors;

  task check;
    input [127:0] name;
    input exp_reg_write;
    input exp_alu_src_imm;
    input [3:0] exp_alu_op;
    input [4:0] exp_rs1, exp_rs2, exp_rd;
    input [31:0] exp_imm;
    begin
      #1;
      if (reg_write !== exp_reg_write) begin $display("FAIL %s reg_write", name); errors++; end
      if (alu_src_imm !== exp_alu_src_imm) begin $display("FAIL %s alu_src_imm", name); errors++; end
      if (alu_op !== exp_alu_op) begin $display("FAIL %s alu_op got=%0h exp=%0h", name, alu_op, exp_alu_op); errors++; end
      if (rs1 !== exp_rs1) begin $display("FAIL %s rs1", name); errors++; end
      if (rs2 !== exp_rs2) begin $display("FAIL %s rs2", name); errors++; end
      if (rd  !== exp_rd ) begin $display("FAIL %s rd",  name); errors++; end
      if (imm !== exp_imm) begin $display("FAIL %s imm got=%h exp=%h", name, imm, exp_imm); errors++; end
    end
  endtask

  initial begin
    errors = 0;

    // test for all R-Type and I-Type Instructions
    
    // R-type ADD: add x3, x1, x2
    // opcode=0110011 funct3=000 funct7=0000000
    instr = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
    check("R-ADD", 1, 0, ALU_ADD, 5'd1, 5'd2, 5'd3, 32'd0);

    // R-type SUB: sub x3, x1, x2 (funct7=0100000)
    instr = {7'b0100000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
    check("R-SUB", 1, 0, ALU_SUB, 5'd1, 5'd2, 5'd3, 32'd0);
    
    // R-type AND: and x3, x1, x2  funct3=111
    instr = {7'b0000000, 5'd2, 5'd1, 3'b111, 5'd3, 7'b0110011};
    check("R-AND", 1, 0, ALU_AND, 5'd1, 5'd2, 5'd3, 32'd0);

    // R-type OR: or x3, x1, x2  funct3=110
    instr = {7'b0000000, 5'd2, 5'd1, 3'b110, 5'd3, 7'b0110011};
    check("R-OR", 1, 0, ALU_OR, 5'd1, 5'd2, 5'd3, 32'd0);

    // R-type XOR: xor x3, x1, x2  funct3=100
    instr = {7'b0000000, 5'd2, 5'd1, 3'b100, 5'd3, 7'b0110011};
    check("R-XOR", 1, 0, ALU_XOR, 5'd1, 5'd2, 5'd3, 32'd0);

    // R-type SLL: sll x3, x1, x2 funct3=001
    instr = {7'b0000000, 5'd2, 5'd1, 3'b001, 5'd3, 7'b0110011};
    check("R-SLL", 1, 0, ALU_SLL, 5'd1, 5'd2, 5'd3, 32'd0);

    // R-type SRL: srl x3, x1, x2 funct3=101 funct7=0000000
    instr = {7'b0000000, 5'd2, 5'd1, 3'b101, 5'd3, 7'b0110011};
    check("R-SRL", 1, 0, ALU_SRL, 5'd1, 5'd2, 5'd3, 32'd0);

    // R-type SRA: sra x3, x1, x2 funct3=101 funct7=0100000
    instr = {7'b0100000, 5'd2, 5'd1, 3'b101, 5'd3, 7'b0110011};
    check("R-SRA", 1, 0, ALU_SRA, 5'd1, 5'd2, 5'd3, 32'd0);

    // R-type SLT: slt x3, x1, x2 funct3=010
    instr = {7'b0000000, 5'd2, 5'd1, 3'b010, 5'd3, 7'b0110011};
    check("R-SLT", 1, 0, ALU_SLT, 5'd1, 5'd2, 5'd3, 32'd0);

    // R-type SLTU: sltu x3, x1, x2 funct3=011
    instr = {7'b0000000, 5'd2, 5'd1, 3'b011, 5'd3, 7'b0110011};
    check("R-SLTU", 1, 0, ALU_SLTU, 5'd1, 5'd2, 5'd3, 32'd0);

    // I-type ADDI: addi x5, x1, 10
    instr = {{20{1'b0}}, 12'd10, 5'd1, 3'b000, 5'd5, 7'b0010011};
    check("I-ADDI", 1, 1, ALU_ADD, 5'd1, 5'd10 /*rs2 field is imm bits*/, 5'd5, 32'd10);

    // I-type ANDI: andi x6, x1, -1 (imm=0xFFF)
    instr = {20'h00000, 12'hFFF, 5'd1, 3'b111, 5'd6, 7'b0010011};
    check("I-ANDI", 1, 1, ALU_AND, 5'd1, 5'h1F, 5'd6, 32'hFFFF_FFFF);

    // I-type SRAI: srai x7, x1, 4  (funct7=0100000, shamt=4)
    instr = {7'b0100000, 5'd4, 5'd1, 3'b101, 5'd7, 7'b0010011};
    check("I-SRAI", 1, 1, ALU_SRA, 5'd1, 5'd4, 5'd7, 32'd4);


    if (errors == 0) $display("ALL DECODER TESTS PASSED");
    else $display("DECODER TESTS FAILED: %0d errors", errors);

    $finish;
  end

endmodule
