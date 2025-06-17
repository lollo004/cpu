`timescale 1ns / 1ps

module tb_cpu;
    reg clk = 0;
    reg rst = 1;
    integer cycle = 0;
    integer i;
    integer dmem_file;

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

    // Simple assembler display function
    function [127:0] decode_assembler_simple;
        input [15:0] instr;
        reg [3:0] opcode;
        begin
            opcode = instr[15:12];
            case (opcode)
                4'h0: decode_assembler_simple = "ADD rx,ry,rz";
                4'h1: decode_assembler_simple = "SUB rx,ry,rz";
                4'h2: decode_assembler_simple = "AND rx,ry,rz";
                4'h3: decode_assembler_simple = "OR rx,ry,rz";
                4'h4: decode_assembler_simple = "LW rt,imm(rs)";
                4'h5: decode_assembler_simple = "SW rt,imm(rs)";
                4'h6: decode_assembler_simple = "BEQ rs,rt,imm";
                4'h7: decode_assembler_simple = "JMP addr";
                default: decode_assembler_simple = "UNKNOWN";
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

                        // Print final execution summary
            $display("\n============================================================");
            $display("EXECUTION RESULTS:");
            $display("============================================================");
            $display("Final PC: %0d", uut.PC);
            $display("Zero Flag: %b", uut.zero_flag);
            $display("Total Cycles: %0d", cycle);
            
            $display("\nFinal Registers:");
            $display("r0=%0d | r1=%0d | r2=%0d | r3=%0d | r4=%0d | r5=%0d | r6=%0d | r7=%0d",
                uut.regfile_inst.registers[0], uut.regfile_inst.registers[1],
                uut.regfile_inst.registers[2], uut.regfile_inst.registers[3],
                uut.regfile_inst.registers[4], uut.regfile_inst.registers[5],
                uut.regfile_inst.registers[6], uut.regfile_inst.registers[7]
            );

            // Print first 4 words of data memory
            $write("Final Data Memory [0..3]: ");
            for (i = 0; i < 4; i = i + 1) begin
                $write("%0d ", uut.dmem_inst.mem[i]);
            end
            $display("");

            // Write complete data memory to file
            dmem_file = $fopen("data_memory_dump.txt", "w");
            if (dmem_file != 0) begin
                $fwrite(dmem_file, "Data Memory Dump - Simulation Complete\n");
                $fwrite(dmem_file, "=====================================\n");
                $fwrite(dmem_file, "Final PC: %0d, Zero Flag: %b, Cycles: %0d\n\n", uut.PC, uut.zero_flag, cycle);
                
                // Write all 256 memory locations
                for (i = 0; i < 256; i = i + 1) begin
                    $fwrite(dmem_file, "mem[%3d] = %8d (0x%08h)\n", i, uut.dmem_inst.mem[i], uut.dmem_inst.mem[i]);
                end
                $fclose(dmem_file);
                $display("Complete data memory saved to: data_memory_dump.txt");
            end else begin
                $display("ERROR: Could not create data_memory_dump.txt");
            end

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

                $display("DEBUG: Starting simulation...");
        $display("DEBUG: Initial reset = %b", rst);
        
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_cpu);
        
        // Hold reset longer and add debug info
        $display("DEBUG: Holding reset for 50ns...");
        #50 rst = 0;
        $display("DEBUG: Reset released at time %0t", $time);
        $display("DEBUG: PC after reset release = %0d", uut.PC);
        
        // Check if CPU is responding
        #10;
        if (uut.PC === 'x) begin
            $display("ERROR: PC is still undefined after reset release!");
            $display("DEBUG: Check CPU reset logic and initial values");
        end

        #1000 begin
            $display("Simulation timeout.");             $display("DEBUG: Final PC = %0d", uut.PC);
            $display("DEBUG: Final instruction = 0x%04h", current_instr);
            
            // Write data memory to file even on timeout
            $display("\n============================================================");
            $display("TIMEOUT - EXECUTION RESULTS:");
            $display("============================================================");
            $display("Final PC: %0d", uut.PC);
            $display("Zero Flag: %b", uut.zero_flag);
            $display("Total Cycles: %0d", cycle);
            
            $display("\nFinal Registers:");
            $display("r0=%0d | r1=%0d | r2=%0d | r3=%0d | r4=%0d | r5=%0d | r6=%0d | r7=%0d",
                uut.regfile_inst.registers[0], uut.regfile_inst.registers[1],
                uut.regfile_inst.registers[2], uut.regfile_inst.registers[3],
                uut.regfile_inst.registers[4], uut.regfile_inst.registers[5],
                uut.regfile_inst.registers[6], uut.regfile_inst.registers[7]
            );

            // Print first 4 words of data memory
            $write("Final Data Memory [0..3]: ");
            for (i = 0; i < 4; i = i + 1) begin
                $write("%0d ", uut.dmem_inst.mem[i]);
            end
            $display("");

            // Write complete data memory to file
            dmem_file = $fopen("data_memory_dump.txt", "w");
            if (dmem_file != 0) begin
                $fwrite(dmem_file, "Data Memory Dump - Simulation Timeout\n");
                $fwrite(dmem_file, "====================================\n");
                $fwrite(dmem_file, "Final PC: %0d, Zero Flag: %b, Cycles: %0d\n\n", uut.PC, uut.zero_flag, cycle);
                
                // Write all 256 memory locations
                for (i = 0; i < 256; i = i + 1) begin
                    $fwrite(dmem_file, "mem[%3d] = %8d (0x%08h)\n", i, uut.dmem_inst.mem[i], uut.dmem_inst.mem[i]);
                end
                $fclose(dmem_file);
                $display("Complete data memory saved to: data_memory_dump.txt");
            end else begin
                $display("ERROR: Could not create data_memory_dump.txt");
            end
            
            $finish;
        end
    end
endmodule
