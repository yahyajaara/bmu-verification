class bmu_ror_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_ror_sequence)

    int unsigned rand_iterations = 10;


    // Constructor
    function new(string name = "bmu_ror_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting ROR sequence",
            UVM_MEDIUM
        )

        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));


        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Directed ROR cases (edge/corner cases)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        // Rotate amount = 0
        send_ror(
            32'hFFFF_0000,
            32'd0,
            "ROTATE_0"      // Expected Result = 0xffff0000
        );

        // Rotate amount = 1
        send_ror(
            32'h8000_0001,
            32'd1,
            "ROTATE_1"      // Expected Result = 0xc0000000   
        );

        // Rotate amount = 2 
        send_ror(
            32'hAAAA_AAAA,
            32'd2,
            "ROTATE_2"      // Expected Result = 0xaaaaaaaa the same 
        );

        // Rotate amount = 15
        send_ror(
            32'h5555_5555,
            32'd15,
            "ROTATE_15"      // Expected Result = 0xaaaaaaaa
        );


        // Rotate amount = 16
        send_ror(
            32'h1234_5678,
            32'd16,
            "ROTATE_16"      // Expected Result = 0x56781234
        );


        // Rotate amount = 30
        send_ror(
            32'h1234_5678,
            32'd30,
            "ROTATE_30"
        );


        // Rotate amount = 31
        send_ror(
            32'h8000_0001,
            32'd31,
            "ROTATE_31"
        );


        // High bits of B must be ignored
        send_ror(
            32'h89AB_CDEF,
            32'hFFFF_FF04,
            "HIGH_B_BITS"
        );

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Directed ROR cases (edge/corner cases)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Constrained-random valid ROR cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        repeat (rand_iterations) begin
            send_random_ror();
        end

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Constrained-random valid ROR cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            send_ror_csr_conflict();
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Invalid AP conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            send_ror_ap_conflict();
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Invalid AP conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        `uvm_info(
            get_type_name(),
            $sformatf(
                "ROR sequence finished: 8 directed, %0d random, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )


    endtask







    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Directed ROR transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_ror(

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

        // Enable ROR operation
        req.ap.ror = 1'b1;

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
                "DIRECTED ROR [%s] A=0x%08h B=0x%08h ROTATE=%0d",
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
    // Random ROR transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_random_ror();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_ror_req"
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
                "Randomization failed in bmu_ror_sequence"
            )

        end


        // Select ROR operation only
        req.ap.ror = 1'b1;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM ROR: A=0x%08h B=0x%08h ROTATE=%0d",
                req.a_in,
                req.b_in,
                req.b_in[4:0]
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ROR + CSR conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_ror_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "ror_csr_conflict_req"
        );


        start_item(req);


        req.valid_in = 1'b1;
        req.ap = '0;

        // Select ROR operation
        req.ap.ror = 1'b1;

        // Enable CSR read at the SAME TIME
        req.csr_ren_in = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        // Give ROR operands known values
        req.a_in = 32'h89AB_CDEF;
        req.b_in = 32'd4;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "ROR + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ROR + AP conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    task send_ror_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "ror_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        // Clear all AP controls first
        req.ap = '0;

        // Valid ROR control
        req.ap.ror = 1'b1;
        // Add another unrelated operation -> invalid conflict
        req.ap.lor = 1'b1;

        // CSR disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Known operands
        req.a_in = 32'h89AB_CDEF;
        req.b_in = 32'h0000_0004;

        finish_item(req);

        `uvm_info(
            get_type_name(),
            $sformatf(
                "ROR + AP CONFLICT: ror=1 lor=1 A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

endclass