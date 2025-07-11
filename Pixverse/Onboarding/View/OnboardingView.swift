//
//  Onboarding.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 08.07.2025.
//

import SwiftUI
import StoreKit
import UserNotifications

struct OnboardingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel = OnboardingViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.flowComplete {
                MainView()
            } else {
                onboardingContent
            }
        }
    }
    
    private var onboardingContent: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if viewModel.showNotificationsRequestScreen {
                // Allow notififcations screen
                notificationRequestView
            } else {
                // Sliding tab views
                onboardingPagesView
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(isPresented: $viewModel.showNotificationPermission) {
            Alert(
                title: Text("Allow Notifications"),
                message: Text("This app will be able to send you messages in your notification center"),
                primaryButton: .default(Text("Allow"), action: {
                    Task {
                        _ = await viewModel.requestNotificationPermission()
                        viewModel.completeOnboarding()
                    }
                    
                }),
                secondaryButton: .cancel(Text("Cancel"), action: {
                    viewModel.completeOnboarding()
                })
            )
        }
        .fullScreenCover(isPresented: $viewModel.showPaywall) {
            PaywallView(onDismiss: {
                viewModel.flowComplete = true
            })
        }
    }
    
    private var onboardingPagesView: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(0..<pages.count, id: \.self) { index in
                SingleOnboardingView(
                    page: pages[index],
                    isLastPage: index == pages.count - 1,
                    currentPage: $viewModel.currentPage,
                    pageCount: pages.count,
                    showPageIndicators: true,
                    action: {
                        viewModel.handleContinue(from: index)
                    }
                )
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private var notificationRequestView: some View {
        TabView {
            SingleOnboardingView(
                page: notificationsRequestPage,
                isLastPage: true,
                currentPage: $viewModel.currentPage,
                pageCount: pages.count,
                showPageIndicators: false,
                action: {
                    viewModel.showNotificationPermission = true
                }
            )
            .transition(.opacity)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    // MARK: - OnboardingItem Data
    private let pages: [OnboardingItem] = [
        OnboardingItem(
            imageName: "onb1",
            title: "Generate magic with AI",
            description: "Generate unique photos and videos in amy style - no skills needed, just imagination."
        ),
        OnboardingItem(
            imageName: "onb2",
            title: "It's that simple",
            description: "No complex tools or editing skills needed - just one prompt and you're ready to go."
        ),
        OnboardingItem(
            imageName: "onb3",
            title: "Create unique photos",
            description: "Bring your imagination to life in any style. Just describe what you want, and get a unique image."
        )
    ]
    
    private let notificationsRequestPage = OnboardingItem(
        imageName: "onb4",
        title: "Always be aware!",
        description: "Allow notification to stay informed and never miss the latest updates."
    )
}

#Preview {
    OnboardingView()
}
