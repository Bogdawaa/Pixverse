//
//  UserDefaultsStorage.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 09.07.2025.
//

import Foundation

final class UserDefaultsStorage: StorageProtocol {
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save(_ value: Any, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func load<T>(forKey key: String) -> T? {
        userDefaults.value(forKey: key) as? T
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
