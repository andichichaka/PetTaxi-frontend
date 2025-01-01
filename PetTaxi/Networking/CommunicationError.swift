//
//  CommunicationError.swift
//  PetTaxi
//
//  Created by Andrey on 27.12.24.
//

enum CommunicationError: Error {
    case invalidURL
    case encodingFailed
    case networkError(String)
    case httpError(Int)
    case noData
    case decodingFailed(String)
    case unauthorized

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .encodingFailed:
            return "Failed to encode the request body."
        case .networkError(let message):
            return "Network error: \(message)"
        case .httpError(let statusCode):
            return "HTTP error: Received status code \(statusCode)."
        case .noData:
            return "No data received from the server."
        case .decodingFailed(let message):
            return "Failed to decode the response: \(message)"
        case .unauthorized:
                    return "Unauthorized. Please log in again."
        }
    }
}
