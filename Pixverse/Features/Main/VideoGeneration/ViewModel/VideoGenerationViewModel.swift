//
//  VideoGenerationViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 16.07.2025.
//

import SwiftUI

enum DownloadState: Equatable {
    case idle
    case inProgress
    case success
    case failure(Error)
    
    static func == (lhs: DownloadState, rhs: DownloadState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.inProgress, .inProgress):
            return true
        case (.success, .success):
            return true
        case (.failure, .failure):
            return true
        default:
            return false
        }
    }
}

// MARK: - Download State
extension DownloadState {
    var isError: Bool {
        if case .failure = self { return true }
        return false
    }
}

@MainActor
final class VideoGenerationViewModel: ObservableObject, GenerationProgressViewModelProtocol {
        
    struct GenerationParameters {
        let templateId: Int
        let image: UIImage?
        let videoUrl: URL?
    }
    
    // MARK: Published
    @Published var isLoading = false
    @Published var error: Error?
    @Published var generatedVideoUrl: String?
    @Published var isGenerationComplete: Bool = false
    @Published var downloadState: DownloadState = .idle
    @Published var errorMessage: String?
    
    @Published private(set) var showDownloadAlert = false
    @Published private(set) var downloadAlertMessage = ""
    
    @Published var showAlert = false
    
    @Published var activeGenerations: [VideoGeneration] = []
    
    private let generationManager = GenerationManager.shared
    private let storage: VideoGenerationStorageService
    private let templateService: TemplateServiceProtocol
    private let statusCheckInterval: TimeInterval = 30

    init(
        templateService: TemplateServiceProtocol = TemplateService(networkClient: DefaultNetworkClientImpl(baseURL: Constants.baseURL)),
        storage: VideoGenerationStorageService = VideoGenerationStorageService()
    ) {
        self.templateService = templateService
        self.storage = storage
        loadGenerations()
    }

    
    // MARK: - Public Methods
    
    func resetData() {
        self.error = nil
        self.errorMessage = nil
        self.downloadState = .idle
        self.generatedVideoUrl = nil
        self.isGenerationComplete = false
        self.isLoading = false
    }
    
    func generate(with parameters: GenerationParameters) async {
        defer {
            Task {
                await generationManager.endGeneration()
            }
        }
                
        let canStart = await generationManager.canStartGeneration()
        guard canStart else {
            errorMessage = "Maximum number of concurrent generations is limited to \(await generationManager.maxConcurrentGenerations). Please wait for current generations to finish."
            showAlert = true
            return
        }
        // Increse generations
        await generationManager.startGeneration()
        
        loadGenerations()

        
        if let image = parameters.image {
            await generateTemplateToVideo(templateId: parameters.templateId, image: image)
        } else if let videoUrl = parameters.videoUrl {
            await generateVideoToVideo(templateId: parameters.templateId, videoURL: videoUrl)

        }
    }
    
    func downloadVideo() async {
        guard let videoURL = generatedVideoUrl, let videoURL = URL(string: videoURL) else { return }
        
        downloadState = .inProgress
        
        do {
            try await VideoDownloader.saveVideoToGallery(from: videoURL)
            downloadState = .success
        } catch {
            downloadState = .failure(error)
        }
    }
    
    // Private Methods
    private func generateTemplateToVideo(templateId: Int, image: UIImage) async {
        isLoading = true
        error = nil
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            error = NSError(domain: "Image converting failed", code: -1)
            isLoading = false
            return
        }
        
        do {
            // Start generation
            let response = try await templateService.generateTemplateVideo(
                userId: Constants.userId,
                appId: Constants.appId,
                templateId: templateId,
                imageData: imageData
            )
            
            // if generation started successfully
            if response.detail == "Success" {
                // save generation to storage
                let generation = VideoGeneration(
                    id: UUID().uuidString,
                    generationId: response.videoId,
                    status: .generating,
                    videoUrl: nil,
                    createdAt: Date()
                )
                try storage.saveGeneration(generation)
                activeGenerations.append(generation)
                
                print("Generation started. Video ID: \(response.videoId)")
                // Check status periodically
                checkStatusUntilCompleted(for: generation)
            } else {
                errorMessage = "Generation failed. Try to change image for generation"
                showAlert = true
                print("generation template to video failed")
            }
            
        } catch let err {
            // Handle errors
            showAlert = true
            errorMessage = "Generation failed. Try to change image for generation"
            error = err
            isLoading = false
        }
    }
    
    private func generateVideoToVideo(templateId: Int?, videoURL: URL) async {
        isLoading = true
        error = nil
        
        do {
            let videoData = try Data(contentsOf: videoURL)
            
            // Start generation
            let response = try await templateService.generateVideoToVideo(
                userId: Constants.userId,
                appId: Constants.appId,
                templateId: templateId,
                videoData: videoData
            )
            
            // if generation started successfully
            if response.detail == "Success" {
                // save generation to storage
                let generation = VideoGeneration(
                    id: UUID().uuidString,
                    generationId: response.videoId,
                    status: .generating,
                    videoUrl: nil,
                    createdAt: Date()
                )
                try storage.saveGeneration(generation)
                activeGenerations.append(generation)
                
                checkStatusUntilCompleted(for: generation)

                print("Video-to-video generation started. Video ID: \(response.videoId)")
            } else {
                showAlert = true
                errorMessage = "Generation failed. Try to change video for generation"
                print("generation video to video failed")

            }
        } catch let err {
            // Handle errors
            showAlert = true
            errorMessage = "Generation failed. Try to change video for generation"
            error = err
            isLoading = false
        }
    }
    
    private func checkStatusUntilCompleted(for generation: VideoGeneration) {
        Task {
            while true {
                do {
                    try await Task.sleep(nanoseconds: UInt64(statusCheckInterval * 1_000_000_000))

                    let status = try await templateService.checkVideoStatus(videoId: generation.generationId)
                    print("status \(status.status)")
                    
                    switch status.status.lowercased() {
                    case "success" where status.videoUrl != nil:
                        if let url = URL(string: status.videoUrl!) {
                            isGenerationComplete = true
                            generatedVideoUrl = status.videoUrl
                            isLoading = false
                            
                            // updaate generation
                            let updated = VideoGeneration(
                                id: generation.id,
                                generationId: generation.generationId,
                                status: .success,
                                videoUrl: url,
                                createdAt: generation.createdAt
                            )
                            try storage.updateGeneration(updated)
                            await MainActor.run {
                                if let index = activeGenerations.firstIndex(where: { $0.id == generation.id }) {
                                    activeGenerations[index] = updated
                                }
                            }
                            return
                        }
                    case "error":
                        errorMessage = "Generation failed. Please try again."
                        error = NSError(domain: "Generation failed", code: -2)
                        isLoading = false
                        print("Status Failed")
                        
                        try storage.deleteGeneration(id: generation.id)
                        await MainActor.run {
                            activeGenerations.removeAll { $0.id == generation.id }
                        }
                        return
                        
                    default:
                        isLoading = true
                    }
                } catch {
                    showAlert = true
                    errorMessage = "Generation failed. Please try again."
                    self.error = error
                    isLoading = false
                    break
                }
            }
        }
    }
}

// MARK: - Storage Management
extension VideoGenerationViewModel {
    private func loadGenerations() {
        do {
            activeGenerations = try storage.getGenerations()
            activeGenerations
                .filter { $0.status == .generating }
                .forEach { checkStatusUntilCompleted(for: $0) }
        } catch {
            print("Error loading generations: \(error)")
        }
    }
}
