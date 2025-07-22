//
//  TemplateToVideoResponseDTO.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 17.07.2025.
//

import Foundation

struct VideoGenerationResponseDTO: Decodable {
    let videoId: Int
    let detail: String
    
    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case detail
    }
}
