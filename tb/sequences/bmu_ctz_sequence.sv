class bmu_ctz_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_ctz_sequence)

    int unsigned rand_iterations = 10;


    function new(string name = "bmu_ctz_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting CTZ sequence",
            UVM_MEDIUM
        )

        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));


        // ============================================================
        // Directed CTZ cases
        // ============================================================

    
        // A = 0 -> result = 0
        send_ctz(
            32'h0000_0000,
            "ALL_ZERO"
        );


        // All Ones -> result = 0
        send_ctz(
            32'hFFFF_FFFF,
            "ALL_ONES"
        );


        // bit[0] = 1 -> CTZ = 0
        send_ctz(
            32'h0000_0001,
            "BIT0_SET"
        );


        // 10b -> CTZ = 1
        send_ctz(
            32'h0000_0002,
            "BIT1_SET"
        );


        // 100b -> CTZ = 2
        send_ctz(
            32'h0000_0004,
            "BIT2_SET"
        );


        // bit[8] = 1 -> CTZ = 8
        send_ctz(
            32'h0000_0100,
            "BIT8_SET"
        );


        // bit[31] = 1 -> CTZ = 31
        send_ctz(
            32'h8000_0000,
            "BIT31_SET"
        );


        // ...1010 -> CTZ = 1
        send_ctz(
            32'hAAAA_AAAA,
            "ALTERNATING_A"
        );


        // ...0101 -> CTZ = 0
        send_ctz(
            32'h5555_5555,
            "ALTERNATING_5"
        );

        // ============================================================
        // END Directed CTZ cases
        // ============================================================



        // ============================================================
        // Constrained-random CTZ cases
        // ============================================================

        repeat (rand_iterations) begin
            send_random_ctz();
        end

        // ============================================================
        // END Constrained-random CTZ cases
        // ============================================================



        // ============================================================
        // CSR + CTZ conflict
        // ============================================================
            send_ctz_csr_conflict();
        // ============================================================
        // END CSR + CTZ conflict
        // ============================================================



        // ============================================================
        // Invalid AP conflict case
        // ============================================================
            send_ctz_ap_conflict();
        // ============================================================
        // END Invalid AP conflict case
        // ============================================================


        `uvm_info(
            get_type_name(),
            $sformatf(
                "CTZ sequence finished: 9 directed, %0d random, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // Directed CTZ transaction
    // ============================================================

    task send_ctz(
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
        req.ap.ctz = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = a_value;
        req.b_in = 32'h0000_0000;   

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED CTZ [%s] A=0x%08h",
                case_name,
                a_value
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // Random CTZ transaction
    // ============================================================

    task send_random_ctz();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_ctz_req"
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
                "Randomization failed in bmu_ctz_sequence"
            )

        end

        req.ap.ctz = 1'b1;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM CTZ: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // CTZ + CSR conflict
    // ============================================================

    task send_ctz_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "ctz_csr_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;

        req.ap = '0;
        req.ap.ctz = 1'b1;

        req.csr_ren_in    = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        req.a_in = 32'h0000_0100;
        req.b_in = 32'h0000_0000;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "CTZ + CSR CONFLICT: A=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask




    // ============================================================
    // CTZ + AP conflict
    // ============================================================

    task send_ctz_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "ctz_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        req.ap = '0;

        // Valid CTZ control
        req.ap.ctz = 1'b1;
        req.ap.lor = 1'b1;

        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = 32'h0000_0100;
        req.b_in = 32'h0000_0000;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "CTZ + AP CONFLICT: ctz=1 lor=1 A=0x%08h",
                req.a_in
            ),
            UVM_MEDIUM
        )

    endtask


endclass