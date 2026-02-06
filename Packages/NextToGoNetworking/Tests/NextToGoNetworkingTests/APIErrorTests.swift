import Testing
import Foundation
@testable import NextToGoNetworking

@Suite("APIError Tests")
struct APIErrorTests {

    @Test("Invalid URL error has correct description")
    func testInvalidURLErrorDescription() {
        // Given: An invalid URL error
        let error = APIError.invalidURL

        // Then: Error description should be informative
        #expect(error.localizedDescription == "The API endpoint URL is invalid.")
    }

    @Test("Network error has correct description")
    func testNetworkErrorDescription() {
        // Given: A network error
        let underlyingError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet,
            userInfo: [NSLocalizedDescriptionKey: "No internet connection"]
        )
        let error = APIError.networkError(underlyingError)

        // Then: Error description should include underlying error
        let description = error.localizedDescription
        #expect(description.contains("Network error occurred"))
    }

    @Test("Invalid response error has correct description")
    func testInvalidResponseErrorDescription() {
        // Given: An invalid response error with status code
        let error = APIError.invalidResponse(statusCode: 404)

        // Then: Error description should include status code
        let description = error.localizedDescription
        #expect(description.contains("Invalid response from server"))
        #expect(description.contains("404"))
    }

    @Test("Decoding error has correct description")
    func testDecodingErrorDescription() {
        // Given: A decoding error
        let underlyingError = NSError(
            domain: "DecodingError",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"]
        )
        let error = APIError.decodingError(underlyingError)

        // Then: Error description should include underlying error
        let description = error.localizedDescription
        #expect(description.contains("Failed to decode response"))
        #expect(description.contains("Invalid JSON structure"))
    }

    @Test("APIError conforms to LocalizedError")
    func testAPIErrorConformsToLocalisedError() {
        // Given: Various API errors
        let errors: [APIError] = [
            .invalidURL,
            .networkError(NSError(domain: "test", code: 0)),
            .invalidResponse(statusCode: 500),
            .decodingError(NSError(domain: "test", code: 0))
        ]

        // Then: All errors should provide localised descriptions
        for error in errors {
            #expect(!error.localizedDescription.isEmpty)
        }
    }
}
