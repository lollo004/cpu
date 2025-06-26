# Makefile for 16-bit CPU simulation
TARGET = cpu_sim
ASM_INPUT = asm/test.asm
ASM_OUTPUT_DIR = mem
ASSEMBLER = assembler_compiler/main.py
SOURCES = testbench/tb_cpu.v rtl/cpu.v rtl/regfile.v rtl/alu.v rtl/imem.v rtl/dmem.v rtl/control.v
WAVEFORM = cpu.vcd

.PHONY: build run clean view compile

build: $(TARGET)

$(TARGET): $(SOURCES)
	iverilog -o $@ $^

run: $(TARGET)
	vvp $(TARGET)

view: $(WAVEFORM)
	gtkwave $(WAVEFORM)

compile: $(ASM_INPUT) $(ASSEMBLER)
	poetry -C assembler_compiler run python main.py ../asm/test.asm -o ../mem

clean:
	rm -f $(TARGET) $(WAVEFORM)
