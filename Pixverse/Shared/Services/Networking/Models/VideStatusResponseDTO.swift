//
//  VideStatusResponseDTO.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 17.07.2025.
//

import Foundation

struct VideoStatusResponseDTO: Decodable {
    let status: String
    let videoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case videoUrl = "video_url"
    }
}
