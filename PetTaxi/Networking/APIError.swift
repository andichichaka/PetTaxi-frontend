//
//  APIError.swift
//  PetTaxi
//
//  Created by Andrey on 27.12.24.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case unauthorized
    case networkError(String)
    case serverError(Int)
    case noResponse
    case noData
    case encodingError
    case decodingError(String)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let statusCode):
            return "Server error with status code \(statusCode)."
        case .noResponse:
            return "No response from server."
        case .noData:
            return "No data received from server."
        case .encodingError:
            return "Failed to encode the request body."
        case .decodingError(let message):
            return "Failed to decode the response: \(message)"
        }
    }
}
