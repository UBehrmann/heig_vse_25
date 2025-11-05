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


endmodule


