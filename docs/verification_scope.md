# BMU Verification Scope

## Scope

This project verifies the BMU operations required by the verification plan.

The BMU RTL and specification include more operations, but only the operations listed below are part of this project.

The current scope contains 20 operations.

## Operations in Scope

### Logical
- OR
- ORN
- XOR
- XNOR

### Shift and Mask
- SRL
- SRA
- ROR
- BINV
- SH2ADD

### Arithmetic
- SUB

### Bit Manipulation
- SLT
- SLTU
- CTZ
- CPOP
- SEXT.B
- MAX
- PACK
- GREV

### CSR
- CSR Read
- CSR Write


## Operations Out of Scope

The following operations are available in the RTL or specification but are not required by the current verification plan:

- AND
- CLZ
- MIN
- SEXT.H
- ANDN
- BSET
- BCLR
- BEXT
- ROL
- PACKU
- PACKH
- GORC
- SH1ADD
- SH3ADD

Other branch, ADD, SLL, and control paths that are not selected by the verification plan are also out of scope.


## Reference Order

The project uses the following order when deciding what should be verified and what the expected behavior should be:

1. The BMU Verification Plan defines the verification scope.
2. The BMU Specification v1.1 defines the expected behavior.
3. The RTL and RTL packages define the actual implementation, signal names, and data types.

The RTL will not be used as the reference for expected results.


## BitManip Configuration

The current RTL configuration is:

- `BITMANIP_ZBA = 1`
  - ZBA is enabled.
  - SH2ADD is included in the verification scope.

- `BITMANIP_ZBB = 1`
  - ZBB is enabled.
  - The required ZBB operations are ORN, XNOR, CTZ, CPOP, SEXT.B, and MAX.

- `BITMANIP_ZBS = 1`
  - ZBS is enabled.
  - BINV is included in this group.

- `BITMANIP_ZBP = 0`
  - ZBP is disabled in the current configuration.
  - ROR, PACK, and GREV are still required by the verification plan.
  - According to the specification, these operations belong to ZBP.
  - The RTL appears to allow these operations through shared extension gating even when ZBP is disabled.
  - This will be treated as a potential RTL discrepancy and checked later by simulation.

- `BITMANIP_ZBC = 1`
  - ZBC is enabled in the RTL configuration.
  - It is not part of the current verification scope.

- `BITMANIP_ZBE = 0`
- `BITMANIP_ZBF = 0`
- `BITMANIP_ZBR = 0`
  - These extensions are disabled and are not part of the current verification scope.

The verification scope is determined by the verification plan, not only by the RTL parameter values.