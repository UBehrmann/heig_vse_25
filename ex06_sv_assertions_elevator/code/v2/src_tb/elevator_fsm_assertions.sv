module elevator_fsm_assertions#(int ERRNO = 0)(
    input  logic clk_i,
    input  logic rst_i,

    input  logic call0_i,
    input  logic call1_i,

    input  logic open_o,
    input  logic floor0_o,
    input  logic floor1_o
);

    // clocking block
    default clocking cb @(posedge clk_i);
    endclocking

    default disable iff rst_i;

    //-----------------------------------------------------------------------
    // Assertions : Asynchronous
    //-----------------------------------------------------------------------
    // Assertion 1 : Reinitialization
    // After a reset, the elevator must be at floor 0 with doors closed
    a1 : assert property (
        rst_i |-> (floor0_o && !open_o)
    );

    //-----------------------------------------------------------------------
    // Assertions : Signals state
    //-----------------------------------------------------------------------
    // Assertion 2 : Floors state
    // The elevator cannot be at both floors at the same time
    a2 : assert property (
        !(floor0_o && floor1_o)
    );
    // Assertion 3 : Door opening after arriving at a floor or requesting to open
    a3 : assert property (
        (!floor0_o ##1 floor0_o) |-> open_o[*10]
    );
    a3_1 : assert property (
        (!floor1_o ##1 floor1_o) |-> open_o[*10]
    );
    // Assertion 4 : Keep doors open when there is a call at the current floor
    a4 : assert property (
        (floor0_o & call0_i) ^ (floor1_o & call1_i) |=> open_o[*10]
    );
    // Assertion 5 : Close doors when there is no call at the current floor
    a5 : assert property (
        ((floor0_o & !call0_i) ^ (floor1_o & !call1_i))[*10] |=> !open_o
    );
    // Assertion 6 : Go to floor 1
    a6 : assert property (
        (floor0_o & call1_i & !call0_i & !open_o) |=> ##1 floor1_o
    );
    // Assertion 7 : Go to floor 0
    a7 : assert property (
        (floor1_o & call0_i & !call1_i & !open_o) |=> ##1 floor0_o
    );

endmodule


