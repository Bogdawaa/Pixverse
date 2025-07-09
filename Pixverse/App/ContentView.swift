//
//  ContentView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 08.07.2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var storage = OnboardingStorageService()
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            MainView()
                .navigationDestination(isPresented: .constant(!storage.hasCompletedOnboarding)) {
                    OnboardingView()
                }
            
        }
    }
}

#Preview {
    ContentView()
}
