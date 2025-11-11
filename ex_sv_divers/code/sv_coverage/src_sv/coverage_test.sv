
class coverage_class;
    rand logic wr;
    rand logic rd;
    rand logic[1:0] ptype;
    rand logic[7:0] address;

    // 1.
    covergroup cov_1 @(posedge clk);

        coverpoint cov_type {
            bins cov_type[] = {0,1,2,3};
        }

        coverpoint cov_rd{
            bins cov_rd = {1};
        }

        coverpoint cov_wr{
            bins cov_wr = {1};
        }

        cov_cross_rd: cross cov_rd, cov_type;
        cov_cross_wr: cross cov_wr, cov_type;

    Endgroup

    

    // 2.
    covergroup cov_address @(posedge clk);
        bins cov_low[]: adress = {[0:3]};
        bins cov_high[]: adress = {[252:255]};
        ignore_bins others = default;
    Endgroup

endclass : coverage_class


module coverage_test;

    task test_case1();
        automatic coverage_class obj = new();
        automatic int counter = 0;


        $display("Let's start test 1");

        while ($get_coverage() < 100)
        begin
            counter ++;
            void'(obj.randomize());
            // obj.cov_group_type.sample();
        end
        $display("End of test 1 after %d iterations",counter);


    endtask


    // Programme lancé au démarrage de la simulation
    program TestSuite;
        initial begin
            test_case1();
            $display("done!");
            $stop;
        end
    endprogram

endmodule : coverage_test
