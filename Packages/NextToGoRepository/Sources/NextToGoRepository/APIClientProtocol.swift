import Foundation
import NextToGoNetworking

/// Protocol for API client to enable dependency injection and testing
public protocol APIClientProtocol: Sendable {
    /// Fetches data from the specified endpoint and decodes it
    /// - Parameter endpoint: The API endpoint to fetch from
    /// - Returns: The decoded response of type T
    /// - Throws: APIError if the request fails or decoding fails
    func fetch<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T
}

/// Extension to make APIClient conform to APIClientProtocol
extension APIClient: APIClientProtocol {}
