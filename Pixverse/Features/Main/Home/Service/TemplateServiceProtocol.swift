//
//  TemplateServiceProtocol.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 20.07.2025.
//

import Foundation

protocol TemplateServiceProtocol {
    func fetchTemplates(appID: String) async throws -> TemplateResponseDTO
    func checkVideoStatus(videoId: Int) async throws -> VideoStatusResponseDTO
    
    func generateTemplateVideo(
        userId: String,
        appId: String,
        templateId: Int,
        imageData: Data
    ) async throws -> VideoGenerationResponseDTO
    
    func generateTextToVideo(
        userId: String,
        appId: String,
        prompt: String
    ) async throws -> VideoGenerationResponseDTO
    
    func generateImageToVideo(
        userId: String,
        appId: String,
        prompt: String,
        imageData: Data
    ) async throws -> VideoGenerationResponseDTO
    
    func generateVideoToVideo(
        userId: String,
        appId: String,
        templateId: Int?,
        videoData: Data
    ) async throws -> VideoGenerationResponseDTO
}
