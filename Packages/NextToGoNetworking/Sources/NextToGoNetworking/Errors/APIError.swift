import Foundation

/// Represents errors that can occur during API operations
public enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API endpoint URL is invalid."
        case .networkError(let error):
            return "Network error occurred: \(error.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "Invalid response from server with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
