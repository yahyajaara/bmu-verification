class bmu_environment extends uvm_env;

    `uvm_component_utils(bmu_environment)

    bmu_agent      agent;
    bmu_scoreboard scoreboard;


    function new(string name = "bmu_environment",uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        agent = bmu_agent::type_id::create("agent", this);

        scoreboard = bmu_scoreboard::type_id::create("scoreboard", this);

    endfunction


    // Connect Phase
    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        // Monitor -> Scoreboard
        agent.monitor.port.connect(
            scoreboard.exp
        );

        // Monitor -> Subscriber
        /*agent.monitor.port.connect(
            subscriber.analysis_export
        );*/

    endfunction


endclass