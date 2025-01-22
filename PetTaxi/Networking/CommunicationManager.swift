//
//  CommunicationManager.swift
//  PetTaxi
//
//  Created by Andrey on 26.12.24.
//

import Foundation
import UIKit

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
        
        print("\(requestURL)")

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
                print("Failed to decode response: \(error)")
                print("Raw response: \(String(data: data, encoding: .utf8) ?? "Invalid Data")")
                completion(.failure(.decodingFailed(error.localizedDescription)))
            }
        }.resume()
    }
}

extension CommunicationManager {
    func uploadFile(
        endpoint: Endpoint,
        fileData: Data,
        fieldName: String,
        fileName: String,
        mimeType: String,
        completion: @escaping (Result<Void, CommunicationError>) -> Void
    ) {
        guard let url = URL(string: endpoint.url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        if let token = tokenManager.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("\(token)")
        }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.httpError((response as? HTTPURLResponse)?.statusCode ?? -1)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
}
