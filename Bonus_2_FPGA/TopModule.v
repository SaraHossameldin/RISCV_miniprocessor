module TopModule(input clk, input SSD_clk, input rst, input[3:0] ssdSel,input [1:0] ledSel, 
output [15:0] leds, output [6:0] LED_out, output[3:0] Anode);
wire [31:0] out;

RISCV processor(.clk(clk),.SSD_clk(SSD_clk),.rst(rst),.ssdSel(ssdSel), .ledSel(ledSel), 
.out(out),.leds(leds));

Four_Digit_Seven_Segment_Driver_Optimized topsevseg(.clk(SSD_clk),.num(out[12:0]),.Anode(Anode),
 .LED_out(LED_out));

endmodule
