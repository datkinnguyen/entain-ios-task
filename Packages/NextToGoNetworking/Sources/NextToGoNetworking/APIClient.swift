import Foundation
import NextToGoCore

/// Actor-based API client for thread-safe networking operations
public actor APIClient: Sendable {
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    private let baseURL: String

    /// Creates a new API client with the specified configuration
    /// - Parameters:
    ///   - baseURL: The base URL for API requests
    ///   - urlSession: The URLSession to use for requests (defaults to a configured session)
    public init(
        baseURL: String = AppConfiguration.apiBaseURL,
        urlSession: URLSession? = nil
    ) {
        self.baseURL = baseURL

        // Configure URLSession with proper timeouts
        if let urlSession {
            self.urlSession = urlSession
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = AppConfiguration.networkRequestTimeout
            configuration.timeoutIntervalForResource = AppConfiguration.networkResourceTimeout
            self.urlSession = URLSession(configuration: configuration)
        }

        // Configure decoder
        self.decoder = JSONDecoder()
    }

    /// Fetches data from the specified endpoint and decodes it
    /// - Parameter endpoint: The API endpoint to fetch from
    /// - Returns: The decoded response of type T
    /// - Throws: APIError if the request fails or decoding fails
    public func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // Build URL from endpoint
        guard let url = endpoint.buildURL(baseURL: baseURL) else {
            throw APIError.invalidURL
        }

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method

        // Perform request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(statusCode: 0)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        // Decode response
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
