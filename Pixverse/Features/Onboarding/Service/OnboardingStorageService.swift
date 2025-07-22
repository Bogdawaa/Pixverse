//
//  OnboardingStorageManager.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 09.07.2025.
//

import Foundation

protocol OnboardingStorageServiceProtocol: ObservableObject {
    var hasCompletedOnboarding: Bool { get }
    func markOnboardingComplete()
}

final class OnboardingStorageService: OnboardingStorageServiceProtocol {
    
    // MARK: - Private Properties
    private let storage: StorageProtocol
    private let key = Constants.UserDefaultsKeys.hasCompletedOnboarding
    
    // MARK: - Published
    @Published private(set) var hasCompletedOnboarding: Bool
    
    // MARK: - Initialize
    init(storage: StorageProtocol = UserDefaultsStorage()) {
        self.storage = storage
        self.hasCompletedOnboarding = (try? storage.load(forKey: key)) ?? false
    }
    
    // MARK: - Public Methods
    func markOnboardingComplete() {
        hasCompletedOnboarding = true
        try? storage.save(true, forKey: key)
    }
    
    func markOnboardingUncomplete() {
        hasCompletedOnboarding = false
        storage.remove(forKey: key)
    }
}
