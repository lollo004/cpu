`timescale 1ns / 1ps

`define DEBUG_MODE 1  // Set to 0 for minimal output

module tb_cpu;
    reg clk = 0;
    reg rst = 1;

    cpu uut (.*);

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Helper task: decode instruction opcode to mnemonic
    function [79:0] decode_instr(input [15:0] instr);
        reg [3:0] opcode;
        opcode = instr[15:12];
        begin
            case (opcode)
                4'b0000: decode_instr = "ADD ";
                4'b0001: decode_instr = "SUB ";
                4'b0010: decode_instr = "AND ";
                4'b0011: decode_instr = "OR  ";
                4'b0100: decode_instr = "LW  ";
                4'b0101: decode_instr = "SW  ";
                4'b0110: decode_instr = "BEQ ";
                4'b0111: decode_instr = "JMP ";
                default: decode_instr = "UNK ";
            endcase
        end
    endfunction

    // Display a fixed slice of data memory (4 words)
    task display_dmem_slice;
        integer i;
        begin
            $write("DMEM[0..3]: ");
            for (i = 0; i < 4; i = i + 1) begin
                $write("%04h ", uut.dmem_inst.mem[i]);
            end
            $write("\n");
        end
    endtask

    integer cycle_count = 0;
    integer j;

    always @(posedge clk) begin
        cycle_count = cycle_count + 1;

        if (`DEBUG_MODE) begin
            // Decode instruction mnemonic
            $display("Cycle %0d | PC = %04h | Instr = %04h (%s) | zero_flag=%b",
                cycle_count, uut.PC, uut.imem_inst.mem[uut.PC>>1], decode_instr(uut.imem_inst.mem[uut.PC>>1]));

            // Print selected registers R2-R6 (r0=0 and r1=1 fixed, so skip)
            $display("Regs: R2=%04h R3=%04h R4=%04h R5=%04h R6=%04h",
                uut.regfile_inst.registers[2],
                uut.regfile_inst.registers[3],
                uut.regfile_inst.registers[4],
                uut.regfile_inst.registers[5],
                uut.regfile_inst.registers[6]
            );

            // Show small slice of data memory
            display_dmem_slice();

            $display("-----------------------------------------------------");
        end
    end

    // Simple example assertion: 
    // At cycle 20, expect R4 to have some value (customize as needed)
    always @(posedge clk) begin
        if (cycle_count == 20) begin
            if (uut.regfile_inst.registers[4] !== 16'h0054) begin
                $display("❌ ASSERTION FAILED: R4 != 0x0054 at cycle 20, got %04h", uut.regfile_inst.registers[4]);
                $fatal;
            end
        end
    end

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_cpu);

        #10 rst = 0;       // Release reset at 10ns

        #600;             // Run for 600ns

        // Write final data memory to file for post-simulation inspection
        $writememh("mem/final_dmem.mem", uut.dmem_inst.mem);

        $display("Simulation ended. Final data memory dumped to mem/final_dmem.mem");
        $finish;
    end
endmodule
