//
//  ContentItem.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import Foundation

protocol ContentItemProtocol: Identifiable, Hashable {
    var id: Int { get }
    var name: String { get }
    var prompt: String { get }
    var isActive: Bool { get }
    var previewSmallURL: URL? { get }
    var previewLargeURL: URL? { get }
    
    var category: String? { get }
    var templateId: Int? { get }
}

extension ContentItemProtocol {
    var category: String? { nil }
    var templateId: Int? { nil }
}


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

// Wrapper for ContentItemProtocol for navigation
struct AnyContentItem: Hashable {
    private let _base: any ContentItemProtocol
    private let _hashable: AnyHashable
    
    init<T: ContentItemProtocol>(_ base: T) {
        self._base = base
        self._hashable = AnyHashable(base)
    }
    
    var base: any ContentItemProtocol {
        return _base
    }
    
    static func == (lhs: AnyContentItem, rhs: AnyContentItem) -> Bool {
        lhs._hashable == rhs._hashable
    }
    
    func hash(into hasher: inout Hasher) {
        _hashable.hash(into: &hasher)
    }
}
