module tb_cpu;
    reg clk = 0;
    reg rst = 1;
    
    cpu uut (.*);
    
    always #5 clk = ~clk;  // 10ns clock period
    
    // Function to decode instruction into assembly string
    function [127:0] decode_instr(input [15:0] instr);
        reg [3:0] opcode, rs, rt, rd;
        begin
            opcode = instr[15:12];
            rs     = instr[11:8];
            rt     = instr[7:4];
            rd     = instr[3:0];
            case (opcode)
                4'h0: decode_instr = $sformatf("ADD  R%0d, R%0d, R%0d", rd, rs, rt);
                4'h1: decode_instr = $sformatf("SUB  R%0d, R%0d, R%0d", rd, rs, rt);
                4'h2: decode_instr = $sformatf("AND  R%0d, R%0d, R%0d", rd, rs, rt);
                4'h3: decode_instr = $sformatf("OR   R%0d, R%0d, R%0d", rd, rs, rt);
                4'h4: decode_instr = $sformatf("LW   R2, [0x%03X]", instr[11:0]);
                4'h5: decode_instr = $sformatf("SW   R2, [0x%03X]", instr[11:0]);
                4'h6: decode_instr = $sformatf("BEQZ (Z), [0x%03X]", instr[11:0]);
                4'h7: decode_instr = $sformatf("JMP  [0x%03X]", instr[11:0]);
                default: decode_instr = "UNKNOWN";
            endcase
        end
    endfunction
    
    integer i;
    always @(posedge clk) begin
        $display("\n--- Cycle %0t ---", $time);
        $display("PC = %0d", uut.PC);
        $display("Instruction = 0x%04h (%s)", uut.instruction, decode_instr(uut.instruction));
        
        // Display registers r0..r15
        $write("Registers: ");
        for (i = 0; i < 16; i = i + 1) begin
            $write("R%0d=%0d ", i, uut.regfile_inst.registers[i]);
        end
        $write("\n");
        
        // Display Zero flag
        $display("Zero flag: %b", uut.zero_flag);
        
        // Display first 10 instructions in imem
        $display("Instruction Memory (first 10):");
        for (i = 0; i < 10; i = i + 1)
            $display("  IMEM[%0d] = 0x%04h", i, uut.imem_inst.mem[i]);
        
        // Display first 10 data memory entries
        $display("Data Memory (first 10):");
        for (i = 0; i < 10; i = i + 1)
            $display("  DMEM[%0d] = 0x%04h", i, uut.dmem_inst.mem[i]);
    end

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_cpu);
        #10 rst = 0;  // Release reset after 10ns
        #600 $finish; // Run simulation for enough cycles
    end
endmodule
