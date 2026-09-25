class bmu_csr_write_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_csr_write_sequence)

    int unsigned rand_iterations = 10;


    function new(string name = "bmu_csr_write_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting CSR WRITE sequence",
            UVM_MEDIUM
        )


        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));


        // --------------------------------------------------
        // Directed CSR Write cases
        // --------------------------------------------------

        // csr_imm = 0 -> result must come from A
        send_csr_write(
            32'h1234_5678,
            32'hA5A5_5A5A,
            1'b0,
            "CSR_IMM_0"
        );


        // csr_imm = 1 -> result must come from B
        send_csr_write(
            32'h1234_5678,
            32'hA5A5_5A5A,
            1'b1,
            "CSR_IMM_1"
        );


        // --------------------------------------------------
        // Random CSR Write cases
        // --------------------------------------------------

        repeat (rand_iterations) begin
            send_random_csr_write();
        end


        `uvm_info(
            get_type_name(),
            $sformatf(
                "CSR WRITE sequence finished: 2 directed, %0d random",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask



    // --------------------------------------------------
    // Directed CSR Write
    // --------------------------------------------------
    task send_csr_write(
        input logic [31:0] a_value,
        input logic [31:0] b_value,
        input logic        csr_imm_value,
        input string       case_name
    );

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            $sformatf("req_%s", case_name)
        );

        start_item(req);

        req.valid_in = 1'b1;

        req.ap = '0;

        // Enable CSR Write
        req.ap.csr_write = 1'b1;
        req.ap.csr_imm   = csr_imm_value;

        // CSR Read disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        req.a_in = a_value;
        req.b_in = b_value;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED CSR WRITE [%s] csr_imm=%0b A=0x%08h B=0x%08h",
                case_name,
                csr_imm_value,
                a_value,
                b_value
            ),
            UVM_MEDIUM
        )

    endtask



    // --------------------------------------------------
    // Random CSR Write
    // --------------------------------------------------
    task send_random_csr_write();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_csr_write_req"
        );

        start_item(req);

        if (!req.randomize() with {

            valid_in == 1'b1;

            csr_ren_in == 1'b0;

            csr_rddata_in == 32'h0000_0000;

            ap.csr_write == 1'b1;

            $countones(ap) ==
                (ap.csr_imm ? 2 : 1);

            a_in != b_in;

        }) begin

            `uvm_fatal(
                get_type_name(),
                "Randomization failed in bmu_csr_write_sequence"
            )

        end


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM CSR WRITE: csr_imm=%0b A=0x%08h B=0x%08h",
                req.ap.csr_imm,
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask


endclass