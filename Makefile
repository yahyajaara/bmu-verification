

# ============================================================
# BMU Verification Makefile
# ============================================================



# Simulator
XRUN := xrun

# ============================================================

# Project directories
RTL_DIR ?= ../BMU_RTL
TB_DIR := tb

# ============================================================

# RTL files
RTL_FILES := \
	$(RTL_DIR)/rtl_defines.sv \
	$(RTL_DIR)/rtl_pdef.sv \
	$(RTL_DIR)/rtl_def.sv \
	$(RTL_DIR)/rtl_lib.sv \
	$(RTL_DIR)/Bit_Manipulation_Unit.sv

# ============================================================

# Testbench files
TB_FILES := \
	tb/interface/bmu_interface.sv \
	tb/bmu_tb_pkg.sv \
	top/bmu_tb_top.sv

# ============================================================

# Xcelium options
XRUN_OPTS := \
	-64bit \
	-sv \
	-uvm \
	-access +rwc \
	-timescale 1ns/1ps \
	-incdir $(RTL_DIR) \
	-incdir $(TB_DIR) \
	-top bmu_tb_top

# ============================================================

# Default values
TEST ?= bmu_base_test

RAND_ITERS ?= 10

SEED ?= 1

# ============================================================

# Generic simulation command
run:
	@echo ""
	@echo "============================================================"
	@echo "                 BMU VERIFICATION RUN"
	@echo "============================================================"
	@echo " TEST NAME      : $(TEST)"
	@echo " SEED           : $(SEED)"
	@echo " RANDOM ITERS   : $(RAND_ITERS)"
	@echo "============================================================"
	@echo ""

	$(XRUN) $(XRUN_OPTS) \
		-svseed $(SEED) \
		$(RTL_FILES) \
		$(TB_FILES) \
		+UVM_TESTNAME=$(TEST) \
		+BMU_RAND_ITERS=$(RAND_ITERS)

# ============================================================



# ============================================================
# Test shortcuts
# ============================================================

# Base Test(make base)
base: 
	$(MAKE) run TEST=bmu_base_test


# OR Test (make or)
or: 
	$(MAKE) run TEST=bmu_or_test


# ORN Test (make orn)
orn:
	$(MAKE) run TEST=bmu_orn_test


# XOR Test (make xor)
xor:
	$(MAKE) run TEST=bmu_xor_test


# XNOR Test (make xnor)
xnor:
	$(MAKE) run TEST=bmu_xnor_test


# SRL Test (make srl)
srl:
	$(MAKE) run TEST=bmu_srl_test


# SRA Test (make sra)
sra:
	$(MAKE) run TEST=bmu_sra_test


# ROR Test (make ror)
ror:
	$(MAKE) run TEST=bmu_ror_test


# BINV Test (make binv)
binv:
	$(MAKE) run TEST=bmu_binv_test


# SH2ADD Test (make sh2add)
sh2add:
	$(MAKE) run TEST=bmu_sh2add_test


# SUB Test (make sub)
sub:
	$(MAKE) run TEST=bmu_sub_test


# SLT Test (make slt)
slt:
	$(MAKE) run TEST=bmu_slt_test


# SLTU Test (make sltu)
sltu:
	$(MAKE) run TEST=bmu_sltu_test


# CTZ Test (make ctz)
ctz:
	$(MAKE) run TEST=bmu_ctz_test


# CPOP Test (make cpop)
cpop:
	$(MAKE) run TEST=bmu_cpop_test


# SEXT_B Test (make sext_b)
sext_b:
	$(MAKE) run TEST=bmu_sext_b_test


# MAX Test (make max)
max:
	$(MAKE) run TEST=bmu_max_test


# PACK Test (make pack)
pack:
	$(MAKE) run TEST=bmu_pack_test


# GREV Test (make grev)
grev:
	$(MAKE) run TEST=bmu_grev_test


# CSR_READ Test (make csr_read)
csr_read:
	$(MAKE) run TEST=bmu_csr_read_test


# CSR_WRITE Test (make csr_write)
csr_write:
	$(MAKE) run TEST=bmu_csr_write_test



# ============================================================


clean:
	rm -rf xcelium.d
	rm -rf INCA_libs
	rm -rf waves.shm
	rm -rf cov_work
	rm -f xrun.log
	rm -f xrun.history
	rm -f xrun.key


.PHONY: run base or orn xor xnor srl sra ror binv sh2add sub slt sltu ctz cpop sext_b max pack grev csr_read csr_write clean