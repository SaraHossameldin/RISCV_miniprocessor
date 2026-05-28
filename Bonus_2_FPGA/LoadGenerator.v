module generator(input[31:0] word_in, input [2:0] funct3, output reg [31:0] word_out);
always @ * 
    begin
    if(funct3==3'b000)
        begin
        word_out = { {24{word_in[7]}}, word_in[7:0] };
        end
    else if (funct3==3'b001)
        begin
        word_out = { {16{word_in[15]}}, word_in[15:0] };
        end
    else if(funct3==3'b010)
        begin
        word_out = word_in;
        end
    else if (funct3==3'b100)
        begin
        word_out = { {24{1'b0}}, word_in[7:0] };
        end
    else if (funct3==3'b101)
        begin
        word_out = { {16{1'b0}}, word_in[15:0] };
        end
    else
        begin
        word_out = 32'bXXXXXXXX_XXXXXXXX_XXXXXXXX_XXXXXXXX;
        end
    end
endmodule
