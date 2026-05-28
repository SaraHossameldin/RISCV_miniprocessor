module ALUcontrol
(
    input  [1:0]  ALUOp,
    input  [31:0] instruction,
    output reg [3:0] ALUselect
);

always @(*) begin

    if (ALUOp == 2'b00) begin
        // load, store, jalr → add
        ALUselect = 4'b0000;
    end

    else if (ALUOp == 2'b01) begin
        // branch → subtract
        ALUselect = 4'b0001;
    end

    else if (ALUOp == 2'b10) begin

        // ===============================
        //            R-Type
        // ===============================
        if (instruction[6:0] == 7'b0110011) begin

            if (instruction[14:12] == 3'b000 && instruction[31:25] == 7'b0000000)
                ALUselect = 4'b00_00; // add
            else if (instruction[14:12] == 3'b000 && instruction[31:25] == 7'b0100000)
                ALUselect = 4'b00_01; // sub
            else if (instruction[14:12] == 3'b001)
                ALUselect = 4'b10_00; // sll
            else if (instruction[14:12] == 3'b101 && instruction[31:25] == 7'b0000000)
                ALUselect = 4'b10_01; // srl
            else if (instruction[14:12] == 3'b101 && instruction[31:25] == 7'b0100000)
                ALUselect = 4'b10_10; // sra
            else if (instruction[14:12] == 3'b010)
                ALUselect = 4'b11_01; // slt
            else if (instruction[14:12] == 3'b011)
                ALUselect = 4'b11_11; // sltu
            else if (instruction[14:12] == 3'b100)
                ALUselect = 4'b01_11; // xor
            else if (instruction[14:12] == 3'b110)
                ALUselect = 4'b01_00; // or
            else if (instruction[14:12] == 3'b111)
                ALUselect = 4'b01_01; // and
            else
                ALUselect = 4'bXXXX;

        end

        // ===============================
        //            I-Type
        // ===============================
        else if (instruction[6:0] == 7'b0010011) begin

            if (instruction[14:12] == 3'b000)
                ALUselect = 4'b00_00; // addi
            else if (instruction[14:12] == 3'b010)
                ALUselect = 4'b11_01; // slti
            else if (instruction[14:12] == 3'b011)
                ALUselect = 4'b11_11; // sltiu
            else if (instruction[14:12] == 3'b100)
                ALUselect = 4'b01_11; // xori
            else if (instruction[14:12] == 3'b110)
                ALUselect = 4'b01_00; // ori
            else if (instruction[14:12] == 3'b111)
                ALUselect = 4'b01_01; // andi
            else if (instruction[14:12] == 3'b001)
                ALUselect = 4'b10_00; // slli
            else if (instruction[14:12] == 3'b101 && instruction[31:25] == 7'b0000000)
                ALUselect = 4'b10_01; // srli
            else if (instruction[14:12] == 3'b101 && instruction[31:25] == 7'b0100000)
                ALUselect = 4'b10_10; // srai
            else
                ALUselect = 4'bXXXX;

        end

        else begin
            ALUselect = 4'bXXXX;
        end

    end

    else begin
        ALUselect = 4'bXXXX;
    end

end

endmodule