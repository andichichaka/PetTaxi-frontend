//
//  Endpoint.swift
//  PetTaxi
//
//  Created by Andrey on 26.12.24.
//

import Foundation

enum Endpoint {
    case signUp
    case logIn
    case fetchPosts
    case custom(String) // For dynamic or ad-hoc URLs

    // Computed property for the base URL
    private var baseURL: String {
        return "http://localhost:3000"
    }

    // Computed property for the full URL
    var url: String {
        switch self {
        case .signUp:
            return "\(baseURL)/auth/signup"
        case .logIn:
            return "\(baseURL)/auth/login"
        case .fetchPosts:
            return "\(baseURL)/posts/get-all"
        case .custom(let customPath):
            return "\(baseURL)/\(customPath)"
        }
    }

    // Computed property for HTTP method
    var method: HTTPMethod {
        switch self {
        case .signUp, .logIn:
            return .POST
        case .fetchPosts:
            return .GET
        case .custom:
            return .GET // Default, can be overridden
        }
    }
}
