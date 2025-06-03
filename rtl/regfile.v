module regfile(
    input clk,
    input rst,
    input [3:0] read_reg1,
    input [3:0] read_reg2,
    output reg [15:0] read_data1,
    output reg [15:0] read_data2,
    input write_en,
    input [3:0] write_reg,
    input [15:0] write_data
);
    reg [15:0] registers [15:0];

    // Initialize r0=0, r1=1, others=0
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1) registers[i] <= 16'b0;
            registers[1] <= 16'b1;
        end
        else if (write_en) begin
            // Prevent writes to r0 and r1
            if (write_reg != 4'd0 && write_reg != 4'd1)
                registers[write_reg] <= write_data;
        end
    end

    // Read ports with r0/r1 override
    always @(*) begin
        read_data1 = (read_reg1 == 4'd0) ? 16'b0 : 
                    (read_reg1 == 4'd1) ? 16'b1 : registers[read_reg1];
        read_data2 = (read_reg2 == 4'd0) ? 16'b0 : 
                    (read_reg2 == 4'd1) ? 16'b1 : registers[read_reg2];
    end
endmodule
