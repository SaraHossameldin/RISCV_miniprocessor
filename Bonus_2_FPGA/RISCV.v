module RISCV
    (
        input clk,
        input SSD_clk, // CHECK: Signal is not read
        input rst,
        input[3:0] ssdSel,
        input[1:0] ledSel,
        output reg [31:0] out,
        output  reg [15:0]leds
    );
// Clock
wire n_clk=~clk; 
wire sclk; 
wire n_sclk;
assign n_sclk=~sclk; 
clock_div2 CLKDIV (.clk(clk),.rst(rst), .clk_out(sclk));

wire branch;
wire MemRead;
wire[1:0] ALUOp;
wire MemWrite;
wire RegWrite;
wire [31:0] pcIn;
wire [31:0] address;
wire zeroflag;
//wire[31:0] targetaddr; --> Unassigned and Unused
wire [31:0] readdata1;
wire [31:0] readdata2;
//wire [31:0] AlUres; --> Unassigned and Unused
//wire [31:0] memreaddata; --> Unassigned and Unused
wire[31:0] immout;
wire [31:0] alu_out;
wire  [3:0] ALUselect;
wire [31:0] memout;
wire rca2cout; //CHECK: Signal is not read
wire[31:0] rcasum;
wire [31:0] new_address;
wire [1:0] forwardA, forwardB;
wire stall, n_stall;
wire jal, jalr, auipc, lui; 
//wire pcSrc; --> Unassigned and Unused
wire [31:0] addr;
wire [31:0] regwritedata;
wire [31:0]  RF_in;
wire ALUSrc;
wire branch_out;
wire pcSrc;
wire IF_ID_Reg_load_selector;
assign IF_ID_Reg_load_selector = n_stall | pcSrc;

assign n_stall=~stall;
assign regwritedata = RF_in;

wire flush;
wire halt; 


