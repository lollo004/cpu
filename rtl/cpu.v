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
    wire [3:0] Rd_or_Offset = instruction[3:0];
    wire [11:0] Offset12 = instruction[11:0];

    // Register file
    wire [15:0] read_data1, read_data2;
    wire reg_write;
    wire [3:0] write_reg;
    wire [15:0] write_data;
    regfile regfile_inst(
        .clk(clk),
        .rst(rst),
        .read_reg1(Rs),
        .read_reg2(Rt),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .write_en(reg_write),
        .write_reg(write_reg),
        .write_data(write_data)
    );

    // Control unit
    wire mem_read, mem_write, mem_to_reg, branch, jump;
    wire [1:0] alu_op;
    wire alu_src, reg_dst;
    control control_inst(
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .branch(branch),
        .jump(jump),
        .alu_src(alu_src),
        .reg_dst(reg_dst)
    );

    // Sign extension
    wire [15:0] sign_ext_offset = {{12{Rd_or_Offset[3]}}, Rd_or_Offset};

    // ALU input selection
    wire [15:0] alu_b = alu_src ? sign_ext_offset : read_data2;

    // ALU
    wire [15:0] alu_result;
    wire zero;
    alu alu_inst(
        .a(read_data1),
        .b(alu_b),
        .op(alu_op),
        .result(alu_result),
        .zero(zero)
    );

    // Data memory
    wire [15:0] mem_read_data;
    dmem dmem_inst(
        .clk(clk),
        .addr(alu_result),
        .write_data(read_data2),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_read_data)
    );

    // Write-back MUX
    assign write_data = mem_to_reg ? mem_read_data : alu_result;

    // Register destination MUX
    assign write_reg = reg_dst ? Rd_or_Offset : Rt;

    // Branch/jump logic
    wire branch_condition = branch & zero;
    wire [15:0] branch_target = PC_plus_2 + (sign_ext_offset << 1);
    wire [15:0] jump_target = {4'b0, Offset12} << 1;
    wire [15:0] next_PC = 
        jump          ? jump_target :
        branch_condition ? branch_target : 
        PC_plus_2;

    // PC update
    always @(posedge clk or posedge rst) begin
        if (rst) PC <= 16'b0;
        else PC <= next_PC;
    end
endmodule
