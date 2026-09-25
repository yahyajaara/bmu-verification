class bmu_valid_in_test extends bmu_base_test;

    `uvm_component_utils(bmu_valid_in_test)

    virtual bmu_interface vif;


    // ============================================================
    // Constructor
    // ============================================================
    function new(
        string name = "bmu_valid_in_test",
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
                "\n                     VALID_IN TEST",
                "\n============================================================",
                "\nPurpose:",
                "\n  1. Verify valid_in = 1 captures a new result",
                "\n  2. Verify valid_in = 0 holds the previous result",
                "\n  3. Verify valid_in = 1 captures again",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        // ========================================================
        // STEP 1
        // valid_in = 1
        // Capture new result
        // ========================================================

        `uvm_info(
            "VALID_IN_TEST",
            {
                "\n------------------------------------------------------------",
                "\nSTEP 1: VALID_IN = 1 -- CAPTURE",
                "\n------------------------------------------------------------",
                "\nOperation : OR",
                "\nvalid_in  : 1",
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


        if (vif.result_ff == 32'hFFFF_FFFF) begin

            `uvm_info(
                "VALID_IN_TEST",
                $sformatf(
                    {
                        "\n[PASS] VALID_IN = 1 CAPTURE",
                        "\nExpected : 0xFFFFFFFF",
                        "\nActual   : 0x%08h",
                        "\nResult   : result_ff captured the new result correctly."
                    },
                    vif.result_ff
                ),
                UVM_NONE
            )

        end
        else begin

            `uvm_error(
                "VALID_IN_TEST",
                $sformatf(
                    {
                        "\n[FAIL] VALID_IN = 1 CAPTURE",
                        "\nExpected : 0xFFFFFFFF",
                        "\nActual   : 0x%08h",
                        "\nResult   : result_ff did not capture the expected result."
                    },
                    vif.result_ff
                )
            )

        end


        // ========================================================
        // STEP 2
        // valid_in = 0
        // Hold previous result
        // ========================================================

        `uvm_info(
            "VALID_IN_TEST",
            {
                "\n------------------------------------------------------------",
                "\nSTEP 2: VALID_IN = 0 -- HOLD",
                "\n------------------------------------------------------------",
                "\nPrevious result_ff : 0xFFFFFFFF",
                "\nvalid_in            : 0",
                "\nNew A               : 0x00000000",
                "\nNew B               : 0x00000000",
                "\nExpected             : 0xFFFFFFFF",
                "\nReason               : result_ff must hold its old value",
                "\n------------------------------------------------------------"
            },
            UVM_NONE
        )


        @(negedge vif.clk);

        vif.valid_in = 1'b0;
        vif.a_in     = 32'h0000_0000;
        vif.b_in     = 32'h0000_0000;
        vif.ap       = '0;
        vif.ap.lor   = 1'b1;


        @(posedge vif.clk);
        #1;


        if (vif.result_ff == 32'hFFFF_FFFF) begin

            `uvm_info(
                "VALID_IN_TEST",
                $sformatf(
                    {
                        "\n[PASS] VALID_IN = 0 HOLD",
                        "\nExpected : 0xFFFFFFFF",
                        "\nActual   : 0x%08h",
                        "\nResult   : result_ff correctly held the previous value."
                    },
                    vif.result_ff
                ),
                UVM_NONE
            )

        end
        else begin

            `uvm_error(
                "VALID_IN_TEST",
                $sformatf(
                    {
                        "\n[FAIL] VALID_IN = 0 HOLD",
                        "\nExpected : 0xFFFFFFFF",
                        "\nActual   : 0x%08h",
                        "\nResult   : result_ff changed while valid_in was 0."
                    },
                    vif.result_ff
                )
            )

        end


        // ========================================================
        // STEP 3
        // valid_in = 1 again
        // Capture another new result
        // ========================================================

        `uvm_info(
            "VALID_IN_TEST",
            {
                "\n------------------------------------------------------------",
                "\nSTEP 3: VALID_IN = 1 -- RE-CAPTURE",
                "\n------------------------------------------------------------",
                "\nOperation : OR",
                "\nvalid_in  : 1",
                "\nA         : 0x00000001",
                "\nB         : 0x00000002",
                "\nExpected  : 0x00000003",
                "\n------------------------------------------------------------"
            },
            UVM_NONE
        )


        @(negedge vif.clk);

        vif.valid_in = 1'b1;
        vif.a_in     = 32'h0000_0001;
        vif.b_in     = 32'h0000_0002;
        vif.ap       = '0;
        vif.ap.lor   = 1'b1;


        @(posedge vif.clk);
        #1;


        if (vif.result_ff == 32'h0000_0003) begin

            `uvm_info(
                "VALID_IN_TEST",
                $sformatf(
                    {
                        "\n[PASS] VALID_IN = 1 RE-CAPTURE",
                        "\nExpected : 0x00000003",
                        "\nActual   : 0x%08h",
                        "\nResult   : result_ff captured the new result correctly."
                    },
                    vif.result_ff
                ),
                UVM_NONE
            )

        end
        else begin

            `uvm_error(
                "VALID_IN_TEST",
                $sformatf(
                    {
                        "\n[FAIL] VALID_IN = 1 RE-CAPTURE",
                        "\nExpected : 0x00000003",
                        "\nActual   : 0x%08h",
                        "\nResult   : result_ff did not capture the new value."
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
                "\n                  VALID_IN TEST FINISHED",
                "\n============================================================",
                "\nChecks completed:",
                "\n  [1] valid_in = 1  -> Capture",
                "\n  [2] valid_in = 0  -> Hold",
                "\n  [3] valid_in = 1  -> Re-Capture",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        phase.drop_objection(this);

    endtask


endclass