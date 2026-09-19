class bmu_csr_read_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_csr_read_sequence)

    int unsigned rand_iterations = 10;


    function new(string name = "bmu_csr_read_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting CSR READ sequence",
            UVM_MEDIUM
        )

        // Allow random iteration count from command line
        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));


        // --------------------------------------------------
        // Directed CSR Read cases
        // --------------------------------------------------

        send_csr_read(
            32'h0000_0000,
            "ZERO"
        );

        send_csr_read(
            32'hFFFF_FFFF,
            "ALL_ONES"
        );

        send_csr_read(
            32'hA5A5_5A5A,
            "PATTERN"
        );



        // --------------------------------------------------
        // Constrained-random CSR Read cases
        // --------------------------------------------------

        repeat (rand_iterations) begin
            send_random_csr_read();
        end


        `uvm_info(
            get_type_name(),
            $sformatf(
                "CSR READ sequence finished: 3 directed, %0d random",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask


    // --------------------------------------------------
    // Directed CSR Read transaction
    // --------------------------------------------------
    task send_csr_read(
        input logic [31:0] csr_data,
        input string       case_name
    );

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            $sformatf("req_%s", case_name)
        );

        start_item(req);

        req.valid_in = 1'b1;

        // No BMU operation active
        req.ap = '0;
        // Enable CSR Read
        req.csr_ren_in = 1'b1;

        // CSR data that should appear at result_ff
        req.csr_rddata_in = csr_data;

        // A and B are irrelevant for CSR Read
        req.a_in = 32'h0000_0000;
        req.b_in = 32'h0000_0000;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED CSR READ [%s] CSR_DATA=0x%08h",
                case_name,
                csr_data
            ),
            UVM_MEDIUM
        )

    endtask


    // --------------------------------------------------
    // Random CSR Read transaction
    // --------------------------------------------------
    task send_random_csr_read();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_csr_read_req"
        );

        start_item(req);

        if (!req.randomize() with {

            valid_in == 1'b1;
            ap == '0;

            csr_ren_in == 1'b1;

            a_in == 32'h0000_0000;

            b_in == 32'h0000_0000;

        }) begin

            `uvm_fatal(
                get_type_name(),
                "Randomization failed in bmu_csr_read_sequence"
            )

        end

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM CSR READ: CSR_DATA=0x%08h",
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask


endclass