
class bmu_error_handling_test extends bmu_base_test;

    `uvm_component_utils(bmu_error_handling_test)


    function new(string name = "bmu_error_handling_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);

        // Replace the base sequence with the error_handling sequence
        bmu_base_sequence::type_id::set_type_override(
            bmu_error_handling_sequence::get_type()
        );

        super.build_phase(phase);

    endfunction


endclass