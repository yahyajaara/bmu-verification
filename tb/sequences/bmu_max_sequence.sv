class bmu_max_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_max_sequence)

    int unsigned rand_iterations = 10;


    function new(string name = "bmu_max_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting MAX sequence",
            UVM_MEDIUM
        )

        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));


        // ============================================================
        // Directed MAX cases
        // ============================================================

        // Positive vs positive
        send_max(
            32'd10,
            32'd20,
            "POSITIVE_POSITIVE"
        );


        // Negative vs negative: -10 vs -20 -> -10
        send_max(
            -32'sd10,
            -32'sd20,
            "NEGATIVE_NEGATIVE"
        );


        // Positive vs negative -> positive
        send_max(
            32'sd10,
            -32'sd20,
            "POSITIVE_NEGATIVE"
        );


        // Main goal: Verify that the signed comparison and the selection 
        // between A and B work correctly in both directions.

        // Negative vs positive -> positive
        send_max(
            -32'sd10,
            32'sd20,
            "NEGATIVE_POSITIVE"
        );





        // Equal operands
        send_max(
            32'sd25,
            32'sd25,
            "EQUAL"
        );


        // Signed maximum vs signed minimum
        send_max(
            32'sh7FFF_FFFF,
            32'sh8000_0000,
            "SIGNED_MAX_MIN"
        );


        // -1 vs 0 -> 0
        send_max(
            32'shFFFF_FFFF,
            32'sh0000_0000,
            "NEGATIVE_ONE_ZERO"
        );


        // 0 vs signed minimum -> 0
        send_max(
            32'sh0000_0000,
            32'sh8000_0000,
            "ZERO_SIGNED_MIN"
        );

        // ============================================================
        // END Directed MAX cases
        // ============================================================



        // ============================================================
        // Constrained-random MAX cases
        // ============================================================

        repeat (rand_iterations) begin
            send_random_max();
        end

        // ============================================================
        // END Constrained-random MAX cases
        // ============================================================



        // ============================================================
        // MAX + CSR conflict
        // ============================================================

        send_max_csr_conflict();

        // ============================================================
        // END MAX + CSR conflict
        // ============================================================



        // ============================================================
        // Invalid AP conflict
        // ============================================================

        send_max_ap_conflict();

        // ============================================================
        // END Invalid AP conflict
        // ============================================================



        // ============================================================
        // Invalid MAX without SUB
        // ============================================================

        send_max_without_sub();

        // ============================================================
        // END Invalid MAX without SUB
        // ============================================================



        `uvm_info(
            get_type_name(),
            $sformatf(
                "MAX sequence finished: 8 directed, %0d random, 1 invalid MAX, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // Directed MAX transaction
    // ============================================================

    task send_max(
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
        req.ap.max    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b0;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = a_value;
        req.b_in = b_value;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED MAX [%s] A=0x%08h B=0x%08h",
                case_name,
                a_value,
                b_value
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // Random MAX transaction
    // ============================================================

    task send_random_max();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_max_req"
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
                "Randomization failed in bmu_max_sequence"
            )

        end

        req.ap.max    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b0;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM MAX: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // MAX + CSR conflict
    // ============================================================

    task send_max_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "max_csr_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;

        req.ap = '0;
        req.ap.max    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b0;

        req.csr_ren_in    = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        req.a_in = 32'd10;
        req.b_in = 32'd20;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "MAX + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // MAX + AP conflict
    // ============================================================

    task send_max_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "max_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        req.ap = '0;

        req.ap.max    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b0;

        // Unrelated operation -> invalid AP conflict
        req.ap.lor = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = 32'd10;
        req.b_in = 32'd20;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "MAX + AP CONFLICT: max=1 sub=1 lor=1 A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // Invalid MAX: max = 1, sub = 0
    // ============================================================

    task send_max_without_sub();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "max_without_sub_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        req.ap = '0;

        // MAX requires both max and sub.
        // This intentionally leaves sub disabled.
        req.ap.max    = 1'b1;
        req.ap.sub    = 1'b0;
        req.ap.unsign = 1'b0;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = 32'd10;
        req.b_in = 32'd20;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "INVALID MAX WITHOUT SUB: max=1 sub=0 A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask


endclass