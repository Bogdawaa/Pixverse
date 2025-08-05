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
    
    let appState = AppState.shared
    
    let closeButtonAppearingDelay: TimeInterval = 2.0
    
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
    
//    let subscriptionOptions = SubscriptionModel.mock
    
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
    
//    func productId(for period: SubscriptionModel.PeriodType) -> String {
//        switch period {
//        case .week: return "weekly_product_id"
//        case .month: return "monthly_product_id"
//        case .year: return "yearly_product_id"
//        }
//    }
    
    
}
