module bmu_tb_top;

    timeunit 1ns;
    timeprecision 1ps;

    import uvm_pkg::*;
    import rtl_pkg::*;
    import bmu_tb_pkg::*;

    logic clk;

    bmu_interface bmu_if(clk);



    Bit_Manipulation_Unit dut (

        .clk           (clk),
        .rst_l         (bmu_if.rst_l),
        .scan_mode     (bmu_if.scan_mode),

        .valid_in      (bmu_if.valid_in),
        .ap            (bmu_if.ap),
        .csr_ren_in    (bmu_if.csr_ren_in),
        .csr_rddata_in (bmu_if.csr_rddata_in),
        .a_in          (bmu_if.a_in),
        .b_in          (bmu_if.b_in),

        .result_ff     (bmu_if.result_ff),
        .error         (bmu_if.error)

    );


    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    initial begin
        bmu_if.scan_mode = 1'b0;

        // Assert reset
        bmu_if.rst_l = 1'b0;

        // Keep reset active across clock edges
        repeat (2) @(posedge clk);

        // Deassert reset safely away from posedge
        @(negedge clk);
        bmu_if.rst_l = 1'b1;
    end


    initial begin

        uvm_config_db #(virtual bmu_interface.drv)::set(
            null,
            "uvm_test_top.*",
            "vif",
            bmu_if
        );

        uvm_config_db #(virtual bmu_interface.mon)::set(
            null,
            "uvm_test_top.*",
            "vif",
            bmu_if
        );

        run_test("bmu_day2_sanity_test");

    end


endmodule