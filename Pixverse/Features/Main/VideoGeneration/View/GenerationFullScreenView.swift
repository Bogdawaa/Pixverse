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
    
    var body: some View {
        ZStack {
            Color(.appBackground)
                .ignoresSafeArea()
            
            VideoPlayer(player: player)
                .disabled(true)
                .edgesIgnoringSafeArea(.all)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding()
                .onAppear {
                    setupPlayer()
                }
                .onDisappear {
                    cleanupPlayer()
                }
            
            // Play/pause Overlay
            if showControls {
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showControls)
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
    }
    
    // MARK: - Player Setup
    
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        player?.isMuted = true
        if isPlaying {
            player?.play()
        }
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player = nil
        cancelAutoHide()
    }
    
    private func togglePlayPause() {
        guard let player = player else { return }
        
        // If video ended, restart from beginning
        if let currentItem = player.currentItem,
           currentItem.currentTime() >= currentItem.duration {
            player.seek(to: .zero) { [weak player] _ in
                player?.pause()
            }
            isPlaying = false
            return
        }
        
        // Normal play/pause toggle
        isPlaying.toggle()
        isPlaying ? player.play() : player.pause()
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
                showControls = false
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
