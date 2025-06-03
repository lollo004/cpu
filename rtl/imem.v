module imem(
    input [15:0] addr,
    output reg [15:0] instruction
);
    // reg [15:0] mem [0:65535];  // 64K words (128KB)
    reg [15:0] mem [0:10];

    initial begin
        // Load instructions from file at startup
        $readmemh("mem/program.mem", mem);
    end

    always @(*) begin
        instruction = mem[addr[15:1]];  // Word addressing
    end
endmodule
