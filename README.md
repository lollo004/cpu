# 🧠 16-bit Verilog CPU with Custom Assembler

A complete 16-bit CPU implementation built from scratch in Verilog, featuring a custom Python-based assembler and comprehensive simulation environment. This processor follows a non-pipelined, single instruction per clock architecture with support for arithmetic, logic, and branching operations.

## ✨ Features

* **Basic Instruction Set**: supports a fundamental set of CPU instructions (e.g., arithmetic, data transfer, control flow).
* **Register File**: manages general-purpose registers for data storage and manipulation.
* **Program Counter**:  tracks the execution flow. 
* **Memory Interaction**: demonstrates basic memory read/write operations.
* **Modular Design**: Weorganized into logical components for clarity and expandability.

## 📁 Project Structure

```
cpu/
├── assembler_compiler/     # Python-based custom assembler
├── asm/                   # Example assembly input files (.asm, .s)
├── mem/                   # Generated memory .hex files
├── rtl/                   # Verilog CPU modules (ALU, regfile, control, etc.)
├── testbench/             # Testbench files for simulation
├── Makefile               # Automated build system
└── README.md              # This file
```

## 📦 Installation

### Requirements

- **Python 3.12+**
- **[Poetry](https://python-poetry.org/docs/)** (for dependency management)
- **[Icarus Verilog](http://iverilog.icarus.com/)** (`iverilog`, `vvp`) for Verilog simulation
- **[GTKWave](http://gtkwave.sourceforge.net/)** for waveform viewing

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/lollo004/cpu.git
   cd cpu
   ```

2. **Install Python dependencies:**
   ```bash
   poetry -C assembler_compiler install
   ```

## 🚀 Usage

### Assembly Development Workflow

#### 1. Write Assembly Code
Create or modify assembly files in the `asm/` directory. The assembler supports standard assembly syntax with CPU-specific instructions.

#### 2. Compile Assembly to Hex
**Option A: Using Makefile (Recommended)**
```bash
make compile
```
This compiles the file specified in `ASM_INPUT` (defaults to `asm/test.asm`) and outputs hex files to `mem/`.

**Option B: Manual Compilation**
```bash
poetry -C assembler_compiler run python main.py ../asm/your_program.asm -o ../mem
```

#### 3. Build and Run Simulation
```bash
make build    # Compile Verilog design and testbench
make run      # Execute simulation
```

#### 4. View Waveforms
```bash
make view     # Open GTKWave with cpu.vcd
```

#### 5. Clean artifacts:
```bash 
make clean
````
Removes build files and waveform dumps.



## 🧪 Testbench output

### Simulation Output Analysis

The simulation outputs:
- **ASCII "TESTING" banner**
- **Register contents** (all general-purpose registers)
- **Current instruction** (decoded format)
- **Status flags** (zero flag, etc.)
- **Data memory contents**

The testbench provides detailed cycle-by-cycle execution information. Here's an example of actual CPU simulation output:

```
████████ ██████  ███████ ████████ ██ ███    ██  ██████  
   ██    ██      ██         ██    ██ ████   ██ ██       
   ██    █████   ███████    ██    ██ ██ ██  ██ ██   ███ 
   ██    ██           ██    ██    ██ ██  ██ ██ ██    ██ 
   ██    ██████  ███████    ██    ██ ██   ████  ██████


VCD info: dumpfile cpu.vcd opened for output.

Cycle=1 | PC=0 | Instr=0x4000 (        OR) | Zero Flag=0
Registers:
  r0=0 | r1=1 | r2=0 | r3=0 | r4=0 | r5=0 | r6=0 | r7=0
Data Memory [0..7]: 10 2 0 0 0 0 0 0

Cycle=2 | PC=2 | Instr=0x0023 (       NOP) | Zero Flag=0
Registers:
  r0=0 | r1=1 | r2=10 | r3=0 | r4=0 | r5=0 | r6=0 | r7=0
Data Memory [0..7]: 10 2 0 0 0 0 0 0

Cycle=5 | PC=8 | Instr=0x2004 (       SUB) | Zero Flag=0
Registers:
  r0=0 | r1=1 | r2=2 | r3=10 | r4=0 | r5=2 | r6=0 | r7=0
Data Memory [0..7]: 10 2 0 0 0 0 0 0

Cycle=6 | PC=10 | Instr=0x045A (       NOP) | Zero Flag=1
Registers:
  r0=0 | r1=1 | r2=2 | r3=10 | r4=0 | r5=2 | r6=0 | r7=0
Data Memory [0..7]: 10 2 0 0 0 0 0 0

...

Cycle=99 | PC=4 | Instr=0x4001 (        OR) | Zero Flag=0
Registers:
  r0=0 | r1=1 | r2=10 | r3=10 | r4=10 | r5=2 | r6=0 | r7=0
Data Memory [0..7]: 10 2 0 0 0 0 0 0

Cycle=100 | PC=6 | Instr=0x0025 (       NOP) | Zero Flag=0
Registers:
  r0=0 | r1=1 | r2=2 | r3=10 | r4=10 | r5=2 | r6=0 | r7=0
Data Memory [0..7]: 10 2 0 0 0 0 0 0

Simulation timeout: $finish called at 1005000 (1ns)
```

### Debugging Workflow

- Use $display logs to follow the CPU execution cycle by cycle: Check console output for register values and instruction execution
- If a bug is found (e.g., wrong value in a register), inspect the wave (cpu.vcd) using GTKWave: Use make view to analyze signal timing


## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests to improve the CPU design or assembler functionality.
