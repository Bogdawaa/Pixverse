//
//  GenerationManager.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 24.07.2025.
//

import Foundation

@MainActor
final class GenerationManager: ObservableObject {
    static let shared = GenerationManager()
    
    @Published private(set) var maxConcurrentGenerations = 2
    @Published private(set) var currentActiveGenerations = 0
    
    private init() {}
    
    func canStartGeneration() -> Bool {
        currentActiveGenerations < maxConcurrentGenerations
    }
    
    func startGeneration() {
        currentActiveGenerations += 1
        debugStatus()
    }
    
    func endGeneration() {
        currentActiveGenerations -= 1
        if currentActiveGenerations < 0 {
            currentActiveGenerations = 0
        }
        debugStatus()
    }
    
    func debugStatus() {
        print("""
        Active generations: \(currentActiveGenerations)
        Max allowed: \(maxConcurrentGenerations)
        Available: \(maxConcurrentGenerations - currentActiveGenerations) / \(maxConcurrentGenerations)
        """)
    }
}
