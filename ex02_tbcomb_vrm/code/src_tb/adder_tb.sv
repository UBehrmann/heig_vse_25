/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Engineering and Management Vaud
********************************************************************************
REDS Institute
Reconfigurable and Embedded Digital Systems
********************************************************************************

File     : adder_tb.sv
Author   : Yann Thoma
Date     : 20.09.2024

Context  : Code example for an adder testbench

********************************************************************************
Description : This testbench illustrates the decomposition into stimuli
              generation and verification, with the use of interfaces.

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   20.09.2024  YTA        Initial version

*******************************************************************************/

interface adder_in_itf #(parameter DATASIZE = 8);
    logic[DATASIZE-1:0] a;
    logic[DATASIZE-1:0] b;
    logic      carry;
endinterface

interface adder_out_itf #(parameter DATASIZE = 8);
    logic[DATASIZE-1:0] result;
    logic      carry;
endinterface

module adder_tb #(
    parameter DATASIZE = 8,
    parameter TESTCASE = 0
);

    timeunit 1ns;         // Definition of the time unit
    timeprecision 1ns;    // Definition of the time precision
   
    // Reference
    logic[DATASIZE:0] result_ref;
   
    // Timings definitions
    time sim_step = 10ns;
    time pulse = 0ns;
   
    logic error_signal = 0;
   
    logic synchro = 0;
   
    always #(sim_step/2) synchro = ~synchro;
   
    // Integer to keep track of the number of errors
    int nb_errors = 0;
   
    adder_in_itf #(.DATASIZE(DATASIZE)) input_itf();
    adder_out_itf #(.DATASIZE(DATASIZE)) output_itf();
   
    // DUV instantiation
    adder #(.SIZE(DATASIZE)) duv(.a_i(input_itf.a),
                                 .b_i(input_itf.b),
                                 .carryin_i(input_itf.carry),
                                 .result_o(output_itf.result),
                                 .carryout_o(output_itf.carry));


    task test_scenario0;
        for(int a = 0; a < 100; a++) begin
            for(int b = 0; b < 100; b++) begin
                input_itf.a = a;
                input_itf.b = b;
                compute_reference(input_itf.a, input_itf.b, result_ref);
                @(posedge(synchro));
            end
        end
    endtask

    task test_scenario1;
        // Directed edge case testing
        logic[DATASIZE-1:0] test_values[];
        int num_tests;
        
        // Define edge case values
        test_values = new[6];
        test_values[0] = 0;                           // Minimum
        test_values[1] = (1 << DATASIZE) - 1;        // Maximum
        test_values[2] = 1;                          // Small value
        test_values[3] = (1 << (DATASIZE-1));        // MSB set
        test_values[4] = (1 << (DATASIZE-1)) - 1;    // MSB clear, others set


        // Test all combinations of edge cases with both carry values
        for(int i = 0; i < test_values.size(); i++) begin
            for(int j = 0; j < test_values.size(); j++) begin
                for(int carry = 0; carry <= 1; carry++) begin
                    input_itf.a = test_values[i];
                    input_itf.b = test_values[j];
                    input_itf.carry = carry;
                    compute_reference(input_itf.a, input_itf.b, result_ref);
                    @(posedge(synchro));
                end
            end
        end
    endtask

    task compute_reference(logic[DATASIZE-1:0] a, logic[DATASIZE-1:0] b, output logic[DATASIZE:0] result);
        result = a + b + input_itf.carry;
    endtask

    task compute_reference_task;
        forever begin
            @(posedge(synchro));
            #1;
            compute_reference(input_itf.a, input_itf.b, result_ref);
        end
    endtask

    task verification;
        @(negedge(synchro));
        forever begin
            if (output_itf.result != result_ref[DATASIZE-1:0] || output_itf.carry != result_ref[DATASIZE]) begin
                nb_errors ++;
                $display("Error for a_i = %d and b_i = %d and carry_i = %d. Expected: result=%d, carry=%d, Observed: result=%d, carry=%d", 
                         input_itf.a, input_itf.b, input_itf.carry, result_ref[DATASIZE-1:0], result_ref[DATASIZE], output_itf.result, output_itf.carry);
                error_signal = 1;
                #pulse;
                error_signal = 0;
            end
            @(negedge(synchro));
        end
    endtask

    initial begin

        $display("Starting simulation with TESTCASE = %d, DATASIZE = %d", TESTCASE, DATASIZE);
        fork
            case(TESTCASE)
                0: test_scenario0;
                1: test_scenario1;
                default: test_scenario0;
            endcase
            compute_reference_task;
            verification;
        join_any

        $display("Ending simulation");
        if (nb_errors > 0)
            $display("Number of errors : %d", nb_errors);
        else
            $display("No errors");

        $finish(0);
    end

endmodule
