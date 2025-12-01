
#include <cmath>

#include <gtest/gtest.h>

/// Shows the potential rounding of floating point values.
/// For doing so, try to compare almost similar values with EXPECT_FLOAT_EQ()
///
TEST(Floating, testRounding) {
    // Add your code here

    float a = 0.1f + 0.2f;
    float b = 0.3f;
    
    // I thought i should be 0.30000001 or something like that
    // but actually this passes...
    EXPECT_EQ(a, b) << "0.1 + 0.2 shouldn't be exactly equal to 0.3";

    EXPECT_FLOAT_EQ(a, b) << "0.1 + 0.2 should be approximately equal to 0.3";
    
    float x = 1.0f / 3.0f;
    float y = 0.333333333f;

    EXPECT_FLOAT_EQ(x, y) << "1/3 should be approximately equal to 0.333333333";
}

///
/// Compute the average of square root numbers in [1, 10] in two different ways:
/// - Do the sum, then divide by 10.
/// - Do the sum of the square roots divided by 10.
///
/// Compare with ASSERT_EQ et ASSERT_FLOAT_EQ. What happens?
///
TEST(Floating, Loop) {
    // Add your code here

    float sum1 = 0.0f;
    float sum2 = 0.0f;

    for (int i = 1; i <= 10; i++) {
        sum1 += std::sqrt((float)(i));
    }

    sum1 /= 10.0f;

    for (int i = 1; i <= 10; i++) {
        sum2 += std::sqrt((float)(i)) / 10.0f;
    }

    ASSERT_EQ(sum1, sum2) << "Sum1 and Sum2 should be exactly equal";

    ASSERT_FLOAT_EQ(sum1, sum2) << "Sum1 and Sum2 should be approximately equal";

    // Both passes. I don't know why...
}

