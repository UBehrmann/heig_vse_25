module alu_assertions#(int SIZE = 8, int ERRNO = 0)(
    input logic[SIZE-1:0] a_i,
    input logic[SIZE-1:0] b_i,
    input logic[SIZE-1:0] s_o,
    input logic           c_o,
    input logic[2:0]      mode_i
);


    bit clk = 0;

    always #5 clk = ~clk;

    // clocking block
    default clocking cb @(posedge clk);
    endclocking

    // TODO : Put your assertions

endmodule
