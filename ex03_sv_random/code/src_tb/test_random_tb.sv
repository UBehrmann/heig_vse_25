/******************************************************************************
Project Math_computer

File : test_random_tb.sv
Description : This module is meant to test some random constructs.
              Currently it is far from being efficient nor useful.

Author : Y. Thoma
Team   : REDS institute

Date   : 07.11.2022

| Modifications |--------------------------------------------------------------
Ver    Date         Who    Description
1.0    07.11.2022   YTA    First version

******************************************************************************/

module test_random_tb;

    logic clk = 0;

    logic[15:0] a;
    logic[15:0] b;
    logic[15:0] c;
    logic[1:0]  m;

    // clock generation
    always #5 clk = ~clk;

    // clocking block
    default clocking cb @(posedge clk);
    endclocking


    // STest class with parity constraint
    class STest;
        rand logic[7:0] sa;
        rand logic[7:0] sb;
        
        // Constraint: If sa is even, then sb must be even
        constraint parity_c {
            (sa[0] == 0) -> (sb[0] == 0);
        }
        
        // Validation function
        function bit validate();
            bit valid = 1;
            if (sa[0] == 0 && sb[0] != 0) begin
                $display("ERROR: sa=%0d is even but sb=%0d is odd!", sa, sb);
                valid = 0;
            end
            return valid;
        endfunction
    endclass

    // RTest class with multiple constraints
    class RTest;
        rand logic[15:0] a;
        rand logic[15:0] b;
        rand logic[15:0] c;
        rand logic[1:0]  m;
        
        // STest member object
        rand STest stest_obj;
        
        // Array of STest objects (max size 10)
        rand STest stest_array[];
        
        // Bias test fields
        rand logic[7:0] bias_x;
        rand logic[7:0] bias_y;
        
        // Constraint 1: m must be in range [0, 2]
        constraint m_range_c {
            m inside {[0:2]};
        }
        
        // Constraint 2: If m == 0, then a < 10
        constraint m0_a_c {
            (m == 0) -> (a < 10);
        }
        
        // Constraint 3: If m == 1, then b in range [12, 16]
        constraint m1_b_c {
            (m == 1) -> (b inside {[12:16]});
        }
        
        // Constraint 4: c must always be greater than a + b
        constraint c_greater_c {
            c > (a + b);
        }
        
        // Constraint for array size (1 to 10 elements)
        constraint array_size_c {
            stest_array.size() inside {[1:10]};
        }
        
        // Bias constraint: if bias_x < 100, then bias_y < 50
        // This creates a significant bias compared to uniform random
        constraint bias_c {
            (bias_x < 100) -> (bias_y < 50);
        }
        
        // Constructor
        function new();
            stest_obj = new();
        endfunction
        
        // Validation function
        function bit validate();
            bit valid = 1;
            
            // Validate m in [0, 2]
            if (m > 2) begin
                $display("ERROR: m=%0d is not in [0, 2]!", m);
                valid = 0;
            end
            
            // Validate: m == 0 -> a < 10
            if (m == 0 && a >= 10) begin
                $display("ERROR: m=0 but a=%0d >= 10!", a);
                valid = 0;
            end
            
            // Validate: m == 1 -> b in [12, 16]
            if (m == 1 && (b < 12 || b > 16)) begin
                $display("ERROR: m=1 but b=%0d is not in [12, 16]!", b);
                valid = 0;
            end
            
            // Validate: c > a + b
            if (c <= (a + b)) begin
                $display("ERROR: c=%0d is not greater than a+b=%0d!", c, a+b);
                valid = 0;
            end
            
            // Validate STest object
            if (!stest_obj.validate()) begin
                valid = 0;
            end
            
            // Validate all STest array elements
            foreach (stest_array[i]) begin
                if (!stest_array[i].validate()) begin
                    $display("ERROR: stest_array[%0d] validation failed!", i);
                    valid = 0;
                end
            end
            
            return valid;
        endfunction
        
        // Display function for debugging
        function void display();
            $display("RTest: a=%0d, b=%0d, c=%0d, m=%0d", a, b, c, m);
            $display("  stest_obj: sa=%0d, sb=%0d", stest_obj.sa, stest_obj.sb);
            $display("  stest_array size=%0d", stest_array.size());
            foreach (stest_array[i]) begin
                $display("    stest_array[%0d]: sa=%0d, sb=%0d", i, stest_array[i].sa, stest_array[i].sb);
            end
            $display("  bias_x=%0d, bias_y=%0d", bias_x, bias_y);
        endfunction
    endclass


    task test_case0();
        RTest rtest_obj;
        int error_count = 0;
        int success_count = 0;
        
        // Bias quantification variables
        int bias_x_lt_100_count = 0;
        int bias_y_lt_50_count = 0;
        int both_conditions_count = 0;
        
        a = 0;
        b = 0;
        c = 0;
        m = 0;

        // Create the object
        rtest_obj = new();
        
        $display("=== Starting 1000 randomizations ===");
        ##1;

        repeat (1000) begin
            // Randomize the object
            if (!rtest_obj.randomize()) begin
                $display("ERROR: Randomization failed!");
                error_count++;
            end else begin
                // Validate constraints
                if (!rtest_obj.validate()) begin
                    $display("ERROR: Constraint validation failed!");
                    rtest_obj.display();
                    error_count++;
                end else begin
                    success_count++;
                end
                
                // Collect bias statistics
                if (rtest_obj.bias_x < 100) bias_x_lt_100_count++;
                if (rtest_obj.bias_y < 50) bias_y_lt_50_count++;
                if (rtest_obj.bias_x < 100 && rtest_obj.bias_y < 50) both_conditions_count++;
            end
            
            // Apply its values to the signals (for nice view in the chronogram)
            a = rtest_obj.a;
            b = rtest_obj.b;
            c = rtest_obj.c;
            m = rtest_obj.m;
            ##1;
        end
        
        // Display summary statistics
        $display("\n=== Randomization Summary ===");
        $display("Total iterations: 1000");
        $display("Successful: %0d", success_count);
        $display("Errors: %0d", error_count);
        
        // Display bias analysis
        $display("\n=== Bias Analysis ===");
        $display("Constraint: (bias_x < 100) -> (bias_y < 50)");
        $display("Times bias_x < 100: %0d (%.1f%%)", bias_x_lt_100_count, (bias_x_lt_100_count * 100.0) / 1000);
        $display("Times bias_y < 50: %0d (%.1f%%)", bias_y_lt_50_count, (bias_y_lt_50_count * 100.0) / 1000);
        $display("Times both conditions met: %0d (%.1f%%)", both_conditions_count, (both_conditions_count * 100.0) / 1000);
        
        // Theoretical analysis without solver (pure random)
        $display("\n=== Theoretical Pure Random (without constraint solver) ===");
        $display("P(bias_x < 100) = 100/256 = %.1f%%", (100.0/256.0) * 100);
        $display("P(bias_y < 50) = 50/256 = %.1f%%", (50.0/256.0) * 100);
        $display("P(both) without constraint = %.1f%%", (100.0/256.0) * (50.0/256.0) * 100);
        
        $display("\n=== Observed vs Pure Random Comparison ===");
        $display("With constraint solver:");
        $display("  P(bias_x < 100 AND bias_y < 50) = %.1f%%", (both_conditions_count * 100.0) / 1000);
        $display("Pure random would give:");
        $display("  P(bias_x < 100 AND bias_y < 50) = %.1f%%", (100.0/256.0) * (50.0/256.0) * 100);
        $display("Bias factor: %.2fx more likely with constraint solver", 
                 ((both_conditions_count * 100.0) / 1000) / ((100.0/256.0) * (50.0/256.0) * 100));
        
        $display("\n=== Analysis ===");
        $display("The implication constraint (bias_x < 100) -> (bias_y < 50) creates a bias where:");
        $display("- When bias_x < 100, bias_y is forced to be < 50");
        $display("- When bias_x >= 100, bias_y can be any value [0,255]");
        $display("This significantly increases the probability of both conditions being true");
        $display("compared to pure random generation without constraint solving.");
    endtask



    // Program launched at simulation start
    program TestSuite;
        initial begin
            test_case0();
            $stop;
        end

    endprogram

endmodule
