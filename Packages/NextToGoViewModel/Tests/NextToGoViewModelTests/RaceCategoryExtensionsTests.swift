import Foundation
import NextToGoCore
@testable import NextToGoViewModel
import Testing

@Suite("RaceCategory Extensions Tests")
struct RaceCategoryExtensionsTests {

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

}
