//
//  SubscriptionModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 09.07.2025.
//

import Foundation

struct SubscriptionModel: Identifiable {
    let id = UUID()
    let period: PeriodType
    let periodPrice: Double
    let fullPrice: Double
    let discount: Int?
    
    enum PeriodType: String {
        case year = "Year"
        case month = "Month"
        case week = "Week"
    }
    
    var titleText: String {
        "\(period.rawValue) \(formattedPrice)/\(frequencyUnit)"
    }
    
    var boldText: [String] {
        [period.rawValue, formattedPrice]
    }
    
    var formattedPrice: String {
        String(format: "$%.2f", periodPrice)
    }
    
    var formattedFullPrice: String {
        String(format: "$%.2f", fullPrice)
    }
    
    var frequencyText: String {
        switch period {
        case .year: return "/week"
        case .month: return "/month"
        case .week: return "/week"
        }
    }
    
    private var frequencyUnit: String {
        switch period {
        case .year: return "week"
        case .month: return "month"
        case .week: return "week"
        }
    }
}

extension SubscriptionModel {
    static let mock = [
        SubscriptionModel(
            period: .year,
            periodPrice: 1.27,
            fullPrice: 69.99,
            discount: 80
        ),
        SubscriptionModel(
            period: .month,
            periodPrice: 9.99,
            fullPrice: 9.99,
            discount: nil
        )
    ]
}
