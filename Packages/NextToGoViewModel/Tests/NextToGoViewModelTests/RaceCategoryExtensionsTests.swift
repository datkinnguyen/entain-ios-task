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

    @Test("All categories have unique icon names")
    func testAllCategoriesHaveUniqueIconNames() {
        let iconNames = RaceCategory.allCases.map { $0.iconName }
        let uniqueIconNames = Set(iconNames)

        #expect(iconNames.count == uniqueIconNames.count)
    }

    @Test("All categories have non-empty icon names")
    func testAllCategoriesHaveNonEmptyIconNames() {
        for category in RaceCategory.allCases {
            #expect(!category.iconName.isEmpty)
        }
    }

}
