//
//  SettingsButton.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI

struct SettingsButton: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        Button {
//            router.shouldShowSettings = true
            router.navigate(to: .settings)
        } label: {
            Image(.setting)
                .tint(.appGreen)
                .frame(width: 24, height: 24)
        }
        .frame(width: 32, height: 32)
    }
}
