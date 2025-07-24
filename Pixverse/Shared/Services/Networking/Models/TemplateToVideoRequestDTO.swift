//
//  TemplateToVideoRequestDTO.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 17.07.2025.
//

import Foundation

struct TemplateToVideoRequestDTO: Encodable {
    let userId: String
    let appId: String
    let templateId: Int
    let image: Data
}
