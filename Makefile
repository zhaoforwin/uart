
SEED ?= 1
VCS = vcs
SIMV = ./simv

FILELIST = filelist.f

TEST = uart_test

VCS_OPTS = \
	-full64 \
	-sverilog \
	-ntb_opts uvm-1.2 \
	-timescale=1ns/1ps \
	-debug_access+all \
	-kdb \
	-l compile.log



SIM_OPTS = \
	+UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=UVM_LOW \
	+ntb_random_seed=$(SEED) \
	-l sim.log

all: sim

comp:
	$(VCS) $(VCS_OPTS) -f $(FILELIST) -top uart_tb

run:
	./simv $(SIM_OPTS)

gui:
	$(SIMV) $(SIM_OPTS) -gui

clean:
	rm -rf \
	simv \
	simv.daidir \
	csrc \
	*.log \
	*.key \
	*.vpd \
	*.vcd \
	*.fsdb \
	DVEfiles \
	verdilog \
	novas.conf \
	novas.rc
