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
    case uploadPic
    case updatePic
    case setRole
    case updateProfile
    case createPost
    case getProfile
    case filterPosts(String)
    case verifyEmail
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
        case .uploadPic:
            return "\(baseURL)/profile/upload-profile-pic"
        case .updatePic:
            return "\(baseURL)/profile/update-profile-pic"
        case .setRole:
            return "\(baseURL)/profile/set-role"
        case .updateProfile:
            return "\(baseURL)/profile/update"
        case .createPost:
            return "\(baseURL)/posts/create"
        case .getProfile:
            return "\(baseURL)/profile"
        case .filterPosts(let filter):
            return "\(baseURL)/posts/search?\(filter)"
        case .verifyEmail:
            return "\(baseURL)/auth/verify-email"
        case .custom(let customPath):
            return "\(baseURL)/\(customPath)"
        }
    }

    var method: HTTPMethod {
            switch self {
            case .signUp, .logIn, .createPost, .uploadPic, .verifyEmail:
                return .POST
            case .fetchPosts, .getProfile, .filterPosts:
                return .GET
            case .updatePic, .updateProfile:
                return .PUT
            case .setRole:
                return .PATCH
            case .custom:
                return .PUT
            }
        }
}

extension Endpoint {
    static func customWithQuery(_ path: String, _ queryItems: [URLQueryItem]) -> Endpoint {
        let fullPath = QueryEndpoint.createURL(path: "http://localhost:3000/\(path)", queryItems: queryItems)
        return .filterPosts(fullPath.replacingOccurrences(of: "http://localhost:3000/posts/search?", with: ""))
    }
}


