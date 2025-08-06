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
                ZStack {
                    Image("onboardingImage")
//                        .resizable()
                    Image(page.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 53)
                        .padding(.top, 53)
                        .clipped()
                }
                .overlay( alignment: .bottom) {
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                .white.opacity(0),
                                .appBackground
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 130)
                }
                
                // Content and Bottom Navigation
                VStack(spacing: 0) {
                    // Text content
                    VStack(alignment: .leading, spacing: 12) {
                        Text(page.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.appMainText)
                        
                        Text(page.description)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.appPrimaryText.opacity(0.94))
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
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .padding(.horizontal, 20)
                    }
                    .padding(.horizontal)
                    .buttonStyle(.primaryButton)
                }
            }
            .background(Color.appBackground)
            .padding(.bottom, 16)
        }
}


#Preview {
    SingleOnboardingView(
        page: OnboardingItem(
            imageName: "iphone with notifications",
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
