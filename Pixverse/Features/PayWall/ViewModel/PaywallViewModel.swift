//
//  PaywallViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 10.07.2025.
//

import SwiftUI
import ApphudSDK

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var selectedOption: SubscriptionModel.PeriodType = .year
    @Published var showCloseButton = false
    @Published var selectedURL: AppURL?
    @Published var title: String?
    @Published var showErrorAlert = false
    @Published var purchaseErrorMessage: String?
    @Published var showSuccessAlert: Bool = false
    
    let appState = AppState.shared
    let closeButtonAppearingDelay: TimeInterval = 2.0
    
    var onContinue: (() -> Void)?
    
    @Published var selectedProduct: ApphudProduct?
    
    
    struct Feature {
        let title: String
        let icon: String
    }
    
    let features = [
        Feature(title: "Exclusive styles and templates", icon: "sparkles"),
        Feature(title: "Unlimited generations", icon: "sparkles"),
        Feature(title: "Lack of advertising", icon: "sparkles")
    ]
    
    var subscriptionOptions: [ApphudProduct] {
        appState.products
    }
    
    func selectOption(_ period: SubscriptionModel.PeriodType) {
        selectedOption = period
    }
    
    func selectProduct(_ product: ApphudProduct) {
        selectedProduct = product
    }
    
    func showCloseButtonAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + closeButtonAppearingDelay) {
            withAnimation(.easeIn(duration: 0.3)) {
                self.showCloseButton = true
            }
        }
    }
    
    func purchaseProduct(product: ApphudProduct) async -> Bool {
        let success = await withCheckedContinuation { continuation in
            appState.purchase(product: product) { result in
                continuation.resume(returning: result)
            }
        }
        if success {
            return true
        } else {
            title = "Error."
            showErrorAlert = true
            purchaseErrorMessage = "Failed to purchase subscription. Please try again."
            
            return false
        }
    }
    
    func restorePurchase() async -> Bool {
        let success = await withCheckedContinuation { continuation in
            appState.restorePurchases() { result in
                continuation.resume(returning: result)
            }
        }
        if success {
            showSuccessAlert = true
            return true
        } else {
            title = "Error."
            showErrorAlert = true
            purchaseErrorMessage = "Failed to restore purchases. Make sure you have active subscriptions or try again later."
            return false
        }
    }
}
