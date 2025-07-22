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
    
    func save<T: Codable>(_ value: T, forKey key: String) throws
    func load<T: Codable>(forKey key: String) throws -> T?
}
