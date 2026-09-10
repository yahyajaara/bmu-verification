class bmu_driver extends uvm_driver #(bmu_sequence_item);

    `uvm_component_utils(bmu_driver)

    // Virtual interface
    virtual bmu_interface.drv vif;

    // Sequence item
    bmu_sequence_item item;


    function new(string name = "bmu_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db #(virtual bmu_interface.drv)::get(
            this,
            "",
            "vif",
            vif
        ))
        `uvm_fatal(get_type_name(), "Failed to get virtual interface")

    endfunction



   task run_phase(uvm_phase phase);

        // Initial idle values
        @(vif.cb_drv);

        vif.cb_drv.valid_in      <= 1'b0;
        vif.cb_drv.ap            <= '0;
        vif.cb_drv.csr_ren_in    <= 1'b0;
        vif.cb_drv.csr_rddata_in <= '0;
        vif.cb_drv.a_in          <= '0;
        vif.cb_drv.b_in          <= '0;


        forever begin

            seq_item_port.get_next_item(item);

            @(vif.cb_drv);

            drive(item);

            `uvm_info(
                get_type_name(),
                $sformatf(
                    "Driver: signals driven to DUT: valid_in = %0b, ap = %0h, csr_ren_in = %0b, csr_rddata_in = %0h, a_in = %0d, b_in = %0d",
                    item.valid_in,
                    item.ap,
                    item.csr_ren_in,
                    item.csr_rddata_in,
                    item.a_in,
                    item.b_in
                ),
                UVM_HIGH
            )

            @(posedge vif.clk);

            seq_item_port.item_done();

        end

    endtask



    task drive(bmu_sequence_item item);

        // Drive the signals to the DUT
        vif.cb_drv.valid_in      <= item.valid_in;
        vif.cb_drv.ap            <= item.ap;
        vif.cb_drv.csr_ren_in    <= item.csr_ren_in;
        vif.cb_drv.csr_rddata_in <= item.csr_rddata_in;
        vif.cb_drv.a_in          <= item.a_in;
        vif.cb_drv.b_in          <= item.b_in;

    endtask

    
endclass