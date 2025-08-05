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
        
        SwiftHelper.apphudHelper.fetchProducts(paywallID: "main") { [weak self] products in
            self?.products = products
        }
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        isLoading = true
        SwiftHelper.apphudHelper.restoreAllProducts { [weak self] success in
            if success {
                self?.checkSubscriptionStatus()
            } else {
                self?.errorMessage = "Failed to restore purchases"
            }
            self?.isLoading = false
            completion(success)
        }
    }
    
    func checkSubscriptionStatus() {
        self.isPremium = SwiftHelper.apphudHelper.isProUser()
    }
    
    func getSymbolsAndPrice(for product: ApphudProduct) -> (Double, String) {
        return SwiftHelper.apphudHelper.returnClearPriceAndSymbol(product: product)
    }
    
    func getSubscriptionUnit(for product: ApphudProduct) -> String? {
        return SwiftHelper.apphudHelper.returnSubscriptionUnit(product: product)
    }
    
    func purchase(product: ApphudProduct, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        SwiftHelper.apphudHelper.purchaseSubscription(subscription: product) { [weak self] success in
            self?.isLoading = false
            if success {
                self?.checkSubscriptionStatus()
            }
            self?.isLoading = false
            completion(success)
        }
    }
}
