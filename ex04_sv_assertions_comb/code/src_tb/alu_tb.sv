
module alu_tb#(int SIZE = 8, int ERRNO = 0);
    
    
    logic[SIZE-1:0] a_sti;
    logic[SIZE-1:0] b_sti;
    logic[2:0] mode_sti;

    logic[SIZE-1:0] s_obs;
    logic c_obs;

    logic clk = 0;
    
    // génération de l'horloge
    always #5 clk = ~clk;
    
    
    // clocking block
    default clocking cb @(posedge clk);
    endclocking

    alu#(SIZE,ERRNO) duv (.a_i(a_sti),
                          .b_i(b_sti),
                          .s_o(s_obs),
                          .c_o(c_obs),
                          .mode_i(mode_sti)
                         );


    // Binding of the DUV and the assertions module
    bind duv alu_assertions binded(.*);
    
    program TestSuite;
    
        initial begin
            for (int a = 0; a < 10; a++)
                for(int b = 0; b < 10; b++)
                    for(int mode = 0; mode < 8; mode++) begin
                        a_sti = a;
                        b_sti = b;
                        mode_sti = mode;
                        @(posedge clk);
                    end
            $finish;
        end
    
    endprogram;

endmodule
