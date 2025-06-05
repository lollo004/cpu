module control(
    input [3:0] opcode,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg [1:0] alu_op,
    output reg branch,
    output reg jump,
    output reg alu_src,
    output reg reg_dst
);
    always @(*) begin
        // Default values
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        mem_to_reg = 0;
        alu_op = 2'b00;
        branch = 0;
        jump = 0;
        reg_dst = 0;

        case (opcode)
            // ADD
            4'b0000: begin
                reg_write = 1;
                reg_dst = 1;
                alu_op = 2'b00;
            end
            // SUB
            4'b0001: begin
                reg_write = 1;
                reg_dst = 1;
                alu_op = 2'b01;
            end
            // AND
            4'b0010: begin
                reg_write = 1;
                reg_dst = 1;
                alu_op = 2'b10;
            end
            // OR
            4'b0011: begin
                reg_write = 1;
                reg_dst = 1;
                alu_op = 2'b11;
            end
            // LW
            4'b0100: begin
                reg_write = 1;
                mem_read = 1;
                mem_to_reg = 1;
            end
            // SW
            4'b0101: begin
                mem_write = 1;
            end
            // BEQ
            4'b0110: begin
                branch = 1;
            end
            
            // JMP
            4'b0111: begin
                jump = 1;
            end
       endcase
    end
endmodule
