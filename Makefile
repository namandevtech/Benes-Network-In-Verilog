TOP := benes_net
RTLDIR := rtl
RTLFILE := $(TOP).v
RTL := $(RTLDIR)/$(RTLFILE)
TBDIR := rtl/tb
TB  := $(TBDIR)/tb_$(RTLFILE)

COMPILER   := iverilog
SIMULATOR  := vvp
VIEWER     := surfer
NETLIST_GEN := yosys

SIMDIR := sim
SIMOUT := $(SIMDIR)/sim_$(TOP).out
VCD := $(SIMDIR)/$(TOP).vcd

.PHONY: all compile simulate view netlist show clean help

all: simulate netlist show

help:
	@echo "Targets:"
	@echo "  make compile   - compile testbench -> $(SIMOUT)"
	@echo "  make simulate  - compile + run (creates wave.vcd if TB dumps)"
	@echo "  make view      - open wave.vcd with $(VIEWER)"
	@echo "  make netlist   - generate structural netlist_struct.v"
	@echo "  make show      - generate schematic netlist.svg and open it"
	@echo "  make clean     - remove generated files"

# Ensure sim/ exists
$(SIMDIR):
	mkdir -p $(SIMDIR)

compile: $(SIMOUT)

$(SIMOUT): $(RTL) $(TB) | $(SIMDIR)
	$(COMPILER) -v -o $@ -f files.f

simulate: compile
	$(SIMULATOR) $(SIMOUT) +VCD=$(VCD)

view:
	@test -f $(VCD) && $(VIEWER) $(VCD) || echo "$(VCD) not found (ensure TB dumps to it)"

netlist: netlist_struct.v

netlist_struct.v: $(RTL)
	$(NETLIST_GEN) -p "read_verilog $(RTL); hierarchy -top $(TOP); proc; opt; flatten; clean; write_verilog -noattr -noexpr $@"

show: netlist.svg

netlist.svg: $(RTL)
	$(NETLIST_GEN) -p "read_verilog $(RTL); hierarchy -top $(TOP); proc; opt; flatten; clean; show -format svg -prefix netlist"
	@test -f $@ && open $@ || true

clean:
	rm -rf $(SIMDIR) netlist_struct.v netlist.svg netlist.dot
