module storeGenerator(
    input [31:0] word_in,
    input [2:0] funct3,
    output reg [31:0] word_out
);
always @(*) begin
    case (funct3)
        3'b000: word_out = {24'b0, word_in[7:0]};    // SB
        3'b001: word_out = {16'b0, word_in[15:0]};   // SH
        3'b010: word_out = word_in;                  // SW
        default: word_out = word_in;                 // default (safety)
    endcase
end
endmodule
