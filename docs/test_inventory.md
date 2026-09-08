## Sequence and Test Plan

Each required BMU operation will have its own sequence and individual test.

### Operation Sequences

Logical:
bmu_or_sequence
bmu_orn_sequence
bmu_xor_sequence
bmu_xnor_sequence

Shift / Mask:
bmu_srl_sequence
bmu_sra_sequence
bmu_ror_sequence
bmu_binv_sequence
bmu_sh2add_sequence

Arithmetic:
bmu_sub_sequence

Bit Manipulation:
bmu_slt_sequence
bmu_sltu_sequence
bmu_ctz_sequence
bmu_cpop_sequence
bmu_sext_b_sequence
bmu_max_sequence
bmu_pack_sequence
bmu_grev_sequence

CSR:
bmu_csr_read_sequence
bmu_csr_write_sequence

A common bmu_base_sequence will also be used.

Grouped operation sequences will not be created.


### Individual Tests

bmu_or_test
bmu_orn_test
bmu_xor_test
bmu_xnor_test
bmu_srl_test
bmu_sra_test
bmu_ror_test
bmu_binv_test
bmu_sh2add_test
bmu_sub_test
bmu_slt_test
bmu_sltu_test
bmu_ctz_test
bmu_cpop_test
bmu_sext_b_test
bmu_max_test
bmu_pack_test
bmu_grev_test
bmu_csr_read_test
bmu_csr_write_test

Additional tests:
bmu_error_handling_test
bmu_random_test


### Functional Group Tests

bmu_logical_test
bmu_shift_mask_test
bmu_arithmetic_test
bmu_bit_manipulation_test
bmu_csr_test


### Extension Tests

bmu_zbb_test
bmu_zbs_test
bmu_zba_test
bmu_zbp_test