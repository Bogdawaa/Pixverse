//
//  SubscriptionButton.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 23.07.2025.
//

import SwiftUI

struct SubscriptionButton: View {
    
    @EnvironmentObject private var router: Router
    
    var body: some View {
        Button {
            router.shouldShowPaywall = true
        } label: {
            Image(systemName: "sparkles")
                .symbolRenderingMode(.monochrome)
                .foregroundColor(.appBackground)
                .padding(4)
                .background {
                    Circle()
                        .fill(Color.appGreen)
                        .frame(width: 32, height: 32)
                }
        }
    }
}
