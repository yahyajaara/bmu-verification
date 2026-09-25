# ============================================================
# BMU Verification Makefile
# ============================================================


# Tools
XRUN := xrun

# ============================================================

# Directories
RTL_DIR ?= ../BMU_RTL
TB_DIR  := tb

SINGLE_RUNNER     := ./sim/scripts/run_test.sh
REGRESSION_RUNNER := ./sim/scripts/run_regression.sh


# Default Values
TEST ?= bmu_base_test
RAND_ITERS ?= 10
SEED ?= 1

# ============================================================


# Generic Direct Xcelium Run
run:
	@echo ""
	@echo "============================================================"
	@echo " BMU VERIFICATION RUN"
	@echo "============================================================"
	@echo " TEST NAME     : $(TEST)"
	@echo " SEED          : $(SEED)"
	@echo " RANDOM ITERS  : $(RAND_ITERS)"
	@echo "============================================================"
	@echo ""

	$(XRUN) \
		-64bit \
		-sv \
		-uvm \
		-access +rwc \
		-timescale 1ns/1ps \
		-coverage all \
		-covoverwrite \
		-incdir $(RTL_DIR) \
		-incdir $(TB_DIR) \
		-incdir $(RTL_DIR)/library \
		-f sim/filelists/rtl.f \
		-f sim/filelists/tb.f \
		-top bmu_tb_top \
		-svseed $(SEED) \
		+UVM_TESTNAME=$(TEST) \
		+BMU_RAND_ITERS=$(RAND_ITERS)


# ============================================================


# Single Operation Tests
base:
	@$(SINGLE_RUNNER) bmu_base_test


or:
	@$(SINGLE_RUNNER) bmu_or_test


orn:
	@$(SINGLE_RUNNER) bmu_orn_test


xor:
	@$(SINGLE_RUNNER) bmu_xor_test


xnor:
	@$(SINGLE_RUNNER) bmu_xnor_test


srl:
	@$(SINGLE_RUNNER) bmu_srl_test


sra:
	@$(SINGLE_RUNNER) bmu_sra_test


ror:
	@$(SINGLE_RUNNER) bmu_ror_test


binv:
	@$(SINGLE_RUNNER) bmu_binv_test


sh2add:
	@$(SINGLE_RUNNER) bmu_sh2add_test


sub:
	@$(SINGLE_RUNNER) bmu_sub_test


slt:
	@$(SINGLE_RUNNER) bmu_slt_test


sltu:
	@$(SINGLE_RUNNER) bmu_sltu_test


ctz:
	@$(SINGLE_RUNNER) bmu_ctz_test


cpop:
	@$(SINGLE_RUNNER) bmu_cpop_test


sext_b:
	@$(SINGLE_RUNNER) bmu_sext_b_test


max:
	@$(SINGLE_RUNNER) bmu_max_test


pack:
	@$(SINGLE_RUNNER) bmu_pack_test


grev:
	@$(SINGLE_RUNNER) bmu_grev_test


csr_read:
	@$(SINGLE_RUNNER) bmu_csr_read_test


csr_write:
	@$(SINGLE_RUNNER) bmu_csr_write_test


# ============================================================


# Group Tests
error:
	@$(MAKE) run TEST=bmu_error_handling_test


logical:
	@$(MAKE) run TEST=bmu_logical_test


shift_mask:
	@$(MAKE) run TEST=bmu_shift_mask_test


arithmetic:
	@$(MAKE) run TEST=bmu_arithmetic_test


bit_manipulation:
	@$(MAKE) run TEST=bmu_bit_manipulation_test


csr:
	@$(MAKE) run TEST=bmu_csr_test


# ============================================================


# Extension Tests
zbb:
	@$(MAKE) run TEST=bmu_zbb_test


zbs:
	@$(MAKE) run TEST=bmu_zbs_test


zba:
	@$(MAKE) run TEST=bmu_zba_test


zbp:
	@$(MAKE) run TEST=bmu_zbp_test


# ============================================================


# Sanity Tests
reset:
	@$(MAKE) run TEST=bmu_reset_test


valid_in:
	@$(MAKE) run TEST=bmu_valid_in_test


# ============================================================


# Regression
regression:
	@$(REGRESSION_RUNNER)


# ============================================================


# Clean
clean:
	rm -rf xcelium.d
	rm -rf INCA_libs
	rm -rf waves.shm
	rm -rf cov_work
	rm -f xrun.log
	rm -f xrun.history
	rm -f xrun.key


# ============================================================


# Help
help:
	@echo ""
	@echo "============================================================"
	@echo " BMU Verification Makefile"
	@echo "============================================================"
	@echo ""
	@echo "Individual operation tests:"
	@echo "  make or"
	@echo "  make orn"
	@echo "  make xor"
	@echo "  make xnor"
	@echo "  make srl"
	@echo "  make sra"
	@echo "  make ror"
	@echo "  make binv"
	@echo "  make sh2add"
	@echo "  make sub"
	@echo "  make slt"
	@echo "  make sltu"
	@echo "  make ctz"
	@echo "  make cpop"
	@echo "  make sext_b"
	@echo "  make max"
	@echo "  make pack"
	@echo "  make grev"
	@echo "  make csr_read"
	@echo "  make csr_write"
	@echo ""
	@echo "Other tests:"
	@echo "  make error"
	@echo "  make logical"
	@echo "  make shift_mask"
	@echo "  make arithmetic"
	@echo "  make bit_manipulation"
	@echo "  make csr"
	@echo ""
	@echo "Extension tests:"
	@echo "  make zbb"
	@echo "  make zbs"
	@echo "  make zba"
	@echo "  make zbp"
	@echo ""
	@echo "Sanity tests:"
	@echo "  make reset"
	@echo "  make valid_in"
	@echo ""
	@echo "Regression:"
	@echo "  make regression"
	@echo ""
	@echo "Other:"
	@echo "  make clean"
	@echo "  make help"
	@echo ""
	@echo "============================================================"


# ============================================================


# Phony Targets
.PHONY: run base or orn xor xnor srl sra ror binv sh2add sub slt sltu ctz cpop sext_b max pack grev csr_read csr_write error logical shift_mask arithmetic bit_manipulation csr zbb zbs zba zbp reset valid_in regression clean help
