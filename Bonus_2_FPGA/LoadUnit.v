module LoadUnit (
    input  [6:0] opcode,   
    input  [2:0] funct3,    
    output reg [1:0] load_size, 
    output reg  unsigned_load 
);

    always @(*) begin
        load_size = 2'b00;
        unsigned_load = 1'b0;
        if (opcode == 7'b0000011) begin
            case (funct3)
                3'b000: begin 
                    load_size = 2'b00; 
                    unsigned_load = 1'b0;
                end
                3'b001: begin 
                    load_size = 2'b01; 
                    unsigned_load = 1'b0;
                end
                3'b010: begin 
                    load_size = 2'b10; 
                    unsigned_load = 1'b0;
                end
                3'b100: begin 
                    load_size = 2'b00; 
                    unsigned_load = 1'b1;
                end
                3'b101: begin 
                    load_size = 2'b01; 
                    unsigned_load = 1'b1;
                end
                default: begin
                    load_size = 2'b00;
                    unsigned_load = 1'b0;
                end
            endcase
        end
    end
endmodule
