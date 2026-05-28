module EX_MEM_Reg (
    input clk,
    input rst,
    input load,
    input flush,
    input RegWrite_in,
    input branch_in,
    input MemRead_in,
    input MemWrite_in,
    input [31:0] Instr_in,
    input jal_in,
    input jalr_in,
    input auipc_in,
    input lui_in,
    input [31:0] branch_add_in,
    input zero_in,
    input c_flag_in,
    input s_flag_in,
    input v_flag_in,
    input [31:0] ALU_result_in,
    input [31:0] Readdata2_in,
    input [4:0] Rd_in,
    input [31:0] imm_in,
    input [2:0] funct3_in,
    input[31:0] PC_in,
    output reg RegWrite_out,
    output reg branch_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg [31:0] Instr_out,
    output reg jal_out,
    output reg jalr_out,
    output reg auipc_out,
    output reg lui_out,
    output reg [31:0] branch_add_out,
    output reg zero_out,
    output reg c_flag_out,
    output reg s_flag_out,
    output reg v_flag_out,
    output reg [31:0] ALU_result_out,
    output reg [31:0] Readdata2_out,
    output reg [4:0] Rd_out,
    output reg [31:0] imm_out,
    output reg [2:0] funct3_out, 
    output reg [31:0] PC_out
    
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        RegWrite_out <= 1'b0;
        branch_out <= 1'b0;
        MemRead_out <= 1'b0;
        MemWrite_out <= 1'b0;
        Instr_out <= 32'b0;
        jal_out <= 1'b0;
        jalr_out <= 1'b0;
        auipc_out <= 1'b0;
        lui_out <= 1'b0;
        branch_add_out <= 32'b0;
        zero_out <= 1'b0;
        c_flag_out <= 1'b0;
        s_flag_out <= 1'b0;
        v_flag_out <= 1'b0;
        ALU_result_out <= 32'b0;
        Readdata2_out <= 32'b0;
        Rd_out <= 5'b0;
        imm_out <= 32'b0;
        funct3_out <= 3'b0;
        PC_out<=32'b0; 
    end else if (load) begin
        if (flush) begin
            RegWrite_out <= 1'b0;
            branch_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            Instr_out <= 32'b0;
            jal_out <= 1'b0;
            jalr_out <= 1'b0;
            auipc_out <= 1'b0;
            lui_out <= 1'b0;
            branch_add_out <= 32'b0;
            zero_out <= 1'b0;
            c_flag_out <= 1'b0;
            s_flag_out <= 1'b0;
            v_flag_out <= 1'b0;
            ALU_result_out <= 32'b0;
            Readdata2_out <= 32'b0;
            Rd_out <= 5'b0;
            imm_out <= 32'b0;
            funct3_out <= 3'b0;
            PC_out<=32'b0; 
        end else begin
            RegWrite_out <= RegWrite_in;
            branch_out <= branch_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            Instr_out <= Instr_in;
            jal_out <= jal_in;
            jalr_out <= jalr_in;
            auipc_out <= auipc_in;
            lui_out <= lui_in;
            branch_add_out <= branch_add_in;
            zero_out <= zero_in;
            c_flag_out <= c_flag_in;
            s_flag_out <= s_flag_in;
            v_flag_out <= v_flag_in;
            ALU_result_out <= ALU_result_in;
            Readdata2_out <= Readdata2_in;
            Rd_out <= Rd_in;
            imm_out <= imm_in;
            funct3_out <= funct3_in;
            PC_out<= PC_in;
        end
    end
end
endmodule