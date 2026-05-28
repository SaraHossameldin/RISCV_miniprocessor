module RISCV_tb();
reg clkssd;
reg clk;
localparam clk_period=10;
 initial begin
clk=1'b0;
forever #(clk_period/2) clk=~clk;
end
reg rst;
reg [3:0] ssdSel;
reg [1:0] ledSel;
wire [12:0]  selected_output;
wire [15:0] led;
RISCV Seba(.clk(clk), .rst(rst), .ssdSel(ssdSel),.ledSel(ledSel),.out(selected_output),.leds(led),.SSD_clk(clkssd));
initial begin
 rst=1'b1;
 #(clk_period)
 rst=1'b0;
end
endmodule