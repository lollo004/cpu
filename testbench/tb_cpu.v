`timescale 1ns / 1ps

module tb_cpu;
    reg clk = 0;
    reg rst = 1;
    integer cycle = 0;
    integer i;

    // Instantiate the CPU
    cpu uut (.*);

    // Clock generation
    always #5 clk = ~clk;

    // Wire to observe current instruction from instruction memory
    wire [15:0] current_instr = uut.imem_inst.instruction;

    // Simple decode function: map opcode to mnemonic string
    function [88:0] decode_instr;
        input [15:0] instr;
        reg [3:0] opcode;
        begin
            opcode = instr[15:12];
            case (opcode)
                4'h0: decode_instr = "ADD";
                4'h1: decode_instr = "SUB";
                4'h2: decode_instr = "AND";
                4'h3: decode_instr = "OR";
                4'h4: decode_instr = "LW";
                4'h5: decode_instr = "SW";
                4'h6: decode_instr = "BEQ";
                4'h7: decode_instr = "JMP";
                default: decode_instr = "UNKN";
            endcase
        end
    endfunction

    // Monitor CPU state on each rising edge
    always @(posedge clk) begin
        cycle = cycle + 1;

        $display("\nCycle=%0d | PC=%0d | Instr=0x%04h (%s) | Zero Flag=%b",
            cycle,
            uut.PC,
            current_instr,
            decode_instr(current_instr),
            uut.zero_flag
        );

        // Print general purpose registers r0 to r7
        $display("Registers:");
        $display(" r0=%0d | r1=%0d | r2=%0d | r3=%0d | r4=%0d | r5=%0d | r6=%0d | r7=%0d",
            uut.regfile_inst.registers[0],
            uut.regfile_inst.registers[1],
            uut.regfile_inst.registers[2],
            uut.regfile_inst.registers[3],
            uut.regfile_inst.registers[4],
            uut.regfile_inst.registers[5],
            uut.regfile_inst.registers[6],
            uut.regfile_inst.registers[7]
        );

        // Print a small range of data memory contents (first 8 words)
        $write("Data Memory [0..7]: ");
        for (i = 0; i < 8; i = i + 1) begin
            $write("%0d ", uut.dmem_inst.mem[i]);
        end
        $display(""); // newline

        // Stop condition (JMP to self)
        if (uut.next_PC == uut.PC) begin
            $display("\nHalt detected. Stopping simulation.");

            if (uut.regfile_inst.registers[6] == 0)
                $display("✅ TEST PASSED: r6 == 0");
            else
                $display("❌ TEST FAILED: r6 = %0d (expected 0)", uut.regfile_inst.registers[6]);
            $finish;
        end
    end

    // Initialization
    initial begin
        // Green ASCII "TESTING" banner
        $display("\n\033[0;32m");
        $display("████████ ███████ ███████ ████████ ██ ███    ██  ██████  ");
        $display("   ██    ██      ██         ██    ██ ████   ██ ██       ");
        $display("   ██    █████   ███████    ██    ██ ██ ██  ██ ██   ███ ");
        $display("   ██    ██           ██    ██    ██ ██  ██ ██ ██    ██ ");
        $display("   ██    ███████ ███████    ██    ██ ██   ████  ██████  ");
        $display("\033[0m\n");

        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_cpu);
        #5 rst = 0;
        #1000 $display("Simulation timeout."); $finish;
    end
endmodule
