module core_pc #(
    parameter int IMEM_WORDS = 16
)(
    input  logic clk,
    input  logic rst,

    // debug
    output logic [31:0] dbg_pc,
    output logic [31:0] dbg_instr,
    output logic [4:0]  dbg_rd,
    output logic        dbg_reg_write,
    output logic [31:0] dbg_wd
);

    // ------------------------
    // Program Counter
    // ------------------------
    logic [31:0] pc;

    always_ff @(posedge clk) begin
        if (rst) pc <= 32'd0;
        else     pc <= pc + 32'd4;
    end

    // ------------------------
    // Instruction memory (ROM)
    // ------------------------
    logic [31:0] imem [0:IMEM_WORDS-1];

    // Initialize ROM with a small program
    // Program:
    //   addi x1, x0, 5
    //   addi x2, x1, 3
    //   add  x3, x1, x2
    //   srai x4, x3, 1
    //   (then NOPs)
    initial begin : init_imem
        integer i;
        for (i = 0; i < IMEM_WORDS; i = i + 1)
            imem[i] = 32'h00000013; // NOP = addi x0,x0,0

        // Encoding helpers (hard-coded encodings)
        imem[0] = 32'h00500093; // addi x1, x0, 5
        imem[1] = 32'h00308113; // addi x2, x1, 3
        imem[2] = 32'h002081B3; // add  x3, x1, x2
        imem[3] = 32'h4011D213; // srai x4, x3, 1
    end

    // Fetch
    logic [31:0] instr;
    logic [$clog2(IMEM_WORDS)-1:0] imem_addr;

    assign imem_addr = pc[($clog2(IMEM_WORDS)+1):2]; // word address
    assign instr     = imem[imem_addr];

    // ------------------------
    // Decode
    // ------------------------
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

    // ------------------------
    // Register file
    // ------------------------
    logic [31:0] rs1_data, rs2_data;

    // Writeback from ALU
    logic [31:0] wd;
    assign wd = dbg_wd;

    regfile u_rf (
        .clk(clk),
        .write_enable(reg_write),
        .read_register1(rs1),
        .read_register2(rs2),
        .write_register(rd),
        .write_data(wd),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    // ------------------------
    // ALU + operand mux
    // ------------------------
    logic [31:0] alu_b;
    logic [31:0] alu_result;
    logic        alu_zero;

    assign alu_b = (alu_src_imm) ? imm : rs2_data;

    alu u_alu (
        .a(rs1_data),
        .b(alu_b),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(alu_zero)
    );

    // ------------------------
    // Debug
    // ------------------------
    assign dbg_pc        = pc;
    assign dbg_instr     = instr;
    assign dbg_rd        = rd;
    assign dbg_reg_write = reg_write;
    assign dbg_wd        = alu_result;

endmodule
