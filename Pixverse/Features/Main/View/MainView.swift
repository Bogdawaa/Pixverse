//
//  MainView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var storage: OnboardingStorageService
    
    var body: some View {
        NavigationStack {
            MainViewWrapper()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Title
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text("Pixverse Video")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    // Setting button
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            //
                        }) {
                            Image(.setting)
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                }
        }
            
    }
}
#Preview {
    MainView()
}
