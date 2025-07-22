//
//  ThumbnailCache.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 19.07.2025.
//

import UIKit

final class ThumbnailCache {
    static let shared = ThumbnailCache()
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {
        cache.countLimit = 100 // Limit cache to 100 items
    }
    
    func set(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func get(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
}

