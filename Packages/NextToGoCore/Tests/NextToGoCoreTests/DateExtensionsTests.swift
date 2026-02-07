import Foundation
@testable import NextToGoCore
import Testing

@Suite("Date Extensions Tests")
struct DateExtensionsTests {

    /// Static reference date for deterministic testing
    static let referenceDate = Date(timeIntervalSince1970: 1704067200) // 2024-01-01 00:00:00 UTC

    @Test("Countdown string for future date shows positive time")
    func testCountdownStringFuture() {
        let futureDate = Self.referenceDate.addingTimeInterval(150) // 2 minutes 30 seconds in the future
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        #expect(countdown.text == "2m 30s")
        #expect(countdown.accessibilityText == "2 minutes")
    }

    @Test("Countdown string for past date shows negative time")
    func testCountdownStringPast() {
        let pastDate = Self.referenceDate.addingTimeInterval(-90) // 1 minute 30 seconds in the past
        let countdown = pastDate.countdownString(from: Self.referenceDate)

        #expect(countdown.text == "-1m 30s")
        #expect(countdown.accessibilityText == "1 minute")
    }

    @Test("Countdown string for exactly 1 minute in future")
    func testCountdownStringExactMinute() {
        let futureDate = Self.referenceDate.addingTimeInterval(60) // Exactly 1 minute
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        #expect(countdown.text == "1m")
        #expect(countdown.accessibilityText == "1 minute")
    }

    @Test("Countdown string for less than 1 minute in future shows seconds only")
    func testCountdownStringUnderMinute() {
        let futureDate = Self.referenceDate.addingTimeInterval(45) // 45 seconds
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        #expect(countdown.text == "45s")
        #expect(countdown.accessibilityText == "45 seconds")
    }

    @Test("Countdown string for 0 seconds shows 0s without negative sign")
    func testCountdownStringZero() {
        let countdown = Self.referenceDate.countdownString(from: Self.referenceDate)

        // Should always be "0s", never "-0s"
        #expect(countdown.text == "0s")
        #expect(countdown.accessibilityText == "0 seconds")
    }

    @Test("Countdown string for 5 minutes or more shows only minutes")
    func testCountdownStringMultipleMinutes() {
        let futureDate = Self.referenceDate.addingTimeInterval(330) // 5 minutes 30 seconds
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        // >= 5 minutes: show only minutes
        #expect(countdown.text == "5m")
        #expect(countdown.accessibilityText == "5 minutes")
    }

    @Test("Countdown string for 3 minutes 45 seconds in past shows minutes and seconds")
    func testCountdownStringMultipleMinutesPast() {
        let pastDate = Self.referenceDate.addingTimeInterval(-225) // 3 minutes 45 seconds in the past
        let countdown = pastDate.countdownString(from: Self.referenceDate)

        // < 5 minutes: show minutes and seconds (visual), only minutes (accessibility)
        #expect(countdown.text == "-3m 45s")
        #expect(countdown.accessibilityText == "3 minutes")
    }

    @Test("Countdown string handles DST-aware calculation")
    func testCountdownStringDSTAware() {
        // Create a date and calculate countdown using timeIntervalSince
        let futureDate = Self.referenceDate.addingTimeInterval(120) // 2 minutes

        let actualCountdown = futureDate.countdownString(from: Self.referenceDate)

        // The countdown should match our DST-aware calculation
        // < 5 minutes: show minutes and seconds
        #expect(actualCountdown.text == "2m")
        #expect(actualCountdown.accessibilityText == "2 minutes")
    }

    @Test("Countdown string for exactly 10 minutes")
    func testCountdownStringTenMinutes() {
        let futureDate = Self.referenceDate.addingTimeInterval(600) // 10 minutes
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        #expect(countdown.text == "10m")
        #expect(countdown.accessibilityText == "10 minutes")
    }

    @Test("Countdown string format consistency")
    func testCountdownStringFormat() {
        struct TestCase {
            let interval: TimeInterval
            let expectedText: String
            let expectedAccessibility: String
        }

        let testCases: [TestCase] = [
            TestCase(interval: 0, expectedText: "0s", expectedAccessibility: "0 seconds"),
            TestCase(interval: 30, expectedText: "30s", expectedAccessibility: "30 seconds"),
            TestCase(interval: 60, expectedText: "1m", expectedAccessibility: "1 minute"),
            TestCase(interval: 90, expectedText: "1m 30s", expectedAccessibility: "1 minute"),
            TestCase(interval: 120, expectedText: "2m", expectedAccessibility: "2 minutes"),
            TestCase(interval: 125, expectedText: "2m 5s", expectedAccessibility: "2 minutes"),
            TestCase(interval: 300, expectedText: "5m", expectedAccessibility: "5 minutes"),
            TestCase(interval: -30, expectedText: "-30s", expectedAccessibility: "30 seconds"),
            TestCase(interval: -60, expectedText: "-1m", expectedAccessibility: "1 minute"),
            TestCase(interval: -125, expectedText: "-2m 5s", expectedAccessibility: "2 minutes")
        ]

        for testCase in testCases {
            let date = Self.referenceDate.addingTimeInterval(testCase.interval)
            let countdown = date.countdownString(from: Self.referenceDate)

            #expect(
                countdown.text == testCase.expectedText,
                "Expected text \(testCase.expectedText) for interval \(testCase.interval), got \(countdown.text)"
            )
            #expect(
                countdown.accessibilityText == testCase.expectedAccessibility,
                "Expected accessibility \(testCase.expectedAccessibility) for interval \(testCase.interval), got \(countdown.accessibilityText)"
            )
        }
    }

    @Test("Countdown string uses timeIntervalSince for DST awareness")
    func testCountdownStringUsesTimeIntervalSince() {
        // Test with a date 2 hours in the future
        let futureDate = Self.referenceDate.addingTimeInterval(7200) // 2 hours = 120 minutes

        let countdown = futureDate.countdownString(from: Self.referenceDate)

        // Verify the countdown is calculated correctly (minutes only)
        #expect(countdown.text == "120m")
        #expect(countdown.accessibilityText == "120 minutes")
    }

    @Test("Countdown string handles large time intervals")
    func testCountdownStringLargeInterval() {
        // Test with 60 minutes (1 hour)
        let futureDate = Self.referenceDate.addingTimeInterval(3600) // 60 minutes
        let countdown = futureDate.countdownString(from: Self.referenceDate)

        #expect(countdown.text == "60m")
        #expect(countdown.accessibilityText == "60 minutes")
    }

    @Test("Countdown string negative sign placement")
    func testCountdownStringNegativeSignPlacement() {
        let pastDate = Self.referenceDate.addingTimeInterval(-150) // 2m 30s in past
        let countdown = pastDate.countdownString(from: Self.referenceDate)

        // Verify negative sign is at the beginning for visual text only
        #expect(countdown.text == "-2m 30s")
        // Accessibility text omits the negative sign and seconds
        #expect(countdown.accessibilityText == "2 minutes")
    }
}
