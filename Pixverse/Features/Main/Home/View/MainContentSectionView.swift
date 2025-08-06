//
//  MainListView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

struct MainContentSectionView: View {
    
    @EnvironmentObject private var router: Router
    
    @ObservedObject var viewModel: ContentSectionViewModel
    
    let section: ContentSection
    
    var showAll: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(section.type.title)
                    .font(.headline)
                    .foregroundStyle(.appMainText)
                
                Spacer()
                
                if section.showAllButton {
                    Button(action: {
                        if showAll {
                            router.navigate(to: .allItems(section: section))
                        } else {
                            if section.type == ContentSectionType.videoTemplates {
                                router.navigate(to: .video)
                                router.selectedVideoTab = .templates
                            } else {
                                router.selectedVideoTab = .styles
                                router.navigate(to: .video)
                            }
                        }
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

