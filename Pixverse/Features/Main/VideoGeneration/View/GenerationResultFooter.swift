//
//  GenerationResultFooter.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 19.07.2025.
//

import SwiftUI
import AVKit

struct GenerationResultFooter: View {
    
    @State var title: String = ""
    
    var items: [any ContentItemProtocol] = []
    @State private var visibleItems: [any ContentItemProtocol] = []
    var onItemSelected: ((any ContentItemProtocol) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.bold)
                .font(.title2)
                .foregroundStyle(.appMainText)
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(items, id:\.id) { item in
                        FooterItemView(item: item)
                            .frame(width: 114, height: 121)
                            .onAppear {
                                preloadNextItems(after: item)
                            }
                            .onTapGesture {
                                onItemSelected?(item)
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(height: 121)
            }
            .frame(height: 121 + 16)
            .padding(.bottom)
        }
//        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Photo generation")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.appMainText)
            }
        }
        .background(.appCard)
        .onAppear {
            visibleItems = Array(items.prefix(5))
        }
    }
    
    private func preloadNextItems(after currentItem: any ContentItemProtocol) {
        guard let currentIndex = items.firstIndex(where: { $0.id == currentItem.id }) else { return }
        
        let nextIndex = currentIndex + 1
        guard nextIndex < items.count else { return }
        
        // Load next batch
        let newItems = Array(items[nextIndex..<min(nextIndex + 3, items.count)])
        
        DispatchQueue.main.async {
            if !visibleItems.contains(where: { $0.id == newItems.first?.id }) {
                visibleItems.append(contentsOf: newItems)
            }
        }
    }
}

struct FooterItemView: View {
    var item: any ContentItemProtocol
    @State private var thumbnail: UIImage?
    
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 114, height: 121)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 114, height: 121)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(ProgressView())
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        guard let videoURL = item.previewSmallURL else { return }
        
        if let cachedImage = ThumbnailCache.shared.get(for: videoURL) {
            self.thumbnail = cachedImage
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            do {
                let cgImage = try generator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 1), actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                
                // Cache thumbnail
                ThumbnailCache.shared.set(uiImage, for: videoURL)
                
                DispatchQueue.main.async {
                    self.thumbnail = uiImage
                }
            } catch {
                print("Failed to generate thumbnail: \(error.localizedDescription)")
            }
        }
    }
}
