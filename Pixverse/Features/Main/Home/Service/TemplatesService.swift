//
//  TemplatesService.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import Foundation

final class TemplateService: TemplateServiceProtocol {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchTemplates(appID: String) async throws -> TemplateResponseDTO {
        let endpoint = GetTemplatesEndpoint.getTemplates(appID: appID)
        return try await networkClient.request(endpoint)
    }
    
    func generateTemplateVideo(
        userId: String,
        appId: String,
        templateId: Int,
        imageData: Data
    ) async throws -> VideoGenerationResponseDTO {
        let endpoint = TemplateToVideoEndpoint.generateVideo(
            userId: userId,
            appId: appId,
            templateId: templateId,
            imageData: imageData
        )
        return try await networkClient.request(endpoint)
    }
    
    func checkVideoStatus(videoId: Int) async throws -> VideoStatusResponseDTO {
        let endpoint = VideoStatusEndpoint.checkStatus(videoId: videoId)
        return try await networkClient.request(endpoint)
    }
    
    func generateTextToVideo(
        userId: String,
        appId: String,
        prompt: String,
    ) async throws -> VideoGenerationResponseDTO {
        let endpoint = TextToVideoEndpoint.generateVideo(
            userId: userId,
            appId: appId,
            prompt: prompt
        )
        return try await networkClient.request(endpoint)
    }
    
    func generateImageToVideo(
        userId: String,
        appId: String,
        prompt: String,
        imageData: Data
    ) async throws -> VideoGenerationResponseDTO {
        let endpoint = ImageToVideoEndpoint.generateVideo(
            userId: userId,
            appId: appId,
            prompt: prompt,
            imageData: imageData
        )
        return try await networkClient.request(endpoint)
    }
    
    func generateVideoToVideo(
        userId: String,
        appId: String,
        templateId: Int?,
        videoData: Data
    ) async throws -> VideoGenerationResponseDTO {
        let endpoint = VideoToVideoEndpoint.generateVideo(
            userId: userId,
            appId: appId,
            templateId: templateId,
            videoData: videoData
        )
        return try await networkClient.request(endpoint)
    }
}
