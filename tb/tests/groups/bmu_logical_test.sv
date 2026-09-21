class bmu_logical_test extends bmu_base_test;

    `uvm_component_utils(bmu_logical_test)


    function new(
        string name = "bmu_logical_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction



    // ==========================================================
    // Run Phase
    // ==========================================================
    task run_phase(uvm_phase phase);

        bmu_or_sequence   or_seq;
        bmu_orn_sequence  orn_seq;
        bmu_xor_sequence  xor_seq;
        bmu_xnor_sequence xnor_seq;


        // Keep simulation alive while sequences are running
        phase.raise_objection(this);


        `uvm_info(
            "TEST_START",
            {
                "\n============================================================",
                "\n              STARTING LOGICAL GROUP TEST",
                "\n============================================================",
                "\n Operations:",
                "\n   1. OR",
                "\n   2. ORN",
                "\n   3. XOR",
                "\n   4. XNOR",
                "\n============================================================\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 1. OR
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n\n\n============================================================",
                "\n START OPERATION [1/4] : OR",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        or_seq = bmu_or_sequence::type_id::create("or_seq");

        or_seq.start(env.agent.sequencer);




        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [1/4] : OR",
                "\n============================================================\n\n\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 2. ORN
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n\n\n============================================================",
                "\n START OPERATION [2/4] : ORN",
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
                "\n END OPERATION [2/4] : ORN",
                "\n============================================================\n\n\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 3. XOR
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n\n\n============================================================",
                "\n START OPERATION [3/4] : XOR",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        xor_seq = bmu_xor_sequence::type_id::create("xor_seq");

        xor_seq.start(env.agent.sequencer);




        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [3/4] : XOR",
                "\n============================================================\n\n\n"
            },
            UVM_NONE
        )





        // ======================================================
        // 4. XNOR
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n\n\n============================================================",
                "\n START OPERATION [4/4] : XNOR",
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
                "\n END OPERATION [4/4] : XNOR",
                "\n============================================================\n\n\n"
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
                "\n              LOGICAL GROUP TEST FINISHED",
                "\n============================================================",
                "\n Completed:",
                "\n   OR",
                "\n   ORN",
                "\n   XOR",
                "\n   XNOR",
                "\n============================================================\n"
            },
            UVM_NONE
        )


        // Allow final messages/checks to complete
        #1;

        phase.drop_objection(this);

    endtask


endclass