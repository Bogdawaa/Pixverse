//
//  MainListView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

struct MainContentSectionView: View {
    
    @EnvironmentObject private var homeCoordinator: HomeCoordinator
    @EnvironmentObject private var appCoordinator: AppCoordinator
    @EnvironmentObject private var videoCoordinator: VideoCoordinator

    
    @ObservedObject var viewModel: ContentSectionViewModel
    let section: ContentSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(section.type.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                if section.showAllButton {
                    Button(action: {
                        appCoordinator.selectedTab = 1
//                        appCoordinator.selectedVideoTab = .templates
                        videoCoordinator.showAllItems(for: section)
                    }) {
                        HStack(spacing: 4) {
                            Text("All")
                            Image(systemName: "chevron.forward")
                                .imageScale(.small)
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(section.items, id: \.id) { item in
                        ContentItemView(item: item)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 8)
    }
}

