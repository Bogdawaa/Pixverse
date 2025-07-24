//
//  AVAsset+Extensions.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 24.07.2025.
//

import AVKit

extension AVAsset {
    func getVideoSize() async -> CGSize? {
        do {
            let tracks = try await loadTracks(withMediaType: .video)
            guard let track = tracks.first else { return nil }
            let size = try await track.load(.naturalSize).applying(track.load(.preferredTransform))
            return CGSize(width: abs(size.width), height: abs(size.height))
        } catch {
            print("Error getting video size: \(error)")
            return nil
        }
    }
}
