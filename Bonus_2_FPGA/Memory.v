module Memory
(input clk, input MemRead, input MemWrite,
input [31:0] addr, input [31:0] data_in, output reg [31:0] data_out);
reg [31:0] mem [0:63];
always @ (posedge clk) begin
    if(MemWrite==1'b1)
    begin
    mem[addr / 4]<=data_in;
    end
end
always @(*) begin
    if(MemRead && addr < 64 * 4)
        data_out = mem[addr / 4];
    else
        data_out = 32'b0;
end

initial begin
mem[20]=32'd17;
mem[21]=32'd9;
mem[22]=32'd25;

mem[0]=32'b0000000_00000_00000_000_00000_0110011; //add x0, x0, x0
mem[1]=32'b00010010001101000101001010110111; // LUI x5, 0x12345000
mem[2]=32'b00000000000001010110001100010111; // AUIPC x6, 0x00056000
mem[3]=32'b00000001000000000000000011101111; // JAL x1, 16
mem[4]=32'b0000000_00000_00000_000_00000_0110011; 
mem[5]=32'b0000000_00000_00000_000_00000_0110011; 
mem[6]=32'b0000000_00000_00000_000_00000_0110011; 
mem[7]=32'b0000000_00000_00000_000_00000_0110011; 
mem[8]=32'b0000000_00000_00000_000_00000_0110011; 
mem[9]=32'b0000000_00000_00000_000_00000_0110011; 
mem[10]=32'b0000000_00000_00000_000_00000_0110011; 
mem[11]=32'b00000000000000010000000011100111; // JALR x1, x2, 0
end
endmodule