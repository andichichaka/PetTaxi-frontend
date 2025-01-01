//
//  APIManager.swift
//  PetTaxi
//
//  Created by Andrey on 24.12.24.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    private let tokenManager = TokenManager.shared

    private init() {}

    /// Executes an authenticated request to the provided API endpoint.
    func execute<T: Decodable>(
        apiURL: String,
        method: String = "GET",
        responseType: T.Type,
        body: Encodable? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        // Retrieve token
        guard let token = tokenManager.getToken() else {
            completion(.failure(.unauthorized))
            return
        }

        // Create URL
        guard let url = URL(string: apiURL) else {
            completion(.failure(.invalidURL))
            return
        }

        // Configure request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add body if provided
        if let body = body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
            } catch {
                completion(.failure(.encodingError))
                return
            }
        }

        // Execute request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }

            // Handle response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    completion(.failure(.unauthorized))
                } else {
                    completion(.failure(.serverError(httpResponse.statusCode)))
                }
                return
            }

            // Decode data
            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }
}
