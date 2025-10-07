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

    class Packet;
    endclass

    task play(Packet p);
        // TODO
        // Play the packet (put it on the input)
    endtask


    output_t result;



    task compute_reference(logic[maxsize-1:0] p, output output_t result);
        // TODO
    endtask

    task compute_reference_task;
        forever begin
            @(posedge(synchro));
            #1;
            compute_reference(packet_sti, result);
        end
    endtask

    task verification;
        @(negedge(synchro));
        forever begin
            // TODO : Check the reference against the observed values
            @(negedge(synchro));
        end
    endtask


    task generator;
        automatic Packet p = new;
        packet_sti = 0;
        for (int i = 0; i < 10; i++) begin
            @(posedge synchro);
            void'(p.randomize());
            play(p);
        end
        #10;
    endtask


    initial begin
        logger = new("", 1, 1);
        `LOG_INFO(logger, "Starting simulation");
        fork
            generator;
            verification;
            compute_reference_task;
        join_any
        `LOG_INFO(logger, "Ending simulation");
        $finish;
    end

endmodule

