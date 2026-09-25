class bmu_grev_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_grev_sequence)

    int unsigned rand_iterations = 10;


    function new(string name = "bmu_grev_sequence");
        super.new(name);
    endfunction



    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting GREV sequence",
            UVM_MEDIUM
        )

        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));



        // ============================================================
        // Directed valid GREV cases
        // ============================================================

        // 0x12345678 -> 0x78563412
        send_grev(
            32'h1234_5678,
            32'd24,
            "SPEC_PATTERN"
        );


        // 0xA1B2C3D4 -> 0xD4C3B2A1
        send_grev(
            32'hA1B2_C3D4,
            32'd24,
            "PATTERN_A1B2C3D4"
        );


        // Only B[4:0] controls the GREV mode.
        // 0xFFFF_FFF8[4:0] = 5'b11000 = 24
        send_grev(
            32'h1234_5678,
            32'hFFFF_FFF8,
            "UPPER_B_BITS_IGNORED"
        );

        // ============================================================
        // END Directed valid GREV cases
        // ============================================================





        // ============================================================
        // Invalid GREV modes
        // Expected: result = 0, error = 1
        // ============================================================

        send_grev(
            32'h1234_5678,
            32'd0,
            "INVALID_MODE_0"
        );


        send_grev(
            32'h1234_5678,
            32'd31,
            "INVALID_MODE_31"
        );


        send_grev(
            32'h1234_5678,
            32'hFFFF_FFFF,
            "INVALID_MODE_ALL_ONES"
        );


        // ============================================================
        // END Invalid GREV modes
        // ============================================================





        // ============================================================
        // Constrained-random valid GREV cases
        // ============================================================

        repeat (rand_iterations) begin
            send_random_grev();
        end

        // ============================================================
        // END Constrained-random valid GREV cases
        // ============================================================





        // ============================================================
        // GREV + CSR conflict
        // ============================================================

        send_grev_csr_conflict();

        // ============================================================
        // END GREV + CSR conflict
        // ============================================================





        // ============================================================
        // Invalid AP conflict
        // ============================================================

        send_grev_ap_conflict();

        // ============================================================
        // END Invalid AP conflict
        // ============================================================



        `uvm_info(
            get_type_name(),
            $sformatf(
                "GREV sequence finished: 3 valid directed, 3 invalid modes, %0d random, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask






    // ============================================================
    // Directed valid GREV transaction
    // ============================================================

    task send_grev(
        input logic [31:0] a_value,
        input logic [31:0] b_value,
        input string       case_name
    );

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            $sformatf("req_%s", case_name)
        );

        start_item(req);

        req.valid_in = 1'b1;

        req.ap = '0;
        req.ap.grev = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = a_value;
        req.b_in = b_value;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED GREV [%s] A=0x%08h B=0x%08h MODE=%0d",
                case_name,
                a_value,
                b_value,
                b_value[4:0]
            ),
            UVM_MEDIUM
        )

    endtask





    // ============================================================
    // Random valid GREV transaction
    // ============================================================

    task send_random_grev();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_grev_req"
        );

        start_item(req);

        if (!req.randomize() with {

            valid_in      == 1'b1;
            csr_ren_in    == 1'b0;
            csr_rddata_in == 32'h0000_0000;

            ap == '0;

        }) begin

            `uvm_fatal(
                get_type_name(),
                "Randomization failed in bmu_grev_sequence"
            )

        end

        req.ap.grev = 1'b1;

        // Valid GREV mode.
        // Upper B bits remain random.
        req.b_in[4:0] = 5'b11000;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM GREV: A=0x%08h B=0x%08h MODE=%0d",
                req.a_in,
                req.b_in,
                req.b_in[4:0]
            ),
            UVM_MEDIUM
        )

    endtask





    // ============================================================
    // GREV + CSR conflict
    // ============================================================

    task send_grev_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "grev_csr_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;

        req.ap = '0;
        req.ap.grev = 1'b1;

        req.csr_ren_in    = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        req.a_in = 32'h1234_5678;
        req.b_in = 32'd24;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "GREV + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask





    // ============================================================
    // GREV + AP conflict
    // ============================================================

    task send_grev_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "grev_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;

        req.ap = '0;
        req.ap.grev = 1'b1;

        // Unrelated operation -> invalid AP conflict
        req.ap.lor = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = 32'h1234_5678;
        req.b_in = 32'd24;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "GREV + AP CONFLICT: grev=1 lor=1 A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask


endclass