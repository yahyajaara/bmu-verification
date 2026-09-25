
TESTLIST="sim/testlists/individual.list"
SINGLE_RUNNER="./sim/scripts/run_test.sh"
TMP_LOG="/tmp/bmu_regression_test.log"



# ============================================================


# Map test name -> operation name
get_operation() {
    case "$1" in
        bmu_or_test)          echo "OR" ;;
        bmu_orn_test)         echo "ORN" ;;
        bmu_xor_test)         echo "XOR" ;;
        bmu_xnor_test)        echo "XNOR" ;;
        bmu_srl_test)         echo "SRL" ;;
        bmu_sra_test)         echo "SRA" ;;
        bmu_ror_test)         echo "ROR" ;;
        bmu_binv_test)        echo "BINV" ;;
        bmu_sh2add_test)      echo "SH2ADD" ;;
        bmu_sub_test)         echo "SUB" ;;
        bmu_slt_test)         echo "SLT" ;;
        bmu_sltu_test)        echo "SLTU" ;;
        bmu_ctz_test)         echo "CTZ" ;;
        bmu_cpop_test)        echo "CPOP" ;;
        bmu_sext_b_test)      echo "SEXT.B" ;;
        bmu_max_test)         echo "MAX" ;;
        bmu_pack_test)        echo "PACK" ;;
        bmu_grev_test)        echo "GREV" ;;
        bmu_csr_read_test)    echo "CSR_READ" ;;
        bmu_csr_write_test)   echo "CSR_WRITE" ;;
        *)                    echo "UNKNOWN" ;;
    esac
}


# ============================================================


# Check testlist
if [[ ! -f "$TESTLIST" ]]; then
    echo "ERROR: Testlist not found: $TESTLIST"
    exit 1
fi

if [[ ! -x "$SINGLE_RUNNER" ]]; then
    echo "ERROR: Test runner not executable: $SINGLE_RUNNER"
    exit 1
fi


# ============================================================


# Regression counters
TOTAL=0
PASSED=0
FAILED=0

declare -a RESULT_TEST
declare -a RESULT_OPERATION
declare -a RESULT_COVERAGE
declare -a RESULT_TRANSACTIONS
declare -a RESULT_PASS
declare -a RESULT_FAIL
declare -a RESULT_STATUS


# ============================================================


# Regression start
echo
echo "============================================================"
echo "                  BMU REGRESSION START"
echo "============================================================"
echo
echo "Testlist: $TESTLIST"
echo


# ============================================================


# Read and run every test
while IFS= read -r TEST_NAME || [[ -n "$TEST_NAME" ]]; do

    # Remove possible CR character
    TEST_NAME="${TEST_NAME//$'\r'/}"

    # Skip empty lines
    [[ -z "$TEST_NAME" ]] && continue

    # Skip comments
    [[ "$TEST_NAME" =~ ^[[:space:]]*# ]] && continue

    OPERATION=$(get_operation "$TEST_NAME")

    TOTAL=$((TOTAL + 1))

    echo
    echo "============================================================"
    echo " Running Test $TOTAL"
    echo " Test      : $TEST_NAME"
    echo " Operation : $OPERATION"
    echo "============================================================"
    echo


# ============================================================


    # Run test
    "$SINGLE_RUNNER" "$TEST_NAME" 2>&1 | tee "$TMP_LOG"

    # Get exit code of run_test.sh, not tee
    TEST_EXIT=${PIPESTATUS[0]}

    echo
    echo "------------------------------------------------------------"
    echo " Finished: $TEST_NAME"
    echo "------------------------------------------------------------"
    echo


# ============================================================


    # Default values
    TEST_RESULT="FAIL"
    TEST_COVERAGE="N/A"
    TEST_TRANSACTIONS="0"
    TEST_PASS="0"
    TEST_FAIL="0"


# ============================================================


    # Extract information from test output
    if [[ -f "$TMP_LOG" ]]; then

        TEST_RESULT=$(
            grep -E '^[[:space:]]*Result[[:space:]]*:' "$TMP_LOG" |
            tail -1 |
            sed -E 's/.*Result[[:space:]]*:[[:space:]]*//'
        )

        TEST_RESULT=${TEST_RESULT:-FAIL}


# ============================================================


        # Transactions
        TEST_TRANSACTIONS=$(
            grep -E '^[[:space:]]*Transactions[[:space:]]*:' "$TMP_LOG" |
            tail -1 |
            sed -E 's/.*Transactions[[:space:]]*:[[:space:]]*//'
        )

        TEST_TRANSACTIONS=${TEST_TRANSACTIONS:-0}


# ============================================================


        # Scoreboard PASS
        TEST_PASS=$(
            grep -Ec '^UVM_INFO .* \[SCOREBOARD_PASS\]' "$TMP_LOG"
        )


# ============================================================


        # Scoreboard FAIL
        TEST_FAIL=$(
            grep -Ec '^UVM_ERROR .* \[SCOREBOARD_FAIL\]' "$TMP_LOG"
        )


# ============================================================


        # Coverage
        TEST_COVERAGE="N/A"

        if [[ "$OPERATION" != "UNKNOWN" ]]; then

            COVERAGE_LABEL=$(echo "$OPERATION" | tr '_' ' ')

            TEST_COVERAGE=$(
                grep '\[BMU_COVERAGE\]' "$TMP_LOG" |
                grep -F " $COVERAGE_LABEL " |
                sed -E 's/.*Coverage = ([0-9.]+)%.*/\1/' |
                tail -1
            )
        fi

        TEST_COVERAGE=${TEST_COVERAGE:-N/A}
    fi


# ============================================================


    # Store result
    RESULT_TEST+=("$TEST_NAME")
    RESULT_OPERATION+=("$OPERATION")
    RESULT_COVERAGE+=("$TEST_COVERAGE")
    RESULT_TRANSACTIONS+=("$TEST_TRANSACTIONS")
    RESULT_PASS+=("$TEST_PASS")
    RESULT_FAIL+=("$TEST_FAIL")
    RESULT_STATUS+=("$TEST_RESULT")


# ============================================================


    # Update counters
    if [[ "$TEST_RESULT" == "PASS" ]]; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi

done < "$TESTLIST"


# ============================================================


# Final Regression Summary
echo
echo
echo "============================================================"
echo "                 BMU REGRESSION SUMMARY"
echo "============================================================"
echo

printf "%-24s %-12s %-10s %-13s %-7s %-7s %-8s\n" \
       "Test" "Operation" "Coverage" "Transactions" "PASS" "FAIL" "Result"

echo "--------------------------------------------------------------------------------"

for ((i=0; i<TOTAL; i++)); do

    printf "%-24s %-12s %-10s %-13s %-7s %-7s %-8s\n" \
        "${RESULT_TEST[$i]}" \
        "${RESULT_OPERATION[$i]}" \
        "${RESULT_COVERAGE[$i]}" \
        "${RESULT_TRANSACTIONS[$i]}" \
        "${RESULT_PASS[$i]}" \
        "${RESULT_FAIL[$i]}" \
        "${RESULT_STATUS[$i]}"

done

echo
echo "============================================================"
echo "Total Tests  : $TOTAL"
echo "Passed       : $PASSED"
echo "Failed       : $FAILED"
echo "============================================================"



# ============================================================


# Final result
if [[ "$FAILED" -eq 0 ]]; then
    echo
    echo "ALL TESTS PASSED."
    echo
    exit 0
else
    echo
    echo "REGRESSION COMPLETED WITH FAILURES."
    echo
    exit 1
fi