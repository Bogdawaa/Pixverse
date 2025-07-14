//
//  StyleSingleView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

struct ContentItemView: View {
    
    let item: TemplateItem
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(.onb2)
                .resizable()
                .scaledToFill()
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                .black.opacity(0),
                                .appBackground
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            
            Text(item.name)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .font(.system(size: 14))
                .padding(.horizontal)
                .padding()
        }
        .frame(width: 175, height: 225)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ContentItemView(
        item: TemplateItem(from: TemplateDTO(
            prompt: "",
            name: "Name",
            category: "Category",
            isActive: false,
            previewSmall: "",
            previewLarge: "",
            id: 1,
            templateId: 1
        ))
    )
}
