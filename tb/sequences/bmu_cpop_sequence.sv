class bmu_cpop_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_cpop_sequence)

    int unsigned rand_iterations = 10;


    function new(string name = "bmu_cpop_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting CPOP sequence",
            UVM_MEDIUM
        )

        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));


        // ============================================================
        // Directed CPOP cases
        // ============================================================

        // 0 set bits
        send_cpop(
            32'h0000_0000,
            "ZERO_BITS"
        );


        // 3 set bits
        send_cpop(
            32'h0000_000B,
            "THREE_BITS"
        );


        // 16 set bits - upper half only
        send_cpop(
            32'hFFFF_0000,
            "UPPER_HALF_ONES"
        );


        // 16 set bits - LOWER half only
        send_cpop(
            32'h0000_FFFF,
            "LOWER_HALF_ONES"
        );


        // 31 set bits
        send_cpop(
            32'hFFFF_FFFE,
            "THIRTY_ONE_BITS"
        );


        // 32 set bits
        send_cpop(
            32'hFFFF_FFFF,
            "ALL_ONES"
        );


        // pattern - 16 set bits
        send_cpop(
            32'hAAAA_AAAA,
            "ALTERNATING_A"
        );


        // pattern - 16 set bits
        send_cpop(
            32'h5555_5555,
            "ALTERNATING_5"
        );


        // ============================================================
        // END Directed CPOP cases
        // ============================================================



        // ============================================================
        // Constrained-random CPOP cases
        // ============================================================

        repeat (rand_iterations) begin
            send_random_cpop();
        end

        // ============================================================
        // END Constrained-random CPOP cases
        // ============================================================



        // ============================================================
        // CSR + CPOP conflict
        // ============================================================
            send_cpop_csr_conflict();
        // ============================================================
        // END CSR + CPOP conflict
        // ============================================================



        // ============================================================
        // Invalid AP conflict
        // ============================================================
            send_cpop_ap_conflict();
        // ============================================================
        // END Invalid AP conflict
        // ============================================================


        `uvm_info(
            get_type_name(),
            $sformatf(
                "CPOP sequence finished: 8 directed, %0d random, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // Directed CPOP transaction
    // ============================================================

    task send_cpop(
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
        req.ap.cpop = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = a_value;
        req.b_in = 32'h0000_0000;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED CPOP [%s] A=0x%08h",
                case_name,
                a_value
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // Random CPOP transaction
    // ============================================================

    task send_random_cpop();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_cpop_req"
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
                "Randomization failed in bmu_cpop_sequence"
            )

        end

        req.ap.cpop = 1'b1;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM CPOP: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // CPOP + CSR conflict
    // ============================================================

    task send_cpop_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "cpop_csr_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;

        req.ap = '0;
        req.ap.cpop = 1'b1;

        req.csr_ren_in    = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        req.a_in = 32'hF0F0_F00F;
        req.b_in = 32'h0000_0000;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "CPOP + CSR CONFLICT: A=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // CPOP + AP conflict
    // ============================================================

    task send_cpop_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "cpop_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        req.ap = '0;

        // Valid CPOP control
        req.ap.cpop = 1'b1;
        // Unrelated operation -> invalid AP conflict
        req.ap.lor = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = 32'hF0F0_F00F;
        req.b_in = 32'h0000_0000;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "CPOP + AP CONFLICT: cpop=1 lor=1 A=0x%08h",
                req.a_in
            ),
            UVM_MEDIUM
        )

    endtask


endclass