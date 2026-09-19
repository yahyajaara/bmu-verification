
class bmu_grev_test extends bmu_base_test;

    `uvm_component_utils(bmu_grev_test)


    function new(string name = "bmu_grev_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);

        // Replace the base sequence with the grev sequence
        bmu_base_sequence::type_id::set_type_override(
            bmu_grev_sequence::get_type()
        );

        super.build_phase(phase);

    endfunction


endclass