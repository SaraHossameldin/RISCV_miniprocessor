module ID_EX_Reg(
    input clk,
    input rst,
    input load,
    input flush,
    input branch_in,
    input MemRead_in,
    input MemWrite_in,
    input [1:0] ALUOp_in,
    input ALUSrc_in,
    input RegWrite_in,
    input auipc_in,
    input lui_in,
    input jal_in,
    input jalr_in,
    input [31:0] PC_in,
    input [31:0] Readdata1_in,
    input [31:0] Readdata2_in,
    input [31:0] Imm_in,
    input [3:0] funct_in,
    input [4:0] Rs1_in,
    input [4:0] Rs2_in,
    input [4:0] Rd_in,
    input [31:0] Instr_in,
    output reg branch_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg [1:0] ALUOp_out,
    output reg ALUSrc_out,
    output reg RegWrite_out,
    output reg auipc_out,
    output reg lui_out,
    output reg jal_out,
    output reg jalr_out,
    output reg [31:0] PC_out,
    output reg [31:0] Readdata1_out,
    output reg [31:0] Readdata2_out,
    output reg [31:0] Imm_out,
    output reg [3:0] funct_out,
    output reg [4:0] Rs1_out,
    output reg [4:0] Rs2_out,
    output reg [4:0] Rd_out,
    output reg [31:0] Instr_out
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        branch_out <= 1'b0;
        MemRead_out <= 1'b0;
        MemWrite_out <= 1'b0;
        ALUOp_out <= 3'b0;
        ALUSrc_out <= 1'b0;
        RegWrite_out <= 1'b0;
        auipc_out <= 1'b0;
        lui_out <= 1'b0;
        jal_out <= 1'b0;
        jalr_out <= 1'b0;
        PC_out <= 32'b0;
        Readdata1_out <= 32'b0;
        Readdata2_out <= 32'b0;
        Imm_out <= 32'b0;
        funct_out <= 4'b0;
        Rs1_out <= 5'b0;
        Rs2_out <= 5'b0;
        Rd_out <= 5'b0;
        Instr_out <= 32'b0;
    end else if (load) begin
        if (flush) begin
            branch_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            ALUOp_out <= 2'b0;
            ALUSrc_out <= 1'b0;
            RegWrite_out <= 1'b0;
            auipc_out <= 1'b0;
            lui_out <= 1'b0;
            jal_out <= 1'b0;
            jalr_out <= 1'b0;
            PC_out <= 32'b0;
            Readdata1_out <= 32'b0;
            Readdata2_out <= 32'b0;
            Imm_out <= 32'b0;
            funct_out <= 4'b0;
            Rs1_out <= 5'b0;
            Rs2_out <= 5'b0;
            Rd_out <= 5'b0;
            Instr_out <= 32'b0;
        end else begin
            branch_out <= branch_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            ALUOp_out <= ALUOp_in;
            ALUSrc_out <= ALUSrc_in;
            RegWrite_out <= RegWrite_in;
            auipc_out <= auipc_in;
            lui_out <= lui_in;
            jal_out <= jal_in;
            jalr_out <= jalr_in;
            PC_out <= PC_in;
            Readdata1_out <= Readdata1_in;
            Readdata2_out <= Readdata2_in;
            Imm_out <= Imm_in;
            funct_out <= funct_in;
            Rs1_out <= Rs1_in;
            Rs2_out <= Rs2_in;
            Rd_out <= Rd_in;
            Instr_out <= Instr_in;
        end
    end
end
endmodule