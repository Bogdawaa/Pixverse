//
//  ImageToVideoEndpoint.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 19.07.2025.
//

import Foundation

enum ImageToVideoEndpoint {
    case generateVideo(
        userId: String,
        appId: String,
        prompt: String,
        imageData: Data
    )
}

extension ImageToVideoEndpoint: NetworkRequest {
    typealias Response = VideoGenerationResponseDTO

    var endpoint: String {
        switch self {
        case let .generateVideo(userId, appId, prompt, _):
            return "/pixverse/api/v1/image2video?userId=\(userId)&appId=\(appId)&promptText=\(prompt)"
        }
    }

    var method: HTTPMethod { .POST }
    
    var headers: [String: String]? {
        [
            "accept": "application/json",
            "Content-Type": "multipart/form-data"
        ]
    }
    
    var parameters: [String: Any]? {
        switch self {
        case let .generateVideo(_, _, _, imageData):
            return [
                "image": MultipartFile.image(data: imageData)
            ]
        }
    }
}
