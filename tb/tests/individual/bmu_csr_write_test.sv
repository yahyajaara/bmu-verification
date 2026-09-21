
class bmu_csr_write_test extends bmu_base_test;

    `uvm_component_utils(bmu_csr_write_test)


    function new(string name = "bmu_csr_write_test",uvm_component parent = null);
        super.new(name, parent);
    endfunction


    // Build Phase
    function void build_phase(uvm_phase phase);

        // Replace the base sequence with the csr_write sequence
        bmu_base_sequence::type_id::set_type_override(
            bmu_csr_write_sequence::get_type()
        );

        super.build_phase(phase);

    endfunction


endclass