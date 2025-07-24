//
//  PaywallView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 09.07.2025.
//

import SwiftUI

struct PaywallView: View {
    
    // MARK: - ENvironment
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var appState: AppState
    
    // MARK: - States
    @StateObject private var viewModel = PaywallViewModel()
    
    @State private var showAlert = false
    
    // MARK: - Properties
    private let closeButtonAppearingDelay: TimeInterval = 2.0
    
    // MARK: - Closures
    var onDismiss: () -> Void
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Image + Overlays
                headerImageWithOverlay

                // Subscription options
                subscriptionOptions
                
                // CancelAnyTime Button
                cancelAnyTimeButton
                
                // Continue button
                continueButton
                
                // Legal Buttons
                legalLinksButtons
            }
            .padding()
            
            if appState.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
        .safariSheet(url: $viewModel.selectedURL)
        .onAppear {
            viewModel.showCloseButtonAfterDelay()
            if appState.products.isEmpty {
                appState.fetchProducts(paywallID: "PixverseID")
            }
        }
        .onDisappear { viewModel.showCloseButton = false }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(appState.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: appState.errorMessage) { newValue in
            showAlert = newValue != nil
        }
    }
    
    private var headerImageWithOverlay: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                Image(.paywall)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            .overlay(alignment: .bottom) {
                FeatureListView(features: viewModel.features)
                    .padding()
                    .frame(height: 132)
                    .frame(maxWidth: .infinity)
                    .background(.appDarkGray)
                    .clipShape(.rect(cornerRadius: 30))
                    .foregroundStyle(.white)
            }
            .overlay(alignment: .top) {
                ProBadgeView( action: {
                    // PRO button onTap action
                })
            }
            .overlay(alignment: .topTrailing) {
                CloseButton(isVisible: $viewModel.showCloseButton) {
                    dismiss()
                    onDismiss()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .frame(minWidth: 150)
        }
    }
    
    private var subscriptionOptions: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.subscriptionOptions) { option in
                SubscriptionSingleView(
                    title: option.period.rawValue,
                    price: option.formattedPrice,
                    frequency: option.frequencyText,
                    fullPrice: option.formattedFullPrice,
                    isSelected: viewModel.selectedOption == option.period,
                    discount: option.discount
                )
                .onTapGesture {
                    viewModel.selectOption(option.period)
                }
            }
        }
    }
    
    private var cancelAnyTimeButton: some View {
        Button {
            // Cancel Anytime
        } label: {
            Label("Cancel Anytime",
                  systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90"
            )
            .frame(minHeight: 40)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.gray)
    }
    
    // Continue Button
    private var continueButton: some View {
        Button {
            guard let product = appState.product(for: viewModel.selectedOption) else {
                appState.errorMessage = "Product not available"
                return
            }
            appState.purchase(product: product)
        } label: {
            Text("Continue")
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.primaryButton)
        .disabled(appState.isLoading)
    }
    
    private var legalLinksButtons: some View {
        HStack {
            Group {
                Button("Privacy Policy") {
                    viewModel.selectedURL = .privacy
                }
                Spacer()
                Button(action: {
                    appState.restorePurchases()
                }, label: {
                    Text("Restore Purcahses")
                        .foregroundStyle(.white.opacity(0.6))
                })
                Spacer()
                Button("Terms of Use") {
                    viewModel.selectedURL = .terms
                }
            }
            .foregroundStyle(.white.opacity(0.4))
            .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PaywallView(onDismiss: {})
}
