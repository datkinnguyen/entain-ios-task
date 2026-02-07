import Foundation
@testable import NextToGoNetworking
import Testing

@Suite("APIEndpoint Tests")
struct APIEndpointTests {

    @Test("Next races endpoint has correct method")
    func testNextRacesMethod() {
        // Given: A next races endpoint
        let endpoint = APIEndpoint.nextRaces(count: 10)

        // Then: Method should be GET
        #expect(endpoint.method == "GET")
    }

    @Test("Next races endpoint has correct path")
    func testNextRacesPath() {
        // Given: A next races endpoint
        let endpoint = APIEndpoint.nextRaces(count: 10)

        // Then: Path should be nextraces
        #expect(endpoint.path == "nextraces")
    }

    @Test("Next races endpoint builds query items correctly")
    func testNextRacesQueryItems() {
        // Given: A next races endpoint
        let endpoint = APIEndpoint.nextRaces(count: 10)

        // When: Getting query items
        let queryItems = endpoint.queryItems

        // Then: Should have method and count parameters only
        #expect(queryItems.count == 2)
        #expect(queryItems.contains(where: { $0.name == "method" && $0.value == "nextraces" }))
        #expect(queryItems.contains(where: { $0.name == "count" && $0.value == "10" }))
    }

    @Test("Build URL creates valid URL without trailing slash")
    func testBuildURLWithoutTrailingSlash() {
        // Given: A next races endpoint and base URL without trailing slash
        let endpoint = APIEndpoint.nextRaces(count: 10)
        let baseURL = "https://api.neds.com.au/rest/v1/racing"

        // When: Building URL
        let url = endpoint.buildURL(baseURL: baseURL)

        // Then: URL should match expected format
        #expect(url?.absoluteString == "https://api.neds.com.au/rest/v1/racing/nextraces?method=nextraces&count=10")
    }

    @Test("Build URL creates valid URL with trailing slash")
    func testBuildURLWithTrailingSlash() {
        // Given: A next races endpoint and base URL with trailing slash
        let endpoint = APIEndpoint.nextRaces(count: 10)
        let baseURL = "https://api.neds.com.au/rest/v1/racing/"

        // When: Building URL
        let url = endpoint.buildURL(baseURL: baseURL)

        // Then: URL should match expected format without double slash
        #expect(url?.absoluteString == "https://api.neds.com.au/rest/v1/racing/nextraces?method=nextraces&count=10")
    }

    @Test("Build URL returns nil for invalid base URL")
    func testBuildURLWithInvalidBaseURL() {
        // Given: A next races endpoint and invalid base URL
        let endpoint = APIEndpoint.nextRaces(count: 10)
        let baseURL = "not a valid url"

        // When: Building URL
        let url = endpoint.buildURL(baseURL: baseURL)

        // Then: URL should be nil
        #expect(url == nil)
    }
}
