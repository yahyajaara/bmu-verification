package bmu_tb_pkg;

    import uvm_pkg::*;
    import rtl_pkg::*;

    `include "uvm_macros.svh"

     // Transaction
    `include "sequence_item/bmu_sequence_item.sv"

     // Sequences
     `include "sequences/bmu_base_sequence.sv"


     // Agent Components
    `include "agent/bmu_sequencer.sv"
    `include "agent/bmu_driver.sv"
    `include "agent/bmu_monitor.sv"



     // Checking / Coverage



     // Environment



     // Tests

    class bmu_day2_sanity_test extends uvm_test;

        `uvm_component_utils(bmu_day2_sanity_test)

        bmu_sequencer sequencer;
        bmu_driver    driver;
        bmu_monitor   monitor;

        function new(
            string name = "bmu_day2_sanity_test",
            uvm_component parent = null
        );
            super.new(name, parent);
        endfunction


        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            sequencer = bmu_sequencer::type_id::create("sequencer", this);
            driver    = bmu_driver::type_id::create("driver", this);
            monitor   = bmu_monitor::type_id::create("monitor", this);

        endfunction


        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);

            driver.seq_item_port.connect(
                sequencer.seq_item_export
            );

        endfunction


        task run_phase(uvm_phase phase);

            bmu_base_sequence seq;

            phase.raise_objection(this);

            // Wait until reset is released
            do begin
                @(monitor.vif.cb_mon);
            end
            while (!monitor.vif.cb_mon.rst_l);

            seq = bmu_base_sequence::type_id::create("seq");

            seq.start(sequencer);

            // Keep simulation alive one extra cycle
            @(monitor.vif.cb_mon);

            phase.drop_objection(this);

        endtask

    endclass : bmu_day2_sanity_test

      



      



endpackage : bmu_tb_pkg