//
//  TemplateToVideoEndpoint.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 17.07.2025.
//

import Foundation

enum TemplateToVideoEndpoint {
    case generateVideo(
        userId: String,
        appId: String,
        templateId: Int,
        imageData: Data
    )
}

extension TemplateToVideoEndpoint: NetworkRequest {
    typealias Response = VideoGenerationResponseDTO

    var endpoint: String {
        switch self {
        case let .generateVideo(userId, appId, templateId, _):
            return "/pixverse/api/v1/template2video?userId=\(userId)&appId=\(appId)&templateId=\(templateId)"
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
