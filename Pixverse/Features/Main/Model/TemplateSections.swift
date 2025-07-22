//
//  Templates.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import Foundation

struct TemplateItem: Identifiable, ContentItemProtocol {
    let id: Int
    let templateId: Int?
    let name: String
    let category: String?
    let prompt: String
    let isActive: Bool
    let previewSmallURL: URL?
    let previewLargeURL: URL?
    
    init(from dto: TemplateDTO) {
        self.id = dto.id
        self.templateId = dto.templateId
        self.name = dto.name
        self.category = dto.category
        self.prompt = dto.prompt
        self.isActive = dto.isActive
        self.previewSmallURL = dto.previewSmall.flatMap { URL(string: $0) }
        self.previewLargeURL = dto.previewLarge.flatMap { URL(string: $0) }
    }
}

struct StyleItem: Identifiable, ContentItemProtocol {
    let id: Int
    let templateId: Int?
    let name: String
    let prompt: String
    let isActive: Bool
    let previewSmallURL: URL?
    let previewLargeURL: URL?
    
    init(from dto: StyleDTO) {
        self.id = dto.id
        self.templateId = dto.templateId
        self.name = dto.name
        self.prompt = dto.prompt
        self.isActive = dto.isActive
        self.previewSmallURL = dto.previewSmall.flatMap { URL(string: $0) }
        self.previewLargeURL = dto.previewLarge.flatMap { URL(string: $0) }
    }
}
