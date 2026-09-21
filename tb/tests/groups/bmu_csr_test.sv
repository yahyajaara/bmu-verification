class bmu_csr_test extends bmu_base_test;

    `uvm_component_utils(bmu_csr_test)


    function new(
        string name = "bmu_csr_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction



    // ==========================================================
    // Run Phase
    // ==========================================================
    task run_phase(uvm_phase phase);

        bmu_csr_read_sequence  csr_read_seq;
        bmu_csr_write_sequence csr_write_seq;


        phase.raise_objection(this);


        `uvm_info(
            "TEST_START",
            {
                "\n============================================================",
                "\n                 STARTING CSR GROUP TEST",
                "\n============================================================",
                "\n Operations:",
                "\n   1. CSR READ",
                "\n   2. CSR WRITE",
                "\n============================================================\n"
            },
            UVM_NONE
        )



        // ======================================================
        // 1. CSR READ
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [1/2] : CSR READ",
                "\n============================================================\n"
            },
            UVM_NONE
        )

        csr_read_seq =
            bmu_csr_read_sequence::type_id::create("csr_read_seq");

        csr_read_seq.start(env.agent.sequencer);

        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [1/2] : CSR READ",
                "\n============================================================\n"
            },
            UVM_NONE
        )



        // ======================================================
        // 2. CSR WRITE
        // ======================================================
        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n START OPERATION [2/2] : CSR WRITE",
                "\n============================================================\n"
            },
            UVM_NONE
        )

        csr_write_seq =
            bmu_csr_write_sequence::type_id::create("csr_write_seq");

        csr_write_seq.start(env.agent.sequencer);

        `uvm_info(
            "GROUP_OPERATION",
            {
                "\n============================================================",
                "\n END OPERATION [2/2] : CSR WRITE",
                "\n============================================================\n"
            },
            UVM_NONE
        )



        `uvm_info(
            "GROUP_TEST_DONE",
            {
                "\n============================================================",
                "\n                 CSR GROUP TEST FINISHED",
                "\n============================================================",
                "\n Completed:",
                "\n   CSR READ",
                "\n   CSR WRITE",
                "\n============================================================\n"
            },
            UVM_NONE
        )

        #1;

        phase.drop_objection(this);

    endtask


endclass