class bmu_zbp_test extends bmu_base_test;

    `uvm_component_utils(bmu_zbp_test)

    function new(
        string name = "bmu_zbp_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);

        bmu_ror_sequence  ror_seq;
        bmu_pack_sequence pack_seq;
        bmu_grev_sequence grev_seq;

        phase.raise_objection(this);


        `uvm_info(
            "TEST_START",
            {
                "\n============================================================",
                "\n                 STARTING ZBP EXTENSION TEST",
                "\n============================================================",
                "\n Operations:",
                "\n   1. ROR",
                "\n   2. PACK",
                "\n   3. GREV",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        // ======================================================
        // 1. ROR
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [1/3] : ROR",
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
                "\n END OPERATION [1/3] : ROR",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        // ======================================================
        // 2. PACK
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [2/3] : PACK",
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
                "\n END OPERATION [2/3] : PACK",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        // ======================================================
        // 3. GREV
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [3/3] : GREV",
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
                "\n END OPERATION [3/3] : GREV",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        `uvm_info(
            "GROUP_TEST_DONE",
            {
                "\n============================================================",
                "\n                 ZBP EXTENSION TEST FINISHED",
                "\n============================================================",
                "\n Completed:",
                "\n   ROR",
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