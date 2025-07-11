//
//  NetworkClient.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import Foundation

protocol NetworkClient {
    func request<T: NetworkRequest>(_ request: T) async throws -> T.Response
}

final class DefaultNetworkClientImpl: NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL: String
    
    init(
        baseURL: String,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }
    
    func request<T: NetworkRequest>(_ request: T) async throws -> T.Response {
        guard let url = URL(string: baseURL + request.endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        if let parameters = request.parameters {
            if request.method == .GET {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                urlRequest.url = components?.url
            } else {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            }
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                if httpResponse.statusCode == 401 {
                    throw NetworkError.unauthorized
                } else {
                    throw NetworkError.serverError(code: httpResponse.statusCode)
                }
            }
            
            return try decoder.decode(T.Response.self, from: data)
        } catch let error as URLError {
            throw NetworkError.requestFailed(description: error.localizedDescription)
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(description: error.localizedDescription)
        } catch {
            throw NetworkError.requestFailed(description: error.localizedDescription)
        }
        
    }
}
