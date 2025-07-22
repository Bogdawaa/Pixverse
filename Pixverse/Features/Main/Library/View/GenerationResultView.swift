//
//  RenerationResultView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI
import AVKit

struct GenerationResult: View {
    
    @StateObject private var viewModel = GenerationResultViewModel()

    @State var item: VideoGeneration
    @State private var isPlaying = true
    @State private var videoThumbnail: UIImage?
    @State private var isLoadingThumbnail = false
    @State private var thumbnailError: Error?
    @State private var showFullscreenPlayer = false
    
    
    var body: some View {
        
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                if let videoURL = item.videoUrl {
                    thumbnailView(url: videoURL)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 106)
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                }
                
                // download button
                Button {
                    Task {
                        await viewModel.downloadVideo()
                    }
                } label: {
                    VStack {
                        switch viewModel.downloadState {
                        case .idle, .failure, .success:
                            Text("Download")
                        case .inProgress:
                            HStack {
                                ProgressView()
                                Text("Downloading")
                            }
                        }
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.primaryButton)
                .padding(.horizontal, 24)
                .disabled(viewModel.downloadState == .inProgress)
                .alert("Download Error",
                       isPresented: .constant(viewModel.downloadState.isError),
                       presenting: viewModel.downloadState) { state in
                    Button("OK") { viewModel.downloadState = .idle }
                } message: { state in
                    if case .failure(let error) = state {
                        Text(error.localizedDescription)
                    }
                }
                
                SocialMediaButtonsFooter()
            }
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.horizontal)
            .padding(.vertical, 84)
        }
        .onAppear {
            if let videoUrl = item.videoUrl {
                loadThumbnail(from: videoUrl)
            }
        }
        .navigationDestination(isPresented: $showFullscreenPlayer) {
            if let videoUrl = item.videoUrl {
                FullscreenVideoPlayer(videoURL: videoUrl, isPlaying: $isPlaying)
            }
        }
    }
    
    
    
    // MARK: - Thumbnail
    @ViewBuilder
    private func thumbnailView(url: URL) -> some View {
        Group {
            if let thumbnail = videoThumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .overlay {
                        // Show Full screen Player  button
                        Button(action: {
                            showFullscreenPlayer = true
                        }) {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .imageScale(.large)
                                .padding()
                        }
                    }
            } else if isLoadingThumbnail {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.3))
            } else {
                Color.gray.opacity(0.3)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    private func loadThumbnail(from url: URL) {
        guard videoThumbnail == nil, !isLoadingThumbnail else { return }
        
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
