//
//  ContentSectionViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

protocol ContentSectionViewModelProtocol: ObservableObject {
    var sections: [ContentSection] { get }
    
    func fetchTemplates() async throws
    func didTapShowAll(for section: ContentSectionType)
}

final class ContentSectionViewModel: ContentSectionViewModelProtocol {
    @Published private(set) var sections: [ContentSection] = []
    @Published private(set) var isLoading = false
    @Published var selectedSectionForAllItems: ContentSectionType? = nil
    @Published var error: Error?
    @Published var templates: [TemplateItem] = []
    @Published var styles: [StyleItem] = []
    
    private let templateService: TemplateServiceProtocol
    
    init(templateService: TemplateServiceProtocol = TemplateService(
        networkClient: DefaultNetworkClientImpl(baseURL: "https://trust.coreapis.space")
    )) {
        self.templateService = templateService
        
        Task {
            await fetchTemplates()
        }
    }
    
    @MainActor
    func fetchTemplates() async {
        
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let response = try await templateService.fetchTemplates(appID: "com.test.test")
            try processResponse(response)
            
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.error = error
            print("Error fetching templates: \(error)")
        }
    }
    
    func didTapShowAll(for section: ContentSectionType) {
        print("Show all tapped for \(section.title)")
        selectedSectionForAllItems = section
    }
    
    // MARK: - Private Methods
    @MainActor
    private func processResponse(_ response: TemplateResponseDTO) throws {
        let templates = response.templates?.map(TemplateItem.init) ?? []
        let styles = response.styles?.map(StyleItem.init) ?? []
        
        let trendingTemplates = templates.filter { $0.category?.lowercased() == "trending" }
        
        sections = createHomeSections(from: trendingTemplates, styles: styles)
        isLoading = false
    }
    
    // MARK: - Private Methods
    private func createSections(from templates: [TemplateItem], styles: [StyleItem]) -> [ContentSection] {
        var sections = [ContentSection]()
        
        // sections grouped by categories
        let groupedTemplates = Dictionary(grouping: templates, by: { $0.category ?? "Other" })
        sections += groupedTemplates.map { category, items in
            ContentSection(
                type: .custom(title: category),
                items: items,
                showAllButton: true
            )
        }
        
        // Style section
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
    
    
    private func createHomeSections(from templates: [TemplateItem], styles: [StyleItem]) -> [ContentSection] {
        var sections = [ContentSection]()
        
        // Trending templates section
        if !templates.isEmpty {
            sections.append(
                ContentSection(
                    type: .videoTemplates,
                    items: templates,
                    showAllButton: true)
            )
        }
        
        // Popular styles section
        if !styles.isEmpty {
            sections.append(
                ContentSection(
                    type: .videoStyles,
                    items: styles,
                    showAllButton: true)
            )
        }
        return sections
    }
}
