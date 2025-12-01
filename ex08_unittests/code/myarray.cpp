#include <gtest/gtest.h>

using namespace std;

template <typename T, int SIZE>
class MyArray
{
public:
    MyArray() = default;

    void set(size_t index, T value) {
        internalArray[index] = value;
    }

    T get(size_t index) {
        if (index >= SIZE) {
            throw std::runtime_error("Index too high");
        }
        return internalArray[index];
    }

private:
    std::array<T, SIZE> internalArray;

};


template<typename T>
class MyArrayTest : public ::testing::Test
{
protected:

    ///
    /// \brief testSimpleDirected
    ///
    /// This test shall display some set() and get() at specific indices.
    ///
    void testSimpleDirected() {
        MyArray<T, 10> array;
        
        // Set and get at specific indices
        T t = T(42);
        array.set(0, t);
        EXPECT_EQ(array.get(0), t);

        T t2 = T(100);
        
        array.set(5, t2);
        EXPECT_EQ(array.get(5), t2);

        T t3 = T(255);
        
        array.set(9, t3);
        EXPECT_EQ(array.get(9), t3);
    }

    ///
    /// \brief testConsecutiveSetGet
    ///
    /// This test shall show some write and consecutive read accesses.
    /// They can be hardcoded or can use a for loop, with each time a
    /// write followed by a read at the same index.
    void testConsecutiveSetGet() {
        MyArray<T, 10> array;
        
        // Write and immediately read at the same index
        for (size_t i = 0; i < 10; i++) {
            T value = T(i * 10);
            array.set(i, value);
            EXPECT_EQ(array.get(i), value) << "Failed at index " << i;
        }
    }

    ///
    /// \brief testFullSetGet
    ///
    /// This test shall show writes in the entire array, and then reads of
    /// the entire array.
    void testFullSetGet() {
        MyArray<T, 10> array;
        
        // First, fill the entire array
        for (size_t i = 0; i < 10; i++) {
            T t = T(i * 7);
            array.set(i, t);
        }
        
        // Then, verify all values
        for (size_t i = 0; i < 10; i++) {
            T t = T(i * 7);
            EXPECT_EQ(array.get(i), t) << "Failed at index " << i;
        }
    }

    ///
    /// \brief testDoNotTouchOthers
    ///
    /// This test is meant to show that if we fill the array with values,
    /// then if we write at one address, it shouldn't change all other
    /// indices values.
    ///
    void testDoNotTouchOthers() {
        MyArray<T, 10> array;
        
        // Fill array with initial values
        for (size_t i = 0; i < 10; i++) {
            T t = T(i + 1);
            array.set(i, t);
        }
        
        // Modify one element (index 5)
        T t5 = T(999);
        array.set(5, t5);
        
        // Verify that only index 5 changed, all others remain the same
        for (size_t i = 0; i < 10; i++) {
            if (i == 5) {
                EXPECT_EQ(array.get(i), t5) << "Index 5 should be modified";
            } else {
                T t = T(i + 1);
                EXPECT_EQ(array.get(i), t) << "Index " << i << " should not be modified";
            }
        }
    }

    ///
    /// \brief testBadAccess
    ///
    /// This test is meant to detect exception throwned if bad accesses happen.
    ///
    void testBadAccess() {
        MyArray<T, 10> array;
        
        // Fill array with some values
        for (size_t i = 0; i < 10; i++) {
            T t = T(i);
            array.set(i, t);
        }
        
        // Test access at boundary (index 10 is out of bounds for size 10)
        EXPECT_THROW({
            array.get(10);
        }, std::runtime_error) << "Should throw exception for index 10";
        
        // Test access far beyond boundary
        EXPECT_THROW({
            array.get(100);
        }, std::runtime_error) << "Should throw exception for index 100";
        
        // Test access at maximum size_t (edge case)
        EXPECT_THROW({
            array.get(SIZE_MAX);
        }, std::runtime_error) << "Should throw exception for SIZE_MAX";
        
        // Verify that valid accesses still work after exceptions
        EXPECT_NO_THROW({
            array.get(0);
            array.get(9);
        }) << "Valid indices should not throw exceptions";
    }


};

using MyTypes = ::testing::Types<int,
                                 float,
                                 double
                                 >;

TYPED_TEST_SUITE(MyArrayTest, MyTypes);

TYPED_TEST(MyArrayTest, SimpleDirected) {
    this->testSimpleDirected();
}

TYPED_TEST(MyArrayTest, ConsecutiveSetGet) {
    this->testConsecutiveSetGet();
}

TYPED_TEST(MyArrayTest, FullSetFullGet) {
    this->testFullSetGet();
}

TYPED_TEST(MyArrayTest, DoNotTouchOthers) {
    this->testDoNotTouchOthers();
}


TYPED_TEST(MyArrayTest, BadAccess) {
    this->testBadAccess();
}

