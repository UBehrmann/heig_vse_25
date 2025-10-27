module alu_assertions#(int SIZE = 8, int ERRNO = 0)(
    input logic[SIZE-1:0] a_i,
    input logic[SIZE-1:0] b_i,
    input logic[SIZE-1:0] s_o,
    input logic           c_o,
    input logic[2:0]      mode_i
);

    // Internal clock for assertions
    bit clk = 0;
    always #5 clk = ~clk;

    // Check assertions only when ERRNO is in valid range (0-15)
    bit check_enable = (ERRNO >= 0 && ERRNO <= 15);
    
    // Check all modes at each clock edge
    always @(posedge clk) begin
        automatic logic[SIZE:0] expected_add = {1'b0, a_i} + {1'b0, b_i};
        automatic logic[SIZE:0] expected_sub = {1'b0, a_i} - {1'b0, b_i};
        
        if (check_enable) begin
            // Mode 000: Addition
            if (mode_i == 3'b000)
                assert_mode_000: assert (s_o == expected_add[SIZE-1:0] && c_o == expected_add[SIZE])
                    else $error("Addition failed: a=%0d + b=%0d, expected s=%0d c=%0b, got s=%0d c=%0b", 
                                a_i, b_i, expected_add[SIZE-1:0], expected_add[SIZE], s_o, c_o);
            
            // Mode 001: Subtraction
            if (mode_i == 3'b001)
                assert_mode_001: assert (s_o == expected_sub[SIZE-1:0] && c_o == expected_sub[SIZE])
                    else $error("Subtraction failed: a=%0d - b=%0d, expected s=%0d c=%0b, got s=%0d c=%0b", 
                                a_i, b_i, expected_sub[SIZE-1:0], expected_sub[SIZE], s_o, c_o);
            
            // Mode 010: OR
            if (mode_i == 3'b010)
                assert_mode_010: assert (s_o == (a_i | b_i))
                    else $error("OR failed: a=%0d | b=%0d, expected s=%0d, got s=%0d", 
                                a_i, b_i, (a_i | b_i), s_o);
            
            // Mode 011: AND
            if (mode_i == 3'b011)
                assert_mode_011: assert (s_o == (a_i & b_i))
                    else $error("AND failed: a=%0d & b=%0d, expected s=%0d, got s=%0d", 
                                a_i, b_i, (a_i & b_i), s_o);
            
            // Mode 100: Pass A
            if (mode_i == 3'b100)
                assert_mode_100: assert (s_o == a_i)
                    else $error("Pass A failed: expected s=%0d, got s=%0d", a_i, s_o);
            
            // Mode 101: Pass B
            if (mode_i == 3'b101)
                assert_mode_101: assert (s_o == b_i)
                    else $error("Pass B failed: expected s=%0d, got s=%0d", b_i, s_o);
            
            // Mode 110: Equality
            if (mode_i == 3'b110)
                assert_mode_110: assert (s_o[0] == (a_i == b_i))
                    else $error("Equality failed: a=%0d, b=%0d, expected s[0]=%0b, got s[0]=%0b", 
                                a_i, b_i, (a_i == b_i), s_o[0]);
            
            // Mode 111: Zero
            if (mode_i == 3'b111)
                assert_mode_111: assert (s_o == '0)
                    else $error("Zero failed: expected s=0, got s=%0d", s_o);
        end
    end

endmodule
