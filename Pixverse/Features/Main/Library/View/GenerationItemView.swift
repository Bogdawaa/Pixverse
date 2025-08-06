//
//  GenerationView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI
import AVKit

struct GenerationItemView: View {
    
    @ObservedObject var generation: VideoGeneration
    
    @State private var videoThumbnail: UIImage?
    @State private var isLoadingThumbnail = false
    @State private var thumbnailError: Error?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if generation.status == .generating {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.3))
            } else if generation.status == .success {
                if let videoURL = generation.videoUrl {
                    thumbnailView(url: videoURL)
                        .task {
                            loadThumbnail(from: videoURL)
                        }
                }
            } else {
                Image(systemName: "play.slash.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 175, height: 225)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onReceive(generation.$status) { newStatus in
            if newStatus == .success, let url = generation.videoUrl {
                print("status received. start loading")
                loadThumbnail(from: url)
            }
        }
        .onChange(of: generation.videoUrl) { newUrl in
            if generation.status == .success, let url = newUrl {
                print("status changed. start loading")
                loadThumbnail(from: url)
            }
        }
        .task(id: generation.status) {
            if generation.status == .success, let url = generation.videoUrl {
                loadThumbnail(from: url)
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
                    .overlay(alignment: .bottom) {
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        .black.opacity(0),
                                        .black.opacity(0.8)
                                    ]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            )
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
        
        if let cachedImage = ThumbnailCache.shared.get(for: url) {
            videoThumbnail = cachedImage
            isLoadingThumbnail = false
            return
        }
        
        guard videoThumbnail == nil, !isLoadingThumbnail else { return }
        
        isLoadingThumbnail = true
        
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
