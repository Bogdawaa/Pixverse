//
//  RenerationResultView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI
import AVKit

struct GenerationResult: View {
    
    @ObservedObject var viewModel: GenerationResultViewModel

    var body: some View {
        
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack {
                if let videoURL = viewModel.item.videoUrl {
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
                
                SocialMediaButtonsFooter(shareItem: viewModel.item.videoUrl)
            }
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.horizontal)
            .padding(.vertical, 84)
        }
        .onAppear {
            if let videoUrl = viewModel.item.videoUrl {
                viewModel.loadThumbnail(from: videoUrl)
            }
        }
        .navigationDestination(isPresented: $viewModel.showFullscreenPlayer) {
            if let videoUrl = viewModel.item.videoUrl {
                FullscreenVideoPlayer(videoURL: videoUrl, isPlaying: $viewModel.isPlaying)
            }
        }
    }
    
    
    
    // MARK: - Thumbnail
    @ViewBuilder
    private func thumbnailView(url: URL) -> some View {
        Group {
            if let thumbnail = viewModel.videoThumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 146, height: 168)
                    .overlay {
                        // Show Full screen Player  button
                        Button(action: {
                            viewModel.showFullscreenPlayer = true
                        }) {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .imageScale(.large)
                                .padding()
                        }
                    }
            } else if viewModel.isLoadingThumbnail {
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
}
