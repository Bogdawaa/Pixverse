//
//  Coordinator.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 15.07.2025.
//

import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedVideoTab: TemplateTab = .templates
    @Published var shouldShowSettings = false
    
    func navigateToVideoTemplate() {
        withAnimation {
            selectedTab = 1
            selectedVideoTab = .templates
        }
    }
}

final class HomeCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigateToVideoTab(with url: URL, appCoordinator: AppCoordinator) {
        appCoordinator.selectedTab = 1
        appCoordinator.selectedVideoTab = .templates
    }
    
    func showTemplateTab(for section: ContentSection) {
        path.append(section)
    }
    
    func backToRoot() {
        path.removeLast(path.count)
    }
    
    func back() {
        path.removeLast()
    }
}

// VideoCoordinator.swift
final class VideoCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedImage: UIImage?
    
    func showAllItems(for section: ContentSection) {
        path.append(section)
    }
    
    func showVideoDetail(item: any ContentItemProtocol) {
        path.append(AnyContentItem(item))
    }
    
    func showGenerationProgress(with image: UIImage) {
        selectedImage = image
        path.append(image)
    }
    
    func backToRoot() {
        path.removeLast(path.count)
    }
    
    func back() {
        path.removeLast()
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
