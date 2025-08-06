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
    
    var appState = AppState.shared
    
    // MARK: - States
    @StateObject private var viewModel = PaywallViewModel()
    
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
                    .padding(.horizontal)
                
                // CancelAnyTime Button
                cancelAnyTimeButton
                
                // Continue button
                continueButton
                    .padding(.horizontal)
                
                // Legal Buttons
                legalLinksButtons
                    .padding()
            }
            
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
                appState.fetchProducts()
            }
        }
        .onDisappear { viewModel.showCloseButton = false }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.purchaseErrorMessage ?? "Please try again later."),
                dismissButton: .default(Text("OK")) {
                    viewModel.purchaseErrorMessage = nil
                }
            )
        }
        .onChange(of: viewModel.purchaseErrorMessage) { newValue in
            viewModel.showErrorAlert = newValue != nil
        }
        .alert(isPresented: $viewModel.showSuccessAlert) {
            Alert(
                title: Text("Success"),
                message: Text("Subscriptions restored!"),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                    onDismiss()
                }
            )
        }
    }
    
    private var headerImageWithOverlay: some View {
        ZStack(alignment: .bottom) {
            Image(.paywallContents)
                .resizable()
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                .appBackground.opacity(0),
                                .appBackground.opacity(0.5),
                                .appBackground
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 515)
                }
            .overlay(alignment: .bottom) {
                FeatureListView(features: viewModel.features)
                    .padding()
                    .frame(height: 132)
                    .frame(maxWidth: .infinity)
                    .background(.clear)
                    .foregroundStyle(.appPrimaryText)
            }
            .overlay(alignment: .topTrailing) {
                CloseButton(isVisible: $viewModel.showCloseButton) {
                    dismiss()
                    onDismiss()
                }
            }
            .frame(minWidth: 150)
        }
    }
    
    private var subscriptionOptions: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.subscriptionOptions, id: \.productId) { product in
                SubscriptionSingleView(
                    title: product.name ?? "Unknown name",
                    price: "\(appState.getSymbolsAndPrice(for: product).0)\(appState.getSymbolsAndPrice(for: product).1)",
                    frequency: appState.getSubscriptionUnit(for: product) ?? "Unknown period",
                    isSelected: viewModel.selectedProduct?.productId == product.productId,
                    hasDiscount: product.productId == viewModel.subscriptionOptions.first?.productId ? true : false
                )
                .onTapGesture {
                    viewModel.selectProduct(product)
                    print("Selected: \(viewModel.selectedProduct?.productId ?? "No product selected")")
                }
            }
        }
    }
    
    private var cancelAnyTimeButton: some View {
        Button {
            // Cancel Anytime
        } label: {
            Label("Cancel Anytime",
                  systemImage: ""
            )
            .font(.system(size: 12))
            .frame(minHeight: 40)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.gray)
    }
    
    // Continue Button
    private var continueButton: some View {
        Button {
            guard let product = viewModel.selectedProduct else { return }
            Task {
                if await viewModel.purchaseProduct(product: product) {
                    dismiss()
                    onDismiss()
                }
            }
        } label: {
            Text("Continue")
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.primaryButton)
        .disabled(appState.isLoading || viewModel.selectedProduct == nil)
    }
    
    private var legalLinksButtons: some View {
        HStack {
            Group {
                Button("Privacy Policy") {
                    viewModel.selectedURL = .privacy
                }
                Spacer()
                Button(action: {
                    Task {
                        await viewModel.restorePurchase()
                    }
                }, label: {
                    Text("Restore Purcahses")
                        .foregroundStyle(.appSecondary)
                })
                Spacer()
                Button("Terms of Use") {
                    viewModel.selectedURL = .terms
                }
            }
            .foregroundStyle(.appSecondaryText2)
            .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PaywallView(onDismiss: {})
}
