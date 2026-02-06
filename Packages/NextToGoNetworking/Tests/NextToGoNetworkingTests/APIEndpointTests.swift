import Foundation
@testable import NextToGoNetworking
import Testing

@Suite("APIEndpoint Tests")
struct APIEndpointTests {

    @Test("Next races endpoint has correct method")
    func testNextRacesMethod() {
        // Given: A next races endpoint
        let endpoint = APIEndpoint.nextRaces(count: 10, categoryIds: nil)

        // Then: Method should be GET
        #expect(endpoint.method == "GET")
    }

    @Test("Next races endpoint has correct path")
    func testNextRacesPath() {
        // Given: A next races endpoint
        let endpoint = APIEndpoint.nextRaces(count: 10, categoryIds: nil)

        // Then: Path should be nextraces
        #expect(endpoint.path == "nextraces")
    }

    @Test("Next races endpoint builds query items correctly without category IDs")
    func testNextRacesQueryItemsWithoutCategories() {
        // Given: A next races endpoint without category IDs
        let endpoint = APIEndpoint.nextRaces(count: 10, categoryIds: nil)

        // When: Getting query items
        let queryItems = endpoint.queryItems

        // Then: Should have method and count parameters
        #expect(queryItems.count == 2)
        #expect(queryItems.contains(where: { $0.name == "method" && $0.value == "nextraces" }))
        #expect(queryItems.contains(where: { $0.name == "count" && $0.value == "10" }))
    }

    @Test("Next races endpoint builds query items correctly with category IDs")
    func testNextRacesQueryItemsWithCategories() {
        // Given: A next races endpoint with category IDs
        let categoryIds = ["9daef0d7-bf3c-4f50-921d-8e818c60fe61", "161d9be2-e909-4326-8c2c-35ed71fb460b"]
        let endpoint = APIEndpoint.nextRaces(count: 5, categoryIds: categoryIds)

        // When: Getting query items
        let queryItems = endpoint.queryItems

        // Then: Should have method, count, and category_ids parameters
        #expect(queryItems.count == 3)
        #expect(queryItems.contains(where: { $0.name == "method" && $0.value == "nextraces" }))
        #expect(queryItems.contains(where: { $0.name == "count" && $0.value == "5" }))

        let categoryItem = queryItems.first(where: { $0.name == "category_ids" })
        #expect(categoryItem != nil)
        #expect(categoryItem?.value?.contains("9daef0d7-bf3c-4f50-921d-8e818c60fe61") == true)
        #expect(categoryItem?.value?.contains("161d9be2-e909-4326-8c2c-35ed71fb460b") == true)
    }

    @Test("Build URL creates valid URL without trailing slash")
    func testBuildURLWithoutTrailingSlash() {
        // Given: A next races endpoint and base URL without trailing slash
        let endpoint = APIEndpoint.nextRaces(count: 10, categoryIds: nil)
        let baseURL = "https://api.neds.com.au/rest/v1/racing"

        // When: Building URL
        let url = endpoint.buildURL(baseURL: baseURL)

        // Then: URL should match expected format
        #expect(url?.absoluteString == "https://api.neds.com.au/rest/v1/racing/nextraces?method=nextraces&count=10")
    }

    @Test("Build URL creates valid URL with trailing slash")
    func testBuildURLWithTrailingSlash() {
        // Given: A next races endpoint and base URL with trailing slash
        let endpoint = APIEndpoint.nextRaces(count: 10, categoryIds: nil)
        let baseURL = "https://api.neds.com.au/rest/v1/racing/"

        // When: Building URL
        let url = endpoint.buildURL(baseURL: baseURL)

        // Then: URL should match expected format without double slash
        #expect(url?.absoluteString == "https://api.neds.com.au/rest/v1/racing/nextraces?method=nextraces&count=10")
    }

    @Test("Build URL includes all query parameters")
    func testBuildURLIncludesAllParameters() {
        // Given: A next races endpoint with category IDs
        let categoryIds = ["9daef0d7-bf3c-4f50-921d-8e818c60fe61"]
        let endpoint = APIEndpoint.nextRaces(count: 15, categoryIds: categoryIds)
        let baseURL = "https://api.neds.com.au/rest/v1/racing/"

        // When: Building URL
        let url = endpoint.buildURL(baseURL: baseURL)

        // Then: URL should match expected format with all parameters
        #expect(url?.absoluteString == "https://api.neds.com.au/rest/v1/racing/nextraces?method=nextraces&count=15&category_ids=9daef0d7-bf3c-4f50-921d-8e818c60fe61")
    }

    @Test("Build URL returns nil for invalid base URL")
    func testBuildURLWithInvalidBaseURL() {
        // Given: A next races endpoint and invalid base URL
        let endpoint = APIEndpoint.nextRaces(count: 10, categoryIds: nil)
        let baseURL = "not a valid url"

        // When: Building URL
        let url = endpoint.buildURL(baseURL: baseURL)

        // Then: URL should be nil
        #expect(url == nil)
    }

    @Test("Next races endpoint handles empty category IDs array")
    func testNextRacesWithEmptyCategoryIds() {
        // Given: A next races endpoint with empty category IDs array
        let endpoint = APIEndpoint.nextRaces(count: 10, categoryIds: [])

        // When: Getting query items
        let queryItems = endpoint.queryItems

        // Then: Should not include category_ids parameter
        #expect(queryItems.count == 2)
        #expect(queryItems.contains(where: { $0.name == "category_ids" }) == false)
    }
}
