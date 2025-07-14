//
//  TemplatesService.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import Foundation

protocol TemplateServiceProtocol {
    func fetchTemplates(appID: String) async throws -> TemplateResponseDTO
}

final class TemplateService: TemplateServiceProtocol {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchTemplates(appID: String) async throws -> TemplateResponseDTO {
        let endpoint = TemplatesEndpoint.getTemplates(appID: appID)
        return try await networkClient.request(endpoint)
    }
}
