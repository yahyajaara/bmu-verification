

class bmu_binv_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_binv_sequence)

    int unsigned rand_iterations = 10;


    // Constructor
    function new(string name = "bmu_binv_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting BINV sequence",
            UVM_MEDIUM
        )


        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Directed BINV cases (edge/corner cases)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


        // Index = 0
        send_binv(
            32'h0000_0000,
            32'd0,
            "INDEX_0"
        );


        // Index = 1
        send_binv(
            32'h0000_0002,
            32'd1,
            "INDEX_1"
        );


        // Index = 15
        send_binv(
            32'hFFFF_FFFF,
            32'd15,
            "INDEX_15"
        );


        // Index = 16
        send_binv(
            32'h0000_0000,
            32'd16,
            "INDEX_16"
        );


        // Index = 30
        send_binv(
            32'h5555_5555,
            32'd30,
            "INDEX_30"
        );


        // Index = 31
        send_binv(
            32'h5AAA_AAAA,
            32'd31,
            "INDEX_31"
        );


        // High bits of B must be ignored
        send_binv(
            32'h0000_0000,
            32'hFFFF_FF04,
            "HIGH_B_BITS"
        );


        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Directed BINV cases (edge/corner cases)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Constrained-random valid BINV cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        repeat (rand_iterations) begin
            send_random_binv();
        end

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Constrained-random valid BINV cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            send_binv_csr_conflict();
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Invalid AP conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            send_binv_ap_conflict();
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Invalid AP conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



        `uvm_info(
            get_type_name(),
            $sformatf(
                "BINV sequence finished: 7 directed, %0d random, 1 AP conflict, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

    endtask





    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Directed BINV transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_binv(

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

        // Enable BINV operation
        req.ap.binv = 1'b1;

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
                "DIRECTED BINV [%s] A=0x%08h B=0x%08h INDEX=%0d",
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
    // Random BINV transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_random_binv();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_binv_req"
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
                "Randomization failed in bmu_binv_sequence"
            )

        end


        // Select BINV operation only
        req.ap.binv = 1'b1;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM BINV: A=0x%08h B=0x%08h INDEX=%0d",
                req.a_in,
                req.b_in,
                req.b_in[4:0]
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // BINV + CSR conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_binv_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "binv_csr_conflict_req"
        );


        start_item(req);


        req.valid_in = 1'b1;
        req.ap = '0;

        // Select BINV operation
        req.ap.binv = 1'b1;

        // Enable CSR read at the SAME TIME
        req.csr_ren_in = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        // Give BINV operands known values
        req.a_in = 32'hAAAA_AAAA;
        req.b_in = 32'd4;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "BINV + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // BINV + AP conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    task send_binv_ap_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "binv_ap_conflict_req"
        );

        start_item(req);

        req.valid_in = 1'b1;
        // Clear all AP controls first
        req.ap = '0;

        // Valid BINV control
        req.ap.binv = 1'b1;
        // Add another unrelated operation -> invalid conflict
        req.ap.lor = 1'b1;

        // CSR disabled
        req.csr_ren_in    = 1'b0;
        req.csr_rddata_in = 32'h0000_0000;

        // Known operands
        req.a_in = 32'hAAAA_AAAA;
        req.b_in = 32'h0000_0004;

        finish_item(req);

        `uvm_info(
            get_type_name(),
            $sformatf(
                "BINV + AP CONFLICT: binv=1 lor=1 A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

endclass