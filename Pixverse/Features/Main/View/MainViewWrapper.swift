//
//  MainView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 09.07.2025.
//

import SwiftUI

struct MainViewWrapper: View {
    
    @State private var selectedTab = 0
    @StateObject private var contentVM = ContentSectionViewModel()
    
    let tabs = [
        TabItem(title: "Home", iconName: "appHome", type: .home),
        TabItem(title: "Video", iconName: "appVideo", type: .video),
        TabItem(title: "Photo", iconName: "appPhoto", type: .photo),
        TabItem(title: "Library", iconName: "appGallery", type: .library)
       ]
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    tabView(for: tabs[index].type)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // TabBar
            CapsuleTabBar(selectedTab: $selectedTab, tabs: tabs)
        }
        .background(.appBackground)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    @ViewBuilder
    private func tabView(for type: TabType) -> some View {
        switch type {
        case .home:
            ContentSectionsView(viewModel: contentVM)
        case .video:
            Text("Video")
        case .photo:
            Text("Photo")
        case .library:
            Text("Library")
        }
    }
}



#Preview {
    MainViewWrapper()
}
