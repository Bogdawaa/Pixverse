//
//  ContentSectionViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

protocol ContentSectionViewModelProtocol: ObservableObject {
    var sections: [ContentSection] { get }
    
    func fetchContent()
    func didTapShowAll(for section: ContentSectionType)
}

final class ContentSectionViewModel: ContentSectionViewModelProtocol {
    
    @Published private(set) var sections: [ContentSection] = []
    
    init() {
        fetchContent()
    }
    
    func fetchContent() {
        sections = [
            ContentSection(
                type: .videoTemplates,
                items: [
                    ContentItem(title: "Fun-tastic Mermaid", imageName: "funtasticMermaid"),
                    ContentItem(title: "Subject 3 Fever", imageName: "subject3fever")
                ]
            ),
            ContentSection(
                type: .videoStyles,
                items: [
                    ContentItem(title: "Anime", imageName: "anime"),
                    ContentItem(title: "Voxel art", imageName: "voxelArt")
                ]
            ),
            ContentSection(
                type: .photoStyles,
                items: [
                    ContentItem(title: "Cyberpunk", imageName: "cyberpunk"),
                    ContentItem(title: "Amigurumi", imageName: "amigurumi")
                ]
            )
        ]
    }
    
    func didTapShowAll(for section: ContentSectionType) {
        print("Show all tapped for \(section.rawValue)")
    }
}
