//
//  TextGenerationView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 15.07.2025.
//

import SwiftUI
import AVKit

struct GenerationProgressView<ViewModel: GenerationProgressViewModelProtocol>: View {
    
//    enum MediaType {
//        case image(Image)
//        case video(URL)
//    }
    
    enum VideoDisplayMode {
        case preview
        case fullscreen
    }
    
    @EnvironmentObject var router: Router
    
    @State private var videoDisplayMode: VideoDisplayMode = .preview
    @State private var isPlaying = false
    @State private var videoThumbnail: UIImage?
    @State private var isLoadingThumbnail = false
    @State private var thumbnailError: Error?
    @State private var showFullscreenPlayer = false
    
    @ObservedObject var viewModel: ViewModel
    
    let mediaType: MediaType
    
    var body: some View {
        ZStack {
            Color(.appBackground)
                .ignoresSafeArea()
            
            if viewModel.isGenerationComplete {
                VStack {
                    generationResult
                    Spacer()
                    templatesFooterView
                }
                .transition(.opacity)
                .navigationDestination(isPresented: $showFullscreenPlayer) {
                    if let videoUrl = viewModel.generatedVideoUrl, let url = URL(string: videoUrl) {
                        FullscreenVideoPlayer(videoURL: url, isPlaying: $isPlaying)
                    }
                }
                .navigationDestination(for: AnyContentItem.self) { wrapper in
                    TemplateView(item: wrapper.base, viewModel: viewModel)
                }
                .onAppear {
                    if let videoUrl = viewModel.generatedVideoUrl, let url = URL(string: videoUrl) {
                        loadThumbnail(from: url)
                    }
                }
            } else {
                progressView
                    .transition(.opacity)
            }
        }
        .onDisappear {
            if let vm = viewModel as? TextGenerationViewModel  {
                if vm.isGenerationComplete {
                    vm.resetData()
                }
            }
        }
        .animation(.easeInOut, value: viewModel.isGenerationComplete)
        .animation(.easeInOut, value: videoDisplayMode)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Video generation")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    @ViewBuilder
    private var mediaPreview: some View {
        GeometryReader { geometry in
            let contentWidth = geometry.size.width
            let contentHeight = geometry.size.height
            
            switch mediaType {
            case .image(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: contentWidth, height: contentHeight)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 32))
            case .video(let url):
                VideoPlayer(player: AVPlayer(url: url))
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 78)
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.appBackground.opacity(0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .padding(.vertical, 24)
                        .padding(.horizontal, 78)
                    
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
        }
    }
    
    // MARK: - View while generating
    @ViewBuilder
    private var progressView: some View {
        VStack {
            mediaPreview
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .frame(maxWidth: .infinity)
            
            Text("It can take several minutes to create a video. Please don't leave the app")
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
        }
        .padding(.horizontal)
        .padding(.vertical, 96)
        .background(.appBackground)
        .onAppear {
            print(viewModel.isLoading)
        }
    }
    
    
    // MARK: - Generation result
    @ViewBuilder
    private var generationResult: some View {
        VStack {
            if let videoURL = URL(string: viewModel.generatedVideoUrl ?? "") {
                thumbnailView(url: videoURL)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 106)
                    .padding(.vertical, 24)
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
                            .font(.system(size: 16)).fontWeight(.regular)
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
            if let videoUrl = URL(string: viewModel.generatedVideoUrl ?? "") {
                SocialMediaButtonsFooter(shareItem: videoUrl)
            }
        }
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(16)
    }
    
    // MARK: - Footer with other templates
    private var templatesFooterView: some View {
        GenerationResultFooter(
            title: "Other Templates",
            items: Array(TemplateRepository.shared.getTemplates().prefix(10)),
            onItemSelected: { item in
                router.showVideoDetail(item: item)
                
            }
        )
        .background(.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(16)
    }
    
    // MARK: - Video Preview
    @ViewBuilder
    private func videoPreview(url: URL) -> some View {
        ZStack {
            // Thumbnail or placeholder
            if let thumbnail = videoThumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.black.opacity(0.3)
            }
            
            // Play button
            Button(action: {
                isPlaying = true
                showFullscreenPlayer = true
            }) {
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .imageScale(.large)
                    .padding()
            }
        }
    }
    
    // MARK: - Thumbnail
    @ViewBuilder
    private func thumbnailView(url: URL) -> some View {
        GeometryReader { geometry in
            let contentWidth = geometry.size.width
            let contentHeight = geometry.size.height
            
            Group {
                if let thumbnail = videoThumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: contentWidth, height: contentHeight)
                        .clipped()
                        .overlay {
                        // Show full screen button
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
                        .frame(width: contentWidth, height: contentHeight)
                        .background(Color.gray.opacity(0.3))
                } else {
                    Color.gray.opacity(0.3)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                        .frame(width: contentWidth, height: contentHeight)
                }
            }
            .frame(width: contentWidth, height: contentHeight)
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
    GenerationProgressView(
        viewModel: VideoGenerationViewModel(),
        mediaType: .image(Image(.amigurumi))
    )
}
