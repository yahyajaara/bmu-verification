class bmu_zbs_test extends bmu_base_test;

    `uvm_component_utils(bmu_zbs_test)

    function new(
        string name = "bmu_zbs_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);

        bmu_binv_sequence binv_seq;

        phase.raise_objection(this);


        `uvm_info(
            "TEST_START",
            {
                "\n============================================================",
                "\n                 STARTING ZBS EXTENSION TEST",
                "\n============================================================",
                "\n Operations:",
                "\n   1. BINV",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [1/1] : BINV",
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
                "\n END OPERATION [1/1] : BINV",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        `uvm_info(
            "GROUP_TEST_DONE",
            {
                "\n============================================================",
                "\n                 ZBS EXTENSION TEST FINISHED",
                "\n============================================================",
                "\n Completed:",
                "\n   BINV",
                "\n============================================================\n"
            },
            UVM_NONE
        )

        #10;

        phase.drop_objection(this);

    endtask

endclass