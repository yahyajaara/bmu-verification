class bmu_arithmetic_test extends bmu_base_test;

    `uvm_component_utils(bmu_arithmetic_test)


    function new(
        string name = "bmu_arithmetic_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction



    // ==========================================================
    // Run Phase
    // ==========================================================
    task run_phase(uvm_phase phase);

        bmu_sub_sequence sub_seq;


        phase.raise_objection(this);


        `uvm_info(
            "TEST_START",
            {
                "\n============================================================",
                "\n              STARTING ARITHMETIC GROUP TEST",
                "\n============================================================",
                "\n Operations:",
                "\n   1. SUB",
                "\n============================================================\n"
            },
            UVM_NONE
        )



        // ======================================================
        // 1. SUB
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [1/1] : SUB",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        sub_seq = bmu_sub_sequence::type_id::create("sub_seq");

        sub_seq.start(env.agent.sequencer);


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [1/1] : SUB",
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
                "\n              ARITHMETIC GROUP TEST FINISHED",
                "\n============================================================",
                "\n Completed:",
                "\n   SUB",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        #10;


        phase.drop_objection(this);

    endtask


endclass