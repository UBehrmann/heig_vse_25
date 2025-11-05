module elevator_fsm_wrapper#(int ERRNO = 0)(
    input  logic clk_i,
    input  logic rst_i,
    input  logic call0_i,
    input  logic call1_i,
    output logic open_o,
    output logic floor0_o,
    output logic floor1_o,
    output logic counter_init_o,
    input  logic counter_done_i
);

    // Instantiation of the DUV
    elevator_fsm#(ERRNO) duv(.*);

    // Binding of the DUV and the assertions module
    bind duv elevator_fsm_assertions#(ERRNO) binded(.*);

endmodule
