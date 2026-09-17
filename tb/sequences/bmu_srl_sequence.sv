class bmu_srl_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_srl_sequence)

    int unsigned rand_iterations = 10;


    // Constructor
    function new(string name = "bmu_srl_sequence");
        super.new(name);
    endfunction



    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting SRL sequence",
            UVM_MEDIUM
        )


        void'($value$plusargs(
            "BMU_RAND_ITERS=%d",
            rand_iterations
        ));




        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Directed SRL cases (edge/corner cases)
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        // Shift amount = 0
        send_srl(
            32'hF000_0001,
            32'd0,
            "SHIFT_0"
        );


        // Shift amount = 1
        send_srl(
            32'h8000_0001,   // 1000....0001 >> 1 ===> 0100....0000
            32'd1,
            "SHIFT_1"
        );


        // Shift amount = 2
        send_srl(
            32'hC000_0003,   // 1100....0011 >> 2 ===> 0011....0000
            32'd2,
            "SHIFT_2"
        );


        // Shift amount = 15
        send_srl(
            32'hFFFF_0000,
            32'd15,
            "SHIFT_15"
        );


        // Shift amount = 16
        send_srl(
            32'hFFFF_0000,
            32'd16,
            "SHIFT_16"
        );


        // Shift amount = 30
        send_srl(
            32'hC000_0000,  // C0000000 >> 30 = 00000003
            32'd30,
            "SHIFT_30"
        );


        // Shift amount = 31
        send_srl(
            32'h8000_0000,  // 80000000 >> 31 = 00000001
            32'd31,
            "SHIFT_31"
        );


        // High bits of B must be ignored
        // B = 32'h0000_0004;
        // B = 32'hFFFF_FF04;
        // this value has the same result 

        send_srl(
            32'hF000_0000,
            32'hFFFF_FF04,
            "HIGH_B_BITS"
        );

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Directed SRL cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Constrained-random valid SRL cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        repeat (rand_iterations) begin

            send_random_srl();

        end

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Constrained-random valid SRL cases
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        send_srl_csr_conflict();


        `uvm_info(
            get_type_name(),
            $sformatf(
                "SRL sequence finished: 8 directed, %0d random, 1 CSR conflict",
                rand_iterations
            ),
            UVM_MEDIUM
        )

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // END Approved CSR conflict case
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    endtask







    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Directed SRL transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_srl(

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

        // Enable SRL operation
        req.ap.srl = 1'b1;

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
                "DIRECTED SRL [%s] A=0x%08h B=0x%08h SHIFT=%0d",
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
    // Random SRL transaction
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_random_srl();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "random_srl_req"
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
                "Randomization failed in bmu_srl_sequence"
            )

        end


        // Select SRL operation only
        req.ap.srl = 1'b1;


        finish_item(req);



        `uvm_info(
            get_type_name(),
            $sformatf(
                "RANDOM SRL: A=0x%08h B=0x%08h SHIFT=%0d",
                req.a_in,
                req.b_in,
                req.b_in[4:0]
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // SRL + CSR conflict case
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    task send_srl_csr_conflict();

        bmu_sequence_item req;

        req = bmu_sequence_item::type_id::create(
            "srl_csr_conflict_req"
        );


        start_item(req);


        req.valid_in = 1'b1;
        req.ap = '0;

        // Select SRL operation
        req.ap.srl = 1'b1;

        // Enable CSR read at the SAME TIME
        req.csr_ren_in = 1'b1;
        req.csr_rddata_in = 32'hCAFE_BABE;

        // Give SRL operands known values
        req.a_in = 32'hF000_0000;
        req.b_in = 32'd4;


        finish_item(req);



        `uvm_info(
            get_type_name(),
            $sformatf(
                "SRL + CSR CONFLICT: A=0x%08h B=0x%08h CSR_DATA=0x%08h",
                req.a_in,
                req.b_in,
                req.csr_rddata_in
            ),
            UVM_MEDIUM
        )

    endtask

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


endclass