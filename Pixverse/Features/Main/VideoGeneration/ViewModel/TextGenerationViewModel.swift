//
//  TextGenerationViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 17.07.2025.
//

import SwiftUI
import PhotosUI
import AVKit


@MainActor
final class TextGenerationViewModel: ObservableObject, GenerationProgressViewModelProtocol {
    
    struct GenerationParameters {
        let prompt: String?
        let image: UIImage?
        let videoURL: URL?
        let templateId: Int?
    }

    // MARK: - Handle States
    enum MediaType: Hashable {
        case photo(UIImage)
        case video(URL)
    }
    
    // MARK: - Published Properties
    @Published var selectedImage: UIImage?
    @Published var error: Error?
    @Published var prompt: String = ""
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedMedia: MediaType?
    @Published var generatedVideoUrl: String?
    @Published var downloadState: DownloadState = .idle
    @Published var isGenerationComplete: Bool = false
    @Published var showPhotoAccessAlert = false
    @Published var isLoading = false
    @Published var showMediaPicker = false
    @Published var selectedStyleItem: (any ContentItemProtocol)? = nil
    @Published var styleItems: [StyleItem]? = nil
    @Published var errorMessage: String?
    @Published var showAlert: Bool = false
    
    @Published var activeGenerations: [VideoGeneration] = []
    
    @Published var isUploadPhotoEnabled = true {
        didSet {
            if isUploadPhotoEnabled {
                isUploadVideoEnabled = false
                if case .video = selectedMedia {
                    selectedMedia = nil
                    selectedImage = nil
                }
            }
        }
    }

    @Published var isUploadVideoEnabled = false {
        didSet {
            if isUploadVideoEnabled {
                isUploadPhotoEnabled = false
                if case .photo = selectedMedia {
                    selectedMedia = nil
                    selectedImage = nil
                }
            }
        }
    }
    
    private let storage: VideoGenerationStorageService
    private let templateService: TemplateServiceProtocol
    private let statusCheckInterval: TimeInterval = 30
    private let generationManager = GenerationManager.shared

    
    init(templateService: TemplateServiceProtocol = TemplateService(networkClient: DefaultNetworkClientImpl(baseURL: Constants.baseURL)),
         storage: VideoGenerationStorageService = VideoGenerationStorageService()
    ) {
        self.styleItems = TemplateRepository.shared.getStyles()
        self.templateService = templateService
        self.storage = storage
        loadGenerations()
    }
    
    // MARK: - Computed Propertie
    
    var isGenerateButtonDisabled: Bool {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return true
        }
        
        let hasRequiredPhoto = isUploadPhotoEnabled && hasPhoto
        let hasRequiredVideo = isUploadVideoEnabled && hasVideo
        
        return !(hasRequiredPhoto || hasRequiredVideo)
    }
    
    var shouldShowUploadButton: Bool {
        isUploadPhotoEnabled || isUploadVideoEnabled
    }
    
    var shouldShowStyleSlider: Bool {
        !(TemplateRepository.shared.getStyles().isEmpty) && isUploadVideoEnabled
    }
    
    
    private var hasPhoto: Bool {
        if case .photo = selectedMedia { return true }
        return false
    }
    
    private var hasVideo: Bool {
        if case .video = selectedMedia { return true }
        return false
    }
    
    // MARK: - Public Methods
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            showMediaPicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.showMediaPicker = true
                    } else {
                        self?.showPhotoAccessAlert = true
                    }
                }
            }
        default:
            showPhotoAccessAlert = true
        }
    }
    
    func handleMediaSelection(_ item: PhotosPickerItem?) {
        print("Handling media selection")
        guard let item else { return }
        isLoading = true
        
        Task {
            print("Starting media load")
            if isUploadPhotoEnabled {
                print("Loading photo")
                await loadPhoto(from: item)
            } else if isUploadVideoEnabled {
                print("Loading video")
                await loadVideo(from: item)
            }
            await MainActor.run {
                print("Media load completed")
                isLoading = false
            }
        }
    }
    
    func generate(with parameters: GenerationParameters) async  {
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
        
        switch selectedMedia {
        case .photo(let uiImage):
            if let prompt = parameters.prompt {
                await generateImageToVideo(prompt: prompt, image: uiImage)
            }
        case .video(let _):
            break
        case nil:
            // TODO: add textToVideo Generation
            break
        }
    }
    
    func resetData() {
        errorMessage = nil
        selectedImage = nil
        error = nil
        prompt = ""
        selectedItem = nil
        selectedMedia = nil
        isLoading = false
        isGenerationComplete = false
    }
    
    // MARK: - Private Methods
    
