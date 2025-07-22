//
//  VideoPlayer.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 16.07.2025.
//

import SwiftUI
import AVKit

struct CustomVideoPlayer: UIViewRepresentable {
    let videoURL: URL
    @Binding var isPlaying: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        let player = AVPlayer(url: videoURL)
        player.actionAtItemEnd = .none
        player.allowsExternalPlayback = false
        
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.videoGravity = .resizeAspectFill
//        playerLayer.frame = view.bounds
//        view.layer.addSublayer(playerLayer)
        
        context.coordinator.player = player
//        context.coordinator.playerLayer = playerLayer
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if isPlaying {
            context.coordinator.player?.play()
        } else {
            context.coordinator.player?.pause()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - coordinator
    class Coordinator: NSObject {
        var parent: CustomVideoPlayer
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        
        init(_ parent: CustomVideoPlayer) {
            self.parent = parent
        }
        
        @objc func handleTap() {
            parent.isPlaying.toggle()
        }
    }
}

struct CustomVideoPlayerView: View {
    let videoURL: URL
    @State private var isPlaying = false
    @State private var showControls = true
    
    var body: some View {
        ZStack {
            // Video Player
            CustomVideoPlayer(videoURL: videoURL, isPlaying: $isPlaying)
                .cornerRadius(30)
                .onTapGesture {
                    withAnimation {
                        showControls.toggle()
                    }
                }
            
            // Custom Controls
            if showControls {
                Button(action: {
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.7)))
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showControls = false
                }
            }
        }
    }
}
