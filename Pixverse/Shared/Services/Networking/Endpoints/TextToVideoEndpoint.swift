//
//  TextToVideoEndpoint.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 19.07.2025.
//

enum TextToVideoEndpoint {
    case generateVideo(
        userId: String,
        appId: String,
        prompt: String
    )
}

extension TextToVideoEndpoint: NetworkRequest {
    typealias Response = VideoGenerationResponseDTO

    var endpoint: String {
        switch self {
        case let .generateVideo(userId, appId, prompt):
            return "/pixverse/api/v1/text2video?userId=\(userId)&appId=\(appId)&promptText=\(prompt)"
        }
    }

    var method: HTTPMethod { .POST }
    
    var headers: [String: String]? {
        [
            "accept": "application/json",
            "Content-Type": "multipart/form-data"
        ]
    }
    
    var parameters: [String: Any]? { nil }
}
