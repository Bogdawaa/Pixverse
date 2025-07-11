//
//  ProBadgeView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 10.07.2025.
//

import SwiftUI

struct ProBadgeView: View {
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("PRO")
                .frame(minWidth: 116)
                .frame(minHeight: 30)
                .background(.appBackground)
                .foregroundStyle(.white)
                .fontWeight(.bold)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: 30,
                        bottomTrailingRadius: 30
                    )
                )
        }
    }
}

#Preview {
    ProBadgeView(action: {} )
}
