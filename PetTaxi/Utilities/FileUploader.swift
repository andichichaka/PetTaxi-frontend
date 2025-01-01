////
////  FileUploader.swift
////  PetTaxi
////
////  Created by Andrey on 29.12.24.
////
//
//import Foundation
//
//class FileUploader {
//    static func uploadFile(
//        url: String,
//        token: String,
//        fileData: Data,
//        fieldName: String,
//        fileName: String,
//        mimeType: String,
//        completion: @escaping (Result<Void, Error>) -> Void
//    ) {
//        guard let uploadURL = URL(string: url) else {
//            completion(.failure(NSError(domain: "FileUploader", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
//            return
//        }
//
//        var request = URLRequest(url: uploadURL)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let boundary = UUID().uuidString
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        
//        var body = Data()
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
//        body.append(fileData)
//        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
//        request.httpBody = body
//        
//        URLSession.shared.dataTask(with: request) { _, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                completion(.failure(NSError(domain: "FileUploader", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error or unauthorized"])))
//                return
//            }
//            
//            completion(.success(()))
//        }.resume()
//    }
//}
