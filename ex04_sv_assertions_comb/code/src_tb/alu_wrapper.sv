module alu_wrapper#(int SIZE = 8, int ERRNO = 0)(
    input  logic[SIZE-1:0] a_i,
    input  logic[SIZE-1:0] b_i,
    output logic[SIZE-1:0] s_o,
    output logic           c_o,
    input  logic[2:0]      mode_i
);

    // Instantiation of the DUV
    alu#(SIZE, ERRNO) duv(.*);

    // Binding of the DUV and the assertions module
    bind duv alu_assertions binded(.*);

endmodule
