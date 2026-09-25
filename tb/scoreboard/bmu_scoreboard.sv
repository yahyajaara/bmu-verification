class bmu_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(bmu_scoreboard)

    // Receives transactions from Monitor
    uvm_analysis_imp #(bmu_sequence_item, bmu_scoreboard) exp;


    // Queue for transactions received from Monitor
    bmu_sequence_item packetQueue[$];


    // Reference Model
    bmu_reference_model ref_model;


    // Expected outputs
    logic [31:0] expected_result;
    logic        expected_error;




    // Constructor
    function new(string name = "bmu_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction



    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Create analysis implementation
        exp = new("exp", this);

        // Create reference model
        ref_model = bmu_reference_model::type_id::create("ref_model");

    endfunction



    // write()
    // Only receive the transaction and store it in the queue
    function void write (bmu_sequence_item req);

        // Store transaction received from Monitor
        packetQueue.push_back(req);

        `uvm_info(
            get_type_name(),
            $sformatf(
                {
                    "Received packet: ",
                    "A=0x%08h ",
                    "B=0x%08h ",
                    "valid=%0b ",
                    "Result=0x%08h ",
                    "Error=%0b"
                },

                req.a_in,
                req.b_in,
                req.valid_in,
                req.result_ff,
                req.error
            ),
            UVM_HIGH
        )

    endfunction


    // Run Phase
    task run_phase(uvm_phase phase);

        bmu_sequence_item packet;

        forever begin

            wait(packetQueue.size() > 0);

            packet = packetQueue.pop_front();


            ref_model.predict(
                packet.a_in,
                packet.b_in,
                packet.ap,
                packet.csr_ren_in,
                packet.csr_rddata_in,

                expected_result,
                expected_error
            );


            // Compare DUT Actual Output vs Expected Output
            if ((packet.result_ff !== expected_result) || (packet.error !== expected_error)) begin

                // FAIL
                `uvm_error(
                    "SCOREBOARD_FAIL",
                    $sformatf(
                        {
                            "\n==========================================",
                            "\n  BMU FAIL",
                            "\n==========================================",
                            "\nA               = 0x%08h",
                            "\nB               = 0x%08h",
                            "\nValid           = %0b",
                            "\nAP ACTIVE       = %s",
                            "\nCSR_REN         = %0b",
                            "\nCSR_RDDATA      = 0x%08h",
                            "\n",
                            "\nActual Result   = 0x%08h",
                            "\nExpected Result = 0x%08h",
                            "\n",
                            "\nActual Error    = %0b",
                            "\nExpected Error  = %0b",
                            "\n",
                            "\nSimulation Time = %0t",
                            "\n==========================================\n"
                        },

                        packet.a_in,
                        packet.b_in,
                        packet.valid_in,
                        get_active_ap(packet.ap),
                        packet.csr_ren_in,
                        packet.csr_rddata_in,

                        packet.result_ff,
                        expected_result,

                        packet.error,
                        expected_error,

                        $time
                    )
                )

            end


            else begin

                // PASS
                `uvm_info(
                    "SCOREBOARD_PASS",
                    $sformatf(
                        {
                            "\n------------------------------------------",
                            "\n  BMU PASS",
                            "\n------------------------------------------",
                            "\nA               = 0x%08h",
                            "\nB               = 0x%08h",
                            "\nValid           = %0b",
                            "\nAP ACTIVE       = %s",
                            "\nCSR_REN         = %0b",
                            "\nCSR_RDDATA      = 0x%08h",
                            "\n",
                            "\nActual Result   = 0x%08h",
                            "\nExpected Result = 0x%08h",
                            "\n",
                            "\nActual Error    = %0b",
                            "\nExpected Error  = %0b",
                            "\n------------------------------------------\n"
                        },

                        packet.a_in,
                        packet.b_in,
                        packet.valid_in,
                        get_active_ap(packet.ap),
                        packet.csr_ren_in,
                        packet.csr_rddata_in,

                        packet.result_ff,
                        expected_result,

                        packet.error,
                        expected_error
                    ),
                    UVM_LOW
                )

            end


        end

    endtask




    // ***********************************************
    // Active AP
    // ***********************************************
    function string get_active_ap(rtl_alu_pkt_t ap);

        string active_ap;

        active_ap = "";


        // Logical operations
        if (ap.lor)       active_ap = {active_ap, "lor "};
        if (ap.lxor)      active_ap = {active_ap, "lxor "};
        if (ap.zbb)       active_ap = {active_ap, "zbb "};
        if (ap.land)      active_ap = {active_ap, "land "};


        // Shift / Mask operations
        if (ap.srl)       active_ap = {active_ap, "srl "};
        if (ap.sra)       active_ap = {active_ap, "sra "};
        if (ap.ror)       active_ap = {active_ap, "ror "};
        if (ap.binv)      active_ap = {active_ap, "binv "};

        if (ap.sh2add)    active_ap = {active_ap, "sh2add "};
        if (ap.zba)       active_ap = {active_ap, "zba "};


        // Arithmetic / Compare operations
        if (ap.sub)       active_ap = {active_ap, "sub "};
        if (ap.slt)       active_ap = {active_ap, "slt "};
        if (ap.unsign)    active_ap = {active_ap, "unsign "};


        // Bit manipulation operations
        if (ap.ctz)       active_ap = {active_ap, "ctz "};
        if (ap.cpop)      active_ap = {active_ap, "cpop "};
        if (ap.siext_b)   active_ap = {active_ap, "siext_b "};
        if (ap.max)       active_ap = {active_ap, "max "};
        if (ap.pack)      active_ap = {active_ap, "pack "};
        if (ap.grev)      active_ap = {active_ap, "grev "};


        // CSR Write
        if (ap.csr_write) active_ap = {active_ap, "csr_write "};
        if (ap.csr_imm)   active_ap = {active_ap, "csr_imm "};


        // No AP control active
        if (active_ap == "")
            active_ap = "NONE";

        return active_ap;

    endfunction


endclass