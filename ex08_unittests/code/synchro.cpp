

#include <future>
#include <gtest/gtest.h>
#include <thread>

// Taken here: https://github.com/google/googletest/issues/348
#define ASSERT_DURATION_LE(secs, stmt) { \
std::promise<bool> completed; \
    auto stmt_future = completed.get_future(); \
    std::thread thread([&] { \
            stmt; \
            completed.set_value(true); \
    }); \
    if(stmt_future.wait_for(std::chrono::seconds(secs)) == std::future_status::timeout) { \
        thread.detach(); \
        GTEST_FATAL_FAILURE_("       timed out (> " #secs \
                             " seconds). Check code for interlocking"); \
} \
    else \
    thread.join(); \
}

#define ASSERT_DURATION_GE(secs, stmt) { \
std::promise<bool> completed; \
    auto stmt_future = completed.get_future(); \
    std::thread([&](std::promise<bool>& completed) { \
            stmt; \
            completed.set_value(true); \
    }, std::ref(completed)).detach(); \
    if(stmt_future.wait_for(std::chrono::seconds(secs)) != std::future_status::timeout) \
    GTEST_FATAL_FAILURE_("       The code finished while it shouldn't"); \
}


std::mutex m;
static int global = 0;
static int turn = 0;

void f1()
{
    m.lock();
    global = 1;
    m.unlock();
    while (turn != 1) ;
    m.lock();
    global = 3;
    m.unlock();
}

void f2()
{
    m.lock();
    global = 2;
    m.unlock();
    // Replace 2 by 3 to see the result
    while (turn != 2) ;
    m.lock();
    global = 4;
    m.unlock();
}

TEST(TestThread, testRounding) {
    ASSERT_DURATION_LE(1, {
        std::thread t1(f1);
        std::thread t2(f2);
        EXPECT_LE(global, 2);
        turn = 1;
        usleep(10000);
        EXPECT_EQ(global, 3);
        turn = 2;
        usleep(1000);
        EXPECT_EQ(global, 4);
        t1.join();
        t2.join();
    });

}

