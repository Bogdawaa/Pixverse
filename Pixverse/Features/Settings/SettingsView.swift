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
    
    @State private var showMailUnavailableAlert = false
    @State private var isShowPaywall = false
    
    var body: some View {
        VStack {
            List {
                // MARK: - Purchase Section
                Section(
                    header: Text("Purchases & actions")
                    .font(.headline)
                    .foregroundStyle(.appSecondaryText2)
                    
                
                ) {
                    // Row 1
                    Button {
                        isShowPaywall = true
                    } label: {
                        Text("Subscription management")
                            .padding(.leading, 16)
                    }

                    
                    // Row 2 (with toggle)
                    HStack {
                        Text("Notifications")
                            .padding(.leading, 16)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { viewModel.isNotificationToggleOn },
                            set: { newValue in
                                viewModel.toggleNotifications(newValue: newValue)
                            }))
                            .labelsHidden()
                            .tint(.appGreen)
                    }
                    
                    HStack {
                        // переключатель для тестирования
                        Text("Is Premium User")
                            .padding(.leading, 16)
                        Spacer()
                        Toggle("", isOn: $appState.isPremium)
                            .labelsHidden()
                            .tint(.appGreen)
                    }
                }
                .listRowBackground(Color.appBackground)
                
                // MARK: - Info Section
                Section(
                    header: Text("Info & legal")
                        .font(.headline)
                        .font(.headline)
                        .foregroundStyle(.appSecondaryText2)
                ) {
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
                        Text("Contact us")
                            .padding(.leading, 16)
                            .foregroundColor(.white)
                    }
                    // Row 2
                    Button {
                        viewModel.selectedURL = .privacy
                    } label: {
                        Text("Privacy Policy")
                            .padding(.leading, 16)
                    }

                    
                    // Row 3
                    Button {
                        viewModel.selectedURL = .terms
                    } label: {
                        Text("Usage Policy")
                            .padding(.leading, 16)
                    }
                }
                .listRowBackground(Color.appBackground)
            }
            .scrollDisabled(true)
            .navigationTitle("Subscribers")
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .foregroundStyle(.white)
            .frame(maxHeight: 370)
            
            
            
            Text("App Version: \(viewModel.appVersion)")
                .foregroundStyle(.white.opacity(0.6))
                .font(.system(size: 13))
            
            Spacer()
        }
        .background(Color.appBackground)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("Subscribers")
//                    .font(.system(size: 17, weight: .bold))
//                    .foregroundColor(.white)
//            }
//        }
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
                            .foregroundColor(.white)
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
