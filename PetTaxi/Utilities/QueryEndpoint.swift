//
//  QueryEndpoint.swift
//  PetTaxi
//
//  Created by Andrey on 15.01.25.
//

import Foundation

struct QueryEndpoint {
    static func createURL(path: String, queryItems: [URLQueryItem]) -> String {
        var components = URLComponents(string: path)!
        components.queryItems = queryItems
        
        guard let fullURL = components.url?.absoluteString else {
            fatalError("Failed to construct a valid URL with query parameters")
        }
        return fullURL
    }
}
