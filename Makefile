# Makefile for 16-bit CPU simulation
TARGET = cpu_sim
SOURCES = testbench/tb_cpu.v rtl/cpu.v rtl/regfile.v rtl/alu.v rtl/imem.v rtl/dmem.v rtl/control.v
WAVEFORM = cpu.vcd

.PHONY: build run clean view 

build: $(TARGET)

$(TARGET): $(SOURCES)
	iverilog -o $@ $^

run: $(TARGET)
	vvp $(TARGET)

view: $(WAVEFORM)
	gtkwave $(WAVEFORM)

clean:
	rm -f $(TARGET) $(WAVEFORM)
