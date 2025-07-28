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
        
//        print("Request URL: \(url.absoluteString)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        if let parameters = request.parameters {
            if request.method == .GET {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                urlRequest.url = components?.url
            } else {
                let boundary = "Boundary-\(UUID().uuidString)"
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = createMultipartBody(parameters: parameters, boundary: boundary)
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
                    let responseBody = String(data: data, encoding: .utf8) ?? "No body"
                    print("Server error: \(httpResponse.statusCode), Body: \(responseBody)")
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

extension DefaultNetworkClientImpl {
    private func createMultipartBody(parameters: [String: Any], boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            if let fileData = value as? MultipartFile {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileData.fileName)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: \(fileData.mimeType)\r\n\r\n".data(using: .utf8)!)
                body.append(fileData.data)
                body.append("\r\n".data(using: .utf8)!)
            } else {
                // Handle regular parameters
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

struct MultipartFile {
    let data: Data
    let fileName: String
    let mimeType: String
    
    init(data: Data, fileName: String, mimeType: String) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
    
    static func image(data: Data, fileName: String = "image.jpg") -> MultipartFile {
        return MultipartFile(data: data, fileName: fileName, mimeType: "image/jpeg")
    }
    
    static func video(data: Data, fileName: String = "video.mp4") -> MultipartFile {
        return MultipartFile(data: data, fileName: fileName, mimeType: "video/mp4")
    }
}
