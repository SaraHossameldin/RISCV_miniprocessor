module IF_ID_Reg(
    input clk,
    input rst,
    input flush,
    input load,
    input [31:0] PC_in,
    input [31:0] Instr_in,
    output reg [31:0] PC_out,
    output reg [31:0] Instr_out
);
always @(posedge clk or posedge rst) begin
    if (rst) begin
        PC_out <= 32'b0;
        Instr_out <= 32'b0;
    end else if (load) begin
        if (flush) begin
            PC_out <= 32'b0;
            Instr_out <= 32'b0;
        end else begin
            PC_out <= PC_in;
            Instr_out <= Instr_in;
        end
    end
end
endmodule   