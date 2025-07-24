//
//  ContentView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 08.07.2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var storage = OnboardingStorageService()
    
    var body: some View {
        Group {
            if storage.hasCompletedOnboarding {
                MainView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
}
