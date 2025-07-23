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
    
    var userId: String {
        Apphud.userID()
    }
    
    func fetchProducts(paywallID: String) {
        isLoading = true
        
        SwiftHelper.apphudHelper.fetchProducts(paywallID: paywallID) { [weak self] products in
            self?.products = products
            self?.isLoading = false
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
        self.isPremium = true
    }
    
    func product(for period: SubscriptionModel.PeriodType) -> ApphudProduct? {
        let productId: String
        
        switch period {
        case .week: productId = "weekly_product_id"
        case .month: productId = "monthly_product_id"
        case .year: productId = "yearly_product_id"
        }
        
        return products.first(where: { $0.productId == productId })
    }
}
