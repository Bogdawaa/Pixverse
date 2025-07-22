//
//  VideoGenerationStorageService.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import Foundation

final class VideoGenerationStorageService {
    private let storage: StorageProtocol
    private let key = "video_generations"
    
    init(storage: StorageProtocol = UserDefaultsStorage()) {
        self.storage = storage
    }
    
    func saveGeneration(_ generation: VideoGeneration) throws {
        var generations = try getGenerations()
        generations.removeAll { $0.id == generation.id }
        generations.append(generation)
        try storage.save(generations, forKey: key)
    }
    
    func getGenerations() throws -> [VideoGeneration] {
        try storage.load(forKey: key) ?? []
    }
    
    func updateGeneration(_ generation: VideoGeneration) throws {
        var generations = try getGenerations()
        if let index = generations.firstIndex(where: { $0.id == generation.id }) {
            generations[index] = generation
            try storage.save(generations, forKey: key)
        }
    }
    
    func deleteGeneration(id: String) throws {
        var generations = try getGenerations()
        generations.removeAll { $0.id == id }
        try storage.save(generations, forKey: key)
    }
    
    func cleanupGenerations() throws {
        let generations = try getGenerations()
        let filtered = generations.filter {
            $0.status == .generating || ($0.status == .success && $0.videoUrl != nil)
        }
        try storage.save(filtered, forKey: key)
    }
}
