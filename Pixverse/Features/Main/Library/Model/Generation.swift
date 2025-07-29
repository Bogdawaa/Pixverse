//
//  Generation.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import Foundation

final class VideoGeneration: ObservableObject, Identifiable, Codable {
    let id: String
    let generationId: Int
    @Published var status: Status
    @Published var videoUrl: URL?
    let createdAt: Date
    
    enum Status: String, Codable {
        case generating
        case success
    }
    
    // Regular initializer
    init(id: String, generationId: Int, status: Status, videoUrl: URL? = nil, createdAt: Date) {
        self.id = id
        self.generationId = generationId
        self.status = status
        self.videoUrl = videoUrl
        self.createdAt = createdAt
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        case generationId
        case status
        case videoUrl
        case createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        generationId = try container.decode(Int.self, forKey: .generationId)
        status = try container.decode(Status.self, forKey: .status)
        videoUrl = try container.decodeIfPresent(URL.self, forKey: .videoUrl)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(generationId, forKey: .generationId)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(videoUrl, forKey: .videoUrl)
        try container.encode(createdAt, forKey: .createdAt)
    }
}
