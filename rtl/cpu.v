module cpu(
    input clk,
    input rst
);
    // Program Counter
    reg [15:0] PC;
    wire [15:0] PC_plus_2 = PC + 2;

    // Instruction fetch
    wire [15:0] instruction;
    imem imem_inst(.addr(PC), .instruction(instruction));

    // Instruction decode
    wire [3:0] opcode = instruction[15:12];
    wire [3:0] Rs = instruction[11:8];
    wire [3:0] Rt = instruction[7:4];
    wire [3:0] Rd = instruction[3:0];
    wire [11:0] abs_address = instruction[11:0];

    // Override register indices for LW/SW : R2 reserved
    wire [3:0] regfile_read_reg2 = (opcode == 4'b0101) ? 4'd2 : Rt;
    wire [3:0] regfile_write_reg = (opcode == 4'b0100) ? 4'd2 :
                                  (reg_dst ? Rd : Rt);

    // Register file
    wire [15:0] read_data1, read_data2;
    wire reg_write;
    wire [3:0] write_reg;
    wire [15:0] write_data;
    regfile regfile_inst(
        .clk(clk),
        .rst(rst),
        .read_reg1(Rs),
        .read_reg2(regfile_read_reg2),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .write_en(reg_write),
        .write_reg(regfile_write_reg),
        .write_data(write_data)
    );

    // Control unit
    wire mem_read, mem_write, mem_to_reg, branch, jump;
    wire [1:0] alu_op;
    wire reg_dst;
    control control_inst(
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .branch(branch),
        .jump(jump),
        .reg_dst(reg_dst)
    );

    // Absolute address handling
    wire [15:0] absolute_target = {4'b0, abs_address} << 1;  // 0-extend to 16 bits and double
    wire [15:0] mem_addr = (opcode == 4'b0100 || opcode == 4'b0101) ? 
                           absolute_target : alu_result;  // MUX for memory address

    // ALU
    wire [15:0] alu_result;
    wire alu_zero;
    alu alu_inst(
        .a(read_data1),
        .b(read_data2),
        .op(alu_op),
        .result(alu_result),
        .zero(alu_zero)
    );

    // Data memory
    wire [15:0] mem_read_data;
    dmem dmem_inst(
        .clk(clk),
        .addr(mem_addr),
        .write_data(read_data2),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_read_data)
    );

    // Write-back MUX
    assign write_data = mem_to_reg ? mem_read_data : alu_result;

    // Register destination MUX
    assign write_reg = reg_dst ? Rd : Rt;

    // Zero flag logic: Only update for arithmetic operations (ADD/SUB)
    reg zero_flag;
    wire update_zero = (opcode == 4'b0000) ||  // ADD
                       (opcode == 4'b0001) ||  // SUB
                       (opcode == 4'b0010) ||  // AND
                       (opcode == 4'b0011);    // OR

    always @(posedge clk or posedge rst) begin
        if (rst)
            zero_flag <= 1'b0;
        else if (update_zero)
            zero_flag <= alu_zero; // Update only for ADD/SUB
        // Otherwise, retain previous value
    end

    // Branch/jump logic
    wire branch_condition = branch & (update_zero ? alu_zero : zero_flag);
    wire [15:0] next_PC = 
        jump             ? absolute_target :
        branch_condition ? absolute_target :
        PC_plus_2;

    // PC update
    always @(posedge clk or posedge rst) begin
        if (rst) PC <= 16'b0;
        else PC <= next_PC;
    end
endmodule