//
//  ContentSection.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

enum ContentSectionType: String, CaseIterable {
    case videoTemplates = "Popular Video Templates"
    case videoStyles = "Popular Video Styles"
    case photoStyles = "Popular Photo Styles"
}

struct ContentSection: Identifiable {
    let id = UUID()
    let type: ContentSectionType
    var items: [TemplateItem]
    var showAllButton: Bool = true
}

