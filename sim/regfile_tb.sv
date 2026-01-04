`timescale 1ns/1ps

module regfile_tb;

  // ---- DUT ports (match regfile.sv) ----
  logic        clk;
  logic        we;
  logic [4:0]  rs1, rs2, rd;
  logic [31:0] wd;
  logic [31:0] rs1_data, rs2_data;

  // ---- Instantiate DUT ----
  regfile dut (
    .clk      (clk),
    .write_enable       (we),
    .read_register1      (rs1),
    .read_register2      (rs2),
    .write_register       (rd),
    .write_data       (wd),
    .read_data1 (rs1_data),
    .read_data2 (rs2_data)
  );

  // ---- Clock generation: 100 MHz (10 ns period) ----
  initial clk = 1'b0;
  always  #5 clk = ~clk;

  // ---- Helper task: one write on a rising edge ----
  task automatic write_reg(input logic [4:0] waddr, input logic [31:0] wdata);
    begin
      @(negedge clk);       // set up before next posedge
      we = 1'b1;
      rd = waddr;
      wd = wdata;
      @(posedge clk);       // write occurs here
      #1;                   // small delay for visibility
      we = 1'b0;
    end
  endtask

  // ---- Helper: set read addresses and check expected values ----
  task automatic check_reads(
      input logic [4:0] a1, input logic [31:0] exp1,
      input logic [4:0] a2, input logic [31:0] exp2
  );
    begin
      rs1 = a1;
      rs2 = a2;
      #1; // allow combinational reads to settle
      if (rs1_data !== exp1) begin
        $error("RS1 mismatch: rs1=%0d got=%h exp=%h", a1, rs1_data, exp1);
        $fatal;
      end
      if (rs2_data !== exp2) begin
        $error("RS2 mismatch: rs2=%0d got=%h exp=%h", a2, rs2_data, exp2);
        $fatal;
      end
    end
  endtask

  // ---- Main test sequence ----
  initial begin
    // default init
    we  = 1'b0;
    rs1 = 5'd0;
    rs2 = 5'd0;
    rd  = 5'd0;
    wd  = 32'd0;

    // Let a couple clocks tick
    repeat (2) @(posedge clk);

    $display("TEST 1: x0 should always read as 0");
    check_reads(5'd0, 32'h0000_0000, 5'd0, 32'h0000_0000);

    $display("TEST 2: write to x1, then read back");
    write_reg(5'd1, 32'hDEAD_BEEF);
    check_reads(5'd1, 32'hDEAD_BEEF, 5'd0, 32'h0000_0000);

    $display("TEST 3: write to x2 and x31, read both ports");
    write_reg(5'd2, 32'h1234_5678);
    write_reg(5'd31, 32'hCAFE_BABE);
    check_reads(5'd2, 32'h1234_5678, 5'd31, 32'hCAFE_BABE);

    $display("TEST 4: attempt to write x0 (should be ignored)");
    write_reg(5'd0, 32'hFFFF_FFFF);
    check_reads(5'd0, 32'h0000_0000, 5'd1, 32'hDEAD_BEEF);

    $display("ALL TESTS PASSED ✅");
    $finish;
  end

endmodule
