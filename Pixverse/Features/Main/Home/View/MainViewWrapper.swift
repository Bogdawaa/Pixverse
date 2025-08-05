//
//  MainView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 09.07.2025.
//

import SwiftUI
import Combine

struct MainViewWrapper: View {
    @EnvironmentObject var appState: AppState

    @EnvironmentObject private var router: Router
    
    @StateObject private var contentVM = ContentSectionViewModel()
    @StateObject private var videoVM: VideoViewModel
    @StateObject private var videoGenerationVM = VideoGenerationViewModel()
    @StateObject private var textGenerationVM = TextGenerationViewModel()
    
    @State private var isKeyboardVisible = false
    
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
        
        // Tab Content
        VStack(spacing: 0) {
        NavigationStack(path: $router.path) {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                    TabView(selection: $router.selectedTab) {
                        // MARK: - Home Tab
                        HomeTabView(contentVM: contentVM)
                            .tag(0)
                        
                        // MARK: - Video Tab
                        VideoTabView(
                            videoVM: videoVM,
                            videoGenerationVM: videoGenerationVM,
                            textGenerationVM: textGenerationVM
                        )
                        .tag(1)
                        
                        // MARK: - Library
                        LibraryTabView()
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .video:
                            VideoView(
                                viewModel: videoVM,
                                videoGenerationVM: videoGenerationVM,
                                textGenerationVM: textGenerationVM
                            )
                        case .allItems(let section):
                            AllItemsView(section: section)
                        default:
                            EmptyView()
                        }
                    }
                    .navigationDestination(for: AnyContentItem.self) { wrappedItem in
                        TemplateView(item: wrappedItem.base, viewModel: videoGenerationVM)
                    }
                    .navigationDestination(for: UIImage.self) { image in
                        if router.selectedVideoTab == .templates {
                            GenerationProgressView(viewModel: videoGenerationVM, mediaType: .image(Image(uiImage: image)))
                        } else if router.selectedVideoTab == .textGeneration {
                            GenerationProgressView(viewModel: textGenerationVM, mediaType: .image(Image(uiImage: image)))
                        }
                    }
                    .navigationDestination(for: URL.self) { url in
                        GenerationProgressView(viewModel: videoGenerationVM, mediaType: .video(url))
                    }
                    .navigationDestination(for: GenerationResultViewModel.self) { vm in
                        GenerationResult(viewModel: vm)
                    }
                }
            }
            .tint(.appSecondaryText2)
            .fullScreenCover(isPresented: $router.shouldShowSettings, content: {
                SettingsViewWithToolbar()
            })
            
            // MARK: - Capsuled tabbar
            if !isKeyboardVisible {
                CapsuleTabBar(selectedTab: $router.selectedTab, tabs: tabs)
                    .transition(.move(edge: .bottom))
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.appSecondaryText2)
        
        .onChange(of: router.selectedTab) { newTab in
            if router.selectedTab != newTab {
                router.popToRoot()
            }
        }
        .onReceive(Publishers.keyboardHeight) { height in
            isKeyboardVisible = height > 0
        }
        .animation(.default, value: isKeyboardVisible)
    }
}



#Preview {
    MainViewWrapper()
}
