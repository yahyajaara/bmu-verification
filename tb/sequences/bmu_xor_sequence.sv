class bmu_xor_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_xor_sequence)

    
    int unsigned rand_iterations = 10;


    // Constructor
    function new(string name = "bmu_xor_sequence");
        super.new(name);
    endfunction



    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting XOR sequence",
            UVM_MEDIUM
        )


        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Directed XOR cases (edge/corner cases)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        // 0 XOR 0
        send_xor(
            32'h0000_0000,
            32'h0000_0000,
            "ZERO_ZERO"
        );

        // A = all ones
        send_xor(
            32'hFFFF_FFFF,
            32'h0000_0000,
            "A_ALL_ONES"
        );

        // B = all ones
        send_xor(
            32'h0000_0000,
            32'hFFFF_FFFF,
            "B_ALL_ONES"
        );


        // Complementary bit patterns (corner-case)
        send_xor(
            32'hAAAA_AAAA,   // 1010 1010 1010 ....
            32'h5555_5555,   // 0101 0101 0101 ....
            "AAAA_5555"
        );

        send_xor(
            32'h5555_5555,
            32'hAAAA_AAAA,
            "5555_AAAA"
        );

        send_xor(
            32'hF0F0_F0F0,   // 1111 0000 1111 0000 ...
            32'h0F0F_0F0F,   // 0000 1111 0000 1111 ...
            "F0F0_0F0F"
        );


        // Equal operands (corner-case)
        send_xor(
            32'h1234_5678,
            32'h1234_5678,
            "EQUAL"
        );

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Directed XOR cases (edge/corner cases)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Constrained-random valid XOR cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        repeat (rand_iterations) begin

            send_random_xor();

        end

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Constrained-random valid XOR cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Approved CSR conflict case (corner-case)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        send_xor_csr_conflict();

        `uvm_info(
            get_type_name(),
            $sformatf(
                "XOR sequence finished: 7 directed, %0d random, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    endtask





    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Directed XOR transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_xor(

        input logic [31:0] a_value,
        input logic [31:0] b_value,
        input string       case_name

    );

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            $sformatf("req_%s", case_name)
        );


        // Wait until the sequencer is ready
        start_item(req);


        // Set control signals
        req.valid_in = 1'b1;
        req.ap = '0;

        // Enable XOR operation
        req.ap.lxor = 1'b1;
        req.ap.zbb = 1'b0;

        // CSR is disabled
        req.csr_ren_in = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Set operands
        req.a_in = a_value;
        req.b_in = b_value;


        // Send transaction to driver
        finish_item(req);


        // Print transaction information
        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED XOR [%s] A=0x%08h B=0x%08h",
                case_name,
                a_value,
                b_value
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Random XOR transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_random_xor();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_xor_req"
        );


        start_item(req);


        // Randomize the transaction
        if (!req.randomize() with {

            valid_in == 1'b1;

            csr_ren_in == 1'b0;

            csr_rddata_in == 32'h0000_0000;

            ap == '0;

        }) begin

            `uvm_fatal(
                get_type_name(),
                "Randomization failed in bmu_xor_sequence"
            )

        end

        // Select XOR operation only
        req.ap.lxor = 1'b1;
        req.ap.zbb = 1'b0;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM XOR: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // XOR + CSR conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_xor_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "xor_csr_conflict_req"
        );



        start_item(req);


        req.valid_in = 1'b1;
        req.ap = '0;

        // Select XOR operation
        req.ap.lxor = 1'b1;
        req.ap.zbb = 1'b0;

        // Enable CSR read at the SAME TIME
        req.csr_ren_in = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        // Give XOR operands known values
        req.a_in = 32'h1234_5678;
        req.b_in = 32'h8765_4321;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "XOR + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


endclass