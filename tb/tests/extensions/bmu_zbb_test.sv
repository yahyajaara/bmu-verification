class bmu_zbb_test extends bmu_base_test;

    `uvm_component_utils(bmu_zbb_test)

    function new(
        string name = "bmu_zbb_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);

        bmu_orn_sequence    orn_seq;
        bmu_xnor_sequence   xnor_seq;
        bmu_ctz_sequence    ctz_seq;
        bmu_cpop_sequence   cpop_seq;
        bmu_sext_b_sequence sext_b_seq;
        bmu_max_sequence    max_seq;

        phase.raise_objection(this);


        `uvm_info(
            "TEST_START",
            {
                "\n============================================================",
                "\n                 STARTING ZBB EXTENSION TEST",
                "\n============================================================",
                "\n Operations:",
                "\n   1. ORN",
                "\n   2. XNOR",
                "\n   3. CTZ",
                "\n   4. CPOP",
                "\n   5. SEXT.B",
                "\n   6. MAX",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        // ======================================================
        // 1. ORN
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [1/6] : ORN",
                "\n============================================================\n"
            },
            UVM_NONE
        )

        orn_seq = bmu_orn_sequence::type_id::create("orn_seq");
        orn_seq.start(env.agent.sequencer);

        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [1/6] : ORN",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        // ======================================================
        // 2. XNOR
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [2/6] : XNOR",
                "\n============================================================\n"
            },
            UVM_NONE
        )

        xnor_seq = bmu_xnor_sequence::type_id::create("xnor_seq");
        xnor_seq.start(env.agent.sequencer);

        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [2/6] : XNOR",
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
                "\n START OPERATION [3/6] : CTZ",
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
                "\n END OPERATION [3/6] : CTZ",
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
                "\n START OPERATION [4/6] : CPOP",
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
                "\n END OPERATION [4/6] : CPOP",
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
                "\n START OPERATION [5/6] : SEXT.B",
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
                "\n END OPERATION [5/6] : SEXT.B",
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
                "\n START OPERATION [6/6] : MAX",
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
                "\n END OPERATION [6/6] : MAX",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        `uvm_info(
            "GROUP_TEST_DONE",
            {
                "\n============================================================",
                "\n                 ZBB EXTENSION TEST FINISHED",
                "\n============================================================",
                "\n Completed:",
                "\n   ORN",
                "\n   XNOR",
                "\n   CTZ",
                "\n   CPOP",
                "\n   SEXT.B",
                "\n   MAX",
                "\n============================================================\n"
            },
            UVM_NONE
        )

        #10;

        phase.drop_objection(this);

    endtask

endclass