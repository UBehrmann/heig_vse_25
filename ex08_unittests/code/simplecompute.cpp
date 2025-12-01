#include <cmath>

#include <gtest/gtest.h>

using namespace std;


double compute(double a, uint8_t b) {
    return sqrt(a) / static_cast<double>(b);
}

TEST(TestCompute, test4_2) {
    EXPECT_EQ(compute(4.0, 2), 1);
}

TEST(TestCompute, test16_2) {
    EXPECT_EQ(compute(16.0, 2), 2);
}

TEST(TestCompute, test16_0) {

    double result = compute(16.0, 0);

    // Quelque chose divisé par zéro, c'est infini
    // Donc on vérifie que le résultat est bien infini

    EXPECT_TRUE(std::isinf(result));
}


