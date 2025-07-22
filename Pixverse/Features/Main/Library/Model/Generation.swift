//
//  Generation.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import Foundation

struct VideoGeneration: Codable, Identifiable {
    let id: String
    let generationId: Int
    let status: Status
    let videoUrl: URL?
    let createdAt: Date
    
    enum Status: String, Codable {
        case generating
        case success
    }
}
