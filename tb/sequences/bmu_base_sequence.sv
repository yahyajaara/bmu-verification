class bmu_base_sequence extends uvm_sequence #(bmu_sequence_item);

    `uvm_object_utils(bmu_base_sequence)

    function new(string name = "bmu_base_sequence");
        super.new(name);
    endfunction


    virtual task body();

        bmu_sequence_item item;

        // -----------------------------
        // Item 1 : valid request
        // Simple OR operation
        // -----------------------------
        item = bmu_sequence_item::type_id::create("item1");

        start_item(item);

        item.valid_in      = 1'b1;
        item.ap            = '0;
        item.ap.lor        = 1'b1;

        item.csr_ren_in    = 1'b0;
        item.csr_rddata_in = '0;

        item.a_in          = 32'h0000_0005;
        item.b_in          = 32'h0000_0003;

        finish_item(item);


        // -----------------------------
        // Item 2 : valid_in = 0
        // Used to check result_ff hold
        // -----------------------------
        item = bmu_sequence_item::type_id::create("item2");

        start_item(item);

        item.valid_in      = 1'b0;
        item.ap            = '0;
        item.csr_ren_in    = 1'b0;
        item.csr_rddata_in = '0;
        item.a_in          = '0;
        item.b_in          = '0;

        finish_item(item);

    endtask

endclass : bmu_base_sequence