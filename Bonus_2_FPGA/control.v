module control(
    input [6:0] opcode,
    output reg branch, 
    output reg MemRead,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg RegWrite, 
    output reg auipc, 
    output reg lui,
    output reg jal, 
    output reg jalr, 
    output reg ALUSrc 
);

always @* begin
    branch    = 1'b0;
    MemRead   = 1'b0;
    ALUOp     = 2'b00;
    MemWrite  = 1'b0;
    RegWrite  = 1'b0;
    auipc     = 1'b0;
    lui       = 1'b0;
    jal       = 1'b0;
    jalr      = 1'b0;
    ALUSrc  = 1'b0;

    // --- Opcode decoding ---
    case (opcode)
        7'b0110011: begin  // R-type
            ALUOp    = 2'b10;
            RegWrite = 1'b1;
        end
        7'b0000011: begin  // Load
            MemRead  = 1'b1;
            ALUSrc= 1'b1;
            RegWrite = 1'b1;
        end
        7'b0100011: begin  // Store
            MemWrite = 1'b1;
            ALUSrc = 1'b1;
        end
        7'b0010011: begin  // I-type
            ALUOp    = 2'b10;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
        end
        7'b1100011: begin  // B-type
            branch   = 1'b1;
            ALUOp    = 2'b01;
        end
        7'b0110111: begin  // LUI
            lui      = 1'b1;
            RegWrite = 1'b1;
        end
        7'b0010111: begin  // AUIPC
            auipc    = 1'b1;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            ALUOp    = 2'b00;
        end
        7'b1101111: begin  // JAL
            jal      = 1'b1;
            RegWrite = 1'b1;
        end
        7'b1100111: begin  // JALR
            jalr     = 1'b1;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            ALUOp    = 2'b00;
        end
        7'b0000000: begin  // DEFAULT (NOP)
            // No control signals needed for NOP
        end
        default: begin
                branch    = 1'bX;
                MemRead   = 1'bX;
                ALUOp     = 2'bXX;
                MemWrite  = 1'bX;
                RegWrite  = 1'bX;
                auipc     = 1'bX;
                lui       = 1'bX;
                jal       = 1'bX;
                jalr      = 1'bX;
                ALUSrc  = 1'bX;
        end
    endcase
end
endmodule
