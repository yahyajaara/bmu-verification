
class bmu_ctz_test extends bmu_base_test;

    `uvm_component_utils(bmu_ctz_test)


    function new(string name = "bmu_ctz_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);

        // Replace the base sequence with the ctz sequence
        bmu_base_sequence::type_id::set_type_override(
            bmu_ctz_sequence::get_type()
        );

        super.build_phase(phase);

    endfunction


endclass