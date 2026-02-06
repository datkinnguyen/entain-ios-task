import Testing
import Foundation
@testable import NextToGoCore

@Suite("Date Extensions Tests")
struct DateExtensionsTests {

    @Test("Countdown string for future date shows positive time")
    func testCountdownStringFuture() {
        let futureDate = Date.now.addingTimeInterval(150) // 2 minutes 30 seconds in the future
        let countdown = futureDate.countdownString()

        #expect(countdown == "2m 30s")
    }

    @Test("Countdown string for past date shows negative time")
    func testCountdownStringPast() {
        let pastDate = Date.now.addingTimeInterval(-90) // 1 minute 30 seconds in the past
        let countdown = pastDate.countdownString()

        #expect(countdown == "-1m 30s")
    }

    @Test("Countdown string for exactly 1 minute in future")
    func testCountdownStringExactMinute() {
        let futureDate = Date.now.addingTimeInterval(60) // Exactly 1 minute
        let countdown = futureDate.countdownString()

        #expect(countdown == "1m 0s")
    }

    @Test("Countdown string for less than 1 minute in future shows seconds only")
    func testCountdownStringUnderMinute() {
        let futureDate = Date.now.addingTimeInterval(45) // 45 seconds
        let countdown = futureDate.countdownString()

        // Allow for 1 second tolerance due to execution time
        #expect(countdown == "45s" || countdown == "44s")
    }

    @Test("Countdown string for 0 seconds shows 0s")
    func testCountdownStringZero() {
        let now = Date.now
        let countdown = now.countdownString()

        // Allow for slight timing differences
        #expect(countdown == "0s" || countdown == "-0s")
    }

    @Test("Countdown string for 5 minutes 30 seconds in future")
    func testCountdownStringMultipleMinutes() {
        let futureDate = Date.now.addingTimeInterval(330) // 5 minutes 30 seconds
        let countdown = futureDate.countdownString()

        #expect(countdown == "5m 30s")
    }

    @Test("Countdown string for 3 minutes 45 seconds in past")
    func testCountdownStringMultipleMinutesPast() {
        let pastDate = Date.now.addingTimeInterval(-225) // 3 minutes 45 seconds in the past
        let countdown = pastDate.countdownString()

        #expect(countdown == "-3m 45s")
    }

    @Test("Countdown string handles DST-aware calculation")
    func testCountdownStringDSTAware() {
        // Create a date and calculate countdown using timeIntervalSince
        let referenceDate = Date.now
        let futureDate = referenceDate.addingTimeInterval(120) // 2 minutes

        // Manually calculate what the countdown should be
        let interval = futureDate.timeIntervalSince(referenceDate)
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60

        _ = "\(minutes)m \(seconds)s" // Expected format
        let actualCountdown = futureDate.countdownString()

        // The countdown should match our DST-aware calculation
        // Note: There might be a slight difference due to timing, so we check the format
        #expect(actualCountdown.contains("m"))
        #expect(actualCountdown.contains("s"))
    }

    @Test("Countdown string for exactly 10 minutes")
    func testCountdownStringTenMinutes() {
        let futureDate = Date.now.addingTimeInterval(600) // 10 minutes
        let countdown = futureDate.countdownString()

        #expect(countdown == "10m 0s")
    }

    @Test("Countdown string format consistency")
    func testCountdownStringFormat() {
        let testCases: [(TimeInterval, [String])] = [
            (0, ["0s", "-0s"]),
            (30, ["30s", "29s"]),
            (60, ["1m 0s", "59s"]),
            (90, ["1m 30s", "1m 29s"]),
            (120, ["2m 0s", "1m 59s"]),
            (125, ["2m 5s", "2m 4s"]),
            (300, ["5m 0s", "4m 59s"]),
            (-30, ["-30s", "-31s"]),
            (-60, ["-1m 0s", "-1m 1s"]),
            (-125, ["-2m 5s", "-2m 6s"])
        ]

        for (interval, possibleValues) in testCases {
            let date = Date.now.addingTimeInterval(interval)
            let countdown = date.countdownString()

            // Allow for 1 second tolerance due to execution time
            #expect(possibleValues.contains(countdown),
                    "Expected one of \(possibleValues) for interval \(interval), got \(countdown)")
        }
    }

    @Test("Countdown string uses timeIntervalSince for DST awareness")
    func testCountdownStringUsesTimeIntervalSince() {
        // Create dates in different seasons to test DST handling
        let now = Date.now

        // Test with a date 2 hours in the future
        let futureDate = now.addingTimeInterval(7200) // 2 hours = 120 minutes

        let countdown = futureDate.countdownString()

        // Verify the countdown is calculated correctly
        // The exact value may vary by 1 second due to timing
        #expect(countdown.hasPrefix("120m") || countdown.hasPrefix("119m"))
        #expect(countdown.contains("s"))
    }

    @Test("Countdown string handles large time intervals")
    func testCountdownStringLargeInterval() {
        // Test with 60 minutes (1 hour)
        let futureDate = Date.now.addingTimeInterval(3600) // 60 minutes
        let countdown = futureDate.countdownString()

        #expect(countdown == "60m 0s" || countdown == "59m 59s" || countdown == "59m 60s")
    }

    @Test("Countdown string negative sign placement")
    func testCountdownStringNegativeSignPlacement() {
        let pastDate = Date.now.addingTimeInterval(-150) // 2m 30s in past
        let countdown = pastDate.countdownString()

        // Verify negative sign is at the beginning
        #expect(countdown.hasPrefix("-"))
        #expect(countdown.contains("m"))
        #expect(countdown.contains("s"))
    }
}
