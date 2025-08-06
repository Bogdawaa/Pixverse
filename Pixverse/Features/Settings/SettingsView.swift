//
//  SettingsView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 21.07.2025.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = SettingsViewModel()
    
    @ObservedObject private var generationManager = GenerationManager.shared
    
    @State private var showMailUnavailableAlert = false
    @State private var isShowPaywall = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Purchases & Actions")
                    .font(.headline)
                    .foregroundStyle(.appSecondaryText2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // Row 1
                HStack {
                    Text("Number of avalibable generations")
                    Spacer()
                    Text(
                        "\(generationManager.maxConcurrentGenerations - generationManager.currentActiveGenerations)/\(generationManager.maxConcurrentGenerations)"
                    )
                    .foregroundStyle(.appSecondaryText2)
                    
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                
                Button {
                    if AppState.shared.isPremium {
                        Task {
                            await viewModel.openSubscriptionManagement()
                        }
                    } else {
                        isShowPaywall = true
                    }
                } label: {
                    HStack {
                        Text("Subscription management")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                }
                
                
                // Row 2 (with toggle)
                HStack {
                    Text("Notifications")
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { viewModel.isNotificationToggleOn },
                        set: { newValue in
                            viewModel.toggleNotifications(newValue: newValue)
                        }))
                    .labelsHidden()
                    .tint(.appGreen)
                }
                .frame(height: 44)
                .padding(.horizontal)
                
                #if DEBUG
                HStack {
                    // переключатель для тестирования
                    Text("Is Premium User")
                    Spacer()
                    Toggle("", isOn: $appState.isPremium)
                        .labelsHidden()
                        .tint(.appGreen)
                }
                .frame(height: 44)
                .padding(.horizontal)
                #endif
                
                Text("Info & legal")
                    .font(.headline)
                    .foregroundStyle(.appSecondaryText2)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // Row 1
                Button {
                    if let emailURL = viewModel.getEmailURL() {
                        if UIApplication.shared.canOpenURL(URL(string: "mailto:")!) {
                            UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
                        } else {
                            showMailUnavailableAlert = true
                        }
                    }
                } label: {
                    HStack {
                        Text("Contact us")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                    .foregroundColor(.appMainText)
                }
                // Row 2
                Button {
                    viewModel.selectedURL = .privacy
                } label: {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                }
                
                
                // Row 3
                Button {
                    viewModel.selectedURL = .terms
                } label: {
                    HStack {
                        Text("Usage Policy")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .frame(height: 44)
                    .padding(.horizontal, 16)
                }
            }
            .padding()
            .foregroundStyle(.appMainText)
            
            Text("App Version: \(viewModel.appVersion)")
                .foregroundStyle(.appSecondaryText2)
                .font(.system(size: 13))
            
            Spacer()
        }
        .background(Color.appBackground)
        .safariSheet(url: $viewModel.selectedURL)
        .alert(isPresented: $viewModel.showNotificationPermission) {
            Alert(
                title: Text("Allow Notifications"),
                message: Text("This app will be able to send you messages in your notification center"),
                primaryButton: .default(Text("Allow"), action: {
                    viewModel.requestNotificationPermission()
                }),
                secondaryButton: .cancel(Text("Cancel"), action: {
                    viewModel.isNotificationToggleOn = false
                })
            )
        }
        .alert("Email Not Available", isPresented: $showMailUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please set up an email account on your device to contact support.")
        }
        .fullScreenCover(isPresented: $isShowPaywall) {
            PaywallView {
                isShowPaywall = false
            }
        }
    }

}


struct SettingsViewWithToolbar: View {
    
    @EnvironmentObject private var router: Router
    
    var body: some View {
        NavigationStack {
            SettingsView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            router.shouldShowSettings = false
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Back")
                            }
                            .foregroundColor(.appSecondaryText2)
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Subscribers")
                            .font(.headline)
                            .foregroundColor(.appMainText)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.appBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}


#Preview {
    SettingsView()
}
