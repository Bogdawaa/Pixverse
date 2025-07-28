//
//  Tabbar.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 10.07.2025.
//

import SwiftUI

struct CapsuleTabBar: View {
    
    @EnvironmentObject private var router: Router

    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    var body: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    router.switchTab(to: index)
                    
                }) {
                    VStack(spacing: 4) {
                        Image(tabs[index].iconName)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(selectedTab == index ? .appGreen : .gray)
                        Text(tabs[index].title)
                            .font(.system(size: 10))
                            .foregroundColor(selectedTab == index ? .white : .gray)
                    }
                    .padding(6)
                    .frame(maxWidth: .infinity)

                    .background(
                        Group {
                            if selectedTab == index {
                                Capsule()
                                    .fill(Color.appCard2)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                    )
                    .padding(8)
                }
            }
        }
        .background(
            Capsule()
                .fill(Color.appCard)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    CapsuleTabBar(selectedTab: .constant(0), tabs: [])
}
