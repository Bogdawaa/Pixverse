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
    @Published var isLoading = false
    
    @Published var templates: [TemplateItem] = []
    @Published var styles: [StyleItem] = []
    @Published var error: Error?
    
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
            templates = response.templates?.map(TemplateItem.init) ?? []
            
            if !templates.isEmpty {
                sections.removeAll { $0.type == .videoTemplates }
                sections.insert(ContentSection(
                    type: .videoTemplates,
                    items: templates), at: 0)
            }
            
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.error = error
            print("Error fetching templates: \(error)")
        }
    }
    
    func didTapShowAll(for section: ContentSectionType) {
        print("Show all tapped for \(section.rawValue)")
    }
}
