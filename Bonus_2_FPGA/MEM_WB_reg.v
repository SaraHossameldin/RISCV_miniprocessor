module MEM_WB_Reg(
    input clk,
    input rst,
    input load,
    input [31:0] memout_in,
    input [31:0] ALU_out_in,
    input RegWrite_in,
    input [4:0] Rd_in,
    input [2:0] funct3_in,
    input [31:0] branch_add_in,
    input [31:0] imm_in,
    input auipc_in,
    input jal_in,
    input jalr_in,
    input lui_in,
    input MemRead_in,
    input[31:0] PC_in, 
    output reg [31:0] memout_out,
    output reg [31:0] ALU_out_out,
    output reg RegWrite_out,
    output reg [4:0] Rd_out,
    output reg [2:0] funct3_out,
    output reg [31:0] PC_out,
    output reg [31:0] branch_add_out,
    output reg [31:0] imm_out,
    output reg auipc_out,
    output reg jal_out,
    output reg jalr_out,
    output reg lui_out,
    output reg MemRead_out
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        memout_out <= 32'b0;
        ALU_out_out <= 32'b0;
        RegWrite_out <= 1'b0;
        Rd_out <= 5'b0;
        funct3_out <= 3'b0;
        branch_add_out <= 32'b0;
        imm_out <= 32'b0;
        auipc_out <= 1'b0;
        jal_out <= 1'b0;
        jalr_out <= 1'b0;
        lui_out <= 1'b0;
        MemRead_out <= 1'b0;
        PC_out<=0;
    end else if (load) begin
        memout_out <= memout_in;
        ALU_out_out <= ALU_out_in;
        RegWrite_out <= RegWrite_in;
        Rd_out <= Rd_in;
        funct3_out <= funct3_in;
        branch_add_out <= branch_add_in;
        imm_out <= imm_in;
        auipc_out <= auipc_in;
        jal_out <= jal_in;
        jalr_out <= jalr_in;
        lui_out <= lui_in;
        MemRead_out <= MemRead_in;
        PC_out<=PC_in; 
    end
    end
endmodule