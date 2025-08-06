//
//  SubscriprionOptionView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 09.07.2025.
//

import SwiftUI

struct SubscriptionSingleView: View {
    let title: String
    let price: String
    let frequency: String
    let isSelected: Bool
    let hasDiscount: Bool
    
    var body: some View {
        // Title with attributed price
        AttributedTextView(
            text: "\(price)/ \(frequency)",
            boldParts: [price],
            boldFont: .body.bold(),
            regularFont: .body,
            color: .appMainText
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.appGreen : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .topTrailing) {
            // MARK: - Sale badge
            if hasDiscount {
                Text("SAVE \(80)%")
                    .font(.caption2.bold())
                    .padding(.horizontal, 17)
                    .padding(.vertical, 5)
                    .background(Color.appGreen)
                    .foregroundColor(.appBackground)
                    .clipShape(
                        UnevenRoundedRectangle(
                            bottomLeadingRadius: 20,
                            topTrailingRadius: 8
                        )
                    )
                    .zIndex(1)
                    .clipped()
            }
        }
    }
}

#Preview {
    SubscriptionSingleView(
        title: "Year",
        price: "80",
        frequency: "awawd",
        isSelected: true,
        hasDiscount: true
    )
}
