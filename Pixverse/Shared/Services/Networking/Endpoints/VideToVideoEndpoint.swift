//
//  VideToVideoEndpoint.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 20.07.2025.
//

import Foundation

enum VideoToVideoEndpoint {
    case generateVideo(
        userId: String,
        appId: String,
        templateId: Int?,
        videoData: Data
    )
}

extension VideoToVideoEndpoint: NetworkRequest {
    typealias Response = VideoGenerationResponseDTO

    var endpoint: String {
        switch self {
        case let .generateVideo(userId, appId, templateId, _):
            var baseEndpoint = "/pixverse/api/v1/video2video?userId=\(userId)&appId=\(appId)"
            if let templateId = templateId {
                baseEndpoint += "&templateId=\(templateId)"
            }
            return baseEndpoint
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
        case let .generateVideo(_, _, _, videoData):
            return [
                "video": MultipartFile.video(data: videoData)
            ]
        }
    }
}
