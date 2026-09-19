class bmu_sltu_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_sltu_sequence)

    int unsigned rand_iterations = 10;

    // Constructor
    function new(string name = "bmu_sltu_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting SLTU sequence",
            UVM_MEDIUM
        )

        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));


        // ============================================================
        // Directed SLTU cases
        // ============================================================

        // Unsigned comparison:
        // result = (A < B) ? 1 : 0


        // A == B -> false
        send_sltu(
            32'h0000_0005,
            32'h0000_0005,
            "A_EQUAL_B"
        );


        // 3 < 7 -> true
        send_sltu(
            32'h0000_0003,
            32'h0000_0007,
            "SMALL_LESS_LARGE"
        );


        // 7 < 3 -> false
        send_sltu(
            32'h0000_0007,
            32'h0000_0003,
            "LARGE_GREATER_SMALL"
        );


        // Unsigned:
        // 0xFFFF_FFFF = 4294967295
        // 4294967295 < 0 -> false
        send_sltu(
            32'hFFFF_FFFF,
            32'h0000_0000,
            "UNSIGNED_MAX_VS_ZERO"
        );


        // 0 < 4294967295 -> true
        send_sltu(
            32'h0000_0000,
            32'hFFFF_FFFF,
            "ZERO_LESS_UNSIGNED_MAX"
        );



        // Unsigned:
        // 0x8000_0000 = 2147483648
        // 0x7FFF_FFFF = 2147483647
        // 2147483648 < 2147483647 -> false
        send_sltu(
            32'h8000_0000,
            32'h7FFF_FFFF,
            "80000000_GREATER_7FFFFFFF"
        );


        // 2147483647 < 2147483648 -> true
        send_sltu(
            32'h7FFF_FFFF,
            32'h8000_0000,
            "7FFFFFFF_LESS_80000000"
        );


        // Signed/unsigned divergence case
        // Unsigned: 0xFFFF_FFFF = 4294967295
        // 4294967295 < 1 -> false
        send_sltu(
            32'hFFFF_FFFF,
            32'h0000_0001,
            "SIGNED_UNSIGNED_DIVERGENCE"
        );


        // ============================================================
        // END Directed SLTU cases
        // ============================================================



        // ============================================================
        // Constrained-random SLTU cases
        // ============================================================

        repeat (rand_iterations) begin
            send_random_sltu();
        end

        // ============================================================
        // END Constrained-random SLTU cases
        // ============================================================



        // ============================================================
        // CSR + SLTU conflict
        // ============================================================

        // Expected:
        // result = 0
        // error  = 1

        send_sltu_csr_conflict();

        // ============================================================
        // END CSR + SLTU conflict
        // ============================================================



        // ============================================================
        // Invalid AP conflict case
        // ============================================================

        send_sltu_ap_conflict();

        // ============================================================
        // END Invalid AP conflict case
        // ============================================================



        `uvm_info(
            get_type_name(),
            $sformatf(
                "SLTU sequence finished: 8 directed, %0d random, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // Directed SLTU transaction
    // ============================================================

    task send_sltu(
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

        // SLTU controls
        req.ap.slt    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b1;

        // CSR disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = a_value;
        req.b_in = b_value;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED SLTU [%s] A=0x%08h B=0x%08h",
                case_name,
                a_value,
                b_value
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // Random SLTU transaction
    // ============================================================

    task send_random_sltu();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_sltu_req"
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
                "Randomization failed in bmu_sltu_sequence"
            )

        end


        // Unsigned SLTU controls
        req.ap.slt    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b1;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM SLTU: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // SLTU + CSR conflict
    // ============================================================

    task send_sltu_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sltu_csr_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        req.ap = '0;

        // Valid SLTU controls
        req.ap.slt    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b1;

        // CSR enabled at same time -> conflict
        req.csr_ren_in    = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        req.a_in = 32'hFFFF_FFFF;
        req.b_in = 32'h0000_0001;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "SLTU + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // SLTU + AP conflict
    // ============================================================

    task send_sltu_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sltu_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        // Clear all AP controls first
        req.ap = '0;

        // Valid SLTU controls
        req.ap.slt    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b1;
        // Add unrelated operation -> invalid AP conflict
        req.ap.lor = 1'b1;

        // CSR disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Known operands
        req.a_in = 32'hFFFF_FFFF;
        req.b_in = 32'h0000_0001;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "SLTU + AP CONFLICT: slt=1 sub=1 unsign=1 lor=1 A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ============================================================


endclass