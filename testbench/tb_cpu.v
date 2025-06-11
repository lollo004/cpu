`timescale 1ns/1ps

module tb_cpu;
    reg clk = 0;
    reg rst = 1;

    cpu uut (.*);

    // Clock generation
    always #5 clk = ~clk;

    // Memory view configuration
    parameter DMEM_START_ADDR = 0;
    parameter DMEM_WORDS = 4;  // number of 16-bit words

    // Change detection
    reg [15:0] last_regs [15:0];
    reg [15:0] last_dmem [0:1023];

    // Helper: Instruction decoder (simple)
    function [256*8-1:0] decode_instr;
        input [15:0] instr;
        reg [3:0] op, rs, rt, rd;
        reg [11:0] imm;
        begin
            op = instr[15:12];
            rs = instr[11:8];
            rt = instr[7:4];
            rd = instr[3:0];
            imm = instr[11:0];

            case (op)
                4'h0: decode_instr = {"ADD R",rd + "0",", R",rs + "0",", R",rt + "0"};
                4'h1: decode_instr = {"SUB R",rd + "0",", R",rs + "0",", R",rt + "0"};
                4'h2: decode_instr = {"AND R",rd + "0",", R",rs + "0",", R",rt + "0"};
                4'h3: decode_instr = {"OR  R",rd + "0",", R",rs + "0",", R",rt + "0"};
                4'h4: decode_instr = {"LW  R2, [", imm, "]"};
                4'h5: decode_instr = {"SW  R",rt + "0",", [", imm, "]"};
                4'h6: decode_instr = {"BEQ ", imm};
                4'h7: decode_instr = {"JMP ", imm};
                default: decode_instr = "UNKNOWN";
            endcase
        end
    endfunction

    integer i;
    always @(posedge clk) begin
        $display("\n================ Cycle @ %t ================\n", $time);
        $display("PC       = %0d", uut.PC);
        $display("InstrHex = %h", uut.instruction);
        $display("Decoded  = %s", decode_instr(uut.instruction));
        $display("Zero     = %b | ALU Zero = %b", uut.zero_flag, uut.alu_zero);

        $display("\nRegisters (R2–R15):");
        for (i = 2; i < 16; i = i + 1) begin
            $write("R[%0d] = %h", i, uut.regfile_inst.registers[i]);
            if (uut.regfile_inst.registers[i] !== last_regs[i])
                $write("  ← CHANGED");
            $display("");
            last_regs[i] = uut.regfile_inst.registers[i];
        end

        $display("\nData Memory [%0d to %0d]:", DMEM_START_ADDR, DMEM_START_ADDR + DMEM_WORDS - 1);
        for (i = 0; i < DMEM_WORDS; i = i + 1) begin
            $write("DMEM[%0d] = %h", DMEM_START_ADDR + i, uut.dmem_inst.mem[DMEM_START_ADDR + i]);
            if (uut.dmem_inst.mem[DMEM_START_ADDR + i] !== last_dmem[DMEM_START_ADDR + i])
                $write("  ← CHANGED");
            $display("");
            last_dmem[DMEM_START_ADDR + i] = uut.dmem_inst.mem[DMEM_START_ADDR + i];
        end
    end

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_cpu);
        #10 rst = 0;
        #300 $finish;
    end
endmodule
