class bmu_reference_model extends uvm_object;

    `uvm_object_utils(bmu_reference_model)

    function new(string name = "bmu_reference_model");
        super.new(name);
    endfunction


    function void predict(
        input  logic [31:0]       a_in,
        input  logic [31:0]       b_in,
        input  rtl_alu_pkt_t      ap,
        input  logic              csr_ren_in,
        input  logic [31:0]       csr_rddata_in,
        output logic [31:0]       expected_result,
        output logic              expected_error
    );

        // Default expected values
        expected_result = 32'b0;
        expected_error  = 1'b0;



        // Operation logic will be added here

        //******************************************************
        // 1. CSR READ
        if (csr_ren_in && (ap == '0)) begin
            expected_result = csr_rddata_in;
            expected_error  = 1'b0;
        end
        //******************************************************



        //************************************************************************
        // 2. OR  (ap.lor = 1  ap.zbb = 0)
        else if (ap.lor && !ap.zbb && !csr_ren_in &&($countones(ap) == 1)) begin
            expected_result = a_in | b_in;
            expected_error  = 1'b0;
        end
        // $countones() is a SystemVerilog system function 
        //that counts how many bits are 1.
        //************************************************************************



        //************************************************************************
        // 3. ORN (ap.lor = 1  ap.zbb = 1)
        else if (ap.lor && ap.zbb && !csr_ren_in &&($countones(ap) == 2)) begin
            expected_result = a_in | ~b_in;
            expected_error  = 1'b0;
        end
        //************************************************************************



        //**********************************************************************
        // 4. XOR (ap.lxor = 1  ap.zbb = 0)
        else if (ap.lxor && !ap.zbb && !csr_ren_in && ($countones(ap) == 1)) begin
            expected_result = a_in ^ b_in;
            expected_error  = 1'b0;
        end
        //**********************************************************************



        //**********************************************************************
        // 5. XNOR (ap.lxor = 1  ap.zbb = 1)
        else if (ap.lxor && ap.zbb && !csr_ren_in && ($countones(ap) == 2)) begin
            expected_result = a_in ^ ~b_in;
            expected_error  = 1'b0;
        end
        //**********************************************************************



        //**********************************************************************
        // 6. SRL - Shift Right Logical
        // ap.srl = 1
        // Shift amount = b_in[4:0]
        else if (ap.srl && !csr_ren_in && ($countones(ap) == 1)) begin
            expected_result = a_in >> b_in[4:0];
            expected_error  = 1'b0;
        end
        //**********************************************************************



        //**********************************************************************
        // 7. SRA - Shift Right Arithmetic
        // ap.sra = 1
        // Signed operation
        // Shift amount = b_in[4:0]
        else if (ap.sra && !csr_ren_in && ($countones(ap) == 1)) begin
            expected_result = $signed(a_in) >>> b_in[4:0];
            expected_error  = 1'b0;
        end
        //**********************************************************************



        //**********************************************************************
        // 8. ROR - Rotate Right
        // ap.ror = 1
        // Rotate amount = b_in[4:0]
        else if (ap.ror && !csr_ren_in && ($countones(ap) == 1)) begin

            if (b_in[4:0] == 0)
                expected_result = a_in;
                
            else
                expected_result = (a_in >> b_in[4:0]) | (a_in << (32 - b_in[4:0]));

            expected_error = 1'b0;

        end
        //**********************************************************************



        //**********************************************************************
        // 9. BINV - Bit Invert
        // ap.binv = 1
        // Bit index = b_in[4:0]
        else if (ap.binv && !csr_ren_in && ($countones(ap) == 1)) begin
            expected_result =a_in ^ (32'b1 << b_in[4:0]);
            expected_error = 1'b0;
        end
        //**********************************************************************



        //************************************************************************
        // 10. SH2ADD - Shift Left by 2 and Add
        // ap.sh2add = 1
        // ap.zba    = 1
        // Result = (a_in << 2) + b_in
        else if (ap.sh2add && ap.zba && !csr_ren_in &&
                 ($countones(ap) == 2)) begin

            expected_result = (a_in << 2) + b_in;
            expected_error  = 1'b0;

        end
        //************************************************************************



        //************************************************************************
        // 11. SUB - Subtraction
        // ap.sub = 1
        // ap.zba = 0
        // Result = a_in - b_in
        else if (ap.sub && !csr_ren_in && ($countones(ap) == 1)) begin
            expected_result = a_in - b_in;
            expected_error  = 1'b0;
        end
        //************************************************************************



        //************************************************************************
        // 12. SLT - Set Less Than Signed
        // ap.slt    = 1
        // ap.sub    = 1
        // ap.unsign = 0
        // Signed comparison
        else if (ap.slt && ap.sub && !ap.unsign && !csr_ren_in && ($countones(ap) == 2)) begin

            if ($signed(a_in) < $signed(b_in))
                expected_result = 32'd1;
            else
                expected_result = 32'd0;

            expected_error = 1'b0;

        end
        //************************************************************************



        //************************************************************************
        // 13. SLTU - Set Less Than Unsigned
        // ap.slt    = 1
        // ap.sub    = 1
        // ap.unsign = 1
        // Unsigned comparison
        else if (ap.slt && ap.sub && ap.unsign && !csr_ren_in && ($countones(ap) == 3)) begin

            if (a_in < b_in)
                expected_result = 32'd1;
            else
                expected_result = 32'd0;

            expected_error = 1'b0;

        end
        //************************************************************************



        //************************************************************************
        // 14. CTZ - Count Trailing Zeros
        // ap.ctz = 1
        // Count zeros starting from bit 0
        // Project rule: if a_in = 0, result = 0
        else if (ap.ctz && !csr_ren_in && ($countones(ap) == 1)) begin

            expected_result = 32'd0;

            if (a_in != 32'd0) begin

                for (int i = 0; i < 32; i++) begin

                    if (a_in[i] == 1'b1) begin
                        expected_result = i;
                        break;
                    end

                end

            end

            expected_error = 1'b0;

        end
        //************************************************************************



        //************************************************************************
        // 15. CPOP - Count Population
        // ap.cpop = 1
        // Count all bits equal to 1 in a_in
        else if (ap.cpop && !csr_ren_in && ($countones(ap) == 1)) begin
            expected_result = $countones(a_in);
            expected_error  = 1'b0;
        end
        //************************************************************************



        //************************************************************************
        // 16. SEXT.B - Sign Extend Byte
        // ap.siext_b = 1
        // Sign extend a_in[7:0] to 32 bits
        else if (ap.siext_b && !csr_ren_in && ($countones(ap) == 1)) begin
            expected_result = {{24{a_in[7]}}, a_in[7:0]};
            expected_error  = 1'b0;
        end
        //************************************************************************



        //************************************************************************
        // 17. MAX - Signed Maximum
        // ap.max = 1
        // ap.sub = 1
        // Return the greater signed operand
        else if (ap.max && ap.sub && !csr_ren_in && ($countones(ap) == 2)) begin

            if ($signed(a_in) >= $signed(b_in))
                expected_result = a_in;
            else
                expected_result = b_in;

            expected_error = 1'b0;

        end
        //************************************************************************



        //************************************************************************
        // 18. PACK
        // ap.pack = 1
        // Result = {b_in[15:0], a_in[15:0]}
        else if (ap.pack && !csr_ren_in && ($countones(ap) == 1)) begin
            expected_result = {b_in[15:0], a_in[15:0]};
            expected_error  = 1'b0;
        end
        //************************************************************************



        //************************************************************************
        // 19. GREV - Byte Reverse
        // ap.grev = 1
        // Valid mode: b_in[4:0] = 5'b11000 = 24
        else if (ap.grev && !csr_ren_in && ($countones(ap) == 1)) begin

            if (b_in[4:0] == 5'b11000) begin
                expected_result = {
                    a_in[7:0],
                    a_in[15:8],
                    a_in[23:16],
                    a_in[31:24]
                };

                expected_error = 1'b0;
            end

            else begin
                expected_result = 32'b0;
                expected_error  = 1'b1;
            end

        end
        //************************************************************************



        //************************************************************************
        // 20. CSR WRITE
        // ap.csr_write = 1
        //
        // csr_imm = 0 -> result = a_in
        // csr_imm = 1 -> result = b_in
        else if (ap.csr_write && !csr_ren_in ) begin

            if (!ap.csr_imm && ($countones(ap) == 1)) begin
                expected_result = a_in;
                expected_error  = 1'b0;
            end

            else if (ap.csr_imm && ($countones(ap) == 2)) begin
                expected_result = b_in;
                expected_error  = 1'b0;
            end

            // Error
            else begin
                expected_result = 32'b0;
                expected_error  = 1'b1;
            end

        end
        //************************************************************************







        //************************************************************************
        // Error detection for invalid control combinations
    


        //************************************************************************
        // ERROR 1 - CSR + BMU AP conflict
        // csr_ren_in = 1 and AP is not clear
        // Expected: result = 0, error = 1
        else if (csr_ren_in && (ap != '0)) begin
            expected_result = 32'b0;
            expected_error  = 1'b1;
        end
        //************************************************************************
        


        //************************************************************************
        // ERROR 2 - SH2ADD without Zba
        // ap.sh2add = 1
        // ap.zba    = 0
        // Expected: result = 0, error = 1
        else if (ap.sh2add && !ap.zba && !csr_ren_in && ($countones(ap) == 1)) begin
            expected_result = 32'b0;
            expected_error  = 1'b1;
        end
        //************************************************************************



        //************************************************************************
        // ERROR 3 - SUB with Zba
        // ap.sub = 1
        // ap.zba = 1
        // Expected: result = 0, error = 1
        else if (ap.sub && ap.zba && !csr_ren_in && ($countones(ap) == 2)) begin
            expected_result = 32'b0;
            expected_error  = 1'b1;
        end
        //************************************************************************



        //************************************************************************
        // ERROR 4 - Invalid / conflicting AP control combination as like (ap.lor=1 and ap.lxor=1)
        else if (!csr_ren_in && (ap != '0)) begin
            expected_result = 32'b0;
            expected_error  = 1'b1;
        end
        //************************************************************************


    endfunction

endclass