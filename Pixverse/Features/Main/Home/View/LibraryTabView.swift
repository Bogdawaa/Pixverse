//
//  LibraryTabView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 26.07.2025.
//

import SwiftUI

struct LibraryTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: Router
    
    var body: some View {
        LibraryView()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("My Library")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 34))
                }
                
                if !appState.isPremium {
                    ToolbarItem(placement: .topBarTrailing) {
                        SubscriptionButton()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    SettingsButton()
                }
            }
            .tint(.appSecondaryText2)

    }
}
