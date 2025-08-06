//
//  ContentSectionsView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import SwiftUI

struct ContentSectionsView: View {
    
    @EnvironmentObject private var appState: AppState
    @ObservedObject var viewModel: ContentSectionViewModel
    
    var showAll: Bool
    
    var body: some View {
        ZStack {
            
            Color.appBackground
                .edgesIgnoringSafeArea(.all)
            
            if !viewModel.sections.isEmpty {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 24) {
                        ForEach(viewModel.sections) { section in
                            MainContentSectionView(viewModel: viewModel, section: section, showAll: showAll)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            
            // if loading
            if viewModel.isLoading && viewModel.sections.isEmpty {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.appMainText)
            }
            
            // if empty
            if viewModel.sections.isEmpty && !viewModel.isLoading {
                EmptyView(retryAction: {
                    Task { await viewModel.fetchTemplates() }
                })
            }
            
            // if error
            if let error = viewModel.error {
                ErrorView(
                    error: error,
                    dismissAction: {
                        viewModel.error = nil
                    },
                    retryAction: {
                        Task { await viewModel.fetchTemplates() }
                    }
                )
                .zIndex(1)
                .transition(.opacity)
            }
        }
        .toolbarBackground(Color.appBackground, for: .navigationBar)
    }
}
