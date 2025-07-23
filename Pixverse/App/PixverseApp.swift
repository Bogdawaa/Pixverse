//
//  PixverseApp.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 08.07.2025.
//

import SwiftUI
import ApphudSDK
import SwiftHelper

@main
struct PixverseApp: App {
    
    @StateObject private var appState = AppState.shared
    
    init() {
        Apphud.start(apiKey: "app_wUSLSxe9t1nJzbJVVr1H3fvBV4r7ro")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    appState.checkSubscriptionStatus()
                }
        }
    }
}
