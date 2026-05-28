`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2025 04:00:19 PM
// Design Name: 
// Module Name: shifter
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


module shifter ( input [31:0] a, input[4:0] shamt, 
input [1:0] type, output reg [31:0] r);
always @ * begin
if(type==2'b00)
r = a << shamt;
else if(type==2'b01)
r = a >> shamt;
else if( type==2'b10)
r= $signed(a) >> shamt;
else
r = 32'bXXXXXXXX_XXXXXXXX_XXXXXXXX_XXXXXXXX;
end 
endmodule
