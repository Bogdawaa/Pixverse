//
//  HomeTabView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 26.07.2025.
//

import SwiftUI

struct HomeTabView: View {
    
    @ObservedObject var contentVM: ContentSectionViewModel
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: Router
    
    var body: some View {
        ContentSectionsView(viewModel: contentVM, showAll: false)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Pixverse Videos")
                        .foregroundStyle(.appMainText)
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
