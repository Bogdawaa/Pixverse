//
//  StorageProtocol.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 09.07.2025.
//

import Foundation

protocol StorageProtocol {
    func save(_ value: Any, forKey key: String)
    func load<T>(forKey key: String) -> T?
    func remove(forKey key: String)
}
