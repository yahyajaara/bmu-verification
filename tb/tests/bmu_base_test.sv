class bmu_base_test extends uvm_test;

    `uvm_component_utils(bmu_base_test)

    // Environment
    bmu_environment env;


    // Base sequence
    bmu_base_sequence seq;



    // Constructor
    function new( string name = "bmu_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Create environment
        env = bmu_environment::type_id::create("env", this);

    endfunction



    // Run Phase
     task run_phase(uvm_phase phase);

        // Keep simulation alive while sequence is running
        phase.raise_objection(this);

        `uvm_info(
            "TEST_START",
            $sformatf(
                {
                    "\n============================================================",
                    "\n                 STARTING UVM TEST",
                    "\n============================================================",
                    "\n TEST NAME : %s",
                    "\n============================================================\n"
                },
                get_type_name()
            ),
            UVM_NONE
        )

        seq = bmu_base_sequence::type_id::create("seq");

        seq.start(env.agent.sequencer);

        // Allow last transaction to complete
        #10;

        phase.drop_objection(this);

    endtask


endclass