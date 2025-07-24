//
//  GSPlayerView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 15.07.2025.
//

import SwiftUI
import Photos
import PhotosUI
import AVKit

struct TemplateView<ViewModel: GenerationProgressViewModelProtocol>: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    enum MediaType: Hashable {
        case photo(UIImage)
        case video(URL)
    }
    
    @State var error: Error?
    @State var selectedMedia: MediaType?
    @State var isShowPaywall = false


    @ObservedObject var viewModel: ViewModel
    
    @State private(set)var isLoading = false
    @State private var showPhotoAccessAlert = false
    @State private var showPhotoPicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showAlert = false
    
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = false
    @State private var showControls = true
    @State private var hideTimer: Timer?
    @State private var videoEnded = false
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var videoCoordinator: VideoCoordinator
    
    let item: any ContentItemProtocol
    
    init(
        item: any ContentItemProtocol,
        viewModel: ViewModel,
    ) {
        self.item = item
        self.viewModel = viewModel
    }
    
    var body: some View {
        if let url = item.previewLargeURL {
            VStack(spacing: 24) {
                videoPlayerView(url: url)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                
                // Generate button
                Button(action: {
                    if appState.isPremium {
                        checkPhotoLibraryPermission()
                    } else {
                        isShowPaywall = true
                    }
                }, label: {
                    HStack {
                        Text("Generate")
                            .frame(height: 50)
                        if !appState.isPremium {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.appBackground)
                        }
                    }
                    .frame(maxWidth: .infinity)
                })
                .buttonStyle(.primaryButton)
            }
            .padding(16)
            .padding(.bottom, 16)
            .background(.appBackground)
            // Alert
            .alert("Allow access to photos?", isPresented: $showPhotoAccessAlert) {
                Button("Allow", role: .none) {
                    openAppSettings()
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("To upload an image, the app needs access to your photo library")
            }
            // Error alert
            .alert("Error",
                   isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    showAlert = false
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred during generation")
            }
            // Pick photo
            .photosPicker(isPresented: $showPhotoPicker,
                          selection: $selectedItem,
                          matching: item is TemplateItem ? .images : .videos)
            .onChange(of: selectedItem) { _ in
                if item is TemplateItem {
                    loadImage()
                } else {
                    if let selectedItem = selectedItem {
                        Task {
                            await loadVideo(from: selectedItem)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Templates")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if !appState.isPremium {
                ToolbarItem(placement: .topBarTrailing) {
                        SubscriptionButton()
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowPaywall) {
                PaywallView(onDismiss: {
                    isShowPaywall = false
                })
            }
            
        }
    }
    
    @ViewBuilder
    private func videoPlayerView(url: URL) -> some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width
            let containerHeight = geometry.size.height
            
            ZStack {
                if let player = player {
                    VideoPlayer(player: player)
                        .disabled(true)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: containerWidth, height: containerHeight)
                        .clipped()
                } else {
                    ProgressView()
                        .frame(width: containerWidth, height: containerHeight)
                }
            }
            .frame(width: containerWidth, height: containerHeight)
            .contentShape(Rectangle())
            .overlay(alignment: .center) {
                if showControls || videoEnded {
                    Button(action: togglePlayPause) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 44))
                            .padding()
                    }
                    .transition(.opacity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(9/16, contentMode: .fit)
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            setupPlayer(url: url)
        }
        .onDisappear {
            cleanupPlayer()
        }
    }
    
    private func loadImage() {
        guard let templateId = item.templateId else { return }
        
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                
                if let vm = viewModel as? VideoGenerationViewModel {
                    await vm.generate(with: .init(templateId: templateId, image: image, videoUrl: nil))
                    if vm.errorMessage == nil {
                        videoCoordinator.showGenerationProgress(with: image)
                    } else {
                        showAlert = true
                    }
                }
            }
        }
    }
    
    private func loadVideo(from item: PhotosPickerItem) async {
        guard let templateId = self.item.templateId else { return }
        
        do {
            // Try to get the video file URL
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
                
                if let vm = viewModel as? VideoGenerationViewModel {
                    await vm.generate(with: .init(templateId: templateId, image: nil, videoUrl: url))
                    if vm.errorMessage == nil {
                        if let thumbnail = thumbnail {
                            videoCoordinator.showGenerationProgress(with: thumbnail)
                        } else {
                            videoCoordinator.showGenerationProgress(with: UIImage(resource: .subject3Fever))
                        }
                    } else {
                        showAlert = true
                        print(viewModel.errorMessage)
                    }
                }
                
                return
            }
            
            // try to get the movie file directly
            if let movie = try await item.loadTransferable(type: VideoFileTransferable.self) {
                let url = movie.url
                let thumbnail = generateThumbnail(from: url)
                
                await MainActor.run {
                    selectedMedia = .video(url)
                    selectedImage = thumbnail
                    print("Successfully loaded movie file from: \(url)")
                }
                
                if let thumbnail = thumbnail {
                    videoCoordinator.showGenerationProgress(with: thumbnail)
                } else {
                    videoCoordinator.showGenerationProgress(with: UIImage(resource: .subject3Fever))
                }
                
                if let vm = viewModel as? VideoGenerationViewModel {
                    await vm.generate(with: .init(templateId: templateId, image: nil, videoUrl: url))
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
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            showPhotoPicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        showPhotoPicker = true
                    } else {
                        showPhotoAccessAlert = true
                    }
                }
            }
        default:
            showPhotoAccessAlert = true
        }
    }
        
    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }
    
    // MARK: - Player Setup
    
    private func setupPlayer(url: URL) {
        player = AVPlayer(url: url)
        player?.isMuted = true
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            videoEnded = true
            isPlaying = false
            showControls = true
            cancelAutoHide()
        }
        
        if isPlaying {
            player?.play()
        }
    }
    
    private func cleanupPlayer() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        player?.pause()
        player = nil
        cancelAutoHide()
    }
    
    private func togglePlayPause() {
        guard let player = player else { return }
        
        if videoEnded {
            player.seek(to: .zero)
            videoEnded = false
            isPlaying = true
            player.play()
        } else {
            isPlaying.toggle()
            isPlaying ? player.play() : player.pause()
        }
        
        showControls = true
        resetAutoHideTimer()
    }
    
    private func handleTap() {
        print(#function)
        showControls = true
        resetAutoHideTimer()
    }
    
    private func resetAutoHideTimer() {
        cancelAutoHide()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            withAnimation {
                if !videoEnded {
                    showControls = false
                }
            }
        }
    }
    
    private func cancelAutoHide() {
        hideTimer?.invalidate()
        hideTimer = nil
    }
}

