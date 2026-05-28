module HazardDetectionUnit(
input[4:0] IF_ID_rs1, input [4:0] IF_ID_rs2, input [4:0] ID_EX_RD, 
input ID_EX_MemRead, output reg stall); 
always @ * begin
stall=1'b0; 
if((IF_ID_rs1 == ID_EX_RD || IF_ID_rs2==ID_EX_RD) && (ID_EX_MemRead==1'b1 && ID_EX_RD!=5'b0 ))
stall=1'b1;
end 
endmodule