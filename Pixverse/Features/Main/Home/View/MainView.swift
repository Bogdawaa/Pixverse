//
//  MainView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var storage: OnboardingStorageService
    
    @StateObject private var router = Router()
    
    var body: some View {
        VStack(spacing: 0) {
            MainViewWrapper()
                .environmentObject(router)
        }
        .background(.appBackground)
    }
}
#Preview {
    MainView()
        .environmentObject(OnboardingStorageService())
}
