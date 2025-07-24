//
//  GenerationManager.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 24.07.2025.
//

import Foundation


actor GenerationManager {
    static let shared = GenerationManager()
    
    private(set) var maxConcurrentGenerations = 2
    private var activeGenerations = 0
    
    private init() {}
    
    func canStartGeneration() -> Bool {
        activeGenerations < maxConcurrentGenerations
    }
    
    func startGeneration() {
        activeGenerations += 1
    }
    
    func endGeneration() {
        activeGenerations -= 1
        if activeGenerations < 0 {
            activeGenerations = 0
        }
    }
    
    var currentActiveGenerations: Int {
        activeGenerations
    }
}
