//
//  GenerationResultViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI

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
    
    @Published var generatedVideoUrl: String?
    @Published var downloadState: DownloadState = .idle
    
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
}

// MARK: - Download State
extension GenerationResultViewModel.DownloadState {
    var isError: Bool {
        if case .failure = self { return true }
        return false
    }
}
