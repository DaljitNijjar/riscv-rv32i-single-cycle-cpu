module decoder (
    input  logic [31:0] instr,

    // register specifiers
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,

    // immediate (sign-extended)
    output logic [31:0] imm,

    // control
    output logic        reg_write,   // writeback enable
    output logic        alu_src_imm,  // 1 = ALU uses imm as B input, 0 = uses rs2_data
    output logic [3:0]  alu_op        // matches your ALU opcodes
);

    // Instruction fields
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    // ALU opcodes (MUST match alu.sv)
    localparam logic [3:0]
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

    // Defaults
    always_comb begin
        imm        = 32'd0;
        reg_write  = 1'b0;
        alu_src_imm= 1'b0;
        alu_op     = ALU_ADD;

        unique case (opcode)

            // -------------------------
            // R-type (opcode = 0110011)
            // -------------------------
            7'b0110011: begin
                reg_write   = 1'b1;
                alu_src_imm = 1'b0;

                unique case (funct3)
                    3'b000: alu_op = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD; // sub vs add
                    3'b111: alu_op = ALU_AND;
                    3'b110: alu_op = ALU_OR;
                    3'b100: alu_op = ALU_XOR;
                    3'b001: alu_op = ALU_SLL;
                    3'b101: alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL; // sra vs srl
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    default: alu_op = ALU_ADD;
                endcase
            end

            // -------------------------
            // I-type ALU (opcode = 0010011)
            // addi/andi/ori/xori/slti/sltiu/slli/srli/srai
            // -------------------------
            7'b0010011: begin
                reg_write   = 1'b1;
                alu_src_imm = 1'b1;

                // sign-extended 12-bit immediate
                imm = {{20{instr[31]}}, instr[31:20]};

                unique case (funct3)
                    3'b000: alu_op = ALU_ADD;   // addi
                    3'b111: alu_op = ALU_AND;   // andi
                    3'b110: alu_op = ALU_OR;    // ori
                    3'b100: alu_op = ALU_XOR;   // xori
                    3'b010: alu_op = ALU_SLT;   // slti
                    3'b011: alu_op = ALU_SLTU;  // sltiu

                    // shifts use shamt in instr[24:20], funct7 distinguishes srli/srai
                    3'b001: begin               // slli
                        alu_op = ALU_SLL;
                        imm    = {27'd0, instr[24:20]}; // shamt as immediate
                    end
                    3'b101: begin
                        alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL; // srai vs srli
                        imm    = {27'd0, instr[24:20]}; // shamt as immediate
                    end

                    default: alu_op = ALU_ADD;
                endcase
            end

            default: begin
                // unsupported opcode -> keep defaults (no write)
                reg_write   = 1'b0;
                alu_src_imm = 1'b0;
                alu_op      = ALU_ADD;
                imm         = 32'd0;
            end
        endcase
    end

endmodule
