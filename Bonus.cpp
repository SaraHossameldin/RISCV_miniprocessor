#include <iostream>
#include <fstream>
#include <random>
#include <vector>
#include <string>
#include <iomanip>
#include <cstdint>
#include <map>

using namespace std;

class RISCVTestGenerator {
private:
    random_device rd;
    mt19937 gen;
    uniform_int_distribution<int> reg_dist;
    uniform_int_distribution<int> imm12_dist;
    uniform_int_distribution<int> imm20_dist;
    uniform_int_distribution<int> offset_dist;
    uniform_int_distribution<int> shamt_dist;

    // Register names for readability
    map<int, string> reg_names = {
        {0, "x0"}, {1, "x1"}, {2, "x2"}, {3, "x3"}, {4, "x4"}, {5, "x5"},
        {6, "x6"}, {7, "x7"}, {8, "x8"}, {9, "x9"}, {10, "x10"}, {11, "x11"},
        {12, "x12"}, {13, "x13"}, {14, "x14"}, {15, "x15"}, {16, "x16"},
        {17, "x17"}, {18, "x18"}, {19, "x19"}, {20, "x20"}, {21, "x21"},
        {22, "x22"}, {23, "x23"}, {24, "x24"}, {25, "x25"}, {26, "x26"},
        {27, "x27"}, {28, "x28"}, {29, "x29"}, {30, "x30"}, {31, "x31"}
    };

    struct TestCase {
        string instruction;
        string asm_code;
        string binary;
        string expected_result;
        string description;
    };

    vector<TestCase> test_cases;
    int pc_addr;

public:
    RISCVTestGenerator() : gen(rd()),
        reg_dist(1, 31),  // x1-x31 (avoid x0 for dest in most cases)
        imm12_dist(-2048, 2047),  // 12-bit signed immediate
        imm20_dist(0, 1048575),   // 20-bit unsigned
        offset_dist(-128, 127),   // Small offsets for branches
        shamt_dist(0, 31),        // Shift amount 0-31
        pc_addr(0x1000) {}

