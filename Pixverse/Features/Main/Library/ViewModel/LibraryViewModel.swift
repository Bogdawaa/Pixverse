//
//  LibraryViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI

final class LibraryViewModel: ObservableObject {
    
    @Published var generations: [VideoGeneration] = []
    @Published var selectedGeneration: VideoGeneration?
    
    private let storage = VideoGenerationStorageService()
    
    init() {
        loadGenerations()
    }
    
    func loadGenerations() {
        do {
            generations = try storage.getGenerations()
        } catch {
            print("Error loading generations: \(error)")
        }
    }
}
