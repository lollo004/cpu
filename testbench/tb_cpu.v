module tb_cpu;
    reg clk = 0;
    reg rst = 1;
    
    cpu uut (.*);
    
    always #5 clk = ~clk;  // 10ns clock period

    always @(posedge clk) begin
        $display("r2=%d, r3=%d, r4=%d", 
            uut.regfile_inst.registers[2],
            uut.regfile_inst.registers[3],
            uut.regfile_inst.registers[4]);
        end
            
    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_cpu);
        #5 rst = 0;       // Release reset after 10ns
        #200 $finish;
    end
endmodule
