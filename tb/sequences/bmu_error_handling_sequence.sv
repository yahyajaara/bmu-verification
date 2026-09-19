class bmu_error_handling_sequence extends bmu_base_sequence;

    `uvm_object_utils(bmu_error_handling_sequence)


    function new(string name = "bmu_error_handling_sequence");
        super.new(name);
    endfunction


    virtual task body();

        `uvm_info(
            get_type_name(),
            "Starting BMU ERROR HANDLING sequence",
            UVM_MEDIUM
        )


        // ==================================================
        // 1. CSR + BMU Conflicts
        // ==================================================

        // CSR Read + OR
        send_csr_conflict(
            1'b1,              // lor
            1'b0,              // sub
            1'b0,              // csr_write
            "CSR_READ_PLUS_OR"
        );


        // CSR Read + SUB
        send_csr_conflict(
            1'b0,
            1'b1,
            1'b0,
            "CSR_READ_PLUS_SUB"
        );


        // CSR Read + CSR Write
        send_csr_conflict(
            1'b0,
            1'b0,
            1'b1,
            "CSR_READ_PLUS_CSR_WRITE"
        );


        // ==================================================
        // 2. SH2ADD without Zba
        // ==================================================

        send_sh2add_without_zba();


        // ==================================================
        // 3. SUB with Zba
        // ==================================================

        send_sub_with_zba();


        // ==================================================
        // 4. Generic AP Conflicts
        // ==================================================

        // OR + XOR
        send_ap_conflict(
            1'b1,
            1'b0,
            "OR_PLUS_XOR"
        );


        // SRL + CPOP
        send_ap_conflict(
            1'b0,
            1'b1,
            "SRL_PLUS_CPOP"
        );




        `uvm_info(
            get_type_name(),
            "BMU ERROR HANDLING sequence finished",
            UVM_MEDIUM
        )

    endtask



    // ==========================================================
    // CSR + BMU Conflict
    // ==========================================================
    task send_csr_conflict(
        input logic  lor_en,
        input logic  sub_en,
        input logic  csr_write_en,
        input string case_name
    );

        bmu_sequence_item req;


        req = bmu_sequence_item::type_id::create(
            $sformatf("req_%s", case_name)
        );


        start_item(req);


        // Randomize data only
        if (!req.randomize() with {

            valid_in == 1'b1;

            // CSR Read enabled
            csr_ren_in == 1'b1;

            // Keep data values different
            a_in != b_in;
            a_in != csr_rddata_in;
            b_in != csr_rddata_in;

        }) begin

            `uvm_fatal(
                get_type_name(),
                "Randomization failed in CSR conflict case"
            )

        end


        // Clear all AP controls
        req.ap = '0;

        // Select the required AP operation
        req.ap.lor       = lor_en;
        req.ap.sub       = sub_en;
        req.ap.csr_write = csr_write_en;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "CSR CONFLICT [%s] CSR_DATA=0x%08h A=0x%08h B=0x%08h",
                case_name,
                req.csr_rddata_in,
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ==========================================================
    // SH2ADD without Zba
    // ==========================================================
    task send_sh2add_without_zba();

        bmu_sequence_item req;


        req = bmu_sequence_item::type_id::create(
            "sh2add_without_zba_req"
        );


        start_item(req);


        // Randomize data only
        if (!req.randomize() with {

            valid_in == 1'b1;

            // CSR disabled
            csr_ren_in == 1'b0;

            csr_rddata_in == 32'h0000_0000;

            // Keep operands different
            a_in != b_in;

        }) begin

            `uvm_fatal(
                get_type_name(),
                "Randomization failed in SH2ADD without Zba case"
            )

        end


        // Clear all AP controls
        req.ap = '0;

        // Create SH2ADD without Zba error condition
        req.ap.sh2add = 1'b1;
        req.ap.zba    = 1'b0;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "ERROR CASE [SH2ADD WITHOUT ZBA] A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask



    // ==========================================================
    // SUB with Zba
    // ==========================================================
    task send_sub_with_zba();

        bmu_sequence_item req;


        req = bmu_sequence_item::type_id::create(
            "sub_with_zba_req"
        );


        start_item(req);


        // Randomize data only
        if (!req.randomize() with {

            valid_in == 1'b1;

            // CSR disabled
            csr_ren_in == 1'b0;

            csr_rddata_in == 32'h0000_0000;

            // Keep operands different
            a_in != b_in;

        }) begin

            `uvm_fatal(
                get_type_name(),
                "Randomization failed in SUB with Zba case"
            )

        end


        // Clear all AP controls
        req.ap = '0;


        // Create SUB with Zba error condition
        req.ap.sub = 1'b1;
        req.ap.zba = 1'b1;


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "ERROR CASE [SUB WITH ZBA] A=0x%08h B=0x%08h",
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask




    // ==========================================================
    // Generic AP Conflict
    // ==========================================================
    task send_ap_conflict(
        input logic  or_xor_case,
        input logic  srl_cpop_case,
        input string case_name
    );

        bmu_sequence_item req;


        req = bmu_sequence_item::type_id::create(
            $sformatf("req_%s", case_name)
        );


        start_item(req);


        // Randomize data only
        if (!req.randomize() with {

            valid_in == 1'b1;

            // CSR disabled
            csr_ren_in == 1'b0;

            csr_rddata_in == 32'h0000_0000;

            // Keep operands different
            a_in != b_in;

        }) begin

            `uvm_fatal(
                get_type_name(),
                "Randomization failed in AP conflict case"
            )

        end


        // Clear all AP controls
        req.ap = '0;

        // OR + XOR conflict
        if (or_xor_case) begin
            req.ap.lor  = 1'b1;
            req.ap.lxor = 1'b1;
        end


        // SRL + CPOP conflict
        if (srl_cpop_case) begin
            req.ap.srl  = 1'b1;
            req.ap.cpop = 1'b1;
        end


        finish_item(req);


        `uvm_info(
            get_type_name(),
            $sformatf(
                "AP CONFLICT [%s] A=0x%08h B=0x%08h",
                case_name,
                req.a_in,
                req.b_in
            ),
            UVM_MEDIUM
        )

    endtask


endclass