import Testing
import Foundation
@testable import NextToGoNetworking
import NextToGoCore

@Suite("APIClient Tests", .serialized)
struct APIClientTests {

    @Test("Fetch successfully decodes valid response")
    func testFetchSuccessfulResponse() async throws {
        // Given: A mock URLSession with a successful response
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        let mockJSON = """
        {
            "status": 200,
            "data": {
                "race_summaries": {
                    "race-1": {
                        "race_id": "race-1",
                        "race_name": "Race 1",
                        "race_number": 1,
                        "meeting_name": "Meeting 1",
                        "category_id": "9daef0d7-bf3c-4f50-921d-8e818c60fe61",
                        "advertised_start": {
                            "seconds": 1706745600
                        }
                    }
                }
            }
        }
        """

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockJSON.data(using: .utf8))
        }

        let apiClient = APIClient(
            baseURL: "https://api.neds.com.au/rest/v1/racing/",
            urlSession: urlSession
        )

        // When: Fetching from an endpoint
        let response: RaceResponse = try await apiClient.fetch(.nextRaces(count: 10, categoryIds: nil))

        // Then: Response should be properly decoded
        #expect(response.status == 200)
        #expect(response.races.count == 1)
        #expect(response.races[0].raceId == "race-1")
        #expect(response.races[0].raceName == "Race 1")
    }

    @Test("Fetch throws network error on connection failure")
    func testFetchNetworkError() async throws {
        // Given: A mock URLSession that fails with network error
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        MockURLProtocol.requestHandler = { request in
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        }

        let apiClient = APIClient(
            baseURL: "https://api.neds.com.au/rest/v1/racing/",
            urlSession: urlSession
        )

        // When/Then: Fetching should throw a network error
        await #expect(throws: APIError.self) {
            let _: RaceResponse = try await apiClient.fetch(.nextRaces(count: 10, categoryIds: nil))
        }
    }

    @Test("Fetch throws invalid response error on non-2xx status code")
    func testFetchInvalidResponseError() async throws {
        // Given: A mock URLSession with 404 response
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, nil)
        }

        let apiClient = APIClient(
            baseURL: "https://api.neds.com.au/rest/v1/racing/",
            urlSession: urlSession
        )

        // When/Then: Fetching should throw an invalid response error
        do {
            let _: RaceResponse = try await apiClient.fetch(.nextRaces(count: 10, categoryIds: nil))
            Issue.record("Expected APIError to be thrown")
        } catch let error as APIError {
            if case .invalidResponse(let statusCode) = error {
                #expect(statusCode == 404)
            } else {
                Issue.record("Expected invalidResponse error, got \(error)")
            }
        }
    }

    @Test("Fetch throws decoding error on invalid JSON")
    func testFetchDecodingError() async throws {
        // Given: A mock URLSession with invalid JSON
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        let invalidJSON = """
        {
            "invalid": "json"
        }
        """

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidJSON.data(using: .utf8))
        }

        let apiClient = APIClient(
            baseURL: "https://api.neds.com.au/rest/v1/racing/",
            urlSession: urlSession
        )

        // When/Then: Fetching should throw a decoding error
        await #expect(throws: APIError.self) {
            let _: RaceResponse = try await apiClient.fetch(.nextRaces(count: 10, categoryIds: nil))
        }
    }

    @Test("Fetch handles multiple concurrent requests safely")
    func testConcurrentRequests() async throws {
        // Given: A mock URLSession with successful responses
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        let mockJSON = """
        {
            "status": 200,
            "data": {
                "race_summaries": {
                    "race-1": {
                        "race_id": "race-1",
                        "race_name": "Race 1",
                        "race_number": 1,
                        "meeting_name": "Meeting 1",
                        "category_id": "9daef0d7-bf3c-4f50-921d-8e818c60fe61",
                        "advertised_start": {
                            "seconds": 1706745600
                        }
                    }
                }
            }
        }
        """

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockJSON.data(using: .utf8))
        }

        let apiClient = APIClient(
            baseURL: "https://api.neds.com.au/rest/v1/racing/",
            urlSession: urlSession
        )

        // When: Making multiple concurrent requests
        async let response1: RaceResponse = try apiClient.fetch(.nextRaces(count: 10, categoryIds: nil))
        async let response2: RaceResponse = try apiClient.fetch(.nextRaces(count: 10, categoryIds: nil))
        async let response3: RaceResponse = try apiClient.fetch(.nextRaces(count: 10, categoryIds: nil))

        let results = try await [response1, response2, response3]

        // Then: All requests should succeed
        #expect(results.count == 3)
        for result in results {
            #expect(result.status == 200)
            #expect(result.races.count == 1)
        }
    }
}
