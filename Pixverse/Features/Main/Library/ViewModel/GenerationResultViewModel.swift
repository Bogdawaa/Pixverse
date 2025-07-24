//
//  GenerationResultViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI
import AVKit

final class GenerationResultViewModel: ObservableObject {
    
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
    
    @Published var isPlaying = true
    @Published var videoThumbnail: UIImage?
    @Published var isLoadingThumbnail = false
    @Published var thumbnailError: Error?
    @Published var showFullscreenPlayer = false
    
//    @Published var generatedVideoUrl: String?
    @Published var downloadState: DownloadState = .idle
    var item: VideoGeneration
    
    init(item: VideoGeneration) {
        self.item = item
    }
    
    @MainActor
    func downloadVideo() async {
        guard let videoURL = item.videoUrl else { return }
        
        downloadState = .inProgress
        
        do {
            try await VideoDownloader.saveVideoToGallery(from: videoURL)
            downloadState = .success
        } catch {
            downloadState = .failure(error)
        }
    }
    
    func loadThumbnail(from url: URL) {
        isLoadingThumbnail = true
        
        if let cachedImage = ThumbnailCache.shared.get(for: url) {
            videoThumbnail = cachedImage
            isLoadingThumbnail = false
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            do {
                let imageRef = try generator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: imageRef)
                
                // Cache the thumbnail
                ThumbnailCache.shared.set(thumbnail, for: url)
                
                DispatchQueue.main.async {
                    self.videoThumbnail = thumbnail
                    self.isLoadingThumbnail = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoadingThumbnail = false
                    print("Thumbnail generation failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Download State
extension GenerationResultViewModel.DownloadState {
    var isError: Bool {
        if case .failure = self { return true }
        return false
    }
}
