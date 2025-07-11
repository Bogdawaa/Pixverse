//
//  StyleSingleView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

struct ContentItemView: View {
    
    let item: ContentItem
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(item.imageName)
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
            
            Text(item.title)
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
    ContentItemView(item: ContentItem(title: "Some massive text for test", imageName: "funtasticMermaid"))
}
