include ../../makefile-common

.PHONY: all clean

all: tutorial-2a.exe
	@mkdir -p elf
	@mv *.elf* ./elf
	@cp ./elf/*.elf ./elf/*.elf.map .

# Command line mlir-aie compile script "aiecc.py"
# Sysroot and host target used to cross compile  host executable
# Local runtime_lib needed for testbench functions
tutorial-2a.exe : test.cpp aie.mlir
	aiecc.py -j4 ${AIECC_FLAGS} $(word 2,$^) ${AIECC_HOST_FLAGS} ./$< -o $@

clean:
	rm -rf aie.mlir.prj *elf core* *log pl_sample_counts foo.vcd *exe aiesimulator_output sim .AIE_SIM_CMD_LINE_OPTIONS


