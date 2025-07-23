//
//  SubscriptionButton.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 23.07.2025.
//

import SwiftUI

struct SubscriptionButton: View {
    var body: some View {
        Button {
            //
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
