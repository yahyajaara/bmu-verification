
class bmu_xor_test extends bmu_base_test;

    `uvm_component_utils(bmu_xor_test)


    function new(string name = "bmu_xor_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);

        // Replace the base sequence with the XOR sequence
        bmu_base_sequence::type_id::set_type_override(
            bmu_xor_sequence::get_type()
        );

        super.build_phase(phase);

    endfunction


endclass