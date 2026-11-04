# Basys 3 build, see TangNano9K-MsPacman/basys3/README.md.

PRJ_DIR   := TangNano9K-MsPacman/basys3
PRJ       := mspacman_basys3
VIVADO    ?= /tools/Xilinx/Vivado/2020.2/bin/vivado
WORK      := /tmp/$(PRJ)_bitstream
PROMS     := TangNano9K-MsPacman/proms/.done
GEN_PROMS := $(addprefix TangNano9K-MsPacman/proms/,GFX1 ROM_PGM_0 ROM_PGM_1 PROM1_DST PROM4_DST PROM7_DST)
BIT       := $(PRJ_DIR)/$(PRJ).runs/impl_1/$(PRJ).bit
# bitstream inputs: project, build script, project sources, core sources, PROM VHDL
DEPS      := $(PRJ_DIR)/$(PRJ).xpr $(PRJ_DIR)/build.tcl $(PROMS) \
             $(shell find $(PRJ_DIR)/$(PRJ).srcs TangNano9K-MsPacman/src -type f) \
             $(wildcard TangNano9K-MsPacman/proms/*.vhd)

define BUILD
	mkdir -p $(WORK)
	cd $(WORK) && $(VIVADO) -mode batch -nolog -nojournal \
	    -source $(CURDIR)/$(PRJ_DIR)/build.tcl -tclargs $(CURDIR)/$(PRJ_DIR)/$(PRJ).xpr
	rm -rf $(WORK)
	@echo "Bitstream: $(BIT)"
endef

.PHONY: help roms bitstream load clean

help:
	@echo "roms       compile make_vhdl_prom, unzip mspacmab.zip and mspacman.zip from ROMDIR (default ~/roms), generate PROM VHDL"
	@echo "bitstream  Vivado batch build of $(PRJ_DIR)/$(PRJ).xpr (runs roms if PROM VHDL is missing)"
	@echo "load       program the Basys 3 SRAM (openFPGALoader); builds first if the bitstream is missing or older than its inputs"
	@echo "clean      remove roms, generated PROM VHDL and Vivado outputs (all regenerated)"

roms $(PROMS):
	TangNano9K-MsPacman/tools/make_mspacman_proms.sh

bitstream: $(PROMS)
	$(BUILD)

$(BIT): $(DEPS)
	$(BUILD)

load: $(BIT)
	openFPGALoader -b basys3 $(BIT)

clean:
	rm -f $(addsuffix .vhd,$(GEN_PROMS)) $(PROMS)
	rm -rf TangNano9K-MsPacman/tools/unzip TangNano9K-MsPacman/tools/tools_prom_src/bin
	rm -rf $(addprefix $(PRJ_DIR)/$(PRJ).,cache gen hw ip_user_files runs sim)
