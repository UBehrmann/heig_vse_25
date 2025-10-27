module alu_tb#(int SIZE = 8, int ERRNO = 0);
    
    // Signals
    logic[SIZE-1:0] a_sti, b_sti;
    logic[2:0]      mode_sti;
    logic[SIZE-1:0] s_obs;
    logic           c_obs;
    logic           clk = 0;
    
    // Clock generation
    always #5 clk = ~clk;

    // DUV instantiation
    alu#(SIZE, ERRNO) duv (
        .a_i(a_sti),
        .b_i(b_sti),
        .s_o(s_obs),
        .c_o(c_obs),
        .mode_i(mode_sti)
    );

    // Bind assertions module
    bind duv alu_assertions binded(.*);
    
    // Coverage group
    covergroup cg_alu @(posedge clk);
        cp_mode: coverpoint mode_sti {
            bins modes[] = {[0:7]};
        }
        cp_a: coverpoint a_sti {
            bins zero = {0};
            bins max  = {(2**SIZE)-1};
            bins others = default;
        }
        cp_b: coverpoint b_sti {
            bins zero = {0};
            bins max  = {(2**SIZE)-1};
            bins others = default;
        }
        cx_mode_a: cross cp_mode, cp_a;
        cx_mode_b: cross cp_mode, cp_b;
    endgroup
    
    // Test program
    program TestSuite;
        cg_alu cov;
        int tests = 0;
        
        initial begin
            cov = new();
            
            // Directed tests
            $display("=== Running directed tests ===");
            for (int a = 0; a < 10; a++)
                for(int b = 0; b < 10; b++)
                    for(int mode = 0; mode < 8; mode++) begin
                        a_sti = a[SIZE-1:0];
                        b_sti = b[SIZE-1:0];
                        mode_sti = mode[2:0];
                        @(posedge clk);
                        tests++;
                    end
            
            // Random tests until 100% coverage
            $display("=== Starting random testing ===");
            while (cov.get_coverage() < 100.0 && tests < 10000) begin
                a_sti = $urandom;
                b_sti = $urandom;
                mode_sti = $urandom;
                @(posedge clk);
                tests++;
                if (tests % 1000 == 0)
                    $display("Tests: %0d, Coverage: %.2f%%", tests, cov.get_coverage());
            end
            
            // Report
            $display("=== Complete ===");
            $display("Tests: %0d, Coverage: %.2f%%", tests, cov.get_coverage());
            $finish;
        end
    endprogram

endmodule