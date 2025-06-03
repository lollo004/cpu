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
        case (opcode)
            // ADD
            4'b0000: begin
                {reg_write, mem_read, mem_write, mem_to_reg} = 4'b1000;
                {alu_op, branch, jump} = 3'b000;
                {alu_src, reg_dst} = 2'b01;
            end
            // SUB
            4'b0001: begin
                {reg_write, mem_read, mem_write, mem_to_reg} = 4'b1000;
                {alu_op, branch, jump} = 3'b010;
                {alu_src, reg_dst} = 2'b01;
            end
            // AND
            4'b0010: begin
                {reg_write, mem_read, mem_write, mem_to_reg} = 4'b1000;
                {alu_op, branch, jump} = 3'b100;
                {alu_src, reg_dst} = 2'b01;
            end
            // OR
            4'b0011: begin
                {reg_write, mem_read, mem_write, mem_to_reg} = 4'b1000;
                {alu_op, branch, jump} = 3'b110;
                {alu_src, reg_dst} = 2'b01;
            end
            // LW
            4'b0100: begin
                {reg_write, mem_read, mem_write, mem_to_reg} = 4'b1101;
                {alu_op, branch, jump} = 3'b000;
                {alu_src, reg_dst} = 2'b10;
            end
            // SW
            4'b0101: begin
                {reg_write, mem_read, mem_write, mem_to_reg} = 4'b0010;
                {alu_op, branch, jump} = 3'b000;
                {alu_src, reg_dst} = 2'b10;
            end
            // BEQ
            4'b0110: begin
                {reg_write, mem_read, mem_write, mem_to_reg} = 4'b0000;
                {alu_op, branch, jump} = 3'b011;
                {alu_src, reg_dst} = 2'b00;
            end
            // JMP
            4'b0111: begin
                {reg_write, mem_read, mem_write, mem_to_reg} = 4'b0000;
                {alu_op, branch, jump} = 3'bx1x;
                {alu_src, reg_dst} = 2'bxx;
            end
            // Default: NOP
            default: begin
                {reg_write, mem_read, mem_write, mem_to_reg} = 4'b0000;
                {alu_op, branch, jump} = 3'b000;
                {alu_src, reg_dst} = 2'b00;
            end
        endcase
    end
endmodule
