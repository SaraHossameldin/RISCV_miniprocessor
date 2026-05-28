`timescale 1ns / 1ps

module Branch_Unit(
    input branch,
    input z_flag,
    input c_flag,
    input s_flag,
    input v_flag,
    input [2:0] funct3,
    output reg branch_out
);

always @* begin
    branch_out = 1'b0;  // Default: no branch

    // Only process if this is a branch instruction (opcode = 1100011)
    if (branch) begin
        case (funct3)
            3'b000: branch_out = (z_flag == 1'b1);                // BEQ
            3'b001: branch_out = (z_flag == 1'b0);                // BNE
            3'b100: branch_out = (s_flag != v_flag);              // BLT
            3'b101: branch_out = (s_flag == v_flag);              // BGE
            3'b110: branch_out = (c_flag == 1'b0);                // BLTU
            3'b111: branch_out = (c_flag == 1'b1);                // BGEU
            default: branch_out = 1'b0;
        endcase
    end
end

endmodule