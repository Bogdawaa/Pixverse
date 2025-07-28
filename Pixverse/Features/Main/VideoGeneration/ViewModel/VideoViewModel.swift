//
//  VideoGeneratorViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

// Section Types
enum TemplateTab: String, CaseIterable {
    case templates = "Templates"
    case textGeneration = "Text generation"
    case styles = "Styles"
}


final class VideoViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var selectedTab: TemplateTab = .templates
    @Published var sections: [ContentSection] = []
    @Published var selectedTemplate: TemplateItem?
    @Published var isLoading = false
    @Published var error: Error?
    
    // MARK: - Priperties
    private let templateService: TemplateServiceProtocol
    
    init(templateService: TemplateServiceProtocol = TemplateService(
        networkClient: DefaultNetworkClientImpl(baseURL: Constants.baseURL)
    )) {
        self.templateService = templateService
        self.sections = []
        
        Task {
            await fetchTemplates()
        }
    }
    
    // MARK: - Methods
    @MainActor
    func fetchTemplates() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await templateService.fetchTemplates(appID: Constants.appId)
            let templates = response.templates?.map(TemplateItem.init) ?? []
            let styles = response.styles?.map(StyleItem.init) ?? []
            
            TemplateRepository.shared.update(templates: templates, styles: styles)
            
            sections = createSections(from: templates, styles: styles)
            isLoading = false
        } catch {
            self.isLoading = false
            self.error = error
            print("Error fetching templates: \(error)")
        }
    }
    
    
    private func createSections(from templates: [TemplateItem], styles: [StyleItem]) -> [ContentSection] {
        var sections = [ContentSection]()
        
        // Group templates by category
        let groupedTemplates = Dictionary(grouping: templates, by: { $0.category ?? "Other" })
        sections += groupedTemplates.map { category, items in
            ContentSection(
                type: .custom(title: category),
                items: items,
                showAllButton: true
            )
        }
        
        // Add styles section if available
        if !styles.isEmpty {
            sections.append(
                ContentSection(
                    type: .videoStyles,
                    items: styles,
                    showAllButton: true)
            )
        }
        return sections.sorted { $0.type.title < $1.type.title }
    }
    
    func filteredSections(for tab: TemplateTab) -> [ContentSection] {
        switch tab {
        case .templates:
            return sections.filter {
                if case .custom = $0.type { return true }
                return false
            }
        case .styles:
            return sections.filter { $0.type == .videoStyles }
        case .textGeneration:
            return []
        }
    }
}
