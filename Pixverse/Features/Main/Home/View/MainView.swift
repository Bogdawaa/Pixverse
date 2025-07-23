//
//  MainView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var storage: OnboardingStorageService
    
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var homeCoordinator = HomeCoordinator()
    @StateObject private var videoCoordinator = VideoCoordinator()
    
    var body: some View {
        VStack(spacing: 0) {
            MainViewWrapper()
                .environmentObject(appCoordinator)
                .environmentObject(homeCoordinator)
                .environmentObject(videoCoordinator)
        }
        .background(.appBackground)
    }
}
#Preview {
    MainView()
        .environmentObject(OnboardingStorageService())
}
