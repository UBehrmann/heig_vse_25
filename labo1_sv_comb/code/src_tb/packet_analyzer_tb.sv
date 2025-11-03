/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Engineering and Management Vaud
********************************************************************************
REDS Institute
Reconfigurable and Embedded Digital Systems
********************************************************************************

File     : packet_analyzer_tb.sv
Author   : Yann Thoma
Date     : 07.10.2025

Context  : packet_analyzer component testbench

********************************************************************************
Description : This testbench is decomposed into stimuli
              generation and verification, with the use of interfaces.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   07.10.2025  YTA        Initial version

*******************************************************************************/

import packet_analyzer_pkg::*;

`include "svlogger.sv"

// constants declared in the packet_analyzer_pkg.vhd file have to be used in
// lower case here (cf. QuestaSim user manual)
interface packet_analyzer_result_if;
    logic[errorsize-1:0] error;
    logic[typesize-1:0]  ptype;
    logic[lengthsize-1:0] length;
endinterface

typedef struct packed {
    logic[errorsize-1:0] error;
    logic[typesize-1:0]  ptype;
    logic[lengthsize-1:0] length;
} output_t;

    function logic[7:0] crc8_calculator(logic[maxsize-1:0] data_in,int from, int size);

        const int POLYNOMIAL = 8'h07;  // CRC-8 ATM polynomial: x^8 + x^2 + x + 1
        // const int POLYNOMIAL = 8'hA7;  // CRC-8 polynomial: x^8 + x^7 + x^5 + x^2 + x + 1
        const int INIT_VALUE = 8'h00;   // Initial CRC value
        logic [7:0] crc;
        logic [7:0] d;
        integer i, j;
    
        crc = INIT_VALUE;
        
        for(int i=0; i < size; i++) begin

            crc = crc ^ ({data_in[from + i], crc[7:1]});
            if (crc[7] == 1)
                crc = crc ^ POLYNOMIAL;
        end
        return crc;
    endfunction

    function logic[15:0] crc16_calculator(logic[maxsize-1:0] data_in,int from, int size);

        const int POLYNOMIAL = 16'hA02B;  // CRC-16-ARINC
        const int INIT_VALUE = 8'h00;   // Initial CRC value
        logic [15:0] crc;
        logic [7:0] d;
        integer i, j;

        crc = INIT_VALUE;
        
        for(int i=0; i < size; i++) begin

            crc = crc ^ ({data_in[from + i], crc[15:1]});
            if (crc[15] == 1)
                crc = crc ^ POLYNOMIAL;
        end
        return crc;
    endfunction


module packet_analyzer_tb#(int TESTCASE, int ERRNO);

    timeunit 1ns;         // Definition of the time unit
    timeprecision 1ns;    // Definition of the time precision

    // Timings definitions
    time sim_step = 10ns;
    time pulse = 0ns;

    logic synchro = 0;
    always #(sim_step/2) synchro = ~synchro;

    svlogger logger;
    
    logic[maxsize-1:0] packet_sti;

   
    logic error_signal = 0;
    // Integer to keep track of the number of errors
    int nb_errors = 0;

   
    packet_analyzer_result_if result_if();

    packet_analyzer#(maxsize, ERRNO) duv (
        .packet_i(packet_sti),
        .type_o(result_if.ptype),
        .length_o(result_if.length),
        .error_o(result_if.error)
    );

    parameter int header_size = 6 * 8;

    int nb_tests = 0;
    output_t result;

    // Coverage group for functional coverage
    covergroup packet_coverage @(negedge synchro);
        // Type coverage
        cp_type: coverpoint result_if.ptype {
            bins valid_types = {1, 2, 5};
            bins invalid_types = {0, 3, 4, 6, 7};
        }
        
        // Length coverage
        cp_length: coverpoint result_if.length {
            bins len_small = {[0:15]};
            bins len_medium = {[16:63]};
            bins len_large = {[64:255]};
        }
        
        // Error bit coverage
        cp_error_crc: coverpoint result_if.error[0] {
            bins crc_ok = {0};
            bins crc_error = {1};
        }
        
        cp_error_type: coverpoint result_if.error[1] {
            bins type_ok = {0};
            bins type_error = {1};
        }
        
        cp_error_src: coverpoint result_if.error[2] {
            bins src_ok = {0};
            bins src_error = {1};
        }
        
        cp_error_dst: coverpoint result_if.error[3] {
            bins dst_ok = {0};
            bins dst_error = {1};
        }
        
        cp_error_group: coverpoint result_if.error[4] {
            bins group_ok = {0};
            bins group_error = {1};
        }
        
        // Address boundary coverage - testing edge cases
        cp_source_addr: coverpoint packet_sti[31:16] {
            bins group0_low_boundary = {groupo_low, groupo_low+1};
            bins group0_high_boundary = {group0_high-1, group0_high};
            bins group0_mid = {[(groupo_low+2):(group0_high-2)]};
            bins group1_low_boundary = {group1_low, group1_low+1};
            bins group1_high_boundary = {group1_high-1, group1_high};
            bins group1_mid = {[(group1_low+2):(group1_high-2)]};
            bins invalid_between = {[(group0_high+1):(group1_low-1)]};
            bins invalid_above = {[(group1_high+1):500]};
        }
        
        cp_dest_addr: coverpoint packet_sti[47:32] {
            bins group0_low_boundary = {groupo_low, groupo_low+1};
            bins group0_high_boundary = {group0_high-1, group0_high};
            bins group0_mid = {[(groupo_low+2):(group0_high-2)]};
            bins group1_low_boundary = {group1_low, group1_low+1};
            bins group1_high_boundary = {group1_high-1, group1_high};
            bins group1_mid = {[(group1_low+2):(group1_high-2)]};
            bins invalid_between = {[(group0_high+1):(group1_low-1)]};
            bins invalid_above = {[(group1_high+1):500]};
        }
        
        // Address group classification
        cp_source_group: coverpoint packet_sti[31:16] {
            bins in_group0 = {[groupo_low:group0_high]};
            bins in_group1 = {[group1_low:group1_high]};
            bins invalid = default;
        }
        
        cp_dest_group: coverpoint packet_sti[47:32] {
            bins in_group0 = {[groupo_low:group0_high]};
            bins in_group1 = {[group1_low:group1_high]};
            bins invalid = default;
        }
        
        // Cross coverage for address groups
        cr_address_groups: cross cp_source_group, cp_dest_group;
        
        // Cross coverage: type vs error
        cr_type_error: cross cp_type, cp_error_type {
            // Ignore impossible combinations
            ignore_bins valid_with_error = binsof(cp_type.valid_types) && binsof(cp_error_type.type_error);
            ignore_bins invalid_without_error = binsof(cp_type.invalid_types) && binsof(cp_error_type.type_ok);
        }
        
        // Cross coverage: all error bits
        cr_errors: cross cp_error_crc, cp_error_type, cp_error_src, cp_error_dst, cp_error_group {
            // Can't have CRC error with invalid type (CRC not checked for invalid types)
            ignore_bins crc_with_invalid_type = binsof(cp_error_crc.crc_error) && binsof(cp_error_type.type_error);
            
            // Can't have group mismatch with invalid source or destination
            ignore_bins group_error_with_src_error = binsof(cp_error_src.src_error) && binsof(cp_error_group.group_error);
            ignore_bins group_error_with_dst_error = binsof(cp_error_dst.dst_error) && binsof(cp_error_group.group_error);
        }
    endgroup

    packet_coverage cov_inst;

    class Packet;
        // 0-2 : type 1, 2 ou 5 sinon erreur_o[1] = 1
        // longueur
        // type 1 : 8-15 
        // type 2 : 10-15 
        // type 5 : 12-15
        // 16-31 : source
        // 32-47 : destination 
        // source et destination doivent etre dans des ranges Group0 et Group1
        // Si source est hors des ranges erreur_o[2] = 1
        // Si destination est hors des ranges erreur_o[3] = 1
        // Si les deux sont valide, mais pas dans le meme groupe erreur_o[4] = 1
        // CRC
        // Type 1 : 8 bits
        // Type 2 et 5 : 16 bits
        // Si CRC incorrecte erreur_o[0] = 1

        rand logic [2:0] ptype;
        rand logic [7:0] length;
        rand logic [15:0] source;
        rand logic [15:0] destination;
        rand logic [maxsize-1:0] data;
        rand logic [15:0] crc; // 16 bits max (Type 2 and 5)
        rand logic force_bad_crc;
        
        // Constraints
        constraint c_type {
            ptype inside {1, 2, 5, 0, 3, 4, 6, 7}; // Valid and invalid types
        }
        
        constraint c_length {
            if (ptype == 1)
                length <= 255; // 8 bits for type 1
            else if (ptype == 2)
                length <= 63; // 6 bits for type 2
            else if (ptype == 5)
                length <= 15; // 4 bits for type 5
            else
                length <= 255; // Default for invalid types
        }
        
        constraint c_addresses {
            // Mix of valid and invalid addresses
            source dist {[groupo_low:group0_high] := 40, [group1_low:group1_high] := 40, [256:299] := 10, [401:500] := 10};
            destination dist {[groupo_low:group0_high] := 40, [group1_low:group1_high] := 40, [256:299] := 10, [401:500] := 10};
        }
        
        constraint c_bad_crc {
            force_bad_crc dist {0 := 80, 1 := 20}; // 80% good CRC, 20% bad
        }
        
        function logic[maxsize-1:0] build_packet();
            logic[maxsize-1:0] packet;
            int data_size_bits;
            int crc_size;
            logic[15:0] computed_crc;
            int header_start_bit;
            
            packet = '0;
            
            // Build header (bits 0-47)
            packet[2:0] = ptype;
            
            // Set length based on type
            if (ptype == 1) begin
                packet[15:8] = length;
                data_size_bits = length * 8;
                crc_size = 8;
            end else if (ptype == 2) begin
                packet[15:10] = length[5:0];
                data_size_bits = length * 8;
                crc_size = 16;
            end else if (ptype == 5) begin
                packet[15:12] = length[3:0];
                data_size_bits = length * 8;
                crc_size = 16;
            end else begin
                packet[15:8] = length;
                data_size_bits = length * 8;
                crc_size = 8;
            end
            
            // Source and destination
            packet[31:16] = source;
            packet[47:32] = destination;
            
            // Add data
            for (int i = 0; i < data_size_bits; i++) begin
                packet[header_size + i] = data[i];
            end
            
            // Calculate and add CRC
            if (crc_size == 8) begin
                computed_crc[7:0] = crc8_calculator(packet, 0, header_size + data_size_bits);
                if (force_bad_crc)
                    // CRC is inverted to simulate error
                    computed_crc[7:0] = computed_crc[7:0] ^ 8'hFF;
                for (int k = 0; k < 8; k++) begin
                    packet[header_size + data_size_bits + k] = computed_crc[k];
                end
            end else begin
                computed_crc = crc16_calculator(packet, 0, header_size + data_size_bits);
                if (force_bad_crc)
                    // CRC is inverted to simulate error
                    computed_crc = computed_crc ^ 16'hFFFF;
                for (int k = 0; k < 16; k++) begin
                    packet[header_size + data_size_bits + k] = computed_crc[k];
                end
            end
            
            return packet;
        endfunction

    endclass

    task play(Packet p);
        packet_sti = p.build_packet();
    endtask

    task compute_reference(logic[maxsize-1:0] p, output output_t result);
        logic [2:0] ptype_ref;
        logic [7:0] length_ref;
        logic [15:0] source_ref;
        logic [15:0] destination_ref;
        logic [7:0] error_ref;
        int data_size_bits;
        int crc_size;
        logic [15:0] computed_crc;
        logic [15:0] packet_crc;
        logic source_in_group0, source_in_group1;
        logic dest_in_group0, dest_in_group1;
        
        // Initialize
        error_ref = 8'b0;
        
        // Extract type
        ptype_ref = p[2:0];
        
        // Check type validity (bit 1 of error)
        if (ptype_ref != 1 && ptype_ref != 2 && ptype_ref != 5) begin
            error_ref[1] = 1'b1;
            // Pour les types invalides, le DUV retourne length = 0
            length_ref = 8'b0;
            data_size_bits = 0;
            crc_size = 8;
        end else begin
            // Extract length based on valid type
            if (ptype_ref == 1) begin
                length_ref = p[15:8];
                data_size_bits = length_ref * 8;
                crc_size = 8;
            end else if (ptype_ref == 2) begin
                length_ref = {2'b0, p[15:10]};
                data_size_bits = length_ref * 8;
                crc_size = 16;
            end else if (ptype_ref == 5) begin
                length_ref = {4'b0, p[15:12]};
                data_size_bits = length_ref * 8;
                crc_size = 16;
            end
        end
        
        // Extract source and destination
        source_ref = p[31:16];
        destination_ref = p[47:32];
        
        // Check source address (bit 2 of error)
        source_in_group0 = (source_ref >= groupo_low && source_ref <= group0_high);
        source_in_group1 = (source_ref >= group1_low && source_ref <= group1_high);
        
        if (!source_in_group0 && !source_in_group1) begin
            error_ref[2] = 1'b1;
        end
        
        // Check destination address (bit 3 of error)
        dest_in_group0 = (destination_ref >= groupo_low && destination_ref <= group0_high);
        dest_in_group1 = (destination_ref >= group1_low && destination_ref <= group1_high);
        
        if (!dest_in_group0 && !dest_in_group1) begin
            error_ref[3] = 1'b1;
        end
        
        // Check if both addresses are valid but in different groups (bit 4 of error)
        if ((source_in_group0 || source_in_group1) && (dest_in_group0 || dest_in_group1)) begin
            if ((source_in_group0 && dest_in_group1) || (source_in_group1 && dest_in_group0)) begin
                error_ref[4] = 1'b1;
            end
        end
        
        // Check CRC (bit 0 of error) - only for valid packet types
        if (ptype_ref == 1 || ptype_ref == 2 || ptype_ref == 5) begin
            if (crc_size == 8) begin
                computed_crc[7:0] = crc8_calculator(p, 0, header_size + data_size_bits);
                // Extract CRC from packet
                for (int k = 0; k < 8; k++) begin
                    packet_crc[k] = p[header_size + data_size_bits + k];
                end
                if (computed_crc[7:0] != packet_crc[7:0]) begin
                    error_ref[0] = 1'b1;
                end
            end else begin
                computed_crc = crc16_calculator(p, 0, header_size + data_size_bits);
                // Extract CRC from packet
                for (int k = 0; k < 16; k++) begin
                    packet_crc[k] = p[header_size + data_size_bits + k];
                end
                if (computed_crc != packet_crc) begin
                    error_ref[0] = 1'b1;
                end
            end
        end
        
        // Assign results
        result.ptype = ptype_ref;
        result.length = length_ref;
        result.error = error_ref;
    endtask

    task compute_reference_task;
        forever begin
            @(posedge(synchro));
            #1;
            compute_reference(packet_sti, result);
        end
    endtask

    // Assertion-based verification
    task verification;
        @(negedge(synchro));
        forever begin
            // Check the reference against the observed values
            nb_tests++;
            
            // Assertion: Error bits [4:0] should match reference
            assert_error: assert (result_if.error[4:0] === result.error[4:0])
            else begin
                `LOG_ERROR3(logger, "ERROR mismatch: expected %05b, got %05b", result.error[4:0], result_if.error[4:0]);
                nb_errors++;
            end
            
            // Assertion: Type should match reference
            assert_type: assert (result_if.ptype === result.ptype)
            else begin
                `LOG_ERROR3(logger, "TYPE mismatch: expected %03b, got %03b", result.ptype, result_if.ptype);
                nb_errors++;
            end
            
            // Assertion: Length should match reference
            assert_length: assert (result_if.length === result.length)
            else begin
                `LOG_ERROR3(logger, "LENGTH mismatch: expected %08b, got %08b", result.length, result_if.length);
                nb_errors++;
            end
            
            // Log passing tests
            if (result_if.error[4:0] === result.error[4:0] && result_if.ptype === result.ptype && result_if.length === result.length) begin
                `LOG_DEBUG4(logger, "PASS - Type: %03b, Length: %d, Error: %05b", result.ptype, result.length, result.error[4:0]);
            end
            
            @(negedge(synchro));
        end
    endtask


    // Test scenarios
    
    task test_invalid_types();
        automatic Packet p = new;
        automatic int count = 0;
        
        `LOG_INFO(logger, "=== Test Case 1: Invalid Type Packets ===");
        
        while (count < 100) begin
            @(posedge synchro);
            void'(p.randomize() with {
                ptype inside {0, 3, 4, 6, 7};
                source inside {[groupo_low:group0_high]};
                destination inside {[groupo_low:group0_high]};
                force_bad_crc == 0;
            });
            play(p);
            count++;
        end
        
        `LOG_INFO(logger, "=== Test Case 1 Complete ===");
    endtask

    task test_crc_errors();
        automatic Packet p = new;
        automatic int count = 0;
        
        `LOG_INFO(logger, "=== Test Case 2: CRC Error Packets ===");
        
        while (count < 100) begin
            @(posedge synchro);
            void'(p.randomize() with {
                ptype inside {1, 2, 5};
                source inside {[groupo_low:group0_high]};
                destination inside {[groupo_low:group0_high]};
                force_bad_crc == 1;
            });
            play(p);
            count++;
        end
        
        `LOG_INFO(logger, "=== Test Case 2 Complete ===");
    endtask

    task test_source_errors();
        automatic Packet p = new;
        automatic int count = 0;
        
        `LOG_INFO(logger, "=== Test Case 3: Invalid Source Address ===");
        
        while (count < 100) begin
            @(posedge synchro);
            void'(p.randomize() with {
                ptype inside {1, 2, 5};
                source inside {[256:299], [401:500]};
                destination inside {[groupo_low:group0_high]};
                force_bad_crc == 0;
            });
            play(p);
            count++;
        end
        
        `LOG_INFO(logger, "=== Test Case 3 Complete ===");
    endtask

    task test_destination_errors();
        automatic Packet p = new;
        automatic int count = 0;
        
        `LOG_INFO(logger, "=== Test Case 4: Invalid Destination Address ===");
        
        while (count < 100) begin
            @(posedge synchro);
            void'(p.randomize() with {
                ptype inside {1, 2, 5};
                source inside {[groupo_low:group0_high]};
                destination inside {[256:299], [401:500]};
                force_bad_crc == 0;
            });
            play(p);
            count++;
        end
        
        `LOG_INFO(logger, "=== Test Case 4 Complete ===");
    endtask

    task test_group_mismatch();
        automatic Packet p = new;
        automatic int count = 0;
        
        `LOG_INFO(logger, "=== Test Case 5: Group Mismatch (different groups) ===");
        
        while (count < 100) begin
            @(posedge synchro);
            void'(p.randomize() with {
                ptype inside {1, 2, 5};
                source inside {[groupo_low:group0_high]};
                destination inside {[group1_low:group1_high]};
                force_bad_crc == 0;
            });
            play(p);
            count++;
        end
        
        `LOG_INFO(logger, "=== Test Case 5 Complete ===");
    endtask

    task test_multiple_errors();
        automatic Packet p = new;
        automatic int count = 0;
        
        `LOG_INFO(logger, "=== Test Case 6: Multiple Simultaneous Errors ===");
        
        while (count < 100) begin
            @(posedge synchro);
            void'(p.randomize() with {
                // Random combination of errors
                ptype dist {1:=20, 2:=20, 5:=20, 0:=10, 3:=10, 4:=10, 6:=5, 7:=5};
            });
            play(p);
            count++;
        end
        
        `LOG_INFO(logger, "=== Test Case 6 Complete ===");
    endtask

    task test_random_coverage();
        automatic Packet p = new;
        automatic int random_count = 0;
        automatic real coverage;
        
        `LOG_INFO(logger, "=== Test Case 7: Random Coverage-Driven Testing ===");
        
        while (cov_inst.get_inst_coverage() < 99.0 && random_count < 10000) begin
            @(posedge synchro);
            void'(p.randomize());
            play(p);
            random_count++;
            
            if (random_count % 1000 == 0) begin
                coverage = cov_inst.get_inst_coverage();
                `LOG_INFO3(logger, "Random tests: %0d, Coverage: %0.2f%%", random_count, coverage);
            end
        end

        `LOG_INFO(logger, "=== Test Case 7 Complete ===");
    endtask

    task generator;
        automatic Packet p = new;
        packet_sti = 0;
        @(posedge synchro);
        
        case (TESTCASE)
            0: begin // Run all test cases
                `LOG_INFO(logger, "========================================");
                `LOG_INFO(logger, "Running ALL test cases");
                `LOG_INFO(logger, "========================================");
                test_invalid_types();
                test_crc_errors();
                test_source_errors();
                test_destination_errors();
                test_group_mismatch();
                test_multiple_errors();
                test_random_coverage();
            end
            1: test_invalid_types();
            2: test_crc_errors();
            3: test_source_errors();
            4: test_destination_errors();
            5: test_group_mismatch();
            6: test_multiple_errors();
            7: test_random_coverage();
            default: begin
                `LOG_ERROR2(logger, "Unknown TESTCASE %0d, running all tests", TESTCASE);
                test_invalid_types();
                test_crc_errors();
                test_source_errors();
                test_destination_errors();
                test_group_mismatch();
                test_multiple_errors();
                test_random_coverage();
            end
        endcase
        
        @(posedge synchro);
        #100;
    endtask


    program TestProgram;

        initial begin
            logger = new("packet_analyzer_tb", `SVL_VERBOSE_INFO, `SVL_ROUTE_ALL);
            cov_inst = new();
            
            `LOG_INFO(logger, "========================================");
            `LOG_INFO(logger, "Starting Packet Analyzer Verification");
            `LOG_INFO(logger, "========================================");
            `LOG_INFO3(logger, "TESTCASE: %0d, ERRNO: %0d", TESTCASE, ERRNO);
            `LOG_INFO(logger, "========================================");
            
            fork
                generator;
                verification;
                compute_reference_task;
            join_any
            
            `LOG_INFO(logger, "========================================");
            `LOG_INFO(logger, "Simulation Complete");
            `LOG_INFO(logger, "========================================");
            `LOG_INFO2(logger, "Total tests executed: %0d", nb_tests);
            `LOG_INFO2(logger, "Total errors detected: %0d", nb_errors);
            `LOG_INFO2(logger, "Functional coverage: %0.2f%%", cov_inst.get_inst_coverage());
            `LOG_INFO(logger, "========================================");
            
            if (nb_errors == 0) begin
                `LOG_INFO(logger, "*** TEST PASSED ***");
            end else begin
                `LOG_ERROR2(logger, "*** TEST FAILED with %0d errors ***", nb_errors);
            end
            `LOG_INFO(logger, "========================================");

            // Finish simulation
            $finish;
        end
    endprogram

endmodule

