class bmu_slt_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_slt_sequence)

    int unsigned rand_iterations = 10;

    // Constructor
    function new(string name = "bmu_slt_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting SLT sequence",
            UVM_MEDIUM
        )

        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));


        // ============================================================
        // Directed SLT cases
        // ============================================================

        // Signed comparison:
        // result = ($signed(A) < $signed(B)) ? 1 : 0


         // A == B -> false
        send_slt(
            32'h0000_0005,
            32'h0000_0005,
            "A_EQUAL_B"
        );


        // 3 < 7 -> true
        send_slt(
            32'h0000_0003,
            32'h0000_0007,
            "POS_LESS_POS"
        );


        // 7 < 3 -> false
        send_slt(
            32'h0000_0007,
            32'h0000_0003,
            "POS_GREATER_POS"
        );


        // -16 < -8 -> true
        send_slt(
            32'hFFFF_FFF0,
            32'hFFFF_FFF8,
            "NEG_LESS_NEG"
        );


        // -8 < -16 -> false
        send_slt(
            32'hFFFF_FFF8,
            32'hFFFF_FFF0,
            "NEG_GREATER_NEG"
        );


        // +1 < -1 -> false
        send_slt(
            32'h0000_0001,
            32'hFFFF_FFFF,
            "POS_LESS_NEG"
        );


        // -1 < +1 -> true
        send_slt(
            32'hFFFF_FFFF,
            32'h0000_0001,
            "NEG_LESS_POS"
        );


        // Minimum signed < maximum signed -> true
        send_slt(
            32'h8000_0000,
            32'h7FFF_FFFF,
            "SIGNED_MIN_LESS_MAX"
        );


        // Maximum signed < minimum signed -> false
        send_slt(
            32'h7FFF_FFFF,
            32'h8000_0000,
            "SIGNED_MAX_GREATER_MIN"
        );

        // ============================================================
        // END Directed SLT cases
        // ============================================================



        // ============================================================
        // Constrained-random SLT cases
        // ============================================================

        repeat (rand_iterations) begin
            send_random_slt();
        end

        // ============================================================
        // END Constrained-random SLT cases
        // ============================================================



        // ============================================================
        // CSR + SLT conflict
        // ============================================================

        // Expected:
        // result = 0
        // error  = 1

            send_slt_csr_conflict();

        // ============================================================
        // END CSR + SLT conflict
        // ============================================================



        // ============================================================
        // Invalid AP conflict case
        // ============================================================
            send_slt_ap_conflict();
        // ============================================================
        // END Invalid AP conflict case
        // ============================================================




        `uvm_info(
            get_type_name(),
            $sformatf(
                "SLT sequence finished: 9 directed, %0d random, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // Directed SLT transaction
    // ============================================================

    task send_slt(
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
        // Clear all AP controls first
        req.ap = '0;

        // SLT controls
        req.ap.slt    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b0;

        // CSR disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = a_value;
        req.b_in = b_value;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED SLT [%s] A=0x%08h B=0x%08h",
                case_name,
                a_value,
                b_value
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // Random SLT transaction
    // ============================================================

    task send_random_slt();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_slt_req"
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
                "Randomization failed in bmu_slt_sequence"
            )

        end


        // Signed SLT
        req.ap.slt    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b0;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM SLT: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ============================================================
    // SLT + CSR conflict
    // ============================================================

    task send_slt_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "slt_csr_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        req.ap = '0;

        req.ap.slt    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b0;

        // CSR enabled at same time -> conflict
        req.csr_ren_in    = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        req.a_in = 32'hFFFF_FFFF; // -1
        req.b_in = 32'h0000_0001; // +1

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "SLT + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // SLT + AP conflict
    // ============================================================
    task send_slt_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "slt_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        // Clear all AP controls first
        req.ap = '0;

        // Valid SLT controls
        req.ap.slt    = 1'b1;
        req.ap.sub    = 1'b1;
        req.ap.unsign = 1'b0;
        // Add unrelated operation -> invalid conflict
        req.ap.lor = 1'b1;

        // CSR disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Known operands
        req.a_in = 32'hFFFF_FFFF; // -1 signed
        req.b_in = 32'h0000_0001; // +1 signed

        finish_item(req);

        `uvm_info(
            get_type_name(),
            $sformatf(
                "SLT + AP CONFLICT: slt=1 sub=1 unsign=0 lor=1 A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ============================================================



endclass