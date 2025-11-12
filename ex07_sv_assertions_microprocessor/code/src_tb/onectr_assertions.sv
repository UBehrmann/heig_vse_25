/*******************************************************************************
HEIG-VD
Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
School of Business and Engineering in Canton de Vaud
********************************************************************************
REDS Institute
Reconfigurable Embedded Digital Systems
********************************************************************************

File     : shiftregister_assertions.sv
Author   : Yann Thoma
Date     : 03.11.2017

Context  : Example of assertions usage for formal verification

********************************************************************************
Description : This module contains assertions for verifying a simple shift
              register. The modes are:
                            00 => hold
                            01 => shift left
                            10 => shift right
                            11 => load

********************************************************************************
Dependencies : -

********************************************************************************
Modifications :
Ver   Date        Person     Comments
1.0   03.11.2017  YTA        Initial version

*******************************************************************************/

module onectr_assertions#(int INPUTSIZE = 64)(
    input logic clk,
    input logic rst,
    input logic start_i,
    input logic[INPUTSIZE-1:0] inport,
    input logic[$clog2(INPUTSIZE+1)-1:0] outport
);

function logic[$clog2(INPUTSIZE+1)-1 :0] reference(
    input logic[INPUTSIZE-1:0] input_i);

    logic[$clog2(INPUTSIZE+1)-1  :0] result;

    result = 0;
    // Simply loops on the digits, as it is done by hand
    for (int i = 0; i < INPUTSIZE; i++) begin
        result = result + input_i[i];
    end

    reference = result;

endfunction

property p_stable;
    @( posedge clk) disable iff (rst==1)
            start_i |=> ($stable(inport))[*(INPUTSIZE+1)];
endproperty

    assume property (p_stable);


    property p_start;
        @( posedge clk) disable iff (rst==1)
                start_i |=> (!start_i)[*(INPUTSIZE+1)];
    endproperty

        assume property (p_start);

    property p_add;
        var logic[INPUTSIZE-1:0] data_in;
        @( posedge clk) disable iff (rst==1)
            (start_i, data_in = inport) |-> ##[1:INPUTSIZE+1] (outport == $countones(data_in));
            //    (start_i, data_in = inport) |-> ##(INPUTSIZE+1) (outport == $countones(data_in));
        //        (start_i, data_in = inport) ##1 (!start_i[*(INPUTSIZE+1)]) |-> (outport == $countones(data_in));
                //(start_i, data_in = inport) ##1 (!start_i[*(INPUTSIZE+1)]) |-> (outport == reference(data_in));
    endproperty

    assert_add : assert property (p_add);

/*
    property p_load;
        @( posedge clk_i) disable iff (rst_i==1)
            ((mode_i==2'b11) |=> (value_o == $past(load_value_i)));
    endproperty

    assert_load : assert property (p_load);

    // load operation in a single assertion-property
    assert_load2: assert property (@( posedge clk_i) disable iff (rst_i==1)
            (mode_i==2'b11) |=> value_o == $past(load_value_i));

    // maintain operation
    assert_maintain: assert property (@(posedge clk_i) disable iff (rst_i==1)
        (mode_i==2'b00) |=> value_o == $past(value_o));

    // shift right operation
    property prop_shift_right;
        logic[DATASIZE-1:0] val;
        @(posedge clk_i) disable iff (rst_i==1)
            (mode_i==2'b10, val = value_o) |=>
                value_o == ({$past(ser_in_msb_i), val[DATASIZE-1:1]});
    endproperty

    // shift right operation
    assert_shift_right: assert property (prop_shift_right);

    property prop_shift_left;
        logic[DATASIZE-1:0] val;
        @(posedge clk_i) disable iff (rst_i==1)
            (mode_i==2'b01, val = value_o) |=>
                value_o == ({val[DATASIZE-2:0] , $past(ser_in_lsb_i)});
    endproperty

    // shift right operation
    assert_shift_left: assert property (prop_shift_left);
*/
endmodule
