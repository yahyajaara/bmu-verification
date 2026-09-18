class bmu_sh2add_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_sh2add_sequence)

    int unsigned rand_iterations = 10;


    // Constructor
    function new(string name = "bmu_sh2add_sequence");
        super.new(name);
    endfunction



    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting SH2ADD sequence",
            UVM_MEDIUM
        )


        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Directed SH2ADD cases (edge/corner cases)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        // Result = (A << 2) + B


        // Small normal values
        send_sh2add(
            32'd4,
            32'd7,
            "SMALL_VALUES"
        );


        // A = 0
        send_sh2add(
            32'h0000_0000,
            32'h1234_5678,
            "A_ZERO"
        );


        // B = 0
        send_sh2add(
            32'h1234_5678,
            32'h0000_0000,
            "B_ZERO"
        );


        // Maximum values
        send_sh2add(
            32'hFFFF_FFFF,
            32'hFFFF_FFFF,
            "MAX_VALUES"
        );


        // Zero Minimum
        send_sh2add(
            32'h0000_0000,
            32'h0000_0000,
            "ZERO"
        );


        // Force 32-bit wraparound
        send_sh2add(
            32'h4000_0000,
            32'h0000_0001,
            "WRAPAROUND"      // Expected Result = 0x00000001
        );


        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Directed SH2ADD cases (edge/corner cases)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Constrained-random valid SH2ADD cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        repeat (rand_iterations) begin
            send_random_sh2add();
        end

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Constrained-random valid SH2ADD cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Invalid SH2ADD without ZBA
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        send_sh2add_no_zba();

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Invalid SH2ADD without ZBA
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            send_sh2add_csr_conflict();
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Invalid AP conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            send_sh2add_ap_conflict();
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Invalid AP conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        `uvm_info(
            get_type_name(),
            $sformatf(
                "SH2ADD sequence finished: 6 directed, %0d random, 1 no-ZBA invalid, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask







    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Directed SH2ADD transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_sh2add(

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

        // Enable SH2ADD operation
        req.ap.sh2add = 1'b1;
        // Enable ZBA
        req.ap.zba = 1'b1;

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
                "DIRECTED SH2ADD [%s] A=0x%08h B=0x%08h",
                case_name,
                a_value,
                b_value
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Random SH2ADD transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_random_sh2add();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_sh2add_req"
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
                "Randomization failed in bmu_sh2add_sequence"
            )

        end


        // Select SH2ADD operation
        req.ap.sh2add = 1'b1;
        // Enable ZBA
        req.ap.zba = 1'b1;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM SH2ADD: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // SH2ADD without ZBA
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_sh2add_no_zba();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sh2add_no_zba_req"
        );


        start_item(req);


        req.valid_in = 1'b1;
        req.ap = '0;

        // Select SH2ADD operation
        req.ap.sh2add = 1'b1;
        // ZBA is disabled
        req.ap.zba = 1'b0;

        // CSR is disabled
        req.csr_ren_in = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Set operands
        req.a_in = 32'd4;
        req.b_in = 32'd7;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "SH2ADD WITHOUT ZBA: A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // SH2ADD + CSR conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_sh2add_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sh2add_csr_conflict_req"
        );


        start_item(req);


        req.valid_in = 1'b1;
        req.ap = '0;

        // Select SH2ADD operation
        req.ap.sh2add = 1'b1;
        // Enable ZBA
        req.ap.zba = 1'b1;

        // Enable CSR read at the SAME TIME
        req.csr_ren_in = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        // Give SH2ADD operands known values
        req.a_in = 32'd4;
        req.b_in = 32'd7;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "SH2ADD + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // SH2ADD + AP conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    task send_sh2add_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "sh2add_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        // Clear all AP controls first
        req.ap = '0;

        // Valid SH2ADD controls
        req.ap.sh2add = 1'b1;
        req.ap.zba    = 1'b1;
        // Add another unrelated operation -> invalid conflict
        req.ap.lor = 1'b1;

        // CSR disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Known operands
        req.a_in = 32'h0000_0004;
        req.b_in = 32'h0000_0007;

        finish_item(req);

        `uvm_info(
            get_type_name(),
            $sformatf(
                "SH2ADD + AP CONFLICT: sh2add=1 zba=1 lor=1 A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


endclass