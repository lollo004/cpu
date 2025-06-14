module dmem(
    input clk,
    input [15:0] addr,
    input [15:0] write_data,
    input mem_write,
    input mem_read,
    output reg [15:0] read_data
);
    // reg [15:0] mem [0:65535];  // 64K words (128KB)
    reg [15:0] mem [0:1024];  // 1K words (2KB) for compile time (testing)

    // Load initial data
    initial begin
        $readmemh("mem/data.mem", mem);
    end    

    // Write on positive edge of clock
    always @(posedge clk) begin
        if (mem_write)
            mem[addr[15:1]] <= write_data;  // Word addressing
    end

    // Asynchronous read
    always @(*) begin
        if (mem_read)
            read_data = mem[addr[15:1]];  // Asynchronous read
        else
            read_data = 16'b0;
    end

    // Debugging: Memory dump task
    task dump_memory;
        integer i;
        begin
            $display("\n------ Data Memory Dump ------");
            for (i = 0; i < 8; i = i + 1) begin
                $display("mem[%0d] = %0d", i, mem[i]);
            end
            $display("--------------------------------\n");
        end
    endtask

    // Automatically write memory to file at end of simulation
    initial begin
        $writememh("mem_dump.txt", mem);
    end

endmodule
