//
//  TemplateRepository.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 17.07.2025.
//

import UIKit

final class TemplateRepository {
    static let shared = TemplateRepository()
    
    private(set) var templates: [TemplateItem] = []
    private(set) var styles: [StyleItem] = []
    
    private var lastFetchDate: Date?
    private let cacheExpiration: TimeInterval = 3600
    
    private init() {}
    
    func update(templates: [TemplateItem], styles: [StyleItem]) {
        self.templates = templates
        self.styles = styles
        self.lastFetchDate = Date()
    }
    
    func getStyles() -> [StyleItem] {
        return styles
    }
    
    func getTemplates() -> [TemplateItem] {
        return templates
    }
    
    func needsToRefresh() -> Bool {
        guard let lastFetchDate = lastFetchDate else { return true }
        return Date().timeIntervalSince(lastFetchDate) > cacheExpiration
    }
}
