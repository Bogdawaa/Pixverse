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
        Apphud.start(apiKey: "app_3csKXeauyMzT1PcMyDezXu8D112SW4")
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
