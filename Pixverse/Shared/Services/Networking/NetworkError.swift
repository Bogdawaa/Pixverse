//
//  NetworkError.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(description: String)
    case invalidResponse
    case unauthorized
    case decodingFailed(description: String)
    case serverError(code: Int)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .requestFailed(let desc): return "Request failed: \(desc)"
        case .invalidResponse: return "Invalid response"
        case .unauthorized: return "Unauthorized"
        case .decodingFailed(let desc): return "Decoding error: \(desc)"
        case .serverError(let code): return "Server error (code: \(code))"
        }
    }
}
