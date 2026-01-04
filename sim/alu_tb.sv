`timescale 1ns/1ps

module alu_tb;

  logic [31:0] a, b;
  logic [3:0]  alu_op;
  logic [31:0] result;
  logic        zero;

  alu dut (
    .a(a),
    .b(b),
    .alu_op(alu_op),
    .result(result),
    .zero(zero)
  );

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

  // simple check "macro-like" pattern using a task-less approach
  task check;
    input [31:0] exp;
    begin
      #1;
      if (result !== exp) begin
        $display("FAIL op=%0h a=%h b=%h got=%h exp=%h",
                 alu_op, a, b, result, exp);
        errors = errors + 1;
      end
      if (zero !== (exp == 32'd0)) begin
        $display("ZERO flag wrong op=%0h exp=%b got=%b",
                 alu_op, (exp==0), zero);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    errors = 0;
    $display("ALU TESTS START");

    // ADD
    a = 32'd10; b = 32'd7;  alu_op = ALU_ADD;  check(32'd17);

    // SUB
    a = 32'd10; b = 32'd10; alu_op = ALU_SUB;  check(32'd0);

    // AND / OR / XOR
    a = 32'hF0F0_0000; b = 32'h0FF0_00FF;
    alu_op = ALU_AND; check(32'h00F0_0000);
    alu_op = ALU_OR;  check(32'hFFF0_00FF);
    alu_op = ALU_XOR; check(32'hFF00_00FF);

    // Shifts
    a = 32'h0000_0001; b = 32'd8; alu_op = ALU_SLL; check(32'h0000_0100);
    a = 32'h8000_0000; b = 32'd4; alu_op = ALU_SRL; check(32'h0800_0000);
    a = 32'h8000_0000; b = 32'd4; alu_op = ALU_SRA; check(32'hF800_0000);

    // SLT (signed)
    a = 32'hFFFF_FFFF; b = 32'd1; alu_op = ALU_SLT;  check(32'd1);
    a = 32'd5;         b = 32'd5; alu_op = ALU_SLT;  check(32'd0);

    // SLTU (unsigned)
    a = 32'hFFFF_FFFF; b = 32'd1; alu_op = ALU_SLTU; check(32'd0);
    a = 32'd1;         b = 32'd2; alu_op = ALU_SLTU; check(32'd1);

    if (errors == 0)
      $display("ALL ALU TESTS PASSED");
    else
      $display("ALU TESTS FAILED: %0d errors", errors);

    $finish;
  end

endmodule

