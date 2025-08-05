//
//  OnboardingViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 08.07.2025.
//

import SwiftUI
import StoreKit

protocol OnboardingViewModelProtocol: ObservableObject {
    var currentPage: Int { get set }
    var showNotificationsRequestScreen: Bool { get set }
    var showNotificationPermission: Bool { get set }
    
    func handleContinue(from index: Int)
    func requestNotificationPermission() async -> Bool
}

final class OnboardingViewModel {
    
    // MARK: - Properties
    private let notificationCenter: UNUserNotificationCenter
    private var onboardingStorage: any OnboardingStorageServiceProtocol
    
    // MARK: - Published
    @Published var currentPage = 0
    @Published var showNotificationsRequestScreen = false
    @Published var showNotificationPermission = false
    @Published var showPaywall = false
    @Published var flowComplete = false
        
    // MARK: - Initialize
    init(
        onboardingStorgage: any OnboardingStorageServiceProtocol = OnboardingStorageService(),
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.onboardingStorage = onboardingStorgage
        self.notificationCenter = notificationCenter
    }
    
    // MARK: - Private Methods
    private func requestAppReview() {
        #if DEBUG
        debugPrint("Debug mode - showing notifications request")
        showNotificationsRequestScreen = true
        #else
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNotificationsRequestScreen = true
        }
        #endif
    }
    
    func openAppStoreForRating() {
        guard let url = URL(string: "https://apps.apple.com/app/\(Constants.appStoreAppId)?action=write-review") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - OnboardingViewModelProtocol
extension OnboardingViewModel: OnboardingViewModelProtocol {
    
    func handleContinue(from index: Int) {
        switch index {
        case 2:
            requestAppReview()
        default:
            currentPage += 1
        }
    }
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await MainActor.run {
                self.showNotificationPermission = false
            }
            return granted
        } catch {
            print("Notification permission error: \(error.localizedDescription)")
            return false
        }
    }
    
    func completeOnboarding() {
        onboardingStorage.markOnboardingComplete()
        showPaywall = true
    }
    
    func completePaywall() {
        flowComplete = true
    }
}
