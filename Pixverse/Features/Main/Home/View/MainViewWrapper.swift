//
//  MainView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 09.07.2025.
//

import SwiftUI

struct MainViewWrapper: View {
    @EnvironmentObject var appState: AppState
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var homeCoordinator: HomeCoordinator
    @EnvironmentObject private var videoCoordinator: VideoCoordinator
    
    
    @StateObject private var contentVM = ContentSectionViewModel()
    @StateObject private var videoVM: VideoViewModel
    @StateObject private var videoGenerationVM = VideoGenerationViewModel()
    @StateObject private var textGenerationVM = TextGenerationViewModel()
    
    private let templateService: TemplateServiceProtocol
    
    let tabs = [
        TabItem(title: "Home", iconName: "appHome", type: .home),
        TabItem(title: "Video", iconName: "appVideo", type: .video),
        TabItem(title: "Library", iconName: "appGallery", type: .library)
    ]
    
    init() {
        let service = TemplateService(
            networkClient: DefaultNetworkClientImpl(baseURL: Constants.baseURL)
        )
        self.templateService = service
        _contentVM = StateObject(wrappedValue: ContentSectionViewModel(templateService: service))
        _videoVM = StateObject(wrappedValue: VideoViewModel(templateService: service))
    }
    
    var body: some View {
        
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab Content
                TabView(selection: $appCoordinator.selectedTab) {
                    // Home Tab
                    NavigationStack(path: $homeCoordinator.path) {
                        ZStack {
                            Color.appBackground
                            
                            VStack(spacing: 0) {
                                ContentSectionsView(viewModel: contentVM)
                                    .environmentObject(appCoordinator)
                                    .environmentObject(homeCoordinator)
                                    .environmentObject(videoCoordinator)
                                    .toolbar {
                                        ToolbarItem(placement: .topBarLeading) {
                                                Text("Pixverse Videos")
                                                    .foregroundStyle(.white)
                                                    .fontWeight(.bold)
                                                    .font(.system(size: 34))
                                                
                                        }
                                        // Subscription button
                                        if !appState.isPremium {
                                        ToolbarItem(placement: .topBarTrailing) {
                                                SubscriptionButton()
                                            }
                                        }
                                        ToolbarItem(placement: .topBarTrailing) {
                                            SettingsButton()
                                        }
                                    }
                            }
                        }
                        .navigationDestination(isPresented: $appCoordinator.shouldShowSettings) {
                            SettingsView()
                                .environmentObject(appCoordinator)
                        }
                    }
                    .tag(0)
                    .tint(.appSecondaryText2)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    
                    // Video Tab
                    NavigationStack(path: $videoCoordinator.path) {
                        VideoView(viewModel: videoVM, videoGenerationVM: videoGenerationVM, textGenerationVM: textGenerationVM)
                            .environmentObject(appCoordinator)
                            .environmentObject(homeCoordinator)
                            .environmentObject(videoCoordinator)
                            .toolbarColorScheme(.dark, for: .navigationBar)
                            .navigationDestination(for: AnyContentItem.self) { wrappedItem in
                                TemplateView(item: wrappedItem.base, viewModel: videoGenerationVM)
                                    .environmentObject(videoCoordinator)
                            }
                            .navigationDestination(for: ContentSection.self) { section in
                                AllItemsView(section: section)
                            }
                            .navigationDestination(for: UIImage.self) { image in
                                GenerationProgressView(viewModel: videoGenerationVM, mediaType: .image(Image(uiImage: image)))
                            }
                            .navigationDestination(for: URL.self) { url in
                                GenerationProgressView(viewModel: videoGenerationVM, mediaType: .video(url))
                            }
                    }
                    .tag(1)
                    .tint(.appSecondaryText2)
                    
                    NavigationStack {
                        LibraryView()
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Text("My Library")
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                        .font(.system(size: 34))
                                    
                                }
                                ToolbarItem(placement: .topBarTrailing) {
                                    // Subscription button
                                    if !AppState.shared.isPremium {
                                        SubscriptionButton()
                                    }
                                }
                                ToolbarItem(placement: .topBarTrailing) {
                                    SettingsButton()
                                }
                            }
                            .navigationDestination(isPresented: $appCoordinator.shouldShowSettings) {
                                SettingsView()
                                    .environmentObject(appCoordinator)
                                
                            }
                    }
                    .tag(2)
                    .tint(.appSecondaryText2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                CapsuleTabBar(selectedTab: $appCoordinator.selectedTab, tabs: tabs)
            }
        }
        
    }
    
    private var settingsButton: some View {
        Button {
            //
        } label: {
            Image(.setting)
                .tint(.white)
                .background {
                    Circle()
                        .fill(Color.appCard)
                        .frame(width: 32, height: 32)
                    
                }
        }
    }
}



#Preview {
    MainViewWrapper()
        .environmentObject(AppCoordinator())
        .environmentObject(HomeCoordinator())
        .environmentObject(VideoCoordinator())
}
