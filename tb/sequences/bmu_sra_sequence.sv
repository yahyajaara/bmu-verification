class bmu_sra_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_sra_sequence)

    int unsigned rand_iterations = 10;


    // Constructor
    function new(string name = "bmu_sra_sequence");
        super.new(name);
    endfunction



    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting SRA sequence",
            UVM_MEDIUM
        )


        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Directed SRA cases (edge/corner cases)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        // Shift amount = 0
        send_sra(
            32'hFFFF_FFFF,
            32'd0,
            "SHIFT_0"
        );


        // Shift amount = 1 and Largest positive signed number.
        send_sra(
            32'h7FFF_FFFF, // 0111....1111 ==> 0011....1111
            32'd1,
            "SHIFT_1"
        );


        // Shift amount = 2 and Smallest negative signed number.
        send_sra(
            32'h8000_0000,  // 1000....0000 ==> 1110....0000
            32'd2,
            "SHIFT_2"
        );


        // Shift amount = 15
        send_sra(
            32'h7FFF_FFFF,
            32'd15,
            "SHIFT_15"
        );


        // Shift amount = 16
        send_sra(
            32'h8000_0000,
            32'd16,
            "SHIFT_16"
        );


        // Shift amount = 30
        send_sra(
            32'h4000_0000,  // Expected Result = 0x00000001
            32'd30,
            "SHIFT_30"
        );


        // Shift amount = 31
        send_sra(
            32'h8000_0000,
            32'd31,
            "SHIFT_31"
        );


        // High bits of B must be ignored
        send_sra(
            32'hF000_0000,
            32'hFFFF_FF04,
            "HIGH_B_BITS"
        );

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Directed SRA cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Constrained-random valid SRA cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        repeat (rand_iterations) begin

            send_random_sra();

        end

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Constrained-random valid SRA cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            send_sra_csr_conflict();
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Invalid AP conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            send_sra_ap_conflict();
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Invalid AP conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        `uvm_info(
            get_type_name(),
            $sformatf(
                "SRA sequence finished: 8 directed, %0d random, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask




    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Directed SRA transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_sra(

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

        // Enable SRA operation
        req.ap.sra = 1'b1;

        // CSR is disabled
        req.csr_ren_in = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Set operands
        req.a_in = a_value;
        req.b_in = b_value;


        finish_item(req);



        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED SRA [%s] A=0x%08h B=0x%08h SHIFT=%0d",
                case_name,
                a_value,
                b_value,
                b_value[4:0]
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Random SRA transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_random_sra();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_sra_req"
        );


        start_item(req);


        if (!req.randomize() with {

            valid_in == 1'b1;

            csr_ren_in == 1'b0;

            csr_rddata_in == 32'h0000_0000;

            ap == '0;

        }) begin

            `uvm_fatal(
                get_type_name(),
                "Randomization failed in bmu_sra_sequence"
            )

        end


        // Select SRA operation only
        req.ap.sra = 1'b1;


        finish_item(req);



        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM SRA: A=0x%08h B=0x%08h SHIFT=%0d",
                req.a_in,
                req.b_in,
                req.b_in[4:0]
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // SRA + CSR conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_sra_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sra_csr_conflict_req"
        );


        start_item(req);


        req.valid_in = 1'b1;
        req.ap = '0;

        // Select SRA operation
        req.ap.sra = 1'b1;

        // Enable CSR read at the SAME TIME
        req.csr_ren_in = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        // Give SRA operands known values
        req.a_in = 32'hF000_0000;
        req.b_in = 32'd4;


        finish_item(req);



        `uvm_info(
            get_type_name(),
            $sformatf(
                "SRA + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // SRA + AP conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    task send_sra_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sra_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        // Clear all AP controls first
        req.ap = '0;

        // Valid SRA control
        req.ap.sra = 1'b1;
        // Add another unrelated operation -> invalid conflict
        req.ap.lor = 1'b1;

        // CSR disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Known operands
        req.a_in = 32'hF000_0000;
        req.b_in = 32'h0000_0004;

        finish_item(req);

        `uvm_info(
            get_type_name(),
            $sformatf(
                "SRA + AP CONFLICT: sra=1 lor=1 A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


endclass