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
}

final class HomeCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigateToVideoTab(with url: URL, appCoordinator: AppCoordinator) {
        appCoordinator.selectedTab = 1
        appCoordinator.selectedVideoTab = .templates
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
    
    func showGenerationProgress(with media: TextGenerationViewModel.MediaType) {
        switch media {
        case .photo(let image):
            path.append(image)
        case .video(let url):
            path.append(url)
        }
    }
}
