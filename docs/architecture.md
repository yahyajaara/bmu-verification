# BMU Verification Architecture

## DUT Interface

The BMU uses the following external signals:

### Inputs

- `clk` - DUT clock
- `rst_l` - active-low reset
- `scan_mode` - scan control
- `valid_in` - indicates a valid BMU request
- `ap` - operation/control structure (`rtl_alu_pkt_t`)
- `csr_ren_in` - CSR read enable
- `csr_rddata_in[31:0]` - CSR read data
- `a_in[31:0]` - first operand, declared signed in the DUT
- `b_in[31:0]` - second operand

### Outputs

- `result_ff[31:0]` - registered BMU result
- `error` - error indication

The UVM driver will drive the BMU request inputs.

The UVM monitor will capture the request information together with
`result_ff` and `error`.

## AP Control

The DUT receives the operation controls through `ap`, which is defined
as `rtl_alu_pkt_t` in `rtl_def.sv`.

Only the AP fields required by the verification scope will be used.

The main controls are:

- `lor` and `zbb` for OR / ORN
- `lxor` and `zbb` for XOR / XNOR
- `srl` for SRL
- `sra` for SRA
- `ror` for ROR
- `binv` for BINV
- `sh2add` and `zba` for SH2ADD
- `sub` for SUB
- `slt`, `sub`, and `unsign` for SLT / SLTU
- `ctz` for CTZ
- `cpop` for CPOP
- `siext_b` for SEXT.B
- `max` and `sub` for MAX
- `pack` for PACK
- `grev` for GREV
- `csr_write` and `csr_imm` for CSR Write

CSR Read uses `csr_ren_in` and does not require an AP operation field.

Before setting an operation, the AP structure should be cleared so that
unrelated control fields are not accidentally enabled.

## DUT Timing

`result_ff` is a registered output.

- The driver applies inputs around the negative clock edge.
- Inputs stay stable until the next positive edge.
- If `valid_in = 1`, the DUT updates `result_ff` at the positive edge.
- The monitor samples the request, `result_ff`, and `error` after the update.
- If `valid_in = 0`, `result_ff` keeps its previous value.

`error` is combinational, so it should be sampled while the request is still stable.

`rst_l` is active low. Reset behavior will be checked later using simulation waveforms.

## UVM Architecture

The testbench is organized around a standard UVM flow.

```text
bmu_base_test
    |
bmu_environment
    |
    +-- bmu_agent
    |    |
    |    +-- bmu_sequencer
    |    +-- bmu_driver
    |    +-- bmu_monitor
    |
    +-- bmu_scoreboard
    |    |
    |    +-- bmu_reference_model
    |
    +-- bmu_subscriber