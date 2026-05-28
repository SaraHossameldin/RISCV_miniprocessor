module immediateGen (
    input  wire [31:0]  IR,
    output reg  [31:0]  Imm
);

wire [6:0] opcode;
assign opcode=IR[6:0];
always @(*) begin
	// case (opcode)
	// 	7'b0010011 : Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }<<12;
	// 	7'b0100011 : Imm = { {21{IR[31]}}, IR[30:25], IR[11:8], IR[7] };
	// 	7'b0110111 : Imm = { IR[31], IR[30:20], IR[19:12], 12'b0 } <<12;
	// 	7'b0010111 : Imm = { IR[31], IR[30:20], IR[19:12], 12'b0 };
	// 	7'b1101111 : Imm = { {12{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[24:21], 1'b0 };
	// 	7'b1100111 : Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
	// 	7'b1100011 : Imm = { {20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0}<< 1;
	// 	default    : Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }; // IMM_I
	// endcase

	case (opcode)
        7'b0010011 : Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }; // I-Type
        7'b0100011 : Imm = { {21{IR[31]}}, IR[30:25], IR[11:8], IR[7] }; // S-Type
        7'b0110111 : Imm = { IR[31], IR[30:20], IR[19:12], 12'b0 }<<12; // U-Type (LUI)
        7'b0010111 : Imm = { IR[31], IR[30:20], IR[19:12], 12'b0 }<<12; // U-Type (AUIPC)
        7'b1101111 : Imm = { {12{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[24:21], 1'b0 }<<1; // J-Type
        7'b1100111 : Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }; // I-Type (JALR)
        7'b1100011 : Imm = { {20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0}; // B-Type 
        default    : Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }; // IMM_I
    endcase
end

endmodule