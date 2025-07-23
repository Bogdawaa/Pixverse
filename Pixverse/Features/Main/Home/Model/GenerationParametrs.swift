//
//  GenerationParametrs.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 21.07.2025.
//

import UIKit

protocol GenerationParametersProtocol {
    var templateId: Int? { get }
}

struct ImageToVideoParameters: GenerationParametersProtocol {
    let prompt: String
    let image: UIImage
    let templateId: Int?
}

struct VideoToVideoParameters: GenerationParametersProtocol {
    let videoURL: URL
    let templateId: Int?
}

struct TemplateToVideoParameters: GenerationParametersProtocol {
    let image: UIImage
    let templateId: Int?
    
    init(templateId: Int, image: UIImage) {
        self.templateId = templateId
        self.image = image
    }
}
