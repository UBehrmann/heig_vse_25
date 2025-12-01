

#include <gtest/gtest.h>

typedef unsigned int datatype_t;

class MathComputer
{
public:
    MathComputer(int N) : N(N) {}

    ///
    /// \brief Computes a mathematical function
    /// \param a First parameter
    /// \param b Second paramter
    /// \param c Third parameter
    /// \return a**N + b * c
    ///
    /// This function returns a power of N plus b times c
    ///
    datatype_t compute(datatype_t a, datatype_t b, datatype_t c)
    {
        datatype_t result = 1;
        for (int i = 0; i < N ; i++) {
            result *= a;
        }
        result += b * c;
        return result;
    }

private:
    int N{0};
};


TEST(Computer, simpleComputation) {
    // Add your code here

    MathComputer computer(3);

    // Test random values
    // 2^3 + 3*4 = 8 + 12 = 20
    EXPECT_EQ(computer.compute(2, 3, 4), 20) << "2^3 + 3*4 should be 20"; 

    // Test with zero
    // 0^3 + 5*6 = 0 + 30 = 30
    EXPECT_EQ(computer.compute(0, 5, 6), 30) << "0^3 + 5*6 should be 30";

    // Test with max int value
    // 1^3 + 4294967295*1 = 1 + 4294967295 = 4294967296
    EXPECT_EQ(computer.compute(1, 4294967295, 1), 0) << "1^3 + 4294967295*1 should be 4294967296";

    // test with N = 0
    MathComputer computer2(0);

    // Simple test
    // 5^0 + 3*4 = 1 + 12 = 13
    EXPECT_EQ(computer2.compute(5, 3, 4), 13) << "5^0 + 3*4 should be 13";
}
