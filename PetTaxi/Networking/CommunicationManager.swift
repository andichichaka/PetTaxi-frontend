//
//  CommunicationManager.swift
//  PetTaxi
//
//  Created by Andrey on 26.12.24.
//

import Foundation

final class CommunicationManager {
    static let shared = CommunicationManager()
    private let tokenManager = TokenManager.shared

    private init() {}

    func execute<T: Decodable>(
        endpoint: Endpoint,
        body: Encodable? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, CommunicationError>) -> Void
    ) {
        // Validate URL
        guard let requestURL = URL(string: endpoint.url) else {
            completion(.failure(.invalidURL))
            return
        }

        // Create URLRequest
        var request = URLRequest(url: requestURL)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Bearer Token if available
        if let token = tokenManager.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Attach body if provided
        if let body = body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
            } catch {
                completion(.failure(.encodingFailed))
                return
            }
        }

        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }

            // Handle HTTP response status codes
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }

            // Decode response data
            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingFailed(error.localizedDescription)))
            }
        }.resume()
    }
}
