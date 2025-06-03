module dmem(
    input clk,
    input [15:0] addr,
    input [15:0] write_data,
    input mem_write,
    input mem_read,
    output reg [15:0] read_data
);
    // reg [15:0] mem [0:65535];  // 64K words (128KB)
    reg [15:0] mem [0:2];

    // Load initial data
    initial begin
        // Load initial data
        $readmemh("mem/data.mem", mem);
    end    

    always @(posedge clk) begin
        if (mem_write)
            mem[addr[15:1]] <= write_data;  // Word addressing
    end

    always @(*) begin
        if (mem_read)
            read_data = mem[addr[15:1]];  // Asynchronous read
        else
            read_data = 16'b0;
    end
endmodule
