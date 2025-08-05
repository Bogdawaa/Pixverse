//
//  Coordinator.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 15.07.2025.
//

import SwiftUI

// MARK: - single coordinator
enum Route: Hashable {
    case home
    case video
    case library
    case settings
    case allItems(section: ContentSection)
    case template(item: AnyContentItem)
}

enum MediaType: Hashable {
    case image(Image)
    case video(URL)
    
    static func == (lhs: MediaType, rhs: MediaType) -> Bool {
        switch (lhs, rhs) {
        case (.image, .image): return true
        case (.video, .video): return true
        default: return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .image: hasher.combine(0)
        case .video: hasher.combine(1)
        }
    }
}

final class Router: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedTab: Int = 0
    @Published var selectedVideoTab: TemplateTab = .templates
    @Published var shouldShowSettings = false
    @Published var shouldShowPaywall = false
    @Published var selectedImage: UIImage?
    
    private var savedPaths: [Int: NavigationPath] = [:]
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func switchTab(to tab: Int) {
        guard tab != selectedTab else { return }
        
        //  cохранить текущий стек навигации
        savedPaths[selectedTab] = path
        
        popToRoot()
        
        selectedTab = tab
        
        if let savedPath = savedPaths[tab] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.path = savedPath
            }
        }
    }
    
    func navigateToVideoTab() {
        switchTab(to: 1)
    }
    
    func showVideoDetail(item: any ContentItemProtocol) {
        path.append(AnyContentItem(item))
    }
    
    func showGenerationProgress(with image: UIImage) {
        selectedImage = image
        path.append(image)
    }
    
    func showGenerationProgress(with media: TextGenerationViewModel.MediaType) {
        switch media {
        case .photo(let image):
            path.append(image)
        case .video(let url):
            path.append(url)
        }
    }
}