// This is the IF/ID register:
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [31:0] IF_ID_PC, IF_ID_Inst;
IF_ID_Reg IF_ID(
    .clk(n_sclk),
    .rst(rst),
    .flush(1'b0),
    .load(n_stall),
    .PC_in(address),
    .Instr_in(memout),
    .PC_out(IF_ID_PC),
    .Instr_out(IF_ID_Inst)
);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////


//This is ID/EX register
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

//wire [4:0]id_ex_rd; --> Unassigned and Unused

wire [2:0] funct3;
assign funct3=IF_ID_Inst[14:12];

wire funct7;
assign funct7=IF_ID_Inst[30];

wire [4:0] IF_ID_rs1;
assign IF_ID_rs1=IF_ID_Inst[19:15];

wire [4:0] IF_ID_rs2;
assign IF_ID_rs2 = IF_ID_Inst[24:20];

wire [4:0]IF_ID_rd;
assign IF_ID_rd=IF_ID_Inst[11:7]; 



wire [31:0] ID_EX_PC,ID_EX_Imm; 

//control signals 
wire ID_EX_RegWrite;
wire ID_EX_Memread, ID_EX_MemWrite;
wire ID_EX_ALUSrc; // CHECK: Signal is not read
wire [1:0] ID_EX_ALUOp;
wire ID_EX_branch;
//wire ID_EX_MemToReg; --> Unassigned and Unused


wire [3:0] ID_EX_Func; // CHECK: Signal is not read - follows from IDX_EX_funct7 not being read
wire [31:0] ID_EX_Readdata1, ID_EX_Readdata2;
wire [4:0] ID_EX_Rd;
wire [4:0] ID_EX_rs1, ID_EX_rs2; 
wire [10:0] ID_EX_Ctrl;
assign ID_EX_Ctrl= (stall==1'b1)? 11'b0000_0000000 :
                     {
                       branch,        
                       MemRead,       
                       MemWrite,      
                       ALUOp[1],       
                       ALUOp[0],      
                       ALUSrc,               
                       RegWrite,
                       auipc,
                       lui, 
                       jal, 
                       jalr        
                     };

wire [31:0] ID_EX_inst;
wire ID_EX_jal, ID_EX_jalr, ID_EX_auipc, ID_EX_lui; 

ID_EX_Reg ID_EX (
    .clk(sclk),
    .rst(rst),
    .flush(flush | halt),
    .load(1'b1),
    .branch_in(ID_EX_Ctrl[10]),
    .MemRead_in(ID_EX_Ctrl[9]),
    .MemWrite_in(ID_EX_Ctrl[8]),
    .ALUOp_in(ID_EX_Ctrl[7:6]),
    .ALUSrc_in(ID_EX_Ctrl[5]),
    .RegWrite_in(ID_EX_Ctrl[4]),
    .auipc_in(ID_EX_Ctrl[3]),
    .lui_in(ID_EX_Ctrl[2]),
    .jal_in(ID_EX_Ctrl[1]),
    .jalr_in(ID_EX_Ctrl[0]),
    .PC_in(IF_ID_PC),
    .Readdata1_in(readdata1),
    .Readdata2_in(readdata2),
    .Imm_in(immout),
    .funct_in({funct7,funct3}),
    .Rs1_in(IF_ID_rs1),
    .Rs2_in(IF_ID_rs2),
    .Rd_in(IF_ID_rd),
    .Instr_in(IF_ID_Inst),
    .branch_out(ID_EX_branch),
    .MemRead_out(ID_EX_Memread),
    .MemWrite_out(ID_EX_MemWrite),
    .ALUOp_out(ID_EX_ALUOp),
    .ALUSrc_out(ID_EX_ALUSrc),
    .RegWrite_out(ID_EX_RegWrite),
    .auipc_out(ID_EX_auipc),
    .lui_out(ID_EX_lui),
    .jal_out(ID_EX_jal),
    .jalr_out(ID_EX_jalr),
    .PC_out(ID_EX_PC),
    .Readdata1_out(ID_EX_Readdata1),
    .Readdata2_out(ID_EX_Readdata2),
    .Imm_out(ID_EX_Imm),
    .funct_out(ID_EX_Func),
    .Rs1_out(ID_EX_rs1),
    .Rs2_out(ID_EX_rs2),
    .Rd_out(ID_EX_Rd),
    .Instr_out(ID_EX_inst)
);


//////////////////////////////////////////////////////////////////////////////////////////////////////////////


// This is the EX/Mem register
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [31:0] EX_MEM_BranchAddOut, EX_MEM_ALU_out, EX_MEM_Readdata2;
wire [4:0] EX_MEM_Rd;
wire EX_MEM_Zero,Ex_MEM_c_flag,Ex_MEM_s_flag,Ex_MEM_v_flag;


wire EX_MEM_RegWrite, EX_MEM_branch, EX_MEM_MemRead;
wire EX_MEM_MemWrite; // CHECK: Signal is not read
wire[31:0] EX_MEM_Inst; // CHECK: Signal is not read
wire EX_MEM_jal, EX_MEM_jalr, EX_MEM_auipc, EX_MEM_lui;
wire [2:0] EX_MEM_funct3;
wire[31:0] EX_MEM_imm;
wire [2:0] ex_mem_funct3=ID_EX_inst[14:12];
wire [31:0] EX_MEM_Pc; 

wire [31:0] alu_input2_pre;
wire c_flag, s_flag,v_flag;

EX_MEM_Reg EM_MEM(
    .clk(n_sclk),
    .rst(rst),
    .flush(flush |halt),
    .load(1'b1),
    .RegWrite_in(ID_EX_RegWrite),
    .branch_in(ID_EX_branch),
    .MemRead_in( ID_EX_Memread),
    .MemWrite_in(ID_EX_MemWrite),
    .Instr_in(ID_EX_inst),
    .jal_in(ID_EX_jal),
    .jalr_in(ID_EX_jalr),
    .auipc_in(ID_EX_auipc),
    .lui_in(ID_EX_lui),
    .branch_add_in(rcasum),
    .zero_in(zeroflag),
    .c_flag_in(c_flag),
    .s_flag_in(s_flag),
    .v_flag_in(v_flag),
    .ALU_result_in(alu_out),
    .Readdata2_in(alu_input2_pre),
    .Rd_in(ID_EX_Rd),
    .imm_in(ID_EX_Imm),
    .funct3_in(ex_mem_funct3),
    .PC_in(ID_EX_PC),
    .RegWrite_out(EX_MEM_RegWrite),
    .branch_out(EX_MEM_branch),
    .MemRead_out(EX_MEM_MemRead),
    .MemWrite_out(EX_MEM_MemWrite),
    .Instr_out(EX_MEM_Inst),
    .jal_out(EX_MEM_jal),
    .jalr_out(EX_MEM_jalr),
    .auipc_out(EX_MEM_auipc),
    .lui_out(EX_MEM_lui),
    .branch_add_out(EX_MEM_BranchAddOut),
    .zero_out(EX_MEM_Zero),
    .c_flag_out(Ex_MEM_c_flag),
    .s_flag_out(Ex_MEM_s_flag),
    .v_flag_out(Ex_MEM_v_flag),
    .ALU_result_out(EX_MEM_ALU_out),
    .Readdata2_out(EX_MEM_Readdata2),
    .Rd_out(EX_MEM_Rd),
    .imm_out(EX_MEM_imm),
    .funct3_out(EX_MEM_funct3),
    .PC_out(EX_MEM_Pc)
);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////


//This is the Mem/WB register
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [31:0] MEM_WB_Mem_out,MEM_WB_ALU_out;
wire MEM_WB_RegWrite;
wire [4:0] MEM_WB_Rd;
wire [2:0] MEM_WB_funct3; 
wire [31:0] MEM_WB_BranchAddOut; 
wire [31:0] MEM_WB_imm;
wire MEM_WB_auipc, MEM_WB_jal, MEM_WB_jalr, MEM_WB_lui, MEM_WB_MemRead; 
wire [31:0] MEM_WB_PC; 
MEM_WB_Reg MEM_WB(
    .clk(sclk),
    .rst(rst),
    .load(1'b1),
    .memout_in(memout),
    .ALU_out_in(EX_MEM_ALU_out),
    .RegWrite_in(EX_MEM_RegWrite),
    .Rd_in(EX_MEM_Rd),
    .funct3_in(EX_MEM_funct3),
    .branch_add_in(EX_MEM_BranchAddOut),
    .imm_in(EX_MEM_imm),
    .auipc_in(EX_MEM_auipc),
    .jal_in(EX_MEM_jal),
    .jalr_in(EX_MEM_jalr),
    .lui_in(EX_MEM_lui),
    .MemRead_in(EX_MEM_MemRead),
    .PC_in(EX_MEM_Pc),
    .memout_out(MEM_WB_Mem_out),
    .ALU_out_out(MEM_WB_ALU_out),
    .RegWrite_out(MEM_WB_RegWrite),
    .Rd_out(MEM_WB_Rd),
    .funct3_out(MEM_WB_funct3),
    .PC_out(MEM_WB_PC),
    .branch_add_out(MEM_WB_BranchAddOut),
    .imm_out(MEM_WB_imm),
    .auipc_out(MEM_WB_auipc),
    .jal_out(MEM_WB_jal),
    .jalr_out(MEM_WB_jalr),
    .lui_out(MEM_WB_lui),
    .MemRead_out(MEM_WB_MemRead)
);



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign new_address = address+4;

wire zeroFlag;
assign zeroFlag=EX_MEM_Zero;
wire ex_mem_branch;
assign ex_mem_branch=EX_MEM_branch;
wire and_out; // CHECK: Signal is not read
assign and_out=zeroFlag&ex_mem_branch;

wire [6:0] halt_opcode;
assign halt_opcode= EX_MEM_Inst[6:0]; 
assign pcIn = (branch_out==1'b1 || EX_MEM_jal==1'b1)? EX_MEM_BranchAddOut : (EX_MEM_jalr==1'b1)? EX_MEM_ALU_out : (halt_opcode==7'b1110011 || halt_opcode==7'b0001111)? EX_MEM_Pc: new_address;
assign halt= (halt_opcode==7'b1110011 || halt_opcode==7'b0001111)? 1'b1:1'b0; 
assign pcSrc= (branch_out==1'b1) ?1'b1:1'b0; 
pc DUT2(.D(pcIn),.clk(sclk),.load(n_stall),. rst(rst),.Q(address));


wire [6:0] control_opcode;
assign control_opcode=IF_ID_Inst[6:0];
control DUT(.opcode(control_opcode), .branch(branch), .MemRead(MemRead), .ALUOp(ALUOp), .MemWrite(MemWrite), .RegWrite(RegWrite), .auipc(auipc), .lui(lui), .jal(jal), .jalr(jalr), .ALUSrc(ALUSrc));

 wire [31:0] load_data;
generator Load_Gen(.word_in(MEM_WB_Mem_out),.funct3(MEM_WB_funct3),.word_out(load_data));

wire [31:0] ID_EX_PC_new;
assign ID_EX_PC_new= ID_EX_PC+4; 
assign RF_in= ( MEM_WB_jalr==1'b1 || MEM_WB_jal==1'b1)? MEM_WB_PC+4 : (MEM_WB_lui==1'b1)? MEM_WB_imm: (MEM_WB_auipc==1'b1)? MEM_WB_BranchAddOut :(MEM_WB_MemRead==1'b1)?load_data: MEM_WB_ALU_out;

RF DUT3 ( .clk(sclk), .rst(rst),. regwrite(MEM_WB_RegWrite),.rs1(IF_ID_rs1), .rs2(IF_ID_rs2),.writereg(MEM_WB_Rd), .writedata(RF_in), .rdata1(readdata1),.rdata2(readdata2));

immediateGen DUT5( .IR(IF_ID_Inst), .Imm(immout));

//wire [3:0] ID_EX_funct3; --> Unassigned and Unused
//assign ID_EX_funct3 =ID_EX_Func[2:0]; --> Follows from Unused ID_EX_funct3
wire ID_EX_funct7; //CHECK: Signal is not read
assign ID_EX_funct7 =ID_EX_Func[3]; 
 ALUcontrol dut9(.ALUOp(ID_EX_ALUOp),.instruction(ID_EX_inst), . ALUselect( ALUselect));


wire[31:0] alu_input1, alu_input2;
forwardingUnit FUnit(.EX_MEM_RegWrite(EX_MEM_RegWrite),.EX_MEM_RD(EX_MEM_Rd),
.MEM_WB_RegWrite(MEM_WB_RegWrite), .MEM_WB_RD(MEM_WB_Rd),.ID_EX_rs1(ID_EX_rs1),
.ID_EX_rs2(ID_EX_rs2),.forwardA(forwardA),.forwardB(forwardB));

mux4x132 MUX1 (
    .in1(ID_EX_Readdata2),
    .in2(EX_MEM_ALU_out),
    .in3(regwritedata),
    .in4(32'b0),
    .forward(forwardB),
    .out(alu_input2_pre)
);


wire Immsel;
assign Immsel= ID_EX_Ctrl[5];
mux2to132 LUT7 (
    .a(alu_input2_pre),
    .b(ID_EX_Imm),
    .sel(Immsel),
    .c(alu_input2)
);

mux4x132 MUX2 (
    .in1(ID_EX_Readdata1),
    .in2(EX_MEM_ALU_out),
    .in3(regwritedata),
    .in4(32'b0),
    .forward(forwardA),
    .out(alu_input1)
);

wire [31:0] word_out; 
generator GenStore (.word_in(EX_MEM_Readdata2),.funct3(EX_MEM_funct3),.word_out(word_out));

wire shamtSelect;
wire [4:0] shamt;
assign shamtSelect = ID_EX_Ctrl[5]; 
mux2to132 shamtMux(.a(ID_EX_Readdata2), .b(ID_EX_Imm), .sel(shamtSelect), .c(shamt)); 


ALU DUT6(
    .a(alu_input1),
    .b(alu_input2),
    .shamt(shamt),
    .r(alu_out),
    .cf(c_flag), 
    .zf(zeroflag), 
    .vf(v_flag),
    .sf(s_flag),
    .alufn(ALUselect)
);

Branch_Unit BU(.branch(EX_MEM_branch),.z_flag( EX_MEM_Zero),.c_flag(Ex_MEM_c_flag),.s_flag(Ex_MEM_s_flag),.v_flag(Ex_MEM_v_flag),.funct3(EX_MEM_funct3), .branch_out(branch_out));

HazardDetectionUnit HDU (.IF_ID_rs1(IF_ID_rs1),.IF_ID_rs2(IF_ID_rs2) ,.ID_EX_RD(ID_EX_Rd),.ID_EX_MemRead(ID_EX_Memread),.stall(stall));

RCA DUT12(.a(ID_EX_Imm),.cin(1'b0),.b(ID_EX_PC), .cout(rca2cout),.sum(rcasum));

// Memory
mux2to132 muxMem(.a(address), .b(EX_MEM_ALU_out), .sel(n_sclk), .c(addr));
//Memory Unified_Mem(.clk(sclk),.MemRead(MemRead),.MemWrite(MemWrite), .addr(addr),.data_in(word_out),.data_out(memout));
wire Memory_MemWrite;
assign Memory_MemWrite = EX_MEM_MemWrite & n_sclk; 
Memory Unified_Mem(.clk(n_clk),.MemRead(1'b1),.MemWrite(EX_MEM_MemWrite & n_sclk), .addr(addr),.data_in(word_out),.data_out(memout));

assign flush = branch_out | EX_MEM_jal | EX_MEM_jalr;


always @(*) begin
    case (ledSel)
      2'b00:leds=memout[15:0] ;
      2'b01: leds=memout[31:16];
      2'b10: leds = {
    EX_MEM_branch,
    EX_MEM_MemRead,
    1'b0,
    ID_EX_ALUOp,
    EX_MEM_MemWrite,
    ID_EX_ALUSrc,
    MEM_WB_RegWrite,
    EX_MEM_Zero,
    ALUselect
};
       default: leds = 16'b0;
    endcase
 
end
always @(*) begin
    case (ssdSel)
        4'b0000: out=pcIn;
        4'b0001:out= pcIn+4;
        4'b0010:out=rcasum ;
       
        4'b0011: out=address;
        4'b0100:out=readdata1 ;
        4'b0101: out=readdata2;
       
        4'b0110: out=regwritedata;
        4'b0111: out=immout ;

        4'b1010: out= alu_out;
        4'b1011: out=memout ;
        4'b1100: out=RegWrite;
        
        default: out = 32'b0;
    endcase
end
endmodule