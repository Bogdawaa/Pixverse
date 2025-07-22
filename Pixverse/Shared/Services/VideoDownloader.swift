//
//  VideoDownloader.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 19.07.2025.
//

import Photos

struct VideoDownloader {
    static func saveVideoToGallery(from url: URL) async throws {
        let localURL: URL
        
        if url.isFileURL {
            localURL = url
        } else {
            localURL = try await downloadVideo(from: url)
        }
        
        try await saveToPhotoLibrary(videoURL: localURL)
        
        // delete if it was a downloaded file
        if !url.isFileURL {
            try? FileManager.default.removeItem(at: localURL)
        }
    }
    
    private static func downloadVideo(from url: URL) async throws -> URL {
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let targetURL = documentsURL.appendingPathComponent(url.lastPathComponent)
        
        // Move from temp location to documents
        try FileManager.default.moveItem(at: tempURL, to: targetURL)
        return targetURL
    }
    
    private static func saveToPhotoLibrary(videoURL: URL) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? PhotoLibraryError.unknown)
                }
            }
        }
    }
    
    enum PhotoLibraryError: Error {
        case unknown
    }
}
