//
//  StyleSingleView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI
import AVKit

struct ContentItemView: View {
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var videoCoordinator: VideoCoordinator
    
    let item: any ContentItemProtocol
    
    @State private var videoThumbnail: UIImage?
    @State private var isLoadingThumbnail = false
    @State private var thumbnailError: Error?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let videoURL = item.previewLargeURL {
                thumbnailView(url: videoURL)
                
                Text(item.name)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .font(.system(size: 14))
                    .padding(.horizontal)
                    .padding()
            } else {
                Image(systemName: "play.slash.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 175, height: 225)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            if appCoordinator.selectedTab == 0 {
                appCoordinator.selectedTab = 1
            }
            videoCoordinator.showVideoDetail(item: item)
        }
        .onAppear {
            if let videoUrl = item.previewSmallURL {
                loadThumbnail(from: videoUrl)
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
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    .black.opacity(0),
                                    .appBackground.opacity(0.8)
                                ]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
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

#Preview {
    ContentItemView(
        item: TemplateItem(from: TemplateDTO(
            prompt: "",
            name: "Name",
            category: "Category",
            isActive: false,
            previewSmall: "",
            previewLarge: "",
            id: 1,
            templateId: 1
        ))
    )
}
