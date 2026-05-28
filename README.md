

# **femtoRV32 – Pipelined RISC-V Processor**

### **CSCE 3301 – Computer Architecture – Project 1**

This project implements a **5-stage pipelined RISC-V processor (RV32I)** based on the *femtoRV32* architecture.
It includes full hazard handling (stalling + forwarding), pipeline registers, ALU / control units, and partial FPGA integration.

---

##  **Project Structure**

```
/src
│   alu.v
│   control_unit.v
│   datapath.v
│   forwarding_unit.v
│   hazard_detection_unit.v
│   imm_gen.v
|   SevenSegmentDisplay.v
|   TopModule.v 
│   instruction_memory.v
│   data_memory.v
│   pipeline_registers.v
│   register_file.v
│
/test
│   testbench.v
│   hazard_tests.v
│   forwarding_tests.v
|    Topmodule_tests.v
│   instruction_tests.v
│
/fpga
│   top_fpga.v
│   constraints.xdc
│   clock_divider.v
│   reset_sync.v
│
/docs
    Individual_Contribution_Report.pdf
    Block_Diagrams/
    Waveforms/

# **Processor Features**

## ✔ **5-Stage Pipeline**

* **IF** – Instruction Fetch
* **ID** – Instruction Decode
* **EX** – Execute / ALU
* **MEM** – Data Memory
* **WB** – Write Back

Supports continuous flow of instructions with hazard handling.


# **Hazard Handling**

## ✔ Hazard Detection Unit

Detects **load-use hazards** and introduces a **1-cycle stall**.

Implemented logic:

* Checks if **ID/EX** is a load instruction
* Compares destination register with **rs1/rs2** of IF/ID
* Ignores hazards involving **x0**
* Asserts `stall = 1` when required

This prevents incorrect ALU input values during the execution stage.


## Forwarding Unit

Resolves data hazards without stalling by forwarding results:

| Source      | Forwarding Path                  |
| ----------- | -------------------------------- |
| EX/MEM → EX | `forwardA = 10`, `forwardB = 10` |
| MEM/WB → EX | `forwardA = 01`, `forwardB = 01` |

Priority:

1. Forward from **EX/MEM**
2. Then from **MEM/WB**

Ensures correct ALU inputs for dependent instructions.


#  **Pipeline Registers**

### Each stage has its own register:

* `IF/ID`
* `ID/EX`
* `EX/MEM`
* `MEM/WB`

Supports:

* Normal pipeline advancement
* Stalling (freezing IF/ID)
* Flushing
* Forwarding signals

---

# **RV32I Instruction Support**

All **37 RV32I instructions** are supported:

### **Arithmetic / Logic**

`add, sub, xor, or, and, sll, srl, sra`

### **Immediate**

`addi, ori, xori, slli, srli, srai`

### **Load/Store**

`lw, sw`

### **Branch & Jump**

`beq, bne, blt, bge, jal, jalr`

### **Upper**

`lui, auipc`

Memory initializes as:

```
Mem[i] = i
```


# **Testing and Debugging**

### Extensive Test Benches

* Load-use hazard tests
* Forwarding tests
* Sequence tests covering all hazards
* Full RV32I correctness checks

### Waveform Debugging

Used **GTKWave** to verify:

* Stall cycles
* Forward paths
* Register updates
* Pipeline flow

### Automated Instruction Verification

Random instruction sequence generator for stress testing.


# **How to Run the Simulator**

### **Run using Icarus Verilog**

```bash
cd test
iverilog -o cpu_sim testbench.v ../src/*.v
vvp cpu_sim
```

### **Open Waveforms**

```bash
gtkwave waveform.vcd
```

---

#  **FPGA Implementation (Bonus Feature)**

### **Board:** Digilent **Nexys A7**

Implemented:

* Clock division
* Reset synchronization
* Basic I/O mapping in `constraints.xdc`
* LED output tests
* Switch input support

Vivado Steps:

1. Create new project
2. Add **src/** and **fpga/** files
3. Add `constraints.xdc`
4. Synthesize → Implement → Generate Bitstream

---

# **Team Members**

| Student                | Role                                                                 |
| ---------------------- | -------------------------------------------------------------------- |
| **Mennatallah Essam**  |  Hazard Unit, Forwarding Unit, Testing, FPGA groundwork |
| **Seba Wahba**         | Datapath integration, ALU/MEM modules                                |
| **Sara Hossam Faheem** |Team Leader — Control unit, memory modules, debugging, fixing 90% of the errors     |

---

#  **Main Contributions by Mennatallah Essam**

* Implemented **Hazard Detection Unit**
* Implemented **Forwarding Unit**
* Fixed MUX and forwarding connections in datapath
* Added pipeline stall/flush logic
* Built complete **test benches**
* Performed waveform testing and debugging
* Designed FPGA foundation (constraints + clock/reset logic)
* Coordinated team workflow and system integration

---

 **License**

This project is for academic purposes for **CSCE 3301 – Fall 2025**.
Reproduction is allowed only for learning or non-commercial use.

