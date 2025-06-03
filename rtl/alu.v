module alu(
    input [15:0] a,
    input [15:0] b,
    input [1:0] op,
    output reg [15:0] result,
    output zero
);
    always @(*) begin
        case (op)
            2'b00: result = a + b;   // ADD
            2'b01: result = a - b;   // SUB
            2'b10: result = a & b;   // AND
            2'b11: result = a | b;   // OR
            default: result = 16'b0;
        endcase
    end
    assign zero = (result == 16'b0);
endmodule
