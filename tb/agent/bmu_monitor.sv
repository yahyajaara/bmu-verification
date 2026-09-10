class bmu_monitor extends uvm_monitor;

    `uvm_component_utils(bmu_monitor)

    // Virtual interface
    virtual bmu_interface.mon vif;

    // Analysis port
    uvm_analysis_port #(bmu_sequence_item) port;

    // Sequence item
    bmu_sequence_item item;


    function new(string name = "bmu_monitor",uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Create analysis port
        port = new("port", this);

        // Get virtual interface
        if (!uvm_config_db #(virtual bmu_interface.mon)::get(
            this,
            "",
            "vif",
            vif
        ))
            `uvm_fatal(get_type_name(),"Failed to get virtual interface")

    endfunction


    task run_phase(uvm_phase phase);

        forever begin

            // Sample signals at posedge
            @(vif.cb_mon);

            // Ignore reset cycles
            if (!vif.cb_mon.rst_l)
                continue;

            // Only capture a new transaction when valid_in = 1
            if (vif.cb_mon.valid_in) begin

                // Create a new transaction
                item = bmu_sequence_item::type_id::create("item");
                
                item.valid_in      = vif.cb_mon.valid_in;
                item.ap            = vif.cb_mon.ap;
                item.csr_ren_in    = vif.cb_mon.csr_ren_in;
                item.csr_rddata_in = vif.cb_mon.csr_rddata_in;
                item.a_in          = vif.cb_mon.a_in;
                item.b_in          = vif.cb_mon.b_in;

                item.result_ff     = vif.cb_mon.result_ff;
                item.error         = vif.cb_mon.error;


                `uvm_info(
                    get_type_name(),
                    $sformatf(
                        "Monitor: A=%0d B=%0d valid=%0b result=%0h error=%0b",
                        item.a_in,
                        item.b_in,
                        item.valid_in,
                        item.result_ff,
                        item.error
                    ),
                    UVM_HIGH
                )

                // Send transaction to scoreboard/subscriber
                port.write(item);

            end

        end

    endtask


endclass : bmu_monitor