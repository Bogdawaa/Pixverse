//
//  AppState.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 23.07.2025.
//

import ApphudSDK
import SwiftHelper
import SwiftUI

@MainActor
class AppState: ObservableObject {
    
    static let shared = AppState()
    
    private init() {}
    
    @Published var isPremium: Bool = false
    @Published var products: [ApphudProduct] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var userId: String = Apphud.userID()
    
    func fetchProducts() {
        isLoading = true
        defer { isLoading = false }
        
        Task {
            let fetchedProducts = try await Apphud.fetchProducts()
            fetchedProducts.forEach { product in
                if let product = (Apphud.apphudProductFor(product)) {
                    products.append(product)
                }
            }
        }
    }
    
    func purchase(product: ApphudProduct) {
        isLoading = true
        SwiftHelper.apphudHelper.purchaseSubscription(subscription: product) { [weak self] success in
            self?.isLoading = false
            if success {
                self?.checkSubscriptionStatus()
            } else {
                print("Failed to purchase subscription")
                self?.errorMessage = "Failed to purchase subscription"
            }
        }
    }
    
    func restorePurchases() {
        isLoading = true
        SwiftHelper.apphudHelper.restoreAllProducts { [weak self] success in
            self?.isLoading = false
            if success {
                self?.checkSubscriptionStatus()
            } else {
                self?.errorMessage = "Failed to restore purchases"
            }
        }
    }
    
    func checkSubscriptionStatus() {
//        self.isPremium = SwiftHelper.apphudHelper.isProUser()
        self.isPremium = Apphud.hasActiveSubscription() // TODO: uncomment
    }

    func product(for id: String) -> ApphudProduct? {
        return products.first(where: { $0.productId == id })
    }
    
    func getSymbolsAndPrice(for product: ApphudProduct) -> (Double, String) {
        return SwiftHelper.apphudHelper.returnClearPriceAndSymbol(product: product)
    }
    
    func getSubscriptionUnit(for product: ApphudProduct) -> String? {
        return SwiftHelper.apphudHelper.returnSubscriptionUnit(product: product)
    }
}
