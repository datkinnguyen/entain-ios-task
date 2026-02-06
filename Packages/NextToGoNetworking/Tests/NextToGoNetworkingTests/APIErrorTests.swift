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
        #expect(description.contains("No internet connection"))
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
    func testAPIErrorConformsToLocalizedError() {
        // Given: Various API errors
        let errors: [APIError] = [
            .invalidURL,
            .networkError(NSError(domain: "test", code: 0)),
            .invalidResponse(statusCode: 500),
            .decodingError(NSError(domain: "test", code: 0))
        ]

        // Then: All errors should provide localized descriptions
        for error in errors {
            #expect(!error.localizedDescription.isEmpty)
        }
    }

    @Test("APIError is Error type")
    func testAPIErrorIsError() {
        // Given: An API error
        let error: Error = APIError.invalidURL

        // Then: Should be castable to APIError
        #expect(error is APIError)
    }

    @Test("Different error cases are distinguishable")
    func testErrorCasesAreDistinguishable() {
        // Given: Different error cases
        let invalidURL = APIError.invalidURL
        let networkError = APIError.networkError(NSError(domain: "test", code: 0))
        let invalidResponse = APIError.invalidResponse(statusCode: 404)
        let decodingError = APIError.decodingError(NSError(domain: "test", code: 0))

        // Then: Each case should be identifiable
        if case .invalidURL = invalidURL {
            #expect(true)
        } else {
            Issue.record("Expected invalidURL case")
        }

        if case .networkError = networkError {
            #expect(true)
        } else {
            Issue.record("Expected networkError case")
        }

        if case .invalidResponse = invalidResponse {
            #expect(true)
        } else {
            Issue.record("Expected invalidResponse case")
        }

        if case .decodingError = decodingError {
            #expect(true)
        } else {
            Issue.record("Expected decodingError case")
        }
    }

    @Test("Invalid response error preserves status code")
    func testInvalidResponsePreservesStatusCode() {
        // Given: Various status codes
        let statusCodes = [400, 401, 403, 404, 500, 502, 503]

        for statusCode in statusCodes {
            // When: Creating an invalid response error
            let error = APIError.invalidResponse(statusCode: statusCode)

            // Then: Status code should be preserved
            if case .invalidResponse(let code) = error {
                #expect(code == statusCode)
            } else {
                Issue.record("Expected invalidResponse case with status code \(statusCode)")
            }
        }
    }

    @Test("Network error preserves underlying error")
    func testNetworkErrorPreservesUnderlyingError() {
        // Given: An underlying network error
        let underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        let error = APIError.networkError(underlyingError)

        // Then: Underlying error should be preserved
        if case .networkError(let preserved) = error {
            let nsError = preserved as NSError
            #expect(nsError.domain == NSURLErrorDomain)
            #expect(nsError.code == NSURLErrorTimedOut)
        } else {
            Issue.record("Expected networkError case")
        }
    }

    @Test("Decoding error preserves underlying error")
    func testDecodingErrorPreservesUnderlyingError() {
        // Given: An underlying decoding error
        let underlyingError = NSError(domain: "DecodingError", code: 123)
        let error = APIError.decodingError(underlyingError)

        // Then: Underlying error should be preserved
        if case .decodingError(let preserved) = error {
            let nsError = preserved as NSError
            #expect(nsError.domain == "DecodingError")
            #expect(nsError.code == 123)
        } else {
            Issue.record("Expected decodingError case")
        }
    }
}
