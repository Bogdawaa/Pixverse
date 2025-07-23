//
//  LibraryView.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 21.07.2025.
//

import SwiftUI

struct LibraryView: View {
    
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @StateObject private var viewModel: LibraryViewModel = LibraryViewModel()
    
    private var gridLayout: [GridItem] {
        [GridItem(.adaptive(minimum: 175, maximum: 200), spacing: 0)]
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack {
                if viewModel.generations.isEmpty {
                    emptyContentView
                } else {
                    generationsView
                }
            }
            .padding()
        }
    }
    
    private var emptyContentView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.appCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .frame(width: 175, height: 225)
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(.appCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .frame(width: 175, height: 225)
            }
            
            Text("Start your first creation!")
                .font(.system(size: 28))
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text("Choose what would you'd like to create first - a photo or a video. Your library will soon be full of inspiration")
                .foregroundStyle(.appText)
                .multilineTextAlignment(.center)
            
            Button {
                appCoordinator.navigateToVideoTemplate()
            } label: {
                Text("Video")
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 50)
            }
            .buttonStyle(.primaryButton)
            .padding(.top, 24)
            
            Spacer()
        }
    }
    
    private var generationsView: some View {
        ZStack {
            Color.appBackground
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                LazyVGrid(columns: gridLayout, spacing: 24) {
                    ForEach(viewModel.generations, id: \.id) { item in
                        GenerationItemView(item: item)
                            .frame(width: 175)
                            .frame(height: 225)
                            .onTapGesture {
                                viewModel.selectedGeneration = item
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
        }
        .onAppear {
            viewModel.loadGenerations()
        }
        .navigationDestination(
            isPresented: Binding(
                get: { viewModel.selectedGeneration != nil },
                set: { if !$0 { viewModel.selectedGeneration = nil } }
            )
        ) {
            if let generation = viewModel.selectedGeneration, let _ = generation.videoUrl {
                let vm = GenerationResultViewModel(item: generation)
                GenerationResult(viewModel: vm)
            }
        }
    }
}

#Preview {
    LibraryView()
}
