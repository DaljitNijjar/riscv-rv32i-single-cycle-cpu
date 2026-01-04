module core (
    input  logic        clk,
    input  logic        rst,      // synchronous reset for regfile
    input  logic [31:0] instr,    // instruction injected from testbench

    // useful debug taps
    output logic [4:0]  dbg_rs1,
    output logic [4:0]  dbg_rs2,
    output logic [4:0]  dbg_rd,
    output logic [31:0] dbg_imm,
    output logic [3:0]  dbg_alu_op,
    output logic        dbg_reg_write,
    output logic        dbg_alu_src_imm,
    output logic [31:0] dbg_rs1_data,
    output logic [31:0] dbg_rs2_data,
    output logic [31:0] dbg_alu_b,
    output logic [31:0] dbg_alu_result
);

    // -------- decoder outputs --------
    logic [4:0]  rs1, rs2, rd;
    logic [31:0] imm;
    logic        reg_write;
    logic        alu_src_imm;
    logic [3:0]  alu_op;

    decoder u_dec (
        .instr(instr),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm),
        .reg_write(reg_write),
        .alu_src_imm(alu_src_imm),
        .alu_op(alu_op)
    );

    // -------- regfile wires --------
    logic [31:0] rs1_data, rs2_data;
    logic [31:0] wd;
    logic        we;

    // Writeback is just ALU result for this minimal core
    assign wd = dbg_alu_result;
    assign we = reg_write;

    regfile u_rf (
        .clk(clk),
        .write_enable(we),
        .read_register1(rs1),
        .read_register2(rs2),
        .write_register(rd),
        .write_data(wd),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    // -------- ALU input mux --------
    logic [31:0] alu_b;

    assign alu_b = (alu_src_imm) ? imm : rs2_data;

    // -------- ALU --------
    logic [31:0] alu_result;
    logic        alu_zero;

    alu u_alu (
        .a(rs1_data),
        .b(alu_b),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(alu_zero)
    );

    // -------- debug outputs --------
    assign dbg_rs1        = rs1;
    assign dbg_rs2        = rs2;
    assign dbg_rd         = rd;
    assign dbg_imm        = imm;
    assign dbg_alu_op     = alu_op;
    assign dbg_reg_write  = reg_write;
    assign dbg_alu_src_imm= alu_src_imm;
    assign dbg_rs1_data   = rs1_data;
    assign dbg_rs2_data   = rs2_data;
    assign dbg_alu_b      = alu_b;
    assign dbg_alu_result = alu_result;

endmodule
