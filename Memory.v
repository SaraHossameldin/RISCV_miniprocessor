`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2025 04:25:49 PM
// Design Name: 
// Module Name: Memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Memory
(input clk, input MemRead, input MemWrite,
input [31:0] addr, input [31:0] data_in, output reg [31:0] data_out);
reg [31:0] mem [0:63];
always @ (posedge clk) begin
    if(MemWrite==1'b1)
    begin
    mem[addr / 4]<=data_in;
    end
end
always @(*) begin
    if(MemRead && addr < 64 * 4)
        data_out = mem[addr / 4];
    else
        data_out = 32'b0;
end

initial begin
mem[20]=32'd17;
mem[21]=32'd9;
mem[22]=32'd25;

mem[0]=32'b0000000_00000_00000_000_00000_0110011; //add x0, x0, x0
mem[1]=32'b000001010000_00000_000_01010_0010011; //addi x10, x0, 80
mem[2]=32'b000000000000_01010_010_00001_0000011; //lw x1, 0(x10)
mem[3]=32'b000000000100_01010_010_00010_0000011; //lw x2, 4(x10)
mem[4]=32'b000000001000_01010_010_00011_0000011; //lw x3, 8(x10)
mem[5]=32'b0000000_00010_00001_110_00100_0110011; //or x4, x1, x2
mem[6]=32'b0_000000_00011_00100_000_0100_0_1100011; //beq x4, x3, 4
mem[7]=32'b0000000_00010_00001_000_00011_0110011; //add x3, x1, x2
mem[8]=32'b0000000_00010_00011_000_00101_0110011; //add x5, x3, x2
mem[9]=32'b00000000_010101010_010_01100_0100011; //sw x5, 12(x10)
mem[10]=32'b000000001100_01010_010_00110_0000011; //lw x6, 12(x10)
mem[11]=32'b0000000_00001_00110_111_00111_0110011; //and x7, x6, x1
mem[12]=32'b0100000_00010_00001_000_01000_0110011; //sub x8, x1, x2
mem[13]=32'b0000000_00010_00001_000_00000_0110011; //add x0, x1, x2
mem[14]=32'b0000000_00001_00000_000_01001_0110011; //add x9, x0, x1


end
endmodule