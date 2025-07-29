//
//  LibraryViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI
import Combine

final class LibraryViewModel: ObservableObject {
    
    @Published var generations: [VideoGeneration] = []
    @Published var selectedGeneration: VideoGeneration?
    
    private let storage = VideoGenerationStorageService()
    private var cancellables = Set<AnyCancellable>()
    private var statusCheckTimer: Timer?
    
    init() {
        setupObservers()
        loadGenerations()
        startStatusCheckTimerIfNeeded()
    }
    
    deinit {
        statusCheckTimer?.invalidate()
    }
    
    private func setupObservers() {
        storage.generationsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newGenerations in
                self?.generations = newGenerations.sorted { $0.createdAt > $1.createdAt }
                self?.startStatusCheckTimerIfNeeded()
            }
            .store(in: &cancellables)
    }
    
    func loadGenerations() {
        do {
            let loaded = try storage.getGenerations()
            generations = loaded.sorted { $0.createdAt > $1.createdAt }
            startStatusCheckTimerIfNeeded()
        } catch {
            print("Error loading generations: \(error)")
        }
    }
    
    private func startStatusCheckTimerIfNeeded() {
        statusCheckTimer?.invalidate()
        
        let hasGeneratingItems = generations.contains { $0.status == .generating }
        
        guard hasGeneratingItems else { return }
        statusCheckTimer = Timer.scheduledTimer(
            withTimeInterval: 5.0,
            repeats: true
        ) { [weak self] _ in
            self?.checkGeneratingStatuses()
        }
    }
    
    private func checkGeneratingStatuses() {
        do {
            let freshGenerations = try storage.getGenerations()
            var needsUpdate = false
            
            for generation in generations where generation.status == .generating {
                if let freshGeneration = freshGenerations.first(where: { $0.id == generation.id }),
                   freshGeneration.status != generation.status {
                    
                    generation.status = freshGeneration.status
                    generation.videoUrl = freshGeneration.videoUrl
                    generation.objectWillChange.send()
                    needsUpdate = true
                }
            }
            
            if needsUpdate {
                objectWillChange.send()
            }
            
            let hasGeneratingItems = freshGenerations.contains { $0.status == .generating }
            if !hasGeneratingItems {
                statusCheckTimer?.invalidate()
            }
        } catch {
            print("Error checking generation status: \(error)")
        }
    }
}
