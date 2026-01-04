`timescale 1ns/1ps

module core_pc_tb;

  logic clk, rst;

  logic [31:0] dbg_pc, dbg_instr;
  logic [4:0]  dbg_rd;
  logic        dbg_reg_write;
  logic [31:0] dbg_wd;

  core_pc #(.IMEM_WORDS(16)) dut (
    .clk(clk),
    .rst(rst),
    .dbg_pc(dbg_pc),
    .dbg_instr(dbg_instr),
    .dbg_rd(dbg_rd),
    .dbg_reg_write(dbg_reg_write),
    .dbg_wd(dbg_wd)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst = 1;
    repeat (2) @(posedge clk);
    rst = 0;

    // Run a few cycles
    repeat (10) @(posedge clk);

    $display("Done. Expect writes:");
    $display("pc=0  addi x1 -> 5");
    $display("pc=4  addi x2 -> 8");
    $display("pc=8  add  x3 -> 13");
    $display("pc=12 srai x4 -> 6");
    $finish;
  end

endmodule
