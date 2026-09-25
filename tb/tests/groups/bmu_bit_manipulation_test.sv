class bmu_bit_manipulation_test extends bmu_base_test;

    `uvm_component_utils(bmu_bit_manipulation_test)


    function new(
        string name = "bmu_bit_manipulation_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction



    // ==========================================================
    // Run Phase
    // ==========================================================
    task run_phase(uvm_phase phase);

        bmu_slt_sequence    slt_seq;
        bmu_sltu_sequence   sltu_seq;
        bmu_ctz_sequence    ctz_seq;
        bmu_cpop_sequence   cpop_seq;
        bmu_sext_b_sequence sext_b_seq;
        bmu_max_sequence    max_seq;
        bmu_pack_sequence   pack_seq;
        bmu_grev_sequence   grev_seq;


        phase.raise_objection(this);


        `uvm_info(
            "TEST_START",
            {
                "\n============================================================",
                "\n           STARTING BIT MANIPULATION GROUP TEST",
                "\n============================================================",
                "\n Operations:",
                "\n   1. SLT",
                "\n   2. SLTU",
                "\n   3. CTZ",
                "\n   4. CPOP",
                "\n   5. SEXT.B",
                "\n   6. MAX",
                "\n   7. PACK",
                "\n   8. GREV",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 1. SLT
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [1/8] : SLT",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        slt_seq = bmu_slt_sequence::type_id::create("slt_seq");

        slt_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [1/8] : SLT",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 2. SLTU
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [2/8] : SLTU",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        sltu_seq = bmu_sltu_sequence::type_id::create("sltu_seq");

        sltu_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [2/8] : SLTU",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 3. CTZ
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [3/8] : CTZ",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        ctz_seq = bmu_ctz_sequence::type_id::create("ctz_seq");

        ctz_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [3/8] : CTZ",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 4. CPOP
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [4/8] : CPOP",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        cpop_seq = bmu_cpop_sequence::type_id::create("cpop_seq");

        cpop_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [4/8] : CPOP",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 5. SEXT.B
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [5/8] : SEXT.B",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        sext_b_seq = bmu_sext_b_sequence::type_id::create("sext_b_seq");

        sext_b_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [5/8] : SEXT.B",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 6. MAX
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [6/8] : MAX",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        max_seq = bmu_max_sequence::type_id::create("max_seq");

        max_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [6/8] : MAX",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 7. PACK
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [7/8] : PACK",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        pack_seq = bmu_pack_sequence::type_id::create("pack_seq");

        pack_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [7/8] : PACK",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 8. GREV
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [8/8] : GREV",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        grev_seq = bmu_grev_sequence::type_id::create("grev_seq");

        grev_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [8/8] : GREV",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // Group Test Finished
        // ======================================================
        `uvm_info(
            "GROUP_TEST_DONE",
            {
                "\n============================================================",
                "\n           BIT MANIPULATION GROUP TEST FINISHED",
                "\n============================================================",
                "\n Completed:",
                "\n   SLT",
                "\n   SLTU",
                "\n   CTZ",
                "\n   CPOP",
                "\n   SEXT.B",
                "\n   MAX",
                "\n   PACK",
                "\n   GREV",
                "\n============================================================\n"
            },
            UVM_NONE
        )

        #1;


        phase.drop_objection(this);

    endtask


endclass