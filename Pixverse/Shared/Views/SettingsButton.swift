//
//  SettingsButton.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI

struct SettingsButton: View {
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    var body: some View {
        Button {
            appCoordinator.shouldShowSettings = true
        } label: {
            Image(.setting)
                .tint(.white)
                .background {
                    Circle()
                        .fill(Color.appCard)
                        .frame(width: 32, height: 32)
                }
        }
    }
}
