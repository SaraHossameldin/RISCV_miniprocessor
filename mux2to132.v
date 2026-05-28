module mux2to132
(input [31:0] a,input[31:0]  b,input sel, output[31:0] c);

//   assign c=(sel&b)|(~sel&a);
assign c= sel? b:a;
endmodule
