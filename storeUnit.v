module StoreUnit (
    input  [6:0] opcode,   
    input  [2:0] funct3,    
    output reg [1:0] store_size, 
    output reg  unsigned_store
);
 always @(*) begin
        store_size = 2'b00;
        unsigned_store = 1'b0;
        if (opcode == 7'b0100011) begin
            case (funct3)
                3'b000: begin 
                    store_size = 2'b00; 
                    unsigned_store = 1'b0;
                end
                3'b001: begin 
                    store_size = 2'b01; 
                    unsigned_store = 1'b0;
                end
                3'b010: begin 
                    store_size = 2'b10; 
                    unsigned_store = 1'b0;
                end
                3'b100: begin 
                    store_size = 2'b00; 
                    unsigned_store = 1'b1;
                end
                3'b101: begin 
                    store_size = 2'b01; 
                    unsigned_store = 1'b1;
                end
                default: begin
                    store_size = 2'b00;
                    unsigned_store = 1'b0;
                end
            endcase
        end
    end
endmodule
