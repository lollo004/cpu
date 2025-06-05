module tb_cpu;
    reg clk = 0;
    reg rst = 1;
    
    cpu uut (.*);
    
    always #5 clk = ~clk;  // 10ns clock period

    always @(posedge clk) begin
        $display("PC=%d | r2=%d | r3=%d | r4=%d | r5=%d | r6=%d", 
            uut.PC,
            uut.regfile_inst.registers[2],
            uut.regfile_inst.registers[3],
            uut.regfile_inst.registers[4],
            uut.regfile_inst.registers[5],
            uut.regfile_inst.registers[6]);
        end
            
    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_cpu);
        #5 rst = 0;       // Release reset after 10ns
        #300 $finish;
    end
endmodule
