`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2025 05:06:23 PM
// Design Name: 
// Module Name: RF
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


module RF(input clk, input rst,input regwrite, input[4:0] rs1, input [4:0] rs2, input[4:0] writereg, input[31:0] writedata, output[31:0] rdata1, output[31:0] rdata2);
    reg[31:0] regfile[31:0]; 
    assign rdata1=regfile[rs1];
    assign rdata2=regfile[rs2];

    integer i;
    always @(negedge clk or posedge rst)
        begin
        regfile[0]=32'b0; 
        if(rst==1'b1) begin
            for(i=0; i<32;i=i+1)
            begin
            regfile[i]=32'b0;
            end 
        end else begin
            if(regwrite==1'b1) 
            begin
            if(writereg!=0)
            regfile[writereg]=writedata;
            end
        end
    end
endmodule