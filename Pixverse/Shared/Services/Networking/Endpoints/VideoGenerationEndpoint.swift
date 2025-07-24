//
//  VideoStatusEndpoint.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 17.07.2025.
//

import Foundation

enum VideoStatusEndpoint {
    case checkStatus(videoId: Int)
}

extension VideoStatusEndpoint: NetworkRequest {
    typealias Response = VideoStatusResponseDTO
    
    var endpoint: String {
        switch self {
        case .checkStatus(let videoId):
            return "/pixverse/api/v1/status?id=\(videoId)"
        }
    }
    
    var method: HTTPMethod { .GET }
    var headers: [String: String]? { ["accept": "application/json"] }
    var parameters: [String: Any]? { nil }
}
