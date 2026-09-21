class bmu_reset_test extends bmu_base_test;

    `uvm_component_utils(bmu_reset_test)

    virtual bmu_interface vif;


    // ============================================================
    // Constructor
    // ============================================================
    function new(
        string name = "bmu_reset_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    // ============================================================
    // Build Phase
    // ============================================================
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db #(virtual bmu_interface)::get(
                this,
                "",
                "vif_raw",
                vif
            ))
        begin
            `uvm_fatal(
                get_type_name(),
                "Virtual interface was not found"
            )
        end

    endfunction


    // ============================================================
    // Run Phase
    // ============================================================
    task run_phase(uvm_phase phase);

        phase.raise_objection(this);


        // ========================================================
        // TEST START
        // ========================================================

        `uvm_info(
            "TEST_START",
            {
                "\n============================================================",
                "\n                     BMU RESET TEST",
                "\n============================================================",
                "\nPurpose:",
                "\n  1. Verify reset clears result_ff",
                "\n  2. Verify reset is SYNCHRONOUS",
                "\n  3. Verify result_ff holds after reset",
                "\n  4. Verify DUT works after reset",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        // ========================================================
        // STEP 1
        // Generate non-zero result before reset
        // ========================================================

        `uvm_info(
            "RESET_TEST",
            {
                "\n------------------------------------------------------------",
                "\nSTEP 1: PRE-RESET OPERATION",
                "\n------------------------------------------------------------",
                "\nOperation : OR",
                "\nA         : 0xAAAAAAAA",
                "\nB         : 0x55555555",
                "\nExpected  : 0xFFFFFFFF",
                "\n------------------------------------------------------------"
            },
            UVM_NONE
        )


        @(negedge vif.clk);

        vif.rst_l         = 1'b1;
        vif.valid_in      = 1'b1;
        vif.a_in          = 32'hAAAA_AAAA;
        vif.b_in          = 32'h5555_5555;
        vif.ap            = '0;
        vif.ap.lor        = 1'b1;
        vif.csr_ren_in    = 1'b0;
        vif.csr_rddata_in = '0;


        @(posedge vif.clk);
        #1;


        if (vif.result_ff == 32'hFFFF_FFFF)
        begin

            `uvm_info(
                "RESET_TEST",
                $sformatf(
                    {
                        "\n[PASS] PRE-RESET OPERATION",
                        "\nExpected : 0xFFFFFFFF",
                        "\nActual   : 0x%08h"
                    },
                    vif.result_ff
                ),
                UVM_NONE
            )

        end
        else
        begin

            `uvm_error(
                "RESET_TEST",
                $sformatf(
                    {
                        "\n[FAIL] PRE-RESET OPERATION",
                        "\nExpected : 0xFFFFFFFF",
                        "\nActual   : 0x%08h"
                    },
                    vif.result_ff
                )
            )

        end


        // ========================================================
        // STEP 2
        // Assert reset between clock edges
        // ========================================================

        `uvm_info(
            "RESET_TEST",
            {
                "\n------------------------------------------------------------",
                "\nSTEP 2: ASSERT RESET BETWEEN CLOCK EDGES",
                "\n------------------------------------------------------------",
                "\nExpected synchronous behavior:",
                "\n  result_ff must NOT change immediately.",
                "\n  result_ff must stay 0xFFFFFFFF until next posedge.",
                "\n------------------------------------------------------------"
            },
            UVM_NONE
        )


        @(negedge vif.clk);

        vif.valid_in = 1'b0;
        vif.ap       = '0;
        vif.rst_l    = 1'b0;


        `uvm_info(
            "RESET_TEST",
            "\nReset asserted: rst_l = 0",
            UVM_NONE
        )


        // ========================================================
        // STEP 3
        // Check reset timing BEFORE next posedge
        // ========================================================

        #1;


        `uvm_info(
            "RESET_TEST",
            {
                "\n------------------------------------------------------------",
                "\nSTEP 3: RESET TIMING CHECK",
                "\n------------------------------------------------------------",
                "\nChecking result_ff BEFORE next posedge...",
                "\nExpected : 0xFFFFFFFF",
                "\nReason   : Reset should be synchronous",
                "\n------------------------------------------------------------"
            },
            UVM_NONE
        )


        if (vif.result_ff == 32'hFFFF_FFFF)
        begin

            `uvm_info(
                "RESET_TEST",
                $sformatf(
                    {
                        "\n[PASS] SYNCHRONOUS RESET TIMING",
                        "\nExpected : 0xFFFFFFFF",
                        "\nActual   : 0x%08h",
                        "\nResult   : result_ff did NOT change before clock edge."
                    },
                    vif.result_ff
                ),
                UVM_NONE
            )

        end
        else
        begin

            `uvm_error(
                "RESET_TEST",
                $sformatf(
                    {
                        "\n[FAIL] RESET TIMING",
                        "\nExpected : 0xFFFFFFFF",
                        "\nActual   : 0x%08h",
                        "\nReason   : result_ff changed BEFORE next posedge.",
                        "\nBUG      : Reset behaves ASYNCHRONOUSLY",
                        "\n           instead of SYNCHRONOUSLY."
                    },
                    vif.result_ff
                )
            )

        end


        // ========================================================
        // STEP 4
        // Check reset value after clock edge
        // ========================================================

        `uvm_info(
            "RESET_TEST",
            {
                "\n------------------------------------------------------------",
                "\nSTEP 4: RESET VALUE CHECK",
                "\n------------------------------------------------------------",
                "\nWaiting for clock edge while rst_l = 0...",
                "\nExpected after clock edge: 0x00000000",
                "\n------------------------------------------------------------"
            },
            UVM_NONE
        )


        repeat (2)
            @(posedge vif.clk);

        #1;


        if (vif.result_ff == 32'h0000_0000)
        begin

            `uvm_info(
                "RESET_TEST",
                $sformatf(
                    {
                        "\n[PASS] RESET VALUE",
                        "\nExpected : 0x00000000",
                        "\nActual   : 0x%08h"
                    },
                    vif.result_ff
                ),
                UVM_NONE
            )

        end
        else
        begin

            `uvm_error(
                "RESET_TEST",
                $sformatf(
                    {
                        "\n[FAIL] RESET VALUE",
                        "\nExpected : 0x00000000",
                        "\nActual   : 0x%08h"
                    },
                    vif.result_ff
                )
            )

        end


        // ========================================================
        // STEP 5
        // Deassert reset and check hold
        // ========================================================

        `uvm_info(
            "RESET_TEST",
            {
                "\n------------------------------------------------------------",
                "\nSTEP 5: DEASSERT RESET + HOLD CHECK",
                "\n------------------------------------------------------------",
                "\nvalid_in = 0",
                "\nExpected : result_ff remains 0x00000000",
                "\n------------------------------------------------------------"
            },
            UVM_NONE
        )


        @(negedge vif.clk);

        vif.rst_l = 1'b1;


        `uvm_info(
            "RESET_TEST",
            "\nReset deasserted: rst_l = 1",
            UVM_NONE
        )


        @(posedge vif.clk);
        #1;


        if (vif.result_ff == 32'h0000_0000)
        begin

            `uvm_info(
                "RESET_TEST",
                $sformatf(
                    {
                        "\n[PASS] POST-RESET HOLD",
                        "\nExpected : 0x00000000",
                        "\nActual   : 0x%08h"
                    },
                    vif.result_ff
                ),
                UVM_NONE
            )

        end
        else
        begin

            `uvm_error(
                "RESET_TEST",
                $sformatf(
                    {
                        "\n[FAIL] POST-RESET HOLD",
                        "\nExpected : 0x00000000",
                        "\nActual   : 0x%08h"
                    },
                    vif.result_ff
                )
            )

        end


        // ========================================================
        // STEP 6
        // Verify DUT still works after reset
        // ========================================================

        `uvm_info(
            "RESET_TEST",
            {
                "\n------------------------------------------------------------",
                "\nSTEP 6: POST-RESET OPERATION",
                "\n------------------------------------------------------------",
                "\nOperation : OR",
                "\nA         : 0xF0F0F0F0",
                "\nB         : 0x0F0F0F0F",
                "\nExpected  : 0xFFFFFFFF",
                "\n------------------------------------------------------------"
            },
            UVM_NONE
        )


        @(negedge vif.clk);

        vif.valid_in = 1'b1;
        vif.a_in     = 32'hF0F0_F0F0;
        vif.b_in     = 32'h0F0F_0F0F;
        vif.ap       = '0;
        vif.ap.lor   = 1'b1;


        @(posedge vif.clk);
        #1;


        if (vif.result_ff == 32'hFFFF_FFFF)
        begin

            `uvm_info(
                "RESET_TEST",
                $sformatf(
                    {
                        "\n[PASS] POST-RESET OPERATION",
                        "\nExpected : 0xFFFFFFFF",
                        "\nActual   : 0x%08h",
                        "\nResult   : DUT operates correctly after reset."
                    },
                    vif.result_ff
                ),
                UVM_NONE
            )

        end
        else
        begin

            `uvm_error(
                "RESET_TEST",
                $sformatf(
                    {
                        "\n[FAIL] POST-RESET OPERATION",
                        "\nExpected : 0xFFFFFFFF",
                        "\nActual   : 0x%08h"
                    },
                    vif.result_ff
                )
            )

        end


        // ========================================================
        // Cleanup
        // ========================================================

        @(negedge vif.clk);

        vif.valid_in = 1'b0;
        vif.ap       = '0;


        // ========================================================
        // TEST END
        // ========================================================

        `uvm_info(
            "TEST_DONE",
            {
                "\n============================================================",
                "\n                   RESET TEST FINISHED",
                "\n============================================================",
                "\nCheck UVM summary:",
                "\n  UVM_ERROR = 0  -> Reset timing matches specification",
                "\n  UVM_ERROR = 1  -> Known asynchronous reset bug detected",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        phase.drop_objection(this);

    endtask


endclass