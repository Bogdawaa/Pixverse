//
//  SettingsView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 21.07.2025.
//

import SwiftUI

struct SettingsView: View {
    
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
                        Toggle("", isOn: $viewModel.isToggleOn)
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
                    #if targetEnvironment(simulator)
                        print("Simulator detected - showing preview email")
                        viewModel.showMailComposer = true 
                    #else
                        if MFMailComposeViewController.canSendMail() {
                            viewModel.showMailComposer = true
                        } else {
                            showMailUnavailableAlert = true
                        }
                    #endif
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
        .safariSheet(url: $viewModel.selectedURL)
        .alert(isPresented: $viewModel.showNotificationPermission) {
            Alert(
                title: Text("Allow Notifications"),
                message: Text("This app will be able to send you messages in your notification center"),
                primaryButton: .default(Text("Allow"), action: {
                    Task {
                        _ = await viewModel.requestNotificationPermission()
                    }
                    
                }),
                secondaryButton: .cancel(Text("Cancel"), action: {
                    //
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

#Preview {
    SettingsView()
}