    // Encode R-type instruction
    uint32_t encode_r_type(uint8_t opcode, uint8_t rd, uint8_t funct3,
        uint8_t rs1, uint8_t rs2, uint8_t funct7) {
        return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) |
            (funct3 << 12) | (rd << 7) | opcode;
    }

    // Encode I-type instruction
    uint32_t encode_i_type(uint8_t opcode, uint8_t rd, uint8_t funct3,
        uint8_t rs1, int16_t imm) {
        return ((imm & 0xFFF) << 20) | (rs1 << 15) |
            (funct3 << 12) | (rd << 7) | opcode;
    }

    // Encode S-type instruction
    uint32_t encode_s_type(uint8_t opcode, uint8_t funct3, uint8_t rs1,
        uint8_t rs2, int16_t imm) {
        uint32_t imm11_5 = (imm >> 5) & 0x7F;
        uint32_t imm4_0 = imm & 0x1F;
        return (imm11_5 << 25) | (rs2 << 20) | (rs1 << 15) |
            (funct3 << 12) | (imm4_0 << 7) | opcode;
    }

    // Encode B-type instruction
    uint32_t encode_b_type(uint8_t opcode, uint8_t funct3, uint8_t rs1,
        uint8_t rs2, int16_t imm) {
        uint32_t imm12 = (imm >> 12) & 0x1;
        uint32_t imm10_5 = (imm >> 5) & 0x3F;
        uint32_t imm4_1 = (imm >> 1) & 0xF;
        uint32_t imm11 = (imm >> 11) & 0x1;
        return (imm12 << 31) | (imm10_5 << 25) | (rs2 << 20) |
            (rs1 << 15) | (funct3 << 12) | (imm4_1 << 8) |
            (imm11 << 7) | opcode;
    }

    // Encode U-type instruction
    uint32_t encode_u_type(uint8_t opcode, uint8_t rd, uint32_t imm) {
        return (imm << 12) | (rd << 7) | opcode;
    }

    // Encode J-type instruction
    uint32_t encode_j_type(uint8_t opcode, uint8_t rd, int32_t imm) {
        uint32_t imm20 = (imm >> 20) & 0x1;
        uint32_t imm10_1 = (imm >> 1) & 0x3FF;
        uint32_t imm11 = (imm >> 11) & 0x1;
        uint32_t imm19_12 = (imm >> 12) & 0xFF;
        return (imm20 << 31) | (imm19_12 << 12) | (imm11 << 20) |
            (imm10_1 << 21) | (rd << 7) | opcode;
    }

    string to_binary(uint32_t val) {
        string result;
        for (int i = 31; i >= 0; i--) {
            result += ((val >> i) & 1) ? '1' : '0';
        }
        return result;
    }

    // Generate LUI test
    void gen_lui() {
        int rd = reg_dist(gen);
        uint32_t imm = imm20_dist(gen);
        uint32_t binary = encode_u_type(0b0110111, rd, imm);

        TestCase tc;
        tc.instruction = "LUI";
        tc.asm_code = "lui " + reg_names[rd] + ", 0x" +
            to_string(imm);
        tc.binary = to_binary(binary);
        tc.expected_result = "0x" + to_string((imm << 12));
        tc.description = "Load Upper Immediate";

        test_cases.push_back(tc);
    }

    // Generate AUIPC test
    void gen_auipc() {
        int rd = reg_dist(gen);
        uint32_t imm = imm20_dist(gen) & 0xFFFFF;  // 20-bit
        uint32_t binary = encode_u_type(0b0010111, rd, imm);

        TestCase tc;
        tc.instruction = "AUIPC";
        tc.asm_code = "auipc " + reg_names[rd] + ", 0x" +
            to_string(imm);
        tc.binary = to_binary(binary);
        tc.expected_result = "PC + 0x" + to_string((imm << 12));
        tc.description = "Add Upper Immediate to PC";

        test_cases.push_back(tc);
    }

    // Generate JAL test
    void gen_jal() {
        int rd = reg_dist(gen);
        int offset = (offset_dist(gen) / 2) * 2;  // Even offset
        uint32_t binary = encode_j_type(0b1101111, rd, offset);

        TestCase tc;
        tc.instruction = "JAL";
        tc.asm_code = "jal " + reg_names[rd] + ", " + to_string(offset);
        tc.binary = to_binary(binary);
        tc.expected_result = "PC + 4";
        tc.description = "Jump and Link";

        test_cases.push_back(tc);
    }

    // Generate JALR test
    void gen_jalr() {
        int rd = reg_dist(gen);
        int rs1 = reg_dist(gen);
        int imm = imm12_dist(gen);
        uint32_t binary = encode_i_type(0b1100111, rd, 0b000, rs1, imm);

        TestCase tc;
        tc.instruction = "JALR";
        tc.asm_code = "jalr " + reg_names[rd] + ", " +
            reg_names[rs1] + ", " + to_string(imm);
        tc.binary = to_binary(binary);
        tc.expected_result = "PC + 4";
        tc.description = "Jump and Link Register";

        test_cases.push_back(tc);
    }

    // Generate Branch instructions
    void gen_branch(string name, uint8_t funct3) {
        int rs1 = reg_dist(gen);
        int rs2 = reg_dist(gen);
        int offset = (offset_dist(gen) / 2) * 2;  // Even offset
        uint32_t binary = encode_b_type(0b1100011, funct3, rs1, rs2, offset);

        TestCase tc;
        tc.instruction = name;
        tc.asm_code = name + " " + reg_names[rs1] + ", " +
            reg_names[rs2] + ", " + to_string(offset);
        tc.binary = to_binary(binary);
        tc.expected_result = "Branch taken/not taken";
        tc.description = name + " instruction";

        test_cases.push_back(tc);
    }

    // Generate Load instructions
    void gen_load(string name, uint8_t funct3) {
        int rd = reg_dist(gen);
        int rs1 = reg_dist(gen);
        int offset = imm12_dist(gen);
        uint32_t binary = encode_i_type(0b0000011, rd, funct3, rs1, offset);

        TestCase tc;
        tc.instruction = name;
        tc.asm_code = name + " " + reg_names[rd] + ", " +
            to_string(offset) + "(" + reg_names[rs1] + ")";
        tc.binary = to_binary(binary);
        tc.expected_result = "Loaded value";
        tc.description = name + " instruction";

        test_cases.push_back(tc);
    }

    // Generate Store instructions
    void gen_store(string name, uint8_t funct3) {
        int rs1 = reg_dist(gen);
        int rs2 = reg_dist(gen);
        int offset = imm12_dist(gen);
        uint32_t binary = encode_s_type(0b0100011, funct3, rs1, rs2, offset);

        TestCase tc;
        tc.instruction = name;
        tc.asm_code = name + " " + reg_names[rs2] + ", " +
            to_string(offset) + "(" + reg_names[rs1] + ")";
        tc.binary = to_binary(binary);
        tc.expected_result = "Value stored";
        tc.description = name + " instruction";

        test_cases.push_back(tc);
    }

    // Generate ALU immediate instructions
    void gen_alu_imm(string name, uint8_t funct3) {
        int rd = reg_dist(gen);
        int rs1 = reg_dist(gen);
        int imm = imm12_dist(gen);
        uint32_t binary = encode_i_type(0b0010011, rd, funct3, rs1, imm);

        TestCase tc;
        tc.instruction = name;
        tc.asm_code = name + " " + reg_names[rd] + ", " +
            reg_names[rs1] + ", " + to_string(imm);
        tc.binary = to_binary(binary);
        tc.expected_result = "ALU result";
        tc.description = name + " instruction";

        test_cases.push_back(tc);
    }

    // Generate ALU register instructions
    void gen_alu_reg(string name, uint8_t funct3, uint8_t funct7) {
        int rd = reg_dist(gen);
        int rs1 = reg_dist(gen);
        int rs2 = reg_dist(gen);
        uint32_t binary = encode_r_type(0b0110011, rd, funct3, rs1, rs2, funct7);

        TestCase tc;
        tc.instruction = name;
        tc.asm_code = name + " " + reg_names[rd] + ", " +
            reg_names[rs1] + ", " + reg_names[rs2];
        tc.binary = to_binary(binary);
        tc.expected_result = "ALU result";
        tc.description = name + " instruction";

        test_cases.push_back(tc);
    }

    // Generate shift immediate instructions
    void gen_shift_imm(string name, uint8_t funct3, uint8_t funct7) {
        int rd = reg_dist(gen);
        int rs1 = reg_dist(gen);
        int shamt = shamt_dist(gen);
        uint32_t binary = encode_i_type(0b0010011, rd, funct3, rs1,
            (funct7 << 5) | shamt);

        TestCase tc;
        tc.instruction = name;
        tc.asm_code = name + " " + reg_names[rd] + ", " +
            reg_names[rs1] + ", " + to_string(shamt);
        tc.binary = to_binary(binary);
        tc.expected_result = "Shifted value";
        tc.description = name + " instruction";

        test_cases.push_back(tc);
    }

    // Generate all test cases
    void generate(int num_tests) {
        test_cases.clear();

        // Generate diverse set of instructions
        for (int i = 0; i < num_tests; i++) {
            int choice = gen() % 15;

            switch (choice) {
            case 0: gen_lui(); break;
            case 1: gen_auipc(); break;
            case 2: gen_jal(); break;
            case 3: gen_jalr(); break;
            case 4: gen_branch("beq", 0b000); break;
            case 5: gen_branch("bne", 0b001); break;
            case 6: gen_branch("blt", 0b100); break;
            case 7: gen_branch("bge", 0b101); break;
            case 8: gen_branch("bltu", 0b110); break;
            case 9: gen_branch("bgeu", 0b111); break;
            case 10: gen_load("lw", 0b010); break;
            case 11: gen_store("sw", 0b010); break;
            case 12: gen_alu_imm("addi", 0b000); break;
            case 13: gen_alu_reg("add", 0b000, 0b0000000); break;
            case 14: gen_alu_reg("sub", 0b000, 0b0100000); break;
            }
        }

        // Add specific comprehensive tests
        gen_load("lb", 0b000);
        gen_load("lh", 0b001);
        gen_load("lbu", 0b100);
        gen_load("lhu", 0b101);
        gen_store("sb", 0b000);
        gen_store("sh", 0b001);

        // ALU operations
        gen_alu_reg("sll", 0b001, 0b0000000);
        gen_alu_reg("slt", 0b010, 0b0000000);
        gen_alu_reg("sltu", 0b011, 0b0000000);
        gen_alu_reg("xor", 0b100, 0b0000000);
        gen_alu_reg("srl", 0b101, 0b0000000);
        gen_alu_reg("sra", 0b101, 0b0100000);
        gen_alu_reg("or", 0b110, 0b0000000);
        gen_alu_reg("and", 0b111, 0b0000000);

        // Immediate ALU
        gen_alu_imm("slti", 0b010);
        gen_alu_imm("sltiu", 0b011);
        gen_alu_imm("xori", 0b100);
        gen_alu_imm("ori", 0b110);
        gen_alu_imm("andi", 0b111);

        // Shift immediate
        gen_shift_imm("slli", 0b001, 0b0000000);
        gen_shift_imm("srli", 0b101, 0b0000000);
        gen_shift_imm("srai", 0b101, 0b0100000);
    }

    // Export to assembly file
    void export_asm(const string& filename) {
        ofstream file(filename);

        file << "    .section .text\n";
        file << "    .global _start\n";
        file << "_start:\n";
        file << "    la   t0, results\n";
        file << "    addi t0, t0, 0\n\n";

        for (size_t i = 0; i < test_cases.size(); i++) {
            file << "    # Test " << i << ": " << test_cases[i].description << "\n";
            file << "    " << test_cases[i].asm_code << "\n";
            file << "    # Binary: " << test_cases[i].binary << "\n";
            file << "    # Expected: " << test_cases[i].expected_result << "\n\n";
        }

        file << "done:\n";
        file << "    jal x0, done\n\n";
        file << "    .section .data\n";
        file << "    .align 2\n";
        file << "results:\n";
        for (size_t i = 0; i < test_cases.size(); i++) {
            file << "    .word 0  # " << i << "\n";
        }

        file.close();
    }

    // Export to Verilog memory initialization file
    void export_mem_init(const string& filename) {
        ofstream file(filename);

        file << "// RISC-V Test Memory Initialization\n";
        file << "// Generated test cases\n\n";

        for (size_t i = 0; i < test_cases.size(); i++) {
            uint32_t binary_val = 0;
            for (int j = 0; j < 32; j++) {
                if (test_cases[i].binary[j] == '1') {
                    binary_val |= (1 << (31 - j));
                }
            }
            file << "@" << hex << setw(8) << setfill('0') << (i * 4) << " ";
            file << hex << setw(8) << setfill('0') << binary_val << "\n";
        }

        file.close();
    }

    // Print summary
    void print_summary() {
        cout << "\n=== RISC-V Test Case Generation Summary ===\n";
        cout << "Total test cases generated: " << test_cases.size() << "\n\n";

        map<string, int> inst_count;
        for (const auto& tc : test_cases) {
            inst_count[tc.instruction]++;
        }

        cout << "Instruction breakdown:\n";
        for (const auto& pair : inst_count) {
            cout << "  " << pair.first << ": " << pair.second << "\n";
        }
        cout << "\n";
    }
};

int main(int argc, char* argv[]) {
    int num_tests = 50;  // Default number of random tests

    if (argc > 1) {
        num_tests = stoi(argv[1]);
    }

    RISCVTestGenerator gen;

    cout << "Generating " << num_tests << " RISC-V test cases...\n";
    gen.generate(num_tests);

    gen.export_asm("test_cases.s");
    gen.export_mem_init("test_mem.hex");

    gen.print_summary();

    cout << "Files generated:\n";
    cout << "  - test_cases.s (Assembly)\n";
    cout << "  - test_mem.hex (Verilog memory init)\n";

    return 0;
}
