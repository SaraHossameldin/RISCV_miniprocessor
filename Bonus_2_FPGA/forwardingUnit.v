`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2025 05:07:32 PM
// Design Name: 
// Module Name: forwardingUnit
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

module forwardingUnit(
input EX_MEM_RegWrite, input [4:0] EX_MEM_RD,
input MEM_WB_RegWrite, input [4:0] MEM_WB_RD, 
input[4:0] ID_EX_rs1, input[4:0] ID_EX_rs2, 
output reg [1:0] forwardA, output reg [1:0] forwardB
);
always @(*) begin
    // Default
    forwardA = 2'b00;
    forwardB = 2'b00;

    // EX hazard
    if(EX_MEM_RegWrite &&
       EX_MEM_RD != 0 &&
       EX_MEM_RD == ID_EX_rs1)
        forwardA = 2'b10;

    if(EX_MEM_RegWrite &&
       EX_MEM_RD != 0 &&
       EX_MEM_RD == ID_EX_rs2)
        forwardB = 2'b10;

    // MEM hazard (only if EX hazard NOT taken)
    if(MEM_WB_RegWrite &&
       MEM_WB_RD != 0 &&
       MEM_WB_RD == ID_EX_rs1 &&
       !(EX_MEM_RegWrite && EX_MEM_RD!=0 && EX_MEM_RD==ID_EX_rs1))
        forwardA = 2'b01;

    if(MEM_WB_RegWrite &&
       MEM_WB_RD != 0 &&
       MEM_WB_RD == ID_EX_rs2 &&
       !(EX_MEM_RegWrite && EX_MEM_RD!=0 && EX_MEM_RD==ID_EX_rs2))
        forwardB = 2'b01;
end
endmodule
