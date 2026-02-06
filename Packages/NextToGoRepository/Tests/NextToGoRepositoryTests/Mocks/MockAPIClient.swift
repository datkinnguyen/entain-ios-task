import Foundation
import NextToGoCore
import NextToGoNetworking
@testable import NextToGoRepository

/// Mock API client for testing purposes
actor MockAPIClient: APIClientProtocol {
    var fetchHandler: ((APIEndpoint) async throws -> Any)?
    var fetchCallCount = 0
    var lastEndpoint: APIEndpoint?

    func fetch<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        fetchCallCount += 1
        lastEndpoint = endpoint

        guard let handler = fetchHandler else {
            fatalError("fetchHandler not set in MockAPIClient")
        }

        let result = try await handler(endpoint)

        guard let typedResult = result as? T else {
            fatalError("MockAPIClient: Expected type \(T.self) but got \(type(of: result))")
        }

        return typedResult
    }
}