//    private func generateTextToVideo(prompt: String) async {
//        isLoading = true
//        
//        do {
//            // Start generation
//            let response = try await templateService.generateTextToVideo(
//                userId: Constants.userId,
//                appId: Constants.appId,
//                prompt: prompt
//            )
//            
//            print("Generation started. Video ID: \(response.videoId)")
//            
//            await checkStatusUntilCompleted(videoId: response.videoId)
//        } catch let err {
//            // Handle errors
//            error = err
//            isLoading = false
//        }
//        
//    }
    
    private func generateImageToVideo(prompt: String, image: UIImage) async {
        isLoading = true
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            error = NSError(domain: "Image converting failed", code: -1)
            isLoading = false
            return
        }
        
        do {
            // Start generation
            let response = try await templateService.generateImageToVideo(
                userId: AppState.shared.userId,
                appId: Constants.appId,
                prompt: prompt,
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
                
                checkStatusUntilCompleted(for: generation)
                
                print("Generation started. Video ID: \(response.videoId)")
            } else {
                showAlert = true
                errorMessage = "Generation failed. Try to change image for generation"
                print("Image-to-video generation started. Video ID: \(response.videoId)")
            }
        } catch let err {
            // Handle errors
            showAlert = true
            errorMessage = "Generation failed. Try to change image for generation"
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
                        
                        try storage.deleteGeneration(id: generation.id)
                        await MainActor.run {
                            activeGenerations.removeAll { $0.id == generation.id }
                        }
                        return
                        
                    default:
                        isLoading = true
                    }
                                        
                } catch {
                    errorMessage = "Generation failed. Please try again."
                    showAlert = true
                    self.error = error
                    isLoading = false
                    break
                }
            }
            
        }
    }
    
    // Thumbnail
    private func generateThumbnail(from url: URL) -> UIImage? {
        guard url.startAccessingSecurityScopedResource() else {
            print("No access to secure resource")
            return nil
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        do {
            let time = CMTime(seconds: 0.5, preferredTimescale: 600)
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Load from Library

extension TextGenerationViewModel {
    
    // save to library
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

    private func loadPhoto(from item: PhotosPickerItem) async {
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            await MainActor.run {
                selectedMedia = .photo(image)
                selectedImage = image
            }
        }
    }
    
    private func loadVideo(from item: PhotosPickerItem) async {
        do {
            if let url = try await item.loadTransferable(type: URL.self) {
                guard url.startAccessingSecurityScopedResource() else {
                    throw NSError(domain: "No access to video file", code: -2)
                }
                
                defer { url.stopAccessingSecurityScopedResource() }
                
                // Generate thumbnail
                let thumbnail = generateThumbnail(from: url)
                
                await MainActor.run {
                    selectedMedia = .video(url)
                    selectedImage = thumbnail
                    print("Successfully loaded video from: \(url)")
                }
                return
            }
            
            // get video directly
            if let movie = try await item.loadTransferable(type: VideoFileTransferable.self) {
                let url = movie.url
                let thumbnail = generateThumbnail(from: url)
                
                await MainActor.run {
                    selectedMedia = .video(url)
                    selectedImage = thumbnail
                    print("Successfully loaded movie file from: \(url)")
                }
                return
            }
            
            throw NSError(domain: "Failed to load video URL", code: -1)
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
                print("Error loading video: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Storage Management
extension TextGenerationViewModel {
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
    
    func cleanup() {
        try? storage.cleanupGenerations()
        loadGenerations()
    }

}
