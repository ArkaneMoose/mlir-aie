include ../makefile-common

.PHONY: all clean

all: tutorial-9.exe
	@mkdir -p elf
	@mv *.elf* ./elf
	@cp ./elf/*.elf ./elf/*.elf.map .

external_kernel/kernel.o: external_kernel/kernel.cc
	$(MAKE) -C external_kernel mlir

kernel.o: external_kernel/kernel.o
	cp external_kernel/kernel.o ./kernel.o

kernel_matmul.o: matmul_kernel/kernel.o
	cp matmul_kernel/kernel.o ./kernel_matmul.o

# Command line mlir-aie compile script "aiecc.py"
# Sysroot and host target used to cross compile  host executable
# Local runtime_lib needed for testbench functions
tutorial-9.exe: test.cpp aie.mlir kernel.o
	aiecc.py -j4 $(AIECC_FLAGS) $(word 2,$^) $(AIECC_HOST_FLAGS) ./$< -o $@

clean:
	$(MAKE) -C external_kernel clean
	rm -rf aie.mlir.prj aiesimulator_output *elf core* *log *vcd *exe pl_sample_counts *.o .AIE_SIM_CMD_LINE_OPTIONS

#------------------------------------------------------------------------------
# Additional make targets for tutorial exercises
#------------------------------------------------------------------------------
tutorial-9_perf.exe: ./answers/test_perf.cpp ./aie.mlir kernel.o
	aiecc.py -j4 $(AIECC_FLAGS) $(word 2,$^) $(AIECC_HOST_FLAGS) ./$< -o $@

tutorial-9_matmul_perf.exe: ./answers/test_perf.cpp ./answers/aie_matmul.mlir kernel_matmul.o
	aiecc.py -j4 $(AIECC_FLAGS) $(word 2,$^) $(AIECC_HOST_FLAGS) ./$< -o $@
