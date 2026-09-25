

set -u -o pipefail

# ============================================================
# BMU Verification - Single Test Runner
# ============================================================

XRUN=${XRUN:-xrun}
TEST_NAME=${1:-}

RTL_FILELIST="sim/filelists/rtl.f"
TB_FILELIST="sim/filelists/tb.f"

LOG_DIR="reports/summaries"
LOG_FILE="${LOG_DIR}/${TEST_NAME}.log"


# ============================================================


# Check test name
if [[ -z "$TEST_NAME" ]]; then
    echo "ERROR: No test name was provided."
    echo "Usage: ./sim/scripts/run_test.sh <test_name>"
    exit 2
fi


# ============================================================


# Map test name -> BMU operation
case "$TEST_NAME" in
    bmu_or_test)         OPERATION="OR" ;;
    bmu_orn_test)        OPERATION="ORN" ;;
    bmu_xor_test)        OPERATION="XOR" ;;
    bmu_xnor_test)       OPERATION="XNOR" ;;
    bmu_srl_test)        OPERATION="SRL" ;;
    bmu_sra_test)        OPERATION="SRA" ;;
    bmu_ror_test)        OPERATION="ROR" ;;
    bmu_binv_test)       OPERATION="BINV" ;;
    bmu_sh2add_test)     OPERATION="SH2ADD" ;;
    bmu_sub_test)        OPERATION="SUB" ;;
    bmu_slt_test)        OPERATION="SLT" ;;
    bmu_sltu_test)       OPERATION="SLTU" ;;
    bmu_ctz_test)        OPERATION="CTZ" ;;
    bmu_cpop_test)       OPERATION="CPOP" ;;
    bmu_sext_b_test)     OPERATION="SEXT.B" ;;
    bmu_max_test)        OPERATION="MAX" ;;
    bmu_pack_test)       OPERATION="PACK" ;;
    bmu_grev_test)       OPERATION="GREV" ;;
    bmu_csr_read_test)   OPERATION="CSR_READ" ;;
    bmu_csr_write_test)  OPERATION="CSR_WRITE" ;;
    *)
        OPERATION="UNKNOWN"
        ;;
esac


# ============================================================


# Create log directory
mkdir -p "$LOG_DIR"


echo "============================================================"
echo " BMU Single Test"
echo " Test      : $TEST_NAME"
echo " Operation : $OPERATION"
echo "============================================================"


# ============================================================


# Run Xcelium
"$XRUN" \
    -64bit \
    -sv \
    -uvm \
    -access +rwc \
    -timescale 1ns/1ps \
    -coverage all \
    -covoverwrite \
    -incdir tb \
    -incdir ../BMU_RTL \
    -incdir ../BMU_RTL/library \
    -f "$RTL_FILELIST" \
    -f "$TB_FILELIST" \
    -top bmu_tb_top \
    +UVM_TESTNAME="$TEST_NAME" \
    2>&1 | tee "$LOG_FILE"

XRUN_STATUS=${PIPESTATUS[0]}


# ============================================================


# Extract UVM summary counts
UVM_ERRORS=$(
    grep -E 'UVM_ERROR[[:space:]]*:' "$LOG_FILE" |
    tail -1 |
    sed -E 's/.*UVM_ERROR[[:space:]]*:[[:space:]]*([0-9]+).*/\1/'
)

UVM_FATALS=$(
    grep -E 'UVM_FATAL[[:space:]]*:' "$LOG_FILE" |
    tail -1 |
    sed -E 's/.*UVM_FATAL[[:space:]]*:[[:space:]]*([0-9]+).*/\1/'
)

UVM_ERRORS=${UVM_ERRORS:-0}
UVM_FATALS=${UVM_FATALS:-0}


# ============================================================


# Extract operation coverage
COVERAGE="N/A"

if [[ "$OPERATION" != "UNKNOWN" ]]; then

    COVERAGE_LABEL=$(echo "$OPERATION" | tr '_' ' ')

    COVERAGE=$(
        grep '\[BMU_COVERAGE\]' "$LOG_FILE" |
        grep -F " $COVERAGE_LABEL " |
        sed -E 's/.*Coverage = ([0-9.]+)%.*/\1/' |
        head -1
    )

fi

COVERAGE=${COVERAGE:-N/A}


# ============================================================


# Extract scoreboard PASS / FAIL counts
SCOREBOARD_PASS=$(
    grep -Ec '^UVM_INFO .* \[SCOREBOARD_PASS\]' "$LOG_FILE" || true
)

SCOREBOARD_FAIL=$(
    grep -Ec '^UVM_ERROR .* \[SCOREBOARD_FAIL\]' "$LOG_FILE" || true
)

TOTAL_TRANSACTIONS=$((SCOREBOARD_PASS + SCOREBOARD_FAIL))


# ============================================================


# Determine final result
RESULT="PASS"
REASON="-"


if [[ "$XRUN_STATUS" -ne 0 ]]; then

    RESULT="FAIL"
    REASON="xrun_exit_${XRUN_STATUS}"

elif [[ "$UVM_ERRORS" -ne 0 ]]; then

    RESULT="FAIL"
    REASON="UVM_ERROR"

elif [[ "$UVM_FATALS" -ne 0 ]]; then

    RESULT="FAIL"
    REASON="UVM_FATAL"

fi


# ============================================================


# Final summary
echo ""
echo "============================================================"
echo " BMU TEST SUMMARY"
echo "============================================================"
printf " Test         : %s\n" "$TEST_NAME"
printf " Operation    : %s\n" "$OPERATION"
printf " Coverage     : %s%%\n" "$COVERAGE"
printf " Transactions : %s\n" "$TOTAL_TRANSACTIONS"
printf " PASS         : %s\n" "$SCOREBOARD_PASS"
printf " FAIL         : %s\n" "$SCOREBOARD_FAIL"
printf " UVM_ERROR    : %s\n" "$UVM_ERRORS"
printf " UVM_FATAL    : %s\n" "$UVM_FATALS"
printf " Result       : %s\n" "$RESULT"
printf " Reason       : %s\n" "$REASON"
printf " Log          : %s\n" "$LOG_FILE"
echo "============================================================"


# ============================================================


# Exit status

if [[ "$RESULT" == "PASS" ]]; then
    exit 0
else
    exit 1
fi