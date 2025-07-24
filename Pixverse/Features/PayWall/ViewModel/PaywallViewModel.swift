//
//  PaywallViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 10.07.2025.
//

import SwiftUI

final class PaywallViewModel: ObservableObject {
    @Published var selectedOption: SubscriptionModel.PeriodType = .year
    @Published var showCloseButton = false
    @Published var selectedURL: AppURL?
    
    let closeButtonAppearingDelay: TimeInterval = 2.0
    
    struct Feature {
        let title: String
        let icon: String
    }
    
    let features = [
        Feature(title: "Exclusive styles and templates", icon: "sparkles"),
        Feature(title: "Unlimited generations", icon: "sparkles"),
        Feature(title: "Lack of advertising", icon: "sparkles")
    ]
    
    let subscriptionOptions = SubscriptionModel.mock
    
    func selectOption(_ period: SubscriptionModel.PeriodType) {
        selectedOption = period
    }
    
    func showCloseButtonAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + closeButtonAppearingDelay) {
            withAnimation(.easeIn(duration: 0.3)) {
                self.showCloseButton = true
            }
        }
    }
    
    func productId(for period: SubscriptionModel.PeriodType) -> String {
        switch period {
        case .week: return "weekly_product_id"
        case .month: return "monthly_product_id"
        case .year: return "yearly_product_id"
        }
    }
}
