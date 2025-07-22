//
//  AllItemView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 15.07.2025.
//

import SwiftUI

struct AllItemsView: View {
    let section: ContentSection
    
    private var gridLayout: [GridItem] {
        [GridItem(.adaptive(minimum: 175, maximum: 200), spacing: 0)]
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                LazyVGrid(columns: gridLayout, spacing: 24) {
                    ForEach(section.items, id: \.id) { item in
                        ContentItemView(item: item)
                            .frame(width: 175)
                            .frame(height: 225)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(section.type.title)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
    }
}


#Preview {
    NavigationStack {
        AllItemsView(section: ContentSection(
            type: .videoTemplates,
            items: [
                TemplateItem(from: TemplateDTO(
                    prompt: "",
                    name: "Template 1",
                    category: "Trending",
                    isActive: false,
                    previewSmall: "",
                    previewLarge: "",
                    id: 1,
                    templateId: 1
                )),
                TemplateItem(from: TemplateDTO(
                    prompt: "",
                    name: "Template 2",
                    category: "Trending",
                    isActive: false,
                    previewSmall: "",
                    previewLarge: "",
                    id: 2,
                    templateId: 2
                )),
                TemplateItem(from: TemplateDTO(
                    prompt: "",
                    name: "Template 4",
                    category: "Trending",
                    isActive: false,
                    previewSmall: "",
                    previewLarge: "",
                    id: 3,
                    templateId: 3
                )),
                TemplateItem(from: TemplateDTO(
                    prompt: "",
                    name: "Template 4",
                    category: "Trending",
                    isActive: false,
                    previewSmall: "",
                    previewLarge: "",
                    id: 4,
                    templateId: 4
                ))
            ],
            showAllButton: false
        ))
    }
}
