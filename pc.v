module pc#(parameter n=32 )
(input [n-1:0]D ,input clk,input load, input rst,output [n-1:0]Q);
wire [n-1:0]muxoutput;
genvar i;
generate 
for(i=0;i<n;i=i+1)
begin
 mux2to1 severamuxes(.a(D[i]),.b(Q[i]),.sel(load),.c(muxoutput[i]));
DFlipFlop DUT(.clk(clk),.rst(rst),.D(muxoutput[i]),.Q(Q[i]));

end
endgenerate
endmodule
