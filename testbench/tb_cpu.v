module tb_cpu;
    reg clk = 0;
    reg rst = 1;
    
    cpu uut (.*);
    
    always #5 clk = ~clk;  // 10ns clock period
    
    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_cpu);
        #10 rst = 0;       // Release reset after 10ns
        #1000 $finish;     // Run for 1000ns
    end
endmodule
