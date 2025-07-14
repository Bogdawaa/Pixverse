//
//  ContentItem.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import Foundation

struct ContentItem: Identifiable {
    let id: String
    var title: String
    var imageName: String
    let category: String?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        imageName: String,
        category: String? = nil
    ) {
        self.id = id
        self.title = title
        self.imageName = imageName
        self.category = category
    }
}
