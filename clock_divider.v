`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2025 07:57:47 PM
// Design Name: 
// Module Name: clock_divider
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
module clock_div2 (
    input wire clk,
    input wire rst,
    output reg clk_out
);

always @(posedge clk or posedge rst) begin
    if (rst)
        clk_out <= 1'b0;
    else
        clk_out <= ~clk_out;
end

endmodule

