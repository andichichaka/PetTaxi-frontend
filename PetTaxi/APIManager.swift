//
//  APIManager.swift
//  PetTaxi
//
//  Created by Andrey on 24.12.24.
//

import Foundation

class APIManager {
    static let shared = APIManager()

    func makeAuthenticatedRequest(apiURL: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let token = TokenManager.shared.getToken() else {
            print("No token found")
            return
        }

        guard let url = URL(string: apiURL) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
    }
}

//func makeAuthenticatedRequest(apiURL: String, completion: @escaping (Result<Data, Error>) -> Void) {
//    guard let token = TokenManager.shared.getToken() else {
//        completion(.failure(NSError(domain: "TokenManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token found"])))
//        return
//    }
//
//    guard let url = URL(string: apiURL) else {
//        completion(.failure(NSError(domain: "API", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
//        return
//    }
//
//    var request = URLRequest(url: url)
//    request.httpMethod = "GET"
//    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//    let task = URLSession.shared.dataTask(with: request) { data, response, error in
//        if let error = error {
//            completion(.failure(error))
//            return
//        }
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            completion(.failure(NSError(domain: "API", code: 500, userInfo: [NSLocalizedDescriptionKey: "No response from server"])))
//            return
//        }
//
//        if httpResponse.statusCode == 200, let data = data {
//            completion(.success(data))
//        } else if httpResponse.statusCode == 401 {
//            completion(.failure(NSError(domain: "API", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
//        } else {
//            completion(.failure(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
//        }
//    }
//    task.resume()
//}
