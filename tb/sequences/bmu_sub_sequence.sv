class bmu_sub_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_sub_sequence)

    int unsigned rand_iterations = 10;


    // Constructor
    function new(string name = "bmu_sub_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting SUB sequence",
            UVM_MEDIUM
        )

        // Allow random iteration count to be controlled from command line
        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));


        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Directed SUB cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Result = A - B


        // A - 0
        send_sub(
            32'h1234_5678,
            32'h0000_0000,
            "A_MINUS_ZERO"
        );


        // 0 - B
        send_sub(
            32'h0000_0000,
            32'h1234_5678,
            "ZERO_MINUS_B"
        );


        // A = B
        send_sub(
            32'hDEAD_BEEF,
            32'hDEAD_BEEF,
            "A_EQUAL_B"
        );


        // A > B
        send_sub(
            32'h0000_0014,
            32'h0000_0007,
            "A_GREATER_B"
        );


        // A < B
        send_sub(
            32'h0000_0007,
            32'h0000_0014,
            "A_LESS_B"
        );


        // Negative - Negative
        send_sub(
            32'hFFFF_FFF0,
            32'hFFFF_FFF8,
            "NEG_MINUS_NEG"
        );


        // Positive - Negative
        send_sub(
            32'h0000_0005,
            32'hFFFF_FFFF,
            "POS_MINUS_NEG"
        );


        // Negative - Positive
        send_sub(
            32'hFFFF_FFFF,      // FFFF_FFFF = -1 (signed)
            32'h0000_0001,      // -1 - 1 = -2 
            "NEG_MINUS_POS"
        );


        // Signed maximum
        send_sub(
            32'h7FFF_FFFF,
            32'h0000_0001,
            "SIGNED_MAX"
        );


        // Signed minimum
        send_sub(
            32'h8000_0000,
            32'h0000_0001,
            "SIGNED_MIN"
        );


        // All ones
        send_sub(
            32'hFFFF_FFFF,      
            32'hFFFF_FFFF,         
            "ALL_ONES"
        );


        // MIN_MINUS_MAX
        send_sub(
            32'h8000_0000,      // minimum signed 32-bit
            32'h7FFF_FFFF,      // maximum signed 32-bit
            "MIN_MINUS_MAX"
        );


        // MAX_MINUS_MIN
        send_sub(
            32'h7FFF_FFFF,      // maximum signed 32-bit
            32'h8000_0000,      // minimum signed 32-bit
            "MAX_MINUS_MIN"
        );


        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Directed SUB cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Constrained-random valid SUB cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        repeat (rand_iterations) begin
            send_random_sub();
        end

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Constrained-random valid SUB cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Invalid SUB with ZBA
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        send_sub_with_zba();

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Invalid SUB with ZBA
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Approved CSR conflict case (corner-case)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        send_sub_csr_conflict();

        `uvm_info(
            get_type_name(),
            $sformatf(
                "SUB sequence finished: 13 directed, %0d random, 1 invalid SUB+ZBA, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    endtask



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Directed SUB transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_sub(
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

        // Enable SUB
        req.ap.sub = 1'b1;

        // SUB must NOT operate in ZBA mode
        req.ap.zba = 1'b0;

        // CSR disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Operands
        req.a_in = a_value;
        req.b_in = b_value;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "DIRECTED SUB [%s] A=0x%08h B=0x%08h",
                case_name,
                a_value,
                b_value
            ),
            UVM_MEDIUM
        )

    endtask



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Random SUB transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_random_sub();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_sub_req"
        );

        start_item(req);

        if (!req.randomize() with {

            valid_in       == 1'b1;
            csr_ren_in     == 1'b0;
            csr_rddata_in  == 32'h0000_0000;

            // Start with all AP fields cleared
            ap == '0;

        }) begin

            `uvm_fatal(
                get_type_name(),
                "Randomization failed in bmu_sub_sequence"
            )

        end


        // Select SUB operation
        req.ap.sub = 1'b1;
        // Valid SUB requires ZBA disabled
        req.ap.zba = 1'b0;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM SUB: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Invalid SUB with ZBA
    // Expected by project specification:
    // result = 0
    // error  = 1
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_sub_with_zba();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sub_with_zba_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        req.ap = '0;

        // SUB selected
        req.ap.sub = 1'b1;
        // Invalid configuration for SUB
        req.ap.zba = 1'b1;

        // CSR disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Distinct operands
        req.a_in = 32'h0000_0014;
        req.b_in = 32'h0000_0007;

        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "INVALID SUB + ZBA: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // SUB + CSR conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_sub_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sub_csr_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        req.ap = '0;

        // Select SUB operation
        req.ap.sub = 1'b1;
        // Valid SUB mode
        req.ap.zba = 1'b0;

        // Enable CSR read at the SAME TIME
        req.csr_ren_in = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        // Give SUB operands known values
        req.a_in = 32'h0000_0014;
        req.b_in = 32'h0000_0007;

        finish_item(req);

        `uvm_info(
            get_type_name(),
            $sformatf(
                "SUB + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask


endclass