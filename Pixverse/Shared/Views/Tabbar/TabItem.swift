//
//  TabItem.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import Foundation

enum TabType {
    case home
    case video
    case photo
    case library
}

struct TabItem {
    let title: String
    let iconName: String
    let type: TabType
}
