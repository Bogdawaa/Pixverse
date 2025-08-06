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
            imageName: "iphone with notifications",
            title: "Create videos in seconds",
            description: "Just type your idea - AI makes the video for you. Fast, simple, no editing needed"
        ),
        OnboardingItem(
            imageName: "iPhone - Realism",
            title: "Videos by prompt and style",
            description: "Pick a style, describe the scene - we'll handle the rest automatically and creatively."
        ),
        OnboardingItem(
            imageName: "iphone with notifications-2",
            title: "Generate photos",
            description: "Create vivid portraits and styles with AI - quick, precise, and truly unique."
        )
    ]
    
    private let notificationsRequestPage = OnboardingItem(
        imageName: "iphone with notifications-3",
        title: "Enable notifications",
        description: "Get alerts when your video is ready or a new template drops - never miss updates."
    )
}

#Preview {
    OnboardingView()
}
