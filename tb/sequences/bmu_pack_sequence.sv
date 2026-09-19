class bmu_pack_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_pack_sequence)

    int unsigned rand_iterations = 10;


    function new(string name = "bmu_pack_sequence");
        super.new(name);
    endfunction



    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting PACK sequence",
            UVM_MEDIUM
        )

        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));



        // ============================================================
        // Directed PACK cases
        // ============================================================

        
        // Expected = {16'hEF12, 16'h5678} = 32'hEF12_5678
        send_pack(
            32'h1234_5678,
            32'hABCD_EF12,
            "SPEC_PATTERN"
        );


        // Zero
        send_pack(
            32'h0000_0000,
            32'h0000_0000,
            "ALL_ZERO"
        );


        // All ones
        send_pack(
            32'hFFFF_FFFF,
            32'hFFFF_FFFF,
            "ALL_ONES"
        );


        // Distinct lower halves
        send_pack(
            32'h0000_1234,
            32'h0000_ABCD,
            "DISTINCT_LOWER_HALVES"
        );


        // Upper bits should not affect PACK result
        send_pack(
            32'hFFFF_5678,
            32'hFFFF_EF12,
            "UPPER_BITS_IGNORED"
        );


        // ============================================================
        // END Directed PACK cases
        // ============================================================





        // ============================================================
        // Constrained-random PACK cases
        // ============================================================

        repeat (rand_iterations) begin
            send_random_pack();
        end

        // ============================================================
        // END Constrained-random PACK cases
        // ============================================================





        // ============================================================
        // PACK + CSR conflict
        // ============================================================

        send_pack_csr_conflict();

        // ============================================================
        // END PACK + CSR conflict
        // ============================================================





        // ============================================================
        // Invalid AP conflict
        // ============================================================

        send_pack_ap_conflict();

        // ============================================================
        // END Invalid AP conflict
        // ============================================================



        `uvm_info(
            get_type_name(),
            $sformatf(
                "PACK sequence finished: 5 directed, %0d random, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask





    // ============================================================
    // Directed PACK transaction
    // ============================================================

    task send_pack(
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
        req.ap.pack = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = a_value;
        req.b_in = b_value;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED PACK [%s] A=0x%08h B=0x%08h",
                case_name,
                a_value,
                b_value
            ),
            UVM_MEDIUM
        )

    endtask





    // ============================================================
    // Random PACK transaction
    // ============================================================

    task send_random_pack();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_pack_req"
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
                "Randomization failed in bmu_pack_sequence"
            )

        end

        req.ap.pack = 1'b1;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM PACK: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask





    // ============================================================
    // PACK + CSR conflict
    // ============================================================

    task send_pack_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "pack_csr_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;

        req.ap = '0;
        req.ap.pack = 1'b1;

        req.csr_ren_in    = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        req.a_in = 32'h1234_5678;
        req.b_in = 32'hABCD_EF12;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "PACK + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask





    // ============================================================
    // PACK + AP conflict
    // ============================================================

    task send_pack_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "pack_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        
        req.ap = '0;
        req.ap.pack = 1'b1;

        // Unrelated operation -> invalid AP conflict
        req.ap.lor = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = 32'h1234_5678;
        req.b_in = 32'hABCD_EF12;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "PACK + AP CONFLICT: pack=1 lor=1 A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask


endclass