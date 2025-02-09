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
        guard let requestURL = URL(string: endpoint.url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("\(requestURL)")

        var request = URLRequest(url: requestURL)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = tokenManager.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
            } catch {
                completion(.failure(.encodingFailed))
                return
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    self.tokenManager.refreshToken { success in
                        if success {
                            self.execute(endpoint: endpoint, responseType: responseType, completion: completion)
                        } else {
                            completion(.failure(.httpError(httpResponse.statusCode)))
                        }
                    }
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
            }

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
        if let token = tokenManager.getAccessToken() {
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
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    self.tokenManager.refreshToken { success in
                        if success {
                            self.uploadFile(endpoint: endpoint, fileData: fileData, fieldName: fieldName, fileName: fileName, mimeType: mimeType, completion: completion)
                        } else {
                            completion(.failure(.httpError(httpResponse.statusCode)))
                        }
                    }
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
            }
            
            completion(.success(()))
        }.resume()
    }
    
    func uploadMultipleFiles(
        endpoint: Endpoint,
        files: [(data: Data, fieldName: String, fileName: String, mimeType: String)],
        completion: @escaping (Result<Void, CommunicationError>) -> Void
    ) {
        guard let url = URL(string: endpoint.url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        if let token = tokenManager.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("\(token)")
        }
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        for file in files {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(file.fieldName)\"; filename=\"\(file.fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(file.mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(file.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    self.tokenManager.refreshToken { success in
                        if success {
                            self.uploadMultipleFiles(endpoint: endpoint, files: files, completion: completion)
                        } else {
                            completion(.failure(.httpError(httpResponse.statusCode)))
                        }
                    }
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
            }
            
            completion(.success(()))
        }.resume()
    }
}
