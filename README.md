# RV32I Single-Cycle RISC-V Processor (SystemVerilog)

A modular 32-bit **RV32I single-cycle RISC-V processor** implemented in **SystemVerilog** and simulated using **AMD/Xilinx Vivado**.  
This project focuses on **RTL design, instruction decoding, datapath integration, and verification**.

---

## Overview

This processor implements a subset of the RISC-V RV32I ISA using a **single-cycle datapath**, similar to classic textbook MIPS/RISC designs.

The design is split into clean, reusable modules:
- Instruction decode
- Register file
- ALU
- Program counter & instruction fetch
- Top-level core integration

Unit-level **self-checking testbenches** are provided for verification.

---

## Supported Instructions

### R-type
- `add`
- `sub`
- `and`
- `or`
- `xor`
- `sll`
- `srl`
- `sra`
- `slt`
- `sltu`

### I-type ALU
- `addi`
- `andi`
- `ori`
- `xori`
- `slti`
- `sltiu`
- `slli`
- `srli`
- `srai`

> Memory access (`lw/sw`) and branches are not implemented in this version.

---

## Project Structure

├── src/ # RTL design files
│ ├── alu.sv # 32-bit ALU
│ ├── regfile.sv # 32-register file (x0 hardwired to zero)
│ ├── decoder.sv # RV32I instruction decoder
│ ├── core_pc.sv # Program counter & instruction fetch
│ └── core.sv # Top-level core integration
│
|
├── sim/ # Simulation testbenches
│ ├── alu_tb.sv
│ ├── decoder_tb.sv
│ └── regfile_tb.sv
│
|
├── README.md
├── LICENSE
└── .gitignore


---

## Design Notes

- **Single-cycle datapath**: each instruction completes in one clock cycle
- **Combinational decode and ALU**
- **Synchronous register file write**
- **Instruction memory implemented as ROM (for simulation)**
- Clean separation between datapath and control logic

This structure mirrors classic RISC datapath diagrams while using modern SystemVerilog constructs (`always_ff`, `always_comb`).

---

## Verification

Each major module includes a **self-checking testbench**:
- ALU functional correctness
- Instruction decode validation
- Register file read/write behavior

All testbenches were simulated using **Vivado XSIM** prior to synthesis.

---

## Tools Used

- **SystemVerilog**
- **AMD/Xilinx Vivado**
- Vivado Simulator (XSIM)

---

## Future Improvements

- Branch instructions (`beq`, `bne`)
- Load/store support (`lw`, `sw`)
- Data memory
- Pipeline implementation
- FPGA I/O integration (LEDs / switches on Basys 3)

---

## Author
**Daljit Nijjar**  
Electrical Engineering — University of Calgary (Schulich School of Engineering)
SystemVerilog | RTL | Basys 3 FPGA
