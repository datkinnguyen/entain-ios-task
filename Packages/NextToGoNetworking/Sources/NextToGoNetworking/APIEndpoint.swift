import Foundation

/// Represents an API endpoint with configuration for building requests
public enum APIEndpoint {
    case nextRaces(count: Int, categoryIds: [String]?)

    /// HTTP method for the endpoint
    public var method: String {
        switch self {
        case .nextRaces:
            return "GET"
        }
    }

    /// URL path for the endpoint
    public var path: String {
        switch self {
        case .nextRaces:
            return "nextraces"
        }
    }

    /// Query items for the endpoint
    public var queryItems: [URLQueryItem] {
        switch self {
        case .nextRaces(let count, let categoryIds):
            var items = [
                URLQueryItem(name: "method", value: "nextraces"),
                URLQueryItem(name: "count", value: String(count))
            ]

            if let categoryIds = categoryIds, !categoryIds.isEmpty {
                items.append(URLQueryItem(name: "category_ids", value: categoryIds.joined(separator: ",")))
            }

            return items
        }
    }

    /// Builds a complete URL from the endpoint configuration
    /// - Parameter baseURL: The base URL string for the API
    /// - Returns: A URL if successfully built, nil otherwise
    public func buildURL(baseURL: String) -> URL? {
        guard var components = URLComponents(string: baseURL) else {
            return nil
        }

        components.path += (components.path.hasSuffix("/") ? "" : "/") + path
        components.queryItems = queryItems

        return components.url
    }
}
