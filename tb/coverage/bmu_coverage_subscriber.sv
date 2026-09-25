class bmu_coverage_subscriber extends uvm_subscriber #(bmu_sequence_item);

    `uvm_component_utils(bmu_coverage_subscriber)

    bmu_sequence_item item;


    
    // ==================================================
    // Common input classification (OR + ORN + XOR + XNOR)
    // ==================================================

    function int get_input_class();

        if (item.a_in === 32'h0000_0000 &&
            item.b_in === 32'h0000_0000)
            return 0;

        if (item.a_in === 32'h0000_0000 &&
            item.b_in !== 32'h0000_0000)
            return 1;

        if (item.a_in !== 32'h0000_0000 &&
            item.b_in === 32'h0000_0000)
            return 2;

        if (item.a_in === 32'hFFFF_FFFF &&
            item.b_in === 32'hFFFF_FFFF)
            return 3;

        if (item.b_in === ~item.a_in)
            return 4;

        if (item.a_in === item.b_in)
            return 5;

        return 6;

    endfunction






    // ==================================================
    // OR legality
    // ==================================================

    function bit is_valid_or();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.lor = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction



    // OR Functional Coverage
    covergroup or_coverage;

        option.per_instance = 1;

        or_operand_class: coverpoint get_input_class()
            iff (is_valid_or())
        {

            bins both_zero      = {0};
            bins a_zero         = {1};
            bins b_zero         = {2};
            bins both_all_ones  = {3};
            bins complementary  = {4};
            bins equal_operands = {5};
            bins other          = {6};

        }


        or_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lxor === 1'b1)    ? 2 :
                                         0
        }

        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.lor === 1'b1
        )
        {

            bins csr_conflict = {1};
            bins xor_conflict = {2};

            ignore_bins valid_or = {0};

        }

    endgroup


    // ==================================================
    // END OR coverage
    // ==================================================





    // ==================================================
    // ORN legality
    // ==================================================

    function bit is_valid_orn();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.lor = 1'b1;
        expected_ap.zbb = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // ORN Functional Coverage
    covergroup orn_coverage;

        option.per_instance = 1;

        orn_operand_class: coverpoint get_input_class()
            iff (is_valid_orn())
        {

            bins both_zero      = {0};
            bins a_zero         = {1};
            bins b_zero         = {2};
            bins both_all_ones  = {3};
            bins complementary  = {4};
            bins equal_operands = {5};
            bins other          = {6};

        }


        orn_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.srl === 1'b1)     ? 2 :
                                         0
        }

        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.lor === 1'b1 &&
            item.ap.zbb === 1'b1
        )
        {

            bins csr_conflict = {1};
            bins srl_conflict = {2};

            ignore_bins valid_orn = {0};

        }

    endgroup


    // ==================================================
    // END ORN coverage
    // ==================================================





    // ==================================================
    // XOR legality
    // ==================================================

    function bit is_valid_xor();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.lxor = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // XOR Functional Coverage
    covergroup xor_coverage;

        option.per_instance = 1;

        xor_operand_class: coverpoint get_input_class()
            iff(is_valid_xor())
        {
            bins both_zero      = {0};
            bins a_zero         = {1};
            bins b_zero         = {2};
            bins both_all_ones  = {3};
            bins complementary  = {4};
            bins equal_operands = {5};
            bins other          = {6};
        }

        
        xor_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 : 
            (item.ap.srl === 1'b1)     ? 2 :
                                         0
        }
        iff(
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.lxor === 1'b1
        )

        {
            bins csr_conflict = {1};
            bins srl_conflict  = {2};

            ignore_bins valid_xor = {0};
        }

    endgroup

    // ==================================================
    // END XOR coverage
    // ==================================================





    // ==================================================
    // XNOR legality
    // ==================================================

    function bit is_valid_xnor();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.lxor = 1'b1;
        expected_ap.zbb = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // XNOR Functional Coverage
    covergroup xnor_coverage;

        option.per_instance = 1;

        xnor_operand_class: coverpoint get_input_class()
            iff(is_valid_xnor())
        {
            bins both_zero      = {0};
            bins a_zero         = {1};
            bins b_zero         = {2};
            bins both_all_ones  = {3};
            bins complementary  = {4};
            bins equal_operands = {5};
            bins other          = {6};
        }

        
        xnor_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 : 
            (item.ap.srl === 1'b1)     ? 2 :
                                         0
        }
        iff(
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.lxor === 1'b1  &&
            item.ap.zbb === 1'b1
        )

        {
            bins csr_conflict = {1};
            bins srl_conflict  = {2};

            ignore_bins valid_xnor = {0};
        }

    endgroup


    // ==================================================
    // END XNOR coverage
    // ==================================================





    // ==================================================
    // SRL legality
    // ==================================================

    function bit is_valid_srl();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.srl = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // SRL Functional Coverage
    covergroup srl_coverage;

        option.per_instance = 1;

        // Shift amount coverage
        srl_shift_amount: coverpoint item.b_in[4:0]
            iff (is_valid_srl())
        {
            bins zero          = {5'd0};
            bins interior_low  = {[5'd1 : 5'd15]};
            bins midpoint      = {5'd16};
            bins interior_high = {[5'd17 : 5'd30]};
            bins maximum       = {5'd31};
        }

        
        // Operand MSB coverage
        srl_operand_msb: coverpoint item.a_in[31]
            iff (is_valid_srl())
        {
            bins msb_clear = {1'b0};
            bins msb_set   = {1'b1};
        }

        
        // Shift amount × MSB
        srl_shift_msb_cross:
            cross srl_shift_amount, srl_operand_msb;

       
        // SRL error / conflict coverage
        srl_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lor === 1'b1)    ? 2 :
                                         0
        }
        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.srl === 1'b1
        )

        {
            bins csr_conflict  = {1};
            bins or_conflict = {2};
            ignore_bins valid_srl = {0};
        }

    endgroup


    // ==================================================
    // END SRL coverage
    // ==================================================





    // ==================================================
    // SRA legality
    // ==================================================

    function bit is_valid_sra();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.sra = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // SRA Functional Coverage
    covergroup sra_coverage;

        option.per_instance = 1;

        // Shift amount coverage
        sra_shift_amount: coverpoint item.b_in[4:0]
            iff (is_valid_sra())
        {
            bins zero          = {5'd0};
            bins interior_low  = {[5'd1 : 5'd15]};
            bins midpoint      = {5'd16};
            bins interior_high = {[5'd17 : 5'd30]};
            bins maximum       = {5'd31};
        }


        // Operand MSB coverage
        sra_operand_msb: coverpoint item.a_in[31]
            iff (is_valid_sra())
        {
            bins msb_clear = {1'b0};
            bins msb_set   = {1'b1};
        }


        // Shift amount × MSB
        sra_shift_msb_cross:
            cross sra_shift_amount, sra_operand_msb;

        
        // SRA error / conflict coverage
        sra_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lor === 1'b1)     ? 2 :
                                         0
        }
        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.sra === 1'b1
        )
        {
            bins csr_conflict = {1};
            bins or_conflict  = {2};
            ignore_bins valid_sra = {0};
        }

    endgroup


    // ==================================================
    // END SRA coverage
    // ==================================================





    // ==================================================
    // ROR legality
    // ==================================================

    function bit is_valid_ror();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.ror = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // ROR Functional Coverage
    covergroup ror_coverage;

        option.per_instance = 1;

        // Rotate amount
        ror_rotate_amount: coverpoint item.b_in[4:0]
            iff (is_valid_ror())
        {
            bins zero = {5'd0};

            bins interior_low = {[5'd1 : 5'd15]};

            bins midpoint = {5'd16};

            bins interior_high = {[5'd17 : 5'd30]};

            bins maximum = {5'd31};
        }


       
        // CSR / AP error conditions
        
        ror_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lor === 1'b1)     ? 2 : 0
        }
        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.ror === 1'b1
        )
        {
            bins csr_conflict = {1};

            bins or_conflict = {2};

            ignore_bins valid_ror = {0};
        }

    endgroup

    // ==================================================
    // END ROR coverage
    // ==================================================





    // ==================================================
    // BINV legality
    // ==================================================

    function bit is_valid_binv();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.binv = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // BINV Functional Coverage
    covergroup binv_coverage;

        option.per_instance = 1;

        // Bit index coverage
        binv_bit_index: coverpoint item.b_in[4:0]
            iff (is_valid_binv())
        {
            bins zero = {5'd0};

            bins interior_low = {[5'd1 : 5'd15]};

            bins midpoint = {5'd16};

            bins interior_high = {[5'd17 : 5'd30]};

            bins maximum = {5'd31};
        }


        // Selected bit coverage
        binv_selected_bit: coverpoint item.a_in[item.b_in[4:0]]
            iff (is_valid_binv())
        {
            bins bit_clear = {1'b0};
            bins bit_set   = {1'b1};
        }


        // Bit index × selected bit
        binv_index_bit_cross:
            cross binv_bit_index, binv_selected_bit;


       
        // CSR / AP error conditions
        binv_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lor === 1'b1)     ? 2 : 0
        }
        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.binv === 1'b1
        )
        {
            bins csr_conflict = {1};

            bins or_conflict = {2};

            ignore_bins valid_binv = {0};
        }

    endgroup


    // ==================================================
    // END BINV coverage
    // ==================================================





    // ==================================================
    // SH2ADD legality
    // ==================================================
    function bit is_valid_sh2add();
        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.sh2add = 1'b1;
        expected_ap.zba    = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );
    endfunction


    // SH2ADD Functional Coverage
    covergroup sh2add_coverage;

        option.per_instance = 1;


        // A operand class
        sh2add_a_class: coverpoint {
            (item.a_in === 32'h0000_0000) ? 1 :
            (item.a_in === 32'hFFFF_FFFF) ? 2 : 0
        }
        iff (is_valid_sh2add())
        {
            bins a_zero     = {1};
            bins a_all_ones = {2};
            bins a_other    = {0};
        }


        // B operand class
        sh2add_b_class: coverpoint {
            (item.b_in === 32'h0000_0000) ? 1 :
            (item.b_in === 32'hFFFF_FFFF) ? 2 : 0
        }
        iff (is_valid_sh2add())
        {
            bins b_zero     = {1};
            bins b_all_ones = {2};
            bins b_other    = {0};
        }


        // There is no "cross" operation, 
        //because the result does not depend 
        //on the relationship between A and B


        // Wraparound condition
        sh2add_wraparound: coverpoint {
            (
                item.a_in === 32'h4000_0000 &&
                item.b_in === 32'h0000_0001
            ) ? 1 : 0
        }
        iff (is_valid_sh2add())
        {
            bins normal      = {0};
            bins wraparound  = {1};
        }


        // CSR / AP error conditions
        sh2add_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lor === 1'b1)     ? 2 : 
            (item.ap.zba === 1'b0)     ? 3 :0
        }
        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.sh2add === 1'b1
        )
        {
            bins csr_conflict = {1};
            bins or_conflict  = {2};
             bins zba_missing   = {3};

            ignore_bins valid_sh2add = {0};
        }



    endgroup

    // ==================================================
    // END SH2ADD coverage
    // ==================================================






    // ==================================================
    // SUB legality
    // ==================================================

    function bit is_valid_sub();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.sub = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // SUB Functional Coverage
    covergroup sub_coverage;

        option.per_instance = 1;

        // A/B relationship
        sub_operand_relationship: coverpoint {

            (item.a_in === item.b_in) ? 1 :
            ($signed(item.a_in) > $signed(item.b_in)) ? 2 :
            3
        }

        iff (is_valid_sub())
        {
            bins equal_operands = {1};
            bins a_greater_b    = {2};
            bins a_less_b       = {3};
        }


        sub_relationship_sign_cross:
            cross sub_operand_relationship, sub_sign_relationship
            {
                ignore_bins equal_pos_neg =
                    binsof(sub_operand_relationship.equal_operands) &&
                    binsof(sub_sign_relationship.positive_negative);

                ignore_bins equal_neg_pos =
                    binsof(sub_operand_relationship.equal_operands) &&
                    binsof(sub_sign_relationship.negative_positive);

                ignore_bins greater_neg_pos =
                    binsof(sub_operand_relationship.a_greater_b) &&
                    binsof(sub_sign_relationship.negative_positive);

                ignore_bins less_pos_neg =
                    binsof(sub_operand_relationship.a_less_b) &&
                    binsof(sub_sign_relationship.positive_negative);
            }



        // Signed relationship between A and B
        sub_sign_relationship: coverpoint {

            ($signed(item.a_in) >= 0 &&
            $signed(item.b_in) >= 0) ? 1 :

            ($signed(item.a_in) < 0 &&
            $signed(item.b_in) < 0) ? 2 :

            ($signed(item.a_in) >= 0 &&
            $signed(item.b_in) < 0) ? 3 :
            4
        }

        iff (is_valid_sub())
        {
            bins both_positive  = {1};
            bins both_negative  = {2};
            bins positive_negative = {3};
            bins negative_positive = {4};
        }


        // Special operand values
        sub_special_values: coverpoint {

            (item.a_in === 32'h0000_0000) ? 1 :

            (item.b_in === 32'h0000_0000) ? 2 :

            (item.a_in === 32'h7FFF_FFFF) ? 3 :

            (item.a_in === 32'h8000_0000) ? 4 :

            (item.a_in === 32'hFFFF_FFFF) ? 5 :

            0

        }
        
        iff (is_valid_sub())
        {
            bins a_zero      = {1};
            bins b_zero      = {2};
            bins signed_max  = {3};
            bins signed_min  = {4};
            bins all_ones    = {5};

            bins other       = {0};
        }




        // SUB error / conflict coverage
        sub_error_class: coverpoint {

            (item.csr_ren_in === 1'b1) ? 1 :

            (item.ap.zba === 1'b1) ? 2 :

            (item.ap.lor === 1'b1) ? 3 :

            0

        }

        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.sub === 1'b1
        )

        {
            bins csr_conflict = {1};
            bins zba_conflict = {2};
            bins ap_conflict  = {3};

            ignore_bins valid_sub = {0};
        }


    endgroup

    // ==================================================
    // END SUB coverage
    // ==================================================






    // ==================================================
    // SLT legality
    // ==================================================
    function bit is_valid_slt();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.slt    = 1'b1;
        expected_ap.sub    = 1'b1;
        expected_ap.unsign = 1'b0;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in === 1'b1 &&
            item.ap === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // SLT Functional Coverage
    covergroup slt_coverage;

        option.per_instance = 1;

        // A/B Relationship
        slt_operand_relationship: coverpoint {

            (item.a_in === item.b_in) ? 1 :
            ($signed(item.a_in) > $signed(item.b_in)) ? 2 :
            3
        }

        iff (is_valid_slt())
        {
            bins equal_operands = {1};
            bins a_greater_b    = {2};
            bins a_less_b       = {3};
        }



        // Sign Relationship
        slt_sign_relationship: coverpoint {

            ($signed(item.a_in) >= 0 &&
            $signed(item.b_in) >= 0) ? 1 :

            ($signed(item.a_in) < 0 &&
            $signed(item.b_in) < 0) ? 2 :

            ($signed(item.a_in) >= 0 &&
            $signed(item.b_in) < 0) ? 3 :
            4
        }

        iff (is_valid_slt())
        {
            bins both_positive  = {1};
            bins both_negative  = {2};
            bins positive_negative = {3};
            bins negative_positive = {4};
        }


        // Special operand values
        slt_special_values: coverpoint {
            (item.a_in === 32'h0000_0000) ? 1 :
            (item.b_in === 32'h0000_0000) ? 2 :
            (item.a_in === 32'h7FFF_FFFF) ? 3 :
            (item.b_in === 32'h7FFF_FFFF) ? 4 :
            (item.a_in === 32'h8000_0000) ? 5 :
            (item.b_in === 32'h8000_0000) ? 6 :
            0
        }

        iff (is_valid_slt())
        {
            bins a_zero       = {1};
            bins b_zero       = {2};
            bins a_signed_max = {3};
            bins b_signed_max = {4};
            bins a_signed_min = {5};
            bins b_signed_min = {6};
            bins other        = {0};
        }


        slt_relationship_sign_cross:
            cross slt_operand_relationship, slt_sign_relationship
            {
                ignore_bins equal_pos_neg =
                    binsof(slt_operand_relationship.equal_operands) &&
                    binsof(slt_sign_relationship.positive_negative);

                ignore_bins equal_neg_pos =
                    binsof(slt_operand_relationship.equal_operands) &&
                    binsof(slt_sign_relationship.negative_positive);

                ignore_bins greater_neg_pos =
                    binsof(slt_operand_relationship.a_greater_b) &&
                    binsof(slt_sign_relationship.negative_positive);

                ignore_bins less_pos_neg =
                    binsof(slt_operand_relationship.a_less_b) &&
                    binsof(slt_sign_relationship.positive_negative);
            }


        // SLT error / conflict coverage
        slt_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lor === 1'b1)     ? 2 :
            0
        }

        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.slt === 1'b1
        )
        {
            bins csr_conflict = {1};
            bins ap_conflict  = {2};

            ignore_bins valid_slt = {0};
        }

    endgroup

    // ==================================================
    // END SLT coverage
    // ==================================================





    // ==================================================
    // SLTU legality
    // ==================================================

    function bit is_valid_sltu();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;

        expected_ap.slt    = 1'b1;
        expected_ap.sub    = 1'b1;
        expected_ap.unsign = 1'b1;

        if (item == null)
            return 1'b0;

        return (item.valid_in    === 1'b1)        &&
               (item.ap          === expected_ap) &&
               (item.csr_ren_in  === 1'b0);

    endfunction



    // SLTU Functional Coverage
    covergroup sltu_coverage;

        option.per_instance = 1;

        // Unsigned operand relationship
        sltu_operand_relationship: coverpoint {

            (item.a_in === item.b_in) ? 1 :
            ($unsigned(item.a_in) > $unsigned(item.b_in)) ? 2 :
                                                            3
        }

        iff (is_valid_sltu())
        {
            bins equal_operands = {1};
            bins a_greater_b    = {2};
            bins a_less_b       = {3};
        }


        // Special unsigned values
        sltu_special_values : coverpoint {

            (item.a_in === 32'h0000_0000) ? 1 :
            (item.b_in === 32'h0000_0000) ? 2 :

            (item.a_in === 32'hFFFF_FFFF) ? 3 :
            (item.b_in === 32'hFFFF_FFFF) ? 4 :

            (item.a_in === 32'h8000_0000) ? 5 :
            (item.b_in === 32'h8000_0000) ? 6 :

            (item.a_in === 32'h7FFF_FFFF) ? 7 :
            (item.b_in === 32'h7FFF_FFFF) ? 8 :

            0
        } 
        
        iff (is_valid_sltu())
        {
            bins a_zero             = {1};
            bins b_zero             = {2};

            bins a_unsigned_max     = {3};
            bins b_unsigned_max     = {4};

            bins a_msb_set          = {5};
            bins b_msb_set          = {6};

            bins a_signed_max       = {7};
            bins b_signed_max       = {8};

            bins other              = {0};
        }


        sltu_relationship_special_cross:
            cross sltu_operand_relationship, sltu_special_values;



        // SLTU error classification
        sltu_error_class : coverpoint {

            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lor     === 1'b1) ? 2 :
                                         0

        } iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.slt   === 1'b1
        )
        {
            bins csr_conflict = {1};
            bins ap_conflict  = {2};

            ignore_bins valid_sltu = {0};
        }

    endgroup


    // ==================================================
    // END SLTU coverage
    // ==================================================





    // ==================================================
    // CTZ legality
    // ==================================================

    function bit is_valid_ctz();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.ctz = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // CTZ Functional Coverage
    covergroup ctz_coverage;

        option.per_instance = 1;

        // CTZ count / trailing-zero position
        ctz_count: coverpoint {

            
            (item.a_in === 32'h0000_0000) ? 0 :

            (item.a_in[0] === 1'b1) ? 1 :

            (item.a_in[7:1] !== 7'h00) ? 2 :

            (item.a_in[23:8] !== 16'h0000) ? 3 :

            (item.a_in[30:24] !== 7'h00) ? 4 :

            (item.a_in[31] === 1'b1) ? 5 :

            0
        }

        iff (is_valid_ctz())
        {
            bins all_zero     = {0};
            bins zero_count   = {1};
            bins low_count    = {2};
            bins middle_count = {3};
            bins high_count   = {4};
            bins maximum_count = {5};
        }


        // Special operand values
        ctz_special_values: coverpoint {

            (item.a_in === 32'h0000_0000) ? 1 :

            (item.a_in === 32'hFFFF_FFFF) ? 2 :

            (item.a_in === 32'h0000_0001) ? 3 :

            (item.a_in === 32'h8000_0000) ? 4 :

            0
        }

        iff (is_valid_ctz())
        {
            bins all_zero  = {1};

            bins all_ones  = {2};

            bins lsb_set   = {3};

            bins msb_set   = {4};

            bins other     = {0};
        }


        // CTZ error / conflict coverage
        ctz_error_class: coverpoint {

            (item.csr_ren_in === 1'b1) ? 1 :

            (item.ap.lor === 1'b1) ? 2 :

            0
        }

        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.ctz === 1'b1
        )
        {
            bins csr_conflict = {1};

            bins ap_conflict = {2};

            ignore_bins valid_ctz = {0};
        }


    endgroup

    // ==================================================
    // END CTZ coverage
    // ==================================================





    // ==================================================
    // CPOP Coverage
    // ==================================================

    function bit is_valid_cpop();
        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.cpop = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in    === 1'b1 &&
            item.ap          === expected_ap &&
            item.csr_ren_in  === 1'b0
        );
    endfunction


    covergroup cpop_coverage;

        option.per_instance = 1;

        // Classifies A according to the number of set bits.
        cpop_count: coverpoint {
            ($countones(item.a_in) == 0)                  ? 0 :
            ($countones(item.a_in) inside {[1:15]})       ? 1 :
            ($countones(item.a_in) == 16)                 ? 2 :
            ($countones(item.a_in) inside {[17:31]})      ? 3 :
            ($countones(item.a_in) == 32)                 ? 4 :
            0
        } 

        iff (is_valid_cpop())
        {
            bins zero_bits    = {0};
            bins lower_count  = {1};
            bins half_set     = {2};
            bins upper_count  = {3};
            bins all_bits_set = {4};

        }



        // CPOP special input patterns
        cpop_special_values: coverpoint {
            (item.a_in === 32'h0000_0000) ? 1 :
            (item.a_in === 32'hFFFF_FFFF) ? 2 :
            (item.a_in === 32'hAAAA_AAAA) ? 3 :
            (item.a_in === 32'h5555_5555) ? 4 :
            0
        } 
        
        iff (is_valid_cpop())
        {
            bins all_zero       = {1};
            bins all_ones       = {2};
            bins alternating_a  = {3};
            bins alternating_5  = {4};
            bins other          = {0};
        }



        // CPOP error classification
        cpop_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lor === 1'b1)     ? 2 :
            0
        }
        
        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.cpop === 1'b1
        )

        {
            bins csr_conflict = {1};
            bins ap_conflict  = {2};

            ignore_bins valid_cpop = {0};

        }
        
    endgroup

    // ==================================================
    // END CPOP Coverage
    // ==================================================





    // ==================================================
    // SEXT.B Coverage
    // ==================================================

    function bit is_valid_sext_b();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.siext_b = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in    === 1'b1 &&
            item.ap          === expected_ap &&
            item.csr_ren_in  === 1'b0
        );

    endfunction


    // SEXT.B Functional Coverage
    covergroup sext_b_coverage;

        option.per_instance = 1;


        // Lower byte classification
        sext_b_lower_byte: coverpoint {

            (item.a_in[7:0] === 8'h00) ? 1 :

            (item.a_in[7:0] inside {[8'h01 : 8'h7F]}) ? 2 :

            (item.a_in[7:0] === 8'h80) ? 3 :

            (item.a_in[7:0] inside {[8'h81 : 8'hFE]}) ? 4 :

            (item.a_in[7:0] === 8'hFF) ? 5 :

            0

        }

        iff (is_valid_sext_b())
        {

            bins byte_zero        = {1};
            bins positive_range   = {2};
            bins byte_signed_min  = {3};
            bins negative_range   = {4};
            bins byte_all_ones    = {5};

        }



        // Sign bit coverage
        sext_b_sign_bit: coverpoint item.a_in[7]
        iff (is_valid_sext_b())
        {
            bins positive_sign = {1'b0};
            bins negative_sign = {1'b1};
        }


        sext_b_byte_sign_cross:
            cross sext_b_lower_byte, sext_b_sign_bit;



        // Upper 24-bit classification
        sext_b_upper_bits: coverpoint {

            (item.a_in[31:8] === 24'h000000) ? 1 :

            (item.a_in[31:8] === 24'hFFFFFF) ? 2 :

            0

        }

        iff (is_valid_sext_b())
        {
            bins upper_zero     = {1};
            bins upper_all_ones = {2};

            bins upper_other = default;
        }



        // CSR / AP error conditions
        sext_b_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lor === 1'b1)    ? 2 :
            0
        }

        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.siext_b === 1'b1
        )
        {

            bins csr_conflict = {1};
            bins ap_conflict  = {2};

            ignore_bins valid_sext_b = {0};

        }

    
    endgroup

    // ==================================================
    // END SEXT.B Coverage
    // ==================================================





    // ==================================================
    // MAX legality
    // ==================================================

    function bit is_valid_max();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.max = 1'b1;
        expected_ap.sub = 1'b1;
        expected_ap.unsign = 1'b0;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // MAX Functional Coverage
    covergroup max_coverage;

        option.per_instance = 1;


        // Operand relationship
    max_operand_relationship: coverpoint {

        (item.a_in === item.b_in)                 ? 1 :
        ($signed(item.a_in) > $signed(item.b_in)) ? 2 :
                                                    3

    }

    iff (is_valid_max())
    {
        bins equal_operands = {1};
        bins a_greater_b    = {2};
        bins a_less_b       = {3};
    }



    // Sign relationship
    max_sign_relationship: coverpoint {

            ($signed(item.a_in) >= 0 &&
            $signed(item.b_in) >= 0)       ? 1 :

            ($signed(item.a_in) < 0 &&
            $signed(item.b_in) < 0)        ? 2 :

            ($signed(item.a_in) >= 0 &&
            $signed(item.b_in) < 0)        ? 3 :
            4
        }

        iff (is_valid_max())
        {
            bins both_positive  = {1};
            bins both_negative  = {2};
            bins positive_negative = {3};
            bins negative_positive = {4};
        }



        max_relationship_sign_cross:
            cross max_operand_relationship, max_sign_relationship
            {
                ignore_bins equal_pos_neg =
                    binsof(max_operand_relationship.equal_operands) &&
                    binsof(max_sign_relationship.positive_negative);

                ignore_bins equal_neg_pos =
                    binsof(max_operand_relationship.equal_operands) &&
                    binsof(max_sign_relationship.negative_positive);

                ignore_bins greater_neg_pos =
                    binsof(max_operand_relationship.a_greater_b) &&
                    binsof(max_sign_relationship.negative_positive);

                ignore_bins less_pos_neg =
                    binsof(max_operand_relationship.a_less_b) &&
                    binsof(max_sign_relationship.positive_negative);
            }



        // Special operand values
        max_special_values: coverpoint {
        (item.a_in === 32'h0000_0000) ? 1 :
        (item.b_in === 32'h0000_0000) ? 2 :
        (item.a_in === 32'h7FFF_FFFF) ? 3 :
        (item.b_in === 32'h7FFF_FFFF) ? 4 :
        (item.a_in === 32'h8000_0000) ? 5 :
        (item.b_in === 32'h8000_0000) ? 6 :
        (item.a_in === 32'hFFFF_FFFF) ? 7 :
        (item.b_in === 32'hFFFF_FFFF) ? 8 :
        0
    }

    iff (is_valid_max())
    {
        bins a_zero       = {1};
        bins b_zero       = {2};

        bins a_signed_max = {3};
        bins b_signed_max = {4};

        bins a_signed_min = {5};
        bins b_signed_min = {6};

        bins a_all_ones   = {7};
        bins b_all_ones   = {8};

        bins other        = {0};
    }



    // MAX error conditions
    max_error_class: coverpoint {
        (item.csr_ren_in === 1'b1) ? 1 :
        (item.ap.lor === 1'b1)     ? 2 :
        (item.ap.sub === 1'b0)     ? 3 :
        0
    }

    iff (
        item != null &&
        item.valid_in === 1'b1 &&
        item.ap.max === 1'b1
    )
    {
        bins csr_conflict   = {1};
        bins ap_conflict    = {2};
        bins missing_sub    = {3};

        ignore_bins valid_max = {0};
    }

    endgroup

    // ==================================================
    // END MAX coverage
    // ==================================================





    // ==================================================
    // pack legality
    // ==================================================

    function bit is_valid_pack();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.pack = 1'b1;
        

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction


    // PACK Functional Coverage
    covergroup pack_coverage;

        option.per_instance = 1;

        // A lower-half classification
        pack_a_class: coverpoint {
            (item.a_in[15:0] === 16'h0000) ? 1 :
            (item.a_in[15:0] === 16'hFFFF) ? 2 :
            0
        }

        iff (is_valid_pack())
        {
            bins a_lower_zero     = {1};
            bins a_lower_all_ones = {2};
            bins a_lower_other    = {0};
        }


        // B lower-half classification
        pack_b_class: coverpoint {
            (item.b_in[15:0] === 16'h0000) ? 1 :
            (item.b_in[15:0] === 16'hFFFF) ? 2 :
            0
        }

        iff (is_valid_pack())
        {
            bins b_lower_zero     = {1};
            bins b_lower_all_ones = {2};
            bins b_lower_other    = {0};
        }


        pack_lower_halves_cross:
            cross pack_a_class, pack_b_class;


        // Upper bits classification
        pack_upper_bits: coverpoint {

            (item.a_in[31:16] === 16'h0000 &&
            item.b_in[31:16] === 16'h0000) ? 1 :

            (item.a_in[31:16] === 16'hFFFF &&
            item.b_in[31:16] === 16'hFFFF) ? 2 :

            0
        }

        iff (is_valid_pack())
        {
            bins both_upper_zero = {1};
            bins both_upper_ones = {2};

            ignore_bins other_upper_values = {0};
        }



        // PACK error conditions
        pack_error_class: coverpoint {
            (item.csr_ren_in === 1'b1) ? 1 :
            (item.ap.lor === 1'b1)     ? 2 :
            0
        }

        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.pack === 1'b1
        )
        {
            bins csr_conflict = {1};
            bins ap_conflict  = {2};

            ignore_bins valid_pack = {0};
        }


    endgroup


    // ==================================================
    // END pack coverage
    // ==================================================





    // ==================================================
    // GREV legality
    // ==================================================

    function bit is_valid_grev();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;
        expected_ap.grev = 1'b1;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.ap         === expected_ap &&
            item.csr_ren_in === 1'b0
        );

    endfunction



    // GREV Functional Coverage
    covergroup grev_coverage;

        option.per_instance = 1;


        // GREV mode and upper B bits
        grev_mode_bits: coverpoint {

            (item.b_in[4:0] === 5'd24 &&
            item.b_in[31:5] === 27'h000_0000) ? 1 :

            (item.b_in[4:0] === 5'd24 &&
            item.b_in[31:5] !== 27'h000_0000) ? 2 :

            0
        }

        iff (is_valid_grev())
        {
            bins mode_24_upper_zero    = {1};
            bins mode_24_upper_nonzero = {2};

            ignore_bins other = {0};
        }


        // GREV error conditions
        grev_error_class: coverpoint {

            (item.csr_ren_in === 1'b1) ? 1 :

            (item.b_in[4:0] !== 5'd24) ? 2 :

            (item.ap.lor === 1'b1) ? 3 :

            0
        }

        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.grev === 1'b1
        )

        {
            bins csr_conflict = {1};
            bins invalid_mode = {2};
            bins ap_conflict  = {3};

            ignore_bins valid_grev = {0};
        }

    endgroup


    // ==================================================
    // END GREV coverage
    // ==================================================





    // ==================================================
    // CSR READ COVERAGE
    // ==================================================

    function bit is_valid_csr_read();

        rtl_alu_pkt_t expected_ap;

        expected_ap = '0;

        if (item == null)
            return 1'b0;

        return (
            item.valid_in    === 1'b1 &&
            item.ap          === expected_ap &&
            item.csr_ren_in  === 1'b1
        );

    endfunction


    // CSR READ Functional Coverage
    covergroup csr_read_coverage;

        option.per_instance = 1;

        // CSR read data classification
        csr_read_data_class: coverpoint {

            (item.csr_rddata_in === 32'h0000_0000) ? 1 :
            (item.csr_rddata_in === 32'hFFFF_FFFF) ? 2 :
            (item.csr_rddata_in === 32'hA5A5_5A5A) ? 3 :
            4

        }

        iff (is_valid_csr_read())

        {
            bins zero      = {1};
            bins all_ones  = {2};
            bins pattern   = {3};
            bins other     = {4};
        }


        // CSR Read error / conflict coverage
        csr_read_error_class: coverpoint {

            (item.ap.lor === 1'b1)       ? 1 :
            (item.ap.sub === 1'b1)       ? 2 :
            (item.ap.csr_write === 1'b1) ? 3 :
            0

        }

        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.csr_ren_in === 1'b1
        )

        {
            bins or_conflict        = {1};
            bins sub_conflict       = {2};
            bins csr_write_conflict = {3};

            ignore_bins valid_csr_read = {0};
        }

    endgroup

    // ==================================================
    // END CSR READ COVERAGE
    // ==================================================





    // ==================================================
    // CSR WRITE legality
    // ==================================================

    function bit is_valid_csr_write();

        if (item == null)
            return 1'b0;

        return (
            item.valid_in   === 1'b1 &&
            item.csr_ren_in === 1'b0 &&
            item.ap.csr_write === 1'b1 &&
            $countones(item.ap) == (item.ap.csr_imm ? 2 : 1)
        );

    endfunction



    // CSR WRITE Functional Coverage
    covergroup csr_write_coverage;

        option.per_instance = 1;


        // CSR write source selection
        csr_write_source: coverpoint item.ap.csr_imm
            iff (is_valid_csr_write())

        {
            bins a_source = {1'b0};
            bins b_source = {1'b1};
        }


        // Selected source data
        csr_write_data_class: coverpoint {

            item.ap.csr_imm
                ? (
                    (item.b_in === 32'h0000_0000) ? 1 :
                    (item.b_in === 32'hFFFF_FFFF) ? 2 :
                    3
                )
                :
                (
                    (item.a_in === 32'h0000_0000) ? 1 :
                    (item.a_in === 32'hFFFF_FFFF) ? 2 :
                    3
                )

        }

        iff (is_valid_csr_write())

        {
            bins zero     = {1};
            bins all_ones = {2};
            bins other    = {3};
        }


        // CSR Write error / conflict coverage
        csr_write_error_class: coverpoint {

            (item.csr_ren_in === 1'b1) ? 1 :
            0

        }
        iff (
            item != null &&
            item.valid_in === 1'b1 &&
            item.ap.csr_write === 1'b1
        )
        {
            bins csr_read_conflict = {1};

            ignore_bins valid_csr_write = {0};
        }

    endgroup


    // ==================================================
    // END CSR WRITE COVERAGE
    // ==================================================






    function new(string name = "bmu_coverage_subscriber",uvm_component parent = null);

        super.new(name, parent);

        or_coverage         = new();
        orn_coverage        = new();
        xor_coverage        = new();
        xnor_coverage       = new();
        srl_coverage        = new();
        sra_coverage        = new();
        ror_coverage        = new();
        binv_coverage       = new();
        sh2add_coverage     = new();
        sub_coverage        = new();
        slt_coverage        = new();
        sltu_coverage       = new();
        ctz_coverage        = new();
        cpop_coverage       = new();
        sext_b_coverage     = new();
        max_coverage        = new();
        pack_coverage       = new();
        grev_coverage       = new();
        csr_read_coverage   = new();
        csr_write_coverage  = new();

    endfunction


    virtual function void write(bmu_sequence_item t);

        item = t;

        or_coverage.sample();
        orn_coverage.sample();
        xor_coverage.sample();
        xnor_coverage.sample();
        srl_coverage.sample();
        sra_coverage.sample();
        ror_coverage.sample();
        binv_coverage.sample();
        sh2add_coverage.sample();
        sub_coverage.sample();
        slt_coverage.sample();
        sltu_coverage.sample();
        ctz_coverage.sample();
        cpop_coverage.sample();
        sext_b_coverage.sample();
        max_coverage.sample();
        pack_coverage.sample();
        grev_coverage.sample();
        csr_read_coverage.sample();
        csr_write_coverage.sample();

    endfunction




    virtual function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info("BMU_COVERAGE",
            $sformatf("OR     Coverage = %0.2f%%",
                    or_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("ORN    Coverage = %0.2f%%",
                    orn_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("XOR    Coverage = %0.2f%%",
                    xor_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("XNOR   Coverage = %0.2f%%",
                    xnor_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("SRL    Coverage = %0.2f%%",
                    srl_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("SRA    Coverage = %0.2f%%",
                    sra_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("ROR    Coverage = %0.2f%%",
                    ror_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("BINV   Coverage = %0.2f%%",
                    binv_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("SH2ADD Coverage = %0.2f%%",
                    sh2add_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("SUB    Coverage = %0.2f%%",
                    sub_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("SLT    Coverage = %0.2f%%",
                    slt_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("SLTU   Coverage = %0.2f%%",
                    sltu_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("CTZ    Coverage = %0.2f%%",
                    ctz_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("CPOP   Coverage = %0.2f%%",
                    cpop_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("SEXT.B Coverage = %0.2f%%",
                    sext_b_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("MAX    Coverage = %0.2f%%",
                    max_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("PACK   Coverage = %0.2f%%",
                    pack_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("GREV   Coverage = %0.2f%%",
                    grev_coverage.get_inst_coverage()),
            UVM_NONE)
        
        `uvm_info("BMU_COVERAGE",
            $sformatf("CSR READ  Coverage = %0.2f%%",
                    csr_read_coverage.get_inst_coverage()),
            UVM_NONE)

        `uvm_info("BMU_COVERAGE",
            $sformatf("CSR WRITE Coverage = %0.2f%%",
                    csr_write_coverage.get_inst_coverage()),
            UVM_NONE)

    endfunction : report_phase


endclass