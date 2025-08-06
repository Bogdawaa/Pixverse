//
//  GenerationFullScreenView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 19.07.2025.
//

import SwiftUI
import AVKit

struct FullscreenVideoPlayer: View {
    let videoURL: URL
    @Binding var isPlaying: Bool
    @State private var player: AVPlayer?
    @State private var showControls = false
    @State private var hideTimer: Timer?
    @State private var videoEnded = false
    
    var body: some View {
        ZStack {
            Color(.appBackground)
                .ignoresSafeArea()
            
            VideoPlayer(player: player)
                .disabled(true)
                .edgesIgnoringSafeArea(.all)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding()
                .onAppear {
                    setupPlayer()
                }
                .onDisappear {
                    cleanupPlayer()
                }
            
            // Play/pause Overlay
            if showControls || videoEnded {
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
                .transition(.opacity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Video generation")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.appMainText)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showControls)
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            handleTap()
        }
    }
    
    // MARK: - Player Setup
    
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        player?.isMuted = true
        
        // Add observer for video end
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

#Preview {
    FullscreenVideoPlayer(videoURL: URL(string: "https://media.pixverse.ai/pixverse%2Fmp4%2Fmedia%2Fweb%2Fori%2Fc589dd76-855a-409b-877c-d42f93c0c7cf_seed0.mp4")!, isPlaying: .constant(true))
}
