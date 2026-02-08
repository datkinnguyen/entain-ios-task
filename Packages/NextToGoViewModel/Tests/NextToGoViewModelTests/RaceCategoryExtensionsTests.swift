import Foundation
import NextToGoCore
@testable import NextToGoViewModel
import Testing

@Suite("RaceCategory Extensions Tests")
struct RaceCategoryExtensionsTests {

    // MARK: - Icon Name Tests

    @Test("Horse category returns correct icon name")
    func testHorseCategoryIconName() {
        let category: RaceCategory = .horse
        #expect(category.iconName == "horse-racing")
    }

    @Test("Harness category returns correct icon name")
    func testHarnessCategoryIconName() {
        let category: RaceCategory = .harness
        #expect(category.iconName == "harness-racing")
    }

    @Test("Greyhound category returns correct icon name")
    func testGreyhoundCategoryIconName() {
        let category: RaceCategory = .greyhound
        #expect(category.iconName == "greyhound-racing")
    }

    // MARK: - Accessibility Label Tests (without "racing")

    @Test("Horse category returns correct accessibility label")
    func testHorseCategoryAccessibilityLabel() {
        let category: RaceCategory = .horse
        #expect(category.accessibilityLabel == "Horse")
    }

    @Test("Harness category returns correct accessibility label")
    func testHarnessCategoryAccessibilityLabel() {
        let category: RaceCategory = .harness
        #expect(category.accessibilityLabel == "Harness")
    }

    @Test("Greyhound category returns correct accessibility label")
    func testGreyhoundCategoryAccessibilityLabel() {
        let category: RaceCategory = .greyhound
        #expect(category.accessibilityLabel == "Greyhound")
    }

    // MARK: - Racing Accessibility Label Tests (with "racing")

    @Test("Horse category returns correct racing accessibility label")
    func testHorseCategoryRacingAccessibilityLabel() {
        let category: RaceCategory = .horse
        #expect(category.racingAccessibilityLabel == "Horse racing")
    }

    @Test("Harness category returns correct racing accessibility label")
    func testHarnessCategoryRacingAccessibilityLabel() {
        let category: RaceCategory = .harness
        #expect(category.racingAccessibilityLabel == "Harness racing")
    }

    @Test("Greyhound category returns correct racing accessibility label")
    func testGreyhoundCategoryRacingAccessibilityLabel() {
        let category: RaceCategory = .greyhound
        #expect(category.racingAccessibilityLabel == "Greyhound racing")
    }

}
