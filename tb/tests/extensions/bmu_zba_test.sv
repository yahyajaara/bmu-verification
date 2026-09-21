class bmu_zba_test extends bmu_base_test;

    `uvm_component_utils(bmu_zba_test)

    function new(
        string name = "bmu_zba_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);

        bmu_sh2add_sequence sh2add_seq;

        phase.raise_objection(this);


        `uvm_info(
            "TEST_START",
            {
                "\n============================================================",
                "\n                 STARTING ZBA EXTENSION TEST",
                "\n============================================================",
                "\n Operations:",
                "\n   1. SH2ADD",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [1/1] : SH2ADD",
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
                "\n END OPERATION [1/1] : SH2ADD",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        `uvm_info(
            "GROUP_TEST_DONE",
            {
                "\n============================================================",
                "\n                 ZBA EXTENSION TEST FINISHED",
                "\n============================================================",
                "\n Completed:",
                "\n   SH2ADD",
                "\n============================================================\n"
            },
            UVM_NONE
        )

        #10;

        phase.drop_objection(this);

    endtask

endclass