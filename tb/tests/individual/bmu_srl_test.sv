
class bmu_srl_test extends bmu_base_test;

    `uvm_component_utils(bmu_srl_test)


    function new(string name = "bmu_srl_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);

        // Replace the base sequence with the srl sequence
        bmu_base_sequence::type_id::set_type_override(
            bmu_srl_sequence::get_type()
        );

        super.build_phase(phase);

    endfunction


endclass