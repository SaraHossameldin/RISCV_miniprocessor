module mux4x132( input [31:0] in1, input [31:0] in2, input [31:0] in3, input [31:0] in4,
input[1:0] forward, output reg [31:0] out);

always @ * begin
if(forward==2'b00) out=in1;
else if(forward==2'b10) out=in2;
else if(forward==2'b01) out=in3;
else out=in4;
end 

endmodule