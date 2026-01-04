module regfile (
    input  logic        clk,
    input  logic        write_enable,            // write enable
    input  logic [4:0]  read_register1,                     // read register 1
    input  logic [4:0]  read_register2,                     // read register 2
    input  logic [4:0]  write_register,          // write register
    input  logic [31:0] write_data,                      // write data
    output logic [31:0] read_data1,                // read data 1
    output logic [31:0] read_data2                 // read data 2
);

    // 32 registers, each 32 bits
    logic [31:0] regs [31:0];

    // Combinational reads
    assign read_data1 = (read_register1 == 0) ? 32'b0 : regs[read_register1];
    assign read_data2 = (read_register2 == 0) ? 32'b0 : regs[read_register2];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (write_enable && (write_register != 0)) begin
            regs[write_register] <= write_data;
        end
    end

endmodule
