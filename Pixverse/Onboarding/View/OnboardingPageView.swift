//
//  OnboardingPageView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 08.07.2025.
//

import SwiftUI

struct SingleOnboardingView: View {
    let page: OnboardingItem
    let isLastPage: Bool
    @Binding var currentPage: Int
    let pageCount: Int
    let showPageIndicators: Bool
    let action: () -> Void
    
    var body: some View {

            VStack {
                // Image + Gradient
                Image(page.imageName)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .overlay(
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
                    )
                
                // Content and Bottom Navigation
                VStack(spacing: 0) {
                        HStack(spacing: 8) {
                            ForEach(0..<pageCount, id: \.self) { index in
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(currentPage == index ? .appGreen : .white.opacity(30))
                                    .opacity(currentPage == index ? 1 : 0.5)
                            }
                        }
                        .padding()
                        .background(Color.appCard.clipShape(Capsule()))
                        .padding(.top, 50)
                        .padding(.bottom, 30)
                        .opacity(showPageIndicators ? 1 : 0)
                    
                    // Text content
                    VStack(alignment: .leading, spacing: 12) {
                        Text(page.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(page.description)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 30)
                    }
                    .padding(.horizontal)
                    
                    // Next button
                    Button(action: {
                        if currentPage < pageCount - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            action()
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .padding(.horizontal, 20)
                    }
                    .padding(.horizontal)
                    .buttonStyle(.primaryButton)
                }
            }
            .background(Color.appBackground)
        }
}


#Preview {
    SingleOnboardingView(
        page: OnboardingItem(
            imageName: "onb4",
            title: "Always be aware!",
            description: "Allow notification to stay informed and never miss the latest updates."
        ),
        isLastPage: true,
        currentPage: .constant(5),
        pageCount: 5,
        showPageIndicators: true,
        action: {
            //
        }
    )
}
