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
    let fullPrice: String
    let isSelected: Bool
    let discount: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title with attributed price
            AttributedTextView(
                text: "\(title) \(price)\(frequency)",
                boldParts: [title, price],
                boldFont: .body.bold(),
                regularFont: .body,
                color: .white
            )
            
            // Full price
            Text(fullPrice)
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Capsule()
                .stroke(isSelected ? Color.appGreen : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
        .contentShape(Capsule())
        .overlay(alignment: .topTrailing) {
            // MARK: - Sale badge
            if let discount = discount {
                Text("SAVE \(discount)%")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appGreen)
                    .foregroundColor(.black)
                    .clipShape(
                        UnevenRoundedRectangle(
                            bottomLeadingRadius: 20,
                            topTrailingRadius: 20
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
        fullPrice: "awdw",
        isSelected: true,
        discount: 80
    )
}
