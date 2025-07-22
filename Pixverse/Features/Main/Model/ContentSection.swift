//
//  ContentSection.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

enum ContentSectionType: Hashable {
    case videoTemplates
    case videoStyles
    case photoStyles
    case custom(title: String)
    
    var title: String {
        switch self {
        case .videoTemplates: return "Popular Video Templates"
        case .videoStyles: return "Popular Video Styles"
        case .photoStyles: return "Popular Photo Styles"
        case .custom(let title): return title
        }
    }
}

struct ContentSection: Identifiable, Hashable {
    let id = UUID()
    let type: ContentSectionType
    var items: [any ContentItemProtocol]
    var showAllButton: Bool = true
    
    static func == (lhs: ContentSection, rhs: ContentSection) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.items.map { $0.id } == rhs.items.map { $0.id } &&
        lhs.showAllButton == rhs.showAllButton
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(items.map { $0.id })
        hasher.combine(showAllButton)
    }
}

