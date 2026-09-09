interface bmu_interface(input logic clk);

    import rtl_pkg::*;


    logic                rst_l;          // Reset
    logic                scan_mode;      // Scan control
    logic                valid_in;       // Valid

    rtl_alu_pkt_t        ap;             // predecodes

    logic                csr_ren_in;     // CSR select
    logic         [31:0] csr_rddata_in;  // CSR data
    
    logic signed  [31:0] a_in;           // A operand
    logic         [31:0] b_in;           // B operand

    logic         [31:0] result_ff;      // final result
    logic                error;



    clocking cb_drv @(negedge clk);

        default input #1step output #0;

        output valid_in;
        output ap;
        output csr_ren_in;
        output csr_rddata_in;
        output a_in;
        output b_in;

    endclocking


    clocking cb_mon @(posedge clk);

        default input #0;

        input rst_l;
        input valid_in;
        input ap;
        input csr_ren_in;
        input csr_rddata_in;
        input a_in;
        input b_in;

        input result_ff;
        input error;

    endclocking



    modport drv(
        clocking cb_drv,
        input clk
    );

    modport mon(
        clocking cb_mon,
        input clk
    );


endinterface : bmu_interface