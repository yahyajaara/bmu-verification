class bmu_shift_mask_test extends bmu_base_test;

    `uvm_component_utils(bmu_shift_mask_test)


    function new(
        string name = "bmu_shift_mask_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction



    // ==========================================================
    // Run Phase
    // ==========================================================
    task run_phase(uvm_phase phase);

        bmu_srl_sequence    srl_seq;
        bmu_sra_sequence    sra_seq;
        bmu_ror_sequence    ror_seq;
        bmu_binv_sequence   binv_seq;
        bmu_sh2add_sequence sh2add_seq;


        // Keep simulation alive while sequences are running
        phase.raise_objection(this);


        `uvm_info(
            "TEST_START",
            {
                "\n============================================================",
                "\n              STARTING SHIFT / MASK GROUP TEST",
                "\n============================================================",
                "\n Operations:",
                "\n   1. SRL",
                "\n   2. SRA",
                "\n   3. ROR",
                "\n   4. BINV",
                "\n   5. SH2ADD",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 1. SRL
        // ======================================================

        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n\n\n============================================================",
                "\n START OPERATION [1/5] : SRL",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        srl_seq = bmu_srl_sequence::type_id::create("srl_seq");

        srl_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [1/5] : SRL",
                "\n============================================================\n\n\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 2. SRA
        // ======================================================

        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n\n\n============================================================",
                "\n START OPERATION [2/5] : SRA",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        sra_seq = bmu_sra_sequence::type_id::create("sra_seq");

        sra_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [2/5] : SRA",
                "\n============================================================\n\n\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 3. ROR
        // ======================================================

        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n\n\n============================================================",
                "\n START OPERATION [3/5] : ROR",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        ror_seq = bmu_ror_sequence::type_id::create("ror_seq");

        ror_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [3/5] : ROR",
                "\n============================================================\n\n\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 4. BINV
        // ======================================================

        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n\n\n============================================================",
                "\n START OPERATION [4/5] : BINV",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        binv_seq = bmu_binv_sequence::type_id::create("binv_seq");

        binv_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [4/5] : BINV",
                "\n============================================================\n\n\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 5. SH2ADD
        // ======================================================

        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n\n\n============================================================",
                "\n START OPERATION [5/5] : SH2ADD",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        sh2add_seq = bmu_sh2add_sequence::type_id::create("sh2add_seq");

        sh2add_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [5/5] : SH2ADD",
                "\n============================================================\n\n\n"
            },
            UVM_NONE
        )





        // ======================================================
        // Group Test Finished
        // ======================================================

        `uvm_info(
            "TEST_DONE",
            {
                "\n============================================================",
                "\n              SHIFT / MASK GROUP TEST FINISHED",
                "\n============================================================",
                "\n Completed:",
                "\n   SRL",
                "\n   SRA",
                "\n   ROR",
                "\n   BINV",
                "\n   SH2ADD",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        // Allow last transaction to complete
        #1;


        phase.drop_objection(this);

    endtask


endclass