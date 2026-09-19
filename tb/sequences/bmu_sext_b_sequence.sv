class bmu_sext_b_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_sext_b_sequence)

    int unsigned rand_iterations = 10;


    function new(string name = "bmu_sext_b_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting SEXT.B sequence",
            UVM_MEDIUM
        )

        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));


        // ============================================================
        // Directed SEXT.B cases
        // ============================================================

        // Lower byte = 0x00
        send_sext_b(
            32'h0000_0000,
            "BYTE_00"
        );


        // Lower byte = 0xFF
        send_sext_b(
            32'hFFFF_FFFF,
            "BYTE_FF"
        );


        // Largest positive signed byte
        send_sext_b(
            32'h0000_007F,
            "BYTE_7F"
        );


        // Largest positive signed byte with upper bits set
        send_sext_b(
            32'hFFFF_FF7F,
            "UPPER_ONES_BYTE_7F"
        );


        // Smallest negative signed byte
        send_sext_b(
            32'h0000_0080,
            "BYTE_80"
        );


        // Same low byte 0x7F, different upper bits
        send_sext_b(
            32'hABCD_EF7F,
            "UPPER_BITS_POSITIVE_BYTE"
        );


        // Same low byte 0x80, different upper bits
        send_sext_b(
            32'h1234_5680,
            "UPPER_BITS_NEGATIVE_BYTE"
        );

        // ============================================================
        // END Directed SEXT.B cases
        // ============================================================



        // ============================================================
        // Constrained-random SEXT.B cases
        // ============================================================

        repeat (rand_iterations) begin
            send_random_sext_b();
        end

        // ============================================================
        // END Constrained-random SEXT.B cases
        // ============================================================



        // ============================================================
        // CSR + SEXT.B conflict
        // ============================================================

        send_sext_b_csr_conflict();

        // ============================================================
        // END CSR + SEXT.B conflict
        // ============================================================



        // ============================================================
        // Invalid AP conflict
        // ============================================================

        send_sext_b_ap_conflict();

        // ============================================================
        // END Invalid AP conflict
        // ============================================================


        `uvm_info(
            get_type_name(),
            $sformatf(
                "SEXT.B sequence finished: 7 directed, %0d random, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // Directed SEXT.B transaction
    // ============================================================

    task send_sext_b(
        input logic [31:0] a_value,
        input string       case_name
    );

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            $sformatf("req_%s", case_name)
        );

        start_item(req);

        req.valid_in = 1'b1;

        req.ap = '0;
        req.ap.siext_b = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = a_value;
        req.b_in = 32'h0000_0000;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED SEXT.B [%s] A=0x%08h",
                case_name,
                a_value
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // Random SEXT.B transaction
    // ============================================================

    task send_random_sext_b();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_sext_b_req"
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
                "Randomization failed in bmu_sext_b_sequence"
            )

        end

        req.ap.siext_b = 1'b1;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM SEXT.B: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // SEXT.B + CSR conflict
    // ============================================================

    task send_sext_b_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sext_b_csr_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;

        req.ap = '0;
        req.ap.siext_b = 1'b1;

        req.csr_ren_in    = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        req.a_in = 32'h0000_0080;
        req.b_in = 32'h0000_0000;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "SEXT.B + CSR CONFLICT: A=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // SEXT.B + AP conflict
    // ============================================================

    task send_sext_b_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sext_b_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        req.ap = '0;

        req.ap.siext_b = 1'b1;
        // Unrelated operation -> invalid AP conflict
        req.ap.lor = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = 32'h0000_0080;
        req.b_in = 32'h0000_0000;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "SEXT.B + AP CONFLICT: siext_b=1 lor=1 A=0x%08h",
                req.a_in
            ),
            UVM_MEDIUM
        )

    endtask


endclass