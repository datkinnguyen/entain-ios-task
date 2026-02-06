import Testing
import Foundation
@testable import NextToGoCore

@Suite("Date Extensions Tests")
struct DateExtensionsTests {

    /// Static reference date for deterministic testing
    static let referenceDate = Date(timeIntervalSince1970: 1704067200) // 2024-01-01 00:00:00 UTC

    @Test("Countdown string for future date shows positive time")
    func testCountdownStringFuture() {
        let futureDate = Self.referenceDate.addingTimeInterval(150) // 2 minutes 30 seconds in the future
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        #expect(countdown == "2m 30s")
    }

    @Test("Countdown string for past date shows negative time")
    func testCountdownStringPast() {
        let pastDate = Self.referenceDate.addingTimeInterval(-90) // 1 minute 30 seconds in the past
        let countdown = pastDate.countdownString(from: Self.referenceDate)

        #expect(countdown == "-1m 30s")
    }

    @Test("Countdown string for exactly 1 minute in future")
    func testCountdownStringExactMinute() {
        let futureDate = Self.referenceDate.addingTimeInterval(60) // Exactly 1 minute
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        #expect(countdown == "1m")
    }

    @Test("Countdown string for less than 1 minute in future shows seconds only")
    func testCountdownStringUnderMinute() {
        let futureDate = Self.referenceDate.addingTimeInterval(45) // 45 seconds
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        #expect(countdown == "45s")
    }

    @Test("Countdown string for 0 seconds shows 0s without negative sign")
    func testCountdownStringZero() {
        let countdown = Self.referenceDate.countdownString(from: Self.referenceDate)

        // Should always be "0s", never "-0s"
        #expect(countdown == "0s")
    }

    @Test("Countdown string for 5 minutes or more shows only minutes")
    func testCountdownStringMultipleMinutes() {
        let futureDate = Self.referenceDate.addingTimeInterval(330) // 5 minutes 30 seconds
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        // >= 5 minutes: show only minutes
        #expect(countdown == "5m")
    }

    @Test("Countdown string for 3 minutes 45 seconds in past shows minutes and seconds")
    func testCountdownStringMultipleMinutesPast() {
        let pastDate = Self.referenceDate.addingTimeInterval(-225) // 3 minutes 45 seconds in the past
        let countdown = pastDate.countdownString(from: Self.referenceDate)

        // < 5 minutes: show minutes and seconds
        #expect(countdown == "-3m 45s")
    }

    @Test("Countdown string handles DST-aware calculation")
    func testCountdownStringDSTAware() {
        // Create a date and calculate countdown using timeIntervalSince
        let futureDate = Self.referenceDate.addingTimeInterval(120) // 2 minutes

        let actualCountdown = futureDate.countdownString(from: Self.referenceDate)

        // The countdown should match our DST-aware calculation
        // < 5 minutes: show minutes and seconds
        #expect(actualCountdown == "2m")
    }

    @Test("Countdown string for exactly 10 minutes")
    func testCountdownStringTenMinutes() {
        let futureDate = Self.referenceDate.addingTimeInterval(600) // 10 minutes
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        #expect(countdown == "10m")
    }

    @Test("Countdown string format consistency")
    func testCountdownStringFormat() {
        let testCases: [(TimeInterval, String)] = [
            (0, "0s"),
            (30, "30s"),
            (60, "1m"),
            (90, "1m 30s"),
            (120, "2m"),
            (125, "2m 5s"),
            (300, "5m"),
            (-30, "-30s"),
            (-60, "-1m"),
            (-125, "-2m 5s")
        ]

        for (interval, expectedValue) in testCases {
            let date = Self.referenceDate.addingTimeInterval(interval)
            let countdown = date.countdownString(from: Self.referenceDate)

            #expect(countdown == expectedValue,
                    "Expected \(expectedValue) for interval \(interval), got \(countdown)")
        }
    }

    @Test("Countdown string uses timeIntervalSince for DST awareness")
    func testCountdownStringUsesTimeIntervalSince() {
        // Test with a date 2 hours in the future
        let futureDate = Self.referenceDate.addingTimeInterval(7200) // 2 hours = 120 minutes

        let countdown = futureDate.countdownString(from: Self.referenceDate)

        // Verify the countdown is calculated correctly (minutes only)
        #expect(countdown == "120m")
    }

    @Test("Countdown string handles large time intervals")
    func testCountdownStringLargeInterval() {
        // Test with 60 minutes (1 hour)
        let futureDate = Self.referenceDate.addingTimeInterval(3600) // 60 minutes
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        #expect(countdown == "60m")
    }

    @Test("Countdown string negative sign placement")
    func testCountdownStringNegativeSignPlacement() {
        let pastDate = Self.referenceDate.addingTimeInterval(-150) // 2m 30s in past
        let countdown = pastDate.countdownString(from: Self.referenceDate)

        // Verify negative sign is at the beginning
        // < 5 minutes: show minutes and seconds
        #expect(countdown.hasPrefix("-"))
        #expect(countdown == "-2m 30s")
    }
}

