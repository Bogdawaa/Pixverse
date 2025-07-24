//
//  TemplatesDTO.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

struct TemplateResponseDTO: Decodable {
    let appId: String
    let templates: [TemplateDTO]?
    let styles: [StyleDTO]?
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case appId = "app_id"
        case templates, styles, id
    }
}

struct TemplateDTO: Decodable {
    let prompt: String
    let name: String
    let category: String?
    let isActive: Bool
    let previewSmall: String?
    let previewLarge: String?
    let id: Int
    let templateId: Int?
    
    enum CodingKeys: String, CodingKey {
        case prompt, name, category
        case isActive = "is_active"
        case previewSmall = "preview_small"
        case previewLarge = "preview_large"
        case id
        case templateId = "template_id"
    }
}

struct StyleDTO: Decodable {
    let prompt: String
    let name: String
    let isActive: Bool
    let previewSmall: String?
    let previewLarge: String?
    let id: Int
    let templateId: Int?
    
    enum CodingKeys: String, CodingKey {
        case prompt, name
        case isActive = "is_active"
        case previewSmall = "preview_small"
        case previewLarge = "preview_large"
        case id
        case templateId = "template_id"
    }
}
